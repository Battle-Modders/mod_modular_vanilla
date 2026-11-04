// Tests for ::ModularVanilla.Simulation and the simulated skill.getExpectedDamage

// Shared state for the test handlers (lambdas in yielding tests can't read the test's locals)
::MVSimTest <- {};

local function getSetup()
{
	local attacker = ::BBTest.getPlayerBros()[0];
	local ally = ::BBTest.getPlayerBros()[1];
	local target = ::BBTest.getEnemies()[0];
	local skill = attacker.getSkills().getAttackOfOpportunity();
	::BBTest.assert(skill != null, "attacker has no attack skill");
	return { Attacker = attacker, Ally = ally, Target = target, Skill = skill };
}

local function getBodyArmor( _actor )
{
	local armor = _actor.getItems().getItemAtSlot(::Const.ItemSlot.Body);
	if (armor == null)
	{
		armor = ::new("scripts/items/armor/padded_surcoat");
		_actor.getItems().equip(armor);
	}
	return armor;
}

local function invalidateCache()
{
	::ModularVanilla.Simulation.StateVersion++;
}

local function addTestSkill( _actor, _id )
{
	local s = ::new("scripts/skills/special/oath_of_honor_warning");
	s.m.ID = _id;
	s.m.Name = _id;
	s.m.Type = ::Const.SkillType.StatusEffect;
	s.m.IsHidden = true;
	s.m.Count <- 0;
	_actor.getSkills().add(s);
	return s;
}

local function removeTestSkill( _actor, _id )
{
	_actor.getSkills().removeByID(_id);
	_actor.getSkills().collectGarbage();
}

::BBTest.add("Simulation: bone plating is not consumed", function() {
	// Reforged replaces the vanilla bone plating logic with rf_bone_platings_effect
	if (::Hooks.hasMod("mod_reforged"))
		return;

	local c = getSetup();
	local armor = getBodyArmor(c.Target);
	local oldUpgrade = armor.getUpgrade();
	local upgrade = ::new("scripts/items/armor_upgrades/bone_platings_upgrade");
	armor.setUpgrade(upgrade);
	upgrade.m.IsUsed = false;

	for (local i = 0; i < 10; i++)
	{
		invalidateCache();
		c.Skill.getExpectedDamage(c.Target);
	}
	::BBTest.assertEq(false, upgrade.m.IsUsed, "bone plating was consumed by getExpectedDamage");

	local body = ::ModularVanilla.Simulation.run(@() c.Skill.MV_simulateHit(c.Target, ::Const.BodyPart.Body), [c.Attacker, c.Target]);
	local head = ::ModularVanilla.Simulation.run(@() c.Skill.MV_simulateHit(c.Target, ::Const.BodyPart.Head), [c.Attacker, c.Target]);
	::BBTest.assertEq(0, body.HitpointDamage + body.ArmorDamage, "bone plating should absorb the body hit");
	::BBTest.assert(head.HitpointDamage + head.ArmorDamage > 0, "head hit should deal damage");
	::BBTest.assertEq(false, upgrade.m.IsUsed, "bone plating was consumed by MV_simulateHit");

	// The real event still changes the state
	upgrade.onBeforeDamageReceived(c.Attacker, c.Skill, { BodyPart = ::Const.BodyPart.Body, DamageDirect = 0.0 }, ::Const.CharacterProperties.getClone());
	::BBTest.assertEq(true, upgrade.m.IsUsed, "real onBeforeDamageReceived must still consume the plating");

	armor.setUpgrade(oldUpgrade);
}, { Phase = ::BBTest.Phase.Tactical });

::BBTest.add("Simulation: item modifiers are included", function() {
	local c = getSetup();
	local armor = getBodyArmor(c.Target);
	local oldUpgrade = armor.getUpgrade();
	armor.setUpgrade(null);
	invalidateCache();
	local without = ::ModularVanilla.Simulation.run(@() c.Skill.MV_simulateHit(c.Target, ::Const.BodyPart.Body), [c.Attacker, c.Target]);

	armor.setUpgrade(::new("scripts/items/armor_upgrades/horn_plate_upgrade"));
	local with = ::ModularVanilla.Simulation.run(@() c.Skill.MV_simulateHit(c.Target, ::Const.BodyPart.Body), [c.Attacker, c.Target]);
	armor.setUpgrade(oldUpgrade);

	if (c.Skill.isRanged())
		return;
	::BBTest.assert(with.HitpointDamage + with.ArmorDamage < without.HitpointDamage + without.ArmorDamage,
		format("horn plate should reduce melee damage (%s vs %s)", (with.HitpointDamage + with.ArmorDamage) + "", (without.HitpointDamage + without.ArmorDamage) + ""));
}, { Phase = ::BBTest.Phase.Tactical });

::BBTest.add("Simulation: handler state changes and effects are discarded", function() {
	local c = getSetup();
	::MVSimTest.Ally <- c.Ally;
	::MVSimTest.ScheduledFired <- false;
	::MVSimTest.Calls <- 0;

	local allySkill = c.Ally.getSkills().m.Skills[0];
	local allyHitpoints = c.Ally.getHitpoints();
	local allySkillGarbage = allySkill.isGarbage();
	::MVSimTest.AllySkillID <- allySkill.getID();

	local a = addTestSkill(c.Attacker, "test.sim_attacker");
	a.onBeforeTargetHit <- function( _skill, _targetEntity, _hitInfo )
	{
		::MVSimTest.Calls++;
		this.m.Count++;
		this.m.IsHidden = false;
		_hitInfo.DamageDirect = 1.0;
		this.spawnIcon("perk_16", this.getContainer().getActor().getTile());
		::Sound.play("sounds/combat/pound_01.wav", 1.0, this.getContainer().getActor().getPos());
		::Tactical.EventLog.log("SIMULATION LOG LINE");
		::Time.scheduleEvent(::TimeUnit.Real, 1, function( _x ) { ::MVSimTest.ScheduledFired = true; }, null);
		// Third actor
		::MVSimTest.Ally.m.Hitpoints = 1;
		// Reached through the normal accessors (references held outside of any `m` are not in the scope)
		::MVSimTest.Ally.getSkills().getSkillByID(::MVSimTest.AllySkillID).removeSelf();
		// Structural
		this.getContainer().add(::new("scripts/skills/effects/stunned_effect"));
	};

	local t = addTestSkill(c.Target, "test.sim_target");
	t.onBeforeDamageReceived <- function( _attacker, _skill, _hitInfo, _properties )
	{
		this.m.Count++;
		_properties.DamageReceivedTotalMult = 0.0;
		this.removeSelf();
	};

	local stacks = ::ModularVanilla.Simulation.__getInfoStacks();
	local stackLengths = stacks.map(@(_s) _s.len());
	local attackerM = a.m;
	local containerWasUpdating = c.Attacker.getSkills().m.IsUpdating;

	invalidateCache();
	local result = c.Skill.getExpectedDamage(c.Target);

	::BBTest.assert(::MVSimTest.Calls > 0, "onBeforeTargetHit was not called");
	::BBTest.assertEq(0, result.HitpointDamage, "target handler should zero the damage");
	::BBTest.assertEq(0, result.ArmorDamage, "target handler should zero the armor damage");
	::BBTest.assertEq(0, a.m.Count, "attacker skill m change leaked");
	::BBTest.assertEq(true, a.m.IsHidden, "attacker skill m change leaked");
	::BBTest.assertEq(0, t.m.Count, "target skill m change leaked");
	::BBTest.assert(!t.isGarbage(), "target skill removeSelf leaked");
	::BBTest.assert(attackerM == a.m, "m identity not restored");
	::BBTest.assertEq(allyHitpoints, c.Ally.getHitpoints(), "third actor m change leaked");
	::BBTest.assertEq(allySkillGarbage, allySkill.isGarbage(), "third actor skill change leaked");
	::BBTest.assert(!c.Attacker.getSkills().hasSkill("effects.stunned"), "skill added during simulation leaked");
	::BBTest.assertEq(containerWasUpdating, c.Attacker.getSkills().m.IsUpdating, "IsUpdating changed");
	::BBTest.assert(!::ModularVanilla.Simulation.isActive(), "simulation still active");
	foreach (i, s in stacks)
		::BBTest.assertEq(stackLengths[i], s.len(), "info stack length changed");

	yield ::BBTest.waitFrames(5);
	::BBTest.assert(!::MVSimTest.ScheduledFired, "scheduled event from the simulation fired");
	::BBTest.assert(!c.Attacker.getSkills().hasSkill("effects.stunned"), "skill added during simulation appeared later");

	removeTestSkill(c.Attacker, "test.sim_attacker");
	removeTestSkill(c.Target, "test.sim_target");
}, { Phase = ::BBTest.Phase.Tactical });

::BBTest.add("Simulation: IsUpdating, errors and nesting", function() {
	local c = getSetup();

	// IsUpdating true before stays true
	local container = c.Attacker.getSkills();
	container.m.IsUpdating = true;
	invalidateCache();
	c.Skill.getExpectedDamage(c.Target);
	::BBTest.assertEq(true, container.m.IsUpdating, "IsUpdating true was not kept");
	container.m.IsUpdating = false;

	// An error inside a simulation rolls back and propagates.
	// (Not thrown from a skill event: MSU calls those via acall, which logs the error even when it is caught.)
	local a = addTestSkill(c.Attacker, "test.sim_throw");
	local realM = a.m;
	::BBTest.assertThrows(function() {
		::ModularVanilla.Simulation.run(function() {
			// Reached through the container like the skill events do (references held outside of any `m` are not in the scope)
			c.Attacker.getSkills().getSkillByID("test.sim_throw").m.Count++;
			throw "test error";
		}, [c.Attacker, c.Target]);
	});
	::BBTest.assert(!::ModularVanilla.Simulation.isActive(), "simulation still active after error");
	::BBTest.assert(realM == a.m, "m not restored after error");
	::BBTest.assertEq(0, a.m.Count, "m change leaked after error");
	removeTestSkill(c.Attacker, "test.sim_throw");

	// Nested simulation inside a handler
	local n = addTestSkill(c.Attacker, "test.sim_nested");
	::MVSimTest.NestedResult <- null;
	::MVSimTest.Target <- c.Target;
	n.onBeforeTargetHit <- function( _skill, _targetEntity, _hitInfo )
	{
		this.m.Count++;
		if (this.m.Count == 1)
			::MVSimTest.NestedResult = _skill.getExpectedDamage(::MVSimTest.Target);
	};
	invalidateCache();
	local outer = c.Skill.getExpectedDamage(c.Target);
	::BBTest.assert(::MVSimTest.NestedResult != null, "nested getExpectedDamage did not run");
	::BBTest.assertEq(0, n.m.Count, "m change leaked after nesting");
	::BBTest.assert(!::ModularVanilla.Simulation.isActive(), "simulation still active after nesting");
	removeTestSkill(c.Attacker, "test.sim_nested");
}, { Phase = ::BBTest.Phase.Tactical });

::BBTest.add("Simulation: debug log and timing", function() {
	local c = getSetup();
	local armor = getBodyArmor(c.Target);
	local oldUpgrade = armor.getUpgrade();
	armor.setUpgrade(::new("scripts/items/armor_upgrades/bone_platings_upgrade"));

	::ModularVanilla.Simulation.IsDebug = true;
	invalidateCache();
	c.Skill.getExpectedDamage(c.Target);
	::ModularVanilla.Simulation.IsDebug = false;

	::BBTest.bench("getExpectedDamage uncached", function() {
		::ModularVanilla.Simulation.StateVersion++;
		c.Skill.getExpectedDamage(c.Target);
	}, 100);
	::BBTest.bench("getExpectedDamage cached", function() {
		c.Skill.getExpectedDamage(c.Target);
	}, 100);
	armor.setUpgrade(oldUpgrade);
}, { Phase = ::BBTest.Phase.Tactical });

::BBTest.add("Simulation: AI battle runs without errors", function() {
	// Measure the time spent in simulations and the number of getExpectedDamage calls
	local sim = ::ModularVanilla.Simulation;
	::MVSimTest.Stats <- { Runs = 0, Calls = 0, Time = 0.0, Run = sim.run, Cache = sim.getExpectedDamageCache,
		Pairs = 0, Repeats = 0, RepeatsSameVersion = 0, RepeatsSameFrame = 0, Seen = {}, Epochs = {},
		ActorVersions = {}, MovementVersion = 0, OtherVersion = 0, UpdatesActive = 0, UpdatesOther = 0, UpdateCallers = {},
		RepeatsPerActorVersion = 0, RepeatsSameState = 0 };

	// Snapshot of the state of an actor which can influence getExpectedDamage
	::MVSimTest.actorState <- function( _actor )
	{
		local ret = [];
		foreach (key, value in _actor.getCurrentProperties())
		{
			if (typeof value == "array")
			{
				foreach (v in value)
					ret.push(v);
			}
			else if (typeof value != "function")
			{
				ret.push(value);
			}
		}
		ret.push(_actor.getHitpoints());
		ret.push(_actor.getFatigue());
		ret.push(_actor.getActionPoints());
		ret.push(_actor.getMoraleState());
		local tile = _actor.getTile();
		ret.push(tile.SquareCoords.X);
		ret.push(tile.SquareCoords.Y);
		return ret;
	};
	::MVSimTest.sameState <- function( _a, _b )
	{
		if (_a.len() != _b.len())
			return false;
		foreach (i, v in _a)
		{
			if (v != _b[i])
				return false;
		}
		return true;
	};
	::MVSimTest.actorVersion <- function( _actor )
	{
		local id = _actor.getID();
		return id in ::MVSimTest.Stats.ActorVersions ? ::MVSimTest.Stats.ActorVersions[id] : 0;
	};

	// Count the sources of StateVersion bumps: serve StateVersion through a delegate and look at the caller
	::MVSimTest.Version <- sim.StateVersion;
	::MVSimTest.Bumps <- {};
	delete sim.StateVersion;
	sim.setdelegate({
		function _get( _key )
		{
			if (_key == "StateVersion")
				return ::MVSimTest.Version;
			throw null;
		}
		function _set( _key, _value )
		{
			if (_key != "StateVersion")
				throw null;
			::MVSimTest.Version = _value;
			local info = ::getstackinfos(2);
			local source = info == null ? "unknown" : info.func + " (" + info.src + ":" + info.line + ")";
			if (!(source in ::MVSimTest.Bumps))
				::MVSimTest.Bumps[source] <- 0;
			::MVSimTest.Bumps[source]++;

			local stats = ::MVSimTest.Stats;
			if (info != null && info.func == "update" && "this" in info.locals)
			{
				local actor = info.locals["this"].getActor();
				local id = actor.getID();
				if (!(id in stats.ActorVersions))
					stats.ActorVersions[id] <- 0;
				stats.ActorVersions[id]++;

				local active = ::Tactical.TurnSequenceBar != null ? ::Tactical.TurnSequenceBar.getActiveEntity() : null;
				if (active != null && active.getID() == id)
					stats.UpdatesActive++;
				else
					stats.UpdatesOther++;

				local caller = ::getstackinfos(3);
				local callerKey = caller == null ? "unknown" : caller.func + " (" + caller.src + ":" + caller.line + ")";
				if (!(callerKey in stats.UpdateCallers))
					stats.UpdateCallers[callerKey] <- 0;
				stats.UpdateCallers[callerKey]++;
			}
			else if (info != null && info.func == "onMovementFinish")
			{
				stats.MovementVersion++;
			}
			else if (info != null && info.func == "onDamageReceived" && "this" in info.locals)
			{
				local id = info.locals["this"].getID();
				if (!(id in stats.ActorVersions))
					stats.ActorVersions[id] <- 0;
				stats.ActorVersions[id]++;
			}
			else
			{
				stats.OtherVersion++;
			}
		}
	});
	sim.run = function( _function, _actors = null, _shadowed = null )
	{
		local stats = ::MVSimTest.Stats;
		stats.Runs++;
		// Repeats of the same (skill, target) pair while the same actor is deciding (round + active entity)
		if (_actors != null && _actors.len() == 2 && _shadowed != null && _shadowed.len() == 1 && ::Tactical.TurnSequenceBar != null)
		{
			local active = ::Tactical.TurnSequenceBar.getActiveEntity();
			local epoch = ::Time.getRound() + ":" + (active == null ? "none" : active.getID());
			local key = epoch + "|" + _shadowed[0].getID() + "@" + _actors[0].getID() + ">" + _actors[1].getID();
			local version = ::ModularVanilla.Simulation.StateVersion;
			local frame = ::Time.getFrame();
			local actorVersions = [::MVSimTest.actorVersion(_actors[0]), ::MVSimTest.actorVersion(_actors[1]), stats.MovementVersion, stats.OtherVersion];
			local state = [::MVSimTest.actorState(_actors[0]), ::MVSimTest.actorState(_actors[1]), stats.MovementVersion];
			stats.Pairs++;
			if (key in stats.Seen)
			{
				local last = stats.Seen[key];
				stats.Repeats++;
				if (last.Version == version)
					stats.RepeatsSameVersion++;
				if (last.Frame == frame)
					stats.RepeatsSameFrame++;
				if (::MVSimTest.sameState(last.ActorVersions, actorVersions))
					stats.RepeatsPerActorVersion++;
				if (last.State[2] == state[2] && ::MVSimTest.sameState(last.State[0], state[0]) && ::MVSimTest.sameState(last.State[1], state[1]))
					stats.RepeatsSameState++;
				last.Version = version;
				last.Frame = frame;
				last.ActorVersions = actorVersions;
				last.State = state;
			}
			else
			{
				stats.Seen[key] <- { Version = version, Frame = frame, ActorVersions = actorVersions, State = state };
				if (!(epoch in stats.Epochs))
					stats.Epochs[epoch] <- true;
			}
		}
		local t = ::Time.getExactTime();
		local ret = stats.Run.call(this, _function, _actors, _shadowed);
		stats.Time += ::Time.getExactTime() - t;
		return ret;
	};
	sim.getExpectedDamageCache = function()
	{
		::MVSimTest.Stats.Calls++;
		return ::MVSimTest.Stats.Cache.call(this);
	};

	local start = ::Time.getRealTimeF();
	local startRound = ::Time.getRound();
	yield ::BBTest.waitUntil(@(_c) ::Time.getRound() >= _c.Round + 3 || !::BBTest.getUnits("enemies").len() || !::BBTest.getUnits("allies").len(), 180000, "three AI rounds", { Round = startRound });
	local stats = ::MVSimTest.Stats;
	::ModularVanilla.Simulation.run = stats.Run;
	::ModularVanilla.Simulation.getExpectedDamageCache = stats.Cache;
	::logWarning("MV Simulation AI battle: " + (::Time.getRound() - startRound) + " rounds in " + (::Time.getRealTimeF() - start) + " s, StateVersion=" + ::ModularVanilla.Simulation.StateVersion
		+ ", getExpectedDamage calls=" + stats.Calls + ", simulations=" + stats.Runs + ", time in simulations=" + stats.Time + " s");
	::logWarning("MV Simulation pairs: calls=" + stats.Pairs + " unique per decision=" + stats.Seen.len() + " decisions=" + stats.Epochs.len()
		+ " repeats in same decision=" + stats.Repeats + " (same StateVersion=" + stats.RepeatsSameVersion + ", same frame=" + stats.RepeatsSameFrame
		+ ", same per-actor versions=" + stats.RepeatsPerActorVersion + ", same attacker/target state=" + stats.RepeatsSameState + ")");
	::logWarning("MV Simulation updates: of active entity=" + stats.UpdatesActive + " of other actors=" + stats.UpdatesOther);
	local callers = [];
	foreach (source, count in stats.UpdateCallers)
		callers.push({ Source = source, Count = count });
	callers.sort(@(_a, _b) _b.Count <=> _a.Count);
	foreach (i, c in callers)
	{
		if (i < 12)
			::logWarning("MV Simulation update caller: " + c.Count + " x " + c.Source);
	}

	sim.setdelegate(null);
	sim.StateVersion <- ::MVSimTest.Version;
	local bumps = [];
	foreach (source, count in ::MVSimTest.Bumps)
		bumps.push({ Source = source, Count = count });
	bumps.sort(@(_a, _b) _b.Count <=> _a.Count);
	foreach (b in bumps)
		::logWarning("MV Simulation bump: " + b.Count + " x " + b.Source);
	::BBTest.assert(!::ModularVanilla.Simulation.isActive(), "simulation still active");

	// Cost breakdown on a full map
	local units = ::BBTest.getUnits("allies");
	local enemies = ::BBTest.getUnits("enemies");
	if (units.len() != 0 && enemies.len() != 0)
	{
		::MVSimTest.A <- units[0];
		::MVSimTest.T <- enemies[0];
		::MVSimTest.S <- units[0].getSkills().getAttackOfOpportunity();
		::logWarning("MV Simulation roots=" + ::ModularVanilla.Simulation.__collectRoots([::MVSimTest.A, ::MVSimTest.T]).len());
		::BBTest.bench("full map: collectRoots", @() ::ModularVanilla.Simulation.__collectRoots([::MVSimTest.A, ::MVSimTest.T]), 50);
		::BBTest.bench("full map: empty run", @() ::ModularVanilla.Simulation.run(@() null, [::MVSimTest.A, ::MVSimTest.T]), 50);
		::BBTest.bench("full map: empty run without shadowing", @() ::ModularVanilla.Simulation.run(@() null), 50);
		if (::MVSimTest.S != null)
		{
			// Force-shadowing variants of the simulation done by getExpectedDamage
			::MVSimTest.simulate <- function( _shadowed )
			{
				return ::ModularVanilla.Simulation.run(function() {
					local body = ::MVSimTest.S.MV_simulateHit(::MVSimTest.T, ::Const.BodyPart.Body);
					::ModularVanilla.Simulation.reset();
					local head = ::MVSimTest.S.MV_simulateHit(::MVSimTest.T, ::Const.BodyPart.Head);
					return [body, head];
				}, [::MVSimTest.A, ::MVSimTest.T], _shadowed);
			};
			local a = ::MVSimTest.A, t = ::MVSimTest.T, sk = ::MVSimTest.S;
			::MVSimTest.Variants <- {
				All = [sk, a, a.getSkills(), a.getItems(), t, t.getSkills(), t.getItems()],
				Middle = [sk, t, a.getSkills(), t.getSkills()],
				Minimal = [sk, t]
			};
			local results = {};
			foreach (name in ["All", "Middle", "Minimal", "All", "Middle", "Minimal"])
			{
				::MVSimTest.Variant <- ::MVSimTest.Variants[name];
				results[name] <- ::MVSimTest.simulate(::MVSimTest.Variant);
				::BBTest.bench("full map: force-shadow " + name, @() ::MVSimTest.simulate(::MVSimTest.Variant), 100);
			}
			foreach (name, r in results)
				::logWarning("MV Simulation variant " + name + ": body=" + r[0].HitpointDamage + "/" + r[0].ArmorDamage + " head=" + r[1].HitpointDamage + "/" + r[1].ArmorDamage);

			::BBTest.bench("full map: getExpectedDamage uncached", function() {
				::ModularVanilla.Simulation.StateVersion++;
				::MVSimTest.S.getExpectedDamage(::MVSimTest.T);
			}, 50);
		}
	}
}, {
	Phase = ::BBTest.Phase.Tactical,
	FreshBattle = true,
	Battle = {
		Player = false,
		Allies = { Units = [{ Troop = "Footman", Num = 6 }, { Troop = "Billman", Num = 3 }, { Troop = "Arbalester", Num = 3 }] },
		Enemies = { Spawnlists = [{ Party = "BanditRaiders", Resources = 300 }] }
	}
});
