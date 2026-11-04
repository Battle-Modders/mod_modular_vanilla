// MV: Added
// Runs code speculatively (e.g. skill.getExpectedDamage) without changing the game state.
// While a simulation is running, the `m` table of every object in scope is replaced with a "trap".
// The scope starts with all actors on the map and the global roots (e.g. world flags) and grows lazily:
// every object (e.g. a skill container, a skill, an item) reached through the `m` of an object in scope
// is added to the scope the first time it is reached.
// - Reading a value through the trap returns the real value. Arrays and plain tables are cloned on the first
//   read (and the clone is returned on later reads) so that changing them in place doesn't change the real ones.
// - The first write through the trap clones the object's `m` (every level of its delegate chain) into a "shadow",
//   which is then put in place of the trap and receives all further reads and writes.
// After the simulation the real `m` tables are put back, so all changes made during the simulation are discarded.
// Global effects (sounds, sprite effects, spawned entities, scheduled events, event log) are suppressed
// and structural changes (skill_container.update, equipping/unequipping items) are blocked while simulating.
// Notes:
// - Squirrel's `in` only checks the raw slots of a table and doesn't trigger metamethods, so `in` and `::MSU.isIn`
//   on the `m` of an object which hasn't been written to yet see an empty table. The objects passed as `_shadowed`
//   to `run` (e.g. attacker, target and the used skill) are shadowed right away to avoid this for them.
// - Changes to native state (e.g. sprites) and to objects outside the scope are not rolled back. Objects are
//   outside the scope if they are only reachable through native functions (other than actors) or through
//   values nested more than two levels deep in an `m`.
::ModularVanilla.Simulation <- {
	Depth = 0,
	// Set to true to log every change to an `m` table which was discarded at the end of a simulation
	IsDebug = false,
	// Incremented whenever the state of the tactical battle changes. Used to invalidate cached results.
	StateVersion = 0,
	// Functions which return an object (with an `m` table) or null. The objects are added to the scope.
	GlobalRoots = [
		@() "Flags" in ::World ? ::World.Flags : null,
		@() "Statistics" in ::World && ::World.Statistics != null ? ::World.Statistics.getFlags() : null
	],
	// Returned by suppressed functions. Every member is a function which returns Dummy again,
	// so that code like `::Tactical.spawnEntity(...).setFaction(...)` doesn't crash.
	Dummy = null,
	// One element per running (nested) simulation
	__Transactions = [],
	__ExpectedDamageCache = {
		Frame = -1,
		StateVersion = -1,
		Entries = {}
	},

	function isActive()
	{
		return this.Depth != 0;
	}

	function addGlobalRoot( _function )
	{
		this.GlobalRoots.push(_function);
	}

	// Returns a table of skill -> { target -> result of getExpectedDamage } which is valid for the current
	// frame and battle state. It is reset when either of them changes.
	function getExpectedDamageCache()
	{
		local cache = this.__ExpectedDamageCache;
		local frame = ::Time.getFrame();
		if (cache.Frame != frame || cache.StateVersion != this.StateVersion)
		{
			cache.Frame = frame;
			cache.StateVersion = this.StateVersion;
			cache.Entries = {};
		}
		return cache.Entries;
	}

	// Runs _function (without arguments) inside a simulation and returns its return value.
	// _actors (array or null): the main actors involved e.g. attacker and target. They are always part of the scope.
	// _shadowed (array or null): objects which are shadowed right away. The _actors and their containers always are.
	function run( _function, _actors = null, _shadowed = null )
	{
		if (_actors == null)
			_actors = [];

		local shadowed = _shadowed == null ? [] : clone _shadowed;
		foreach (actor in _actors)
		{
			shadowed.push(actor);
			shadowed.push(actor.getSkills());
			shadowed.push(actor.getItems());
		}

		local stacks = this.__getInfoStacks();
		local transaction = {
			Entries = [],
			EntriesByObj = {},
			Registry = this.__getEntries(),
			Shadowed = shadowed,
			Stacks = stacks,
			StackLengths = stacks.map(@(_s) _s.len()),
			Resync = []
		};

		this.__Transactions.push(transaction);
		this.Depth++;
		foreach (obj in this.__collectRoots(_actors))
		{
			this.__trap(obj);
		}

		local ret;
		try
		{
			this.__shadowRequired(transaction);
			ret = _function();
		}
		catch (error)
		{
			this.__end(transaction);
			throw error;
		}

		this.__end(transaction);
		return ret;
	}

	// Discards all changes made so far in the innermost running simulation, which keeps running.
	// E.g. used by getExpectedDamage to simulate a body hit and a head hit with one installation of the traps.
	function reset()
	{
		local transaction = this.__Transactions.top();
		foreach (entry in transaction.Entries)
		{
			this.__finishEntry(entry, transaction);
			entry.Obj.rawset("m", entry.Trap);
		}
		this.__truncateStacks(transaction);
		this.__shadowRequired(transaction);
	}

	// Wraps the native function _table[_name] so that it does nothing while a simulation is running
	function suppressNative( _table, _name )
	{
		if (!(_name in _table))
			return;

		local original = _table[_name];
		_table[_name] <- function( ... )
		{
			if (::ModularVanilla.Simulation.isActive())
				return ::ModularVanilla.Simulation.Dummy;

			vargv.insert(0, this);
			return original.acall(vargv);
		};
	}

	function __getInfoStacks()
	{
		if (!("State" in ::Tactical) || ::Tactical.State == null)
			return [];

		return [::Tactical.State.m.__MV_CurrentHitInfos, ::Tactical.State.m.__MV_CurrentAttackInfos];
	}

	function __getEntries()
	{
		if (!("State" in ::Tactical) || ::Tactical.State == null)
			return {};

		return ::Tactical.State.m.__MV_SimulationEntries;
	}

	// All actors are roots because native functions (e.g. tile.getEntity()) return them directly
	function __collectRoots( _actors )
	{
		local ret = clone _actors;
		if ("Entities" in ::Tactical && ::Tactical.Entities != null)
		{
			foreach (faction in ::Tactical.Entities.getAllInstances())
			{
				ret.extend(faction);
			}
		}

		foreach (fn in this.GlobalRoots)
		{
			ret.push(fn());
		}

		return ret;
	}

	// Adds _obj to the scope of the innermost running simulation if it is an object with an `m`
	function __trap( _obj )
	{
		if (typeof _obj != "table" || !_obj.rawin("m"))
			return;

		local transaction = this.__Transactions.top();
		if (_obj in transaction.EntriesByObj)
			return;

		local entry;
		if (_obj in transaction.Registry)
		{
			entry = transaction.Registry[_obj];
		}
		else
		{
			entry = this.__createEntry(_obj);
			transaction.Registry[_obj] <- entry;
		}

		local current = _obj.m;
		entry.Stack.push([entry.Real, entry.Shadow, entry.Cache, current]);
		// If the object still has the trap of an outer simulation then the outer simulation
		// hasn't written to it and its base is still entry.Real. Otherwise the current `m` is the base.
		// (Values cached by the outer simulation are clones of the real values, so they are not needed as base.)
		if (current != entry.Trap)
			entry.Real = current;
		entry.Shadow = null;
		entry.Cache = {};
		_obj.rawset("m", entry.Trap);

		transaction.Entries.push(entry);
		transaction.EntriesByObj[_obj] <- entry;
	}

	// Adds the objects in _value (an object, a WeakTableRef, or arrays and plain tables containing them
	// up to _depth levels deep) to the scope of the innermost running simulation
	function __trapValue( _value, _depth = 2 )
	{
		switch (typeof _value)
		{
			case "table":
				if (_value.rawin("m"))
				{
					this.__trap(_value);
				}
				else if (_depth != 0)
				{
					foreach (v in _value)
						this.__trapValue(v, _depth - 1);
				}
				break;

			case "array":
				if (_depth != 0)
				{
					foreach (v in _value)
						this.__trapValue(v, _depth - 1);
				}
				break;

			case "instance":
				if (_value instanceof ::WeakTableRef && !_value.isNull())
					this.__trap(_value.get());
				break;
		}
	}

	function __createEntry( _obj )
	{
		local entry = {
			Obj = _obj,
			Real = _obj.m,
			Shadow = null,
			// Clones of arrays and plain tables read through the trap before the shadow exists
			Cache = {},
			Trap = {},
			Stack = []
		};

		local createShadow = this.__createShadow;
		local cloneValue = this.__cloneValue;
		local ensure = function()
		{
			if (entry.Shadow == null)
			{
				local shadow = createShadow(entry.Real);
				// Reads from the shadow aren't intercepted, so add the objects reachable through it to the scope now
				for (local level = entry.Real; level != null; level = level.getdelegate())
				{
					foreach (value in level)
						::ModularVanilla.Simulation.__trapValue(value);
				}
				foreach (key, value in entry.Cache)
				{
					shadow[key] = value;
				}
				entry.Cache = {};
				entry.Shadow = shadow;
				entry.Obj.rawset("m", shadow);
			}
			return entry.Shadow;
		};

		entry.Trap.setdelegate({
			function _get( _key )
			{
				if (entry.Shadow != null)
					return entry.Shadow[_key];

				if (_key in entry.Cache)
					return entry.Cache[_key];

				local value = entry.Real[_key];
				::ModularVanilla.Simulation.__trapValue(value);
				local c = cloneValue(value);
				if (c != value)
					entry.Cache[_key] <- c;
				return c;
			}

			function _set( _key, _value )
			{
				ensure()[_key] = _value;
			}

			function _newslot( _key, _value )
			{
				ensure()[_key] <- _value;
			}

			function _delslot( _key )
			{
				delete ensure()[_key];
			}
		});
		entry.Ensure <- ensure;

		return entry;
	}

	// Arrays are cloned. Plain data tables are cloned via getClone() if they have it (e.g. character properties).
	// Objects (tables with an `m`), WeakTableRef instances and all other values are returned as they are.
	function __cloneValue( _value )
	{
		switch (typeof _value)
		{
			case "array":
				return clone _value;

			case "table":
				if (!_value.rawin("m"))
					return "getClone" in _value ? _value.getClone() : clone _value;
		}
		return _value;
	}

	// Clones every level of the delegate chain of _m and relinks the clones.
	// Arrays and plain data tables are cloned one level deep so that in-place changes don't reach the real values.
	function __createShadow( _m )
	{
		local levels = [];
		local t = _m;
		while (t != null)
		{
			levels.push(t);
			t = t.getdelegate();
		}

		local shadows = [];
		foreach (level in levels)
		{
			local s = clone level;
			foreach (key, value in level)
			{
				switch (typeof value)
				{
					case "array":
					case "table":
						s[key] = ::ModularVanilla.Simulation.__cloneValue(value);
				}
			}
			shadows.push(s);
		}

		for (local i = 0; i < shadows.len() - 1; i++)
		{
			shadows[i].setdelegate(shadows[i + 1]);
		}

		return shadows[0];
	}

	function __shadowRequired( _transaction )
	{
		foreach (obj in _transaction.Shadowed)
		{
			this.__trap(obj);
			if (obj in _transaction.EntriesByObj)
				_transaction.EntriesByObj[obj].Ensure();
		}
	}

	// Discards the changes of _entry in the current transaction. Afterwards entry has no shadow and no cache.
	function __finishEntry( _entry, _transaction )
	{
		if (this.IsDebug)
			this.__logChanges(_entry);

		if (_entry.Shadow != null && ::MSU.isKindOf(_entry.Obj, "actor"))
		{
			foreach (key in ["Hitpoints", "MoraleState", "Fatigue", "ActionPoints"])
			{
				if (_entry.Shadow[key] != _entry.Real[key])
				{
					_transaction.Resync.push(_entry.Obj);
					break;
				}
			}
		}

		_entry.Shadow = null;
		_entry.Cache = {};
		if (_entry.Trap.len() != 0)
			_entry.Trap.clear();
	}

	function __truncateStacks( _transaction )
	{
		foreach (i, stack in _transaction.Stacks)
		{
			if (stack.len() > _transaction.StackLengths[i])
				stack.resize(_transaction.StackLengths[i]);
		}
	}

	function __end( _transaction )
	{
		this.Depth--;
		this.__Transactions.pop();

		for (local i = _transaction.Entries.len() - 1; i >= 0; i--)
		{
			local entry = _transaction.Entries[i];
			this.__finishEntry(entry, _transaction);

			local saved = entry.Stack.pop();
			entry.Real = saved[0];
			entry.Shadow = saved[1];
			entry.Cache = saved[2];
			entry.Obj.rawset("m", saved[3]);
		}

		this.__truncateStacks(_transaction);

		if (this.Depth == 0)
		{
			foreach (actor in _transaction.Resync)
			{
				if (actor.isAlive() && actor.isPlacedOnMap())
				{
					actor.onUpdateInjuryLayer();
					actor.setDirty(true);
				}
			}
		}
		else
		{
			this.__Transactions.top().Resync.extend(_transaction.Resync);
		}
	}

	function __logChanges( _entry )
	{
		local obj = _entry.Obj;
		local name = "ClassName" in obj ? obj.ClassName : "object";
		if (::MSU.isIn("getID", obj, true))
		{
			try { name += " " + obj.getID(); } catch (error) {}
		}

		foreach (key, value in _entry.Cache)
		{
			if (!this.__isEqual(value, _entry.Real[key]))
				::logWarning("MV Simulation: " + name + " changed m." + key + " in place");
		}

		local shadow = _entry.Shadow;
		local real = _entry.Real;
		while (shadow != null && real != null)
		{
			foreach (key, value in shadow)
			{
				if (!real.rawin(key))
				{
					::logWarning("MV Simulation: " + name + " added m." + key);
				}
				else if (!this.__isEqual(value, real.rawget(key)))
				{
					::logWarning("MV Simulation: " + name + " changed m." + key);
				}
			}
			shadow = shadow.getdelegate();
			real = real.getdelegate();
		}
	}

	// Compares two values of an `m` table. Arrays and tables are compared element-wise up to _depth levels
	// because the shadow contains clones of them.
	function __isEqual( _a, _b, _depth = 2 )
	{
		if (_a == _b)
			return true;

		if (_depth == 0 || typeof _a != typeof _b)
			return false;

		switch (typeof _a)
		{
			case "array":
				if (_a.len() != _b.len())
					return false;
				foreach (i, v in _a)
				{
					if (!this.__isEqual(v, _b[i], _depth - 1))
						return false;
				}
				return true;

			case "table":
				if (_a.len() != _b.len())
					return false;
				foreach (k, v in _a)
				{
					if (!_b.rawin(k) || !this.__isEqual(v, _b.rawget(k), _depth - 1))
						return false;
				}
				return true;
		}

		return false;
	}
};

{
	local dummy = {};
	local dummyFunction = function( ... ) { return dummy; };
	dummy.setdelegate({
		function _get( _key ) { return dummyFunction; }
		function _set( _key, _value ) {}
		function _newslot( _key, _value ) {}
	});
	::ModularVanilla.Simulation.Dummy = dummy;
}
