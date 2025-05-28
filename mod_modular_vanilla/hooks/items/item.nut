::ModularVanilla.MH.hook("scripts/items/item", function(q) {
	// MV: Added part of framework: base item for named items
	q.m.BaseItemScript <- null;
	q.m.IsUsingBaseItemSkills <- true;

	// MV: Added part of framework: base item for named items
	q.getBaseItemFields <- { function getBaseItemFields()
	{
		return [];
	}}.getBaseItemFields;

	// MV: Added part of framework: base item for named items
	q.setValuesBeforeRandomize <- { function setValuesBeforeRandomize( _baseItem )
	{
		if (_baseItem != null)
		{
			foreach (field in this.getBaseItemFields())
			{
				this.m[field] = _baseItem.m[field];
			}
		}
	}}.setValuesBeforeRandomize;

	// MV: Added part of framework: base item for named items
	q.randomizeValues <- { function randomizeValues()
	{
	}}.randomizeValues;
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hookTree("scripts/items/item", function(q) {
		// MV: Part of framework: base item for named items
		q.create = @(__original) { function create()
		{
			// Prevent the vanilla call to this.randomizeValues() within create() from randomizing anything
			// because we want to set the values from the base item first.
			local randomizeValues = this.randomizeValues;
			this.randomizeValues = @() null;
			__original();
			this.randomizeValues = randomizeValues;

			this.setValuesBeforeRandomize(this.m.BaseItemScript == null ? null : ::new(this.m.BaseItemScript));
			this.randomizeValues();
		}}.create;

		// MV: Part of framework: base item for named items
		q.setValuesBeforeRandomize = @(__original) { function setValuesBeforeRandomize( _baseItem )
		{
			if (_baseItem == null)
			{
				__original(_baseItem);
				return;
			}

			// The Named itemtype is lost when copying the ItemType from the base item
			// so we add it back if this item already had it
			local isNamedItem = this.isItemType(::Const.Items.ItemType.Named);
			__original(_baseItem);
			if (isNamedItem)
			{
				this.m.ItemType = this.m.ItemType | ::Const.Items.ItemType.Named;
			}
		}}.setValuesBeforeRandomize;

		// MV: Part of framework: base item for named items
		q.onEquip = @(__original) function()
		{
			if (this.m.BaseItemScript == null || !this.m.IsUsingBaseItemSkills)
				return __original();

			local function getParents( _obj )
			{
				local ret = [];
				while ("SuperName" in _obj && _obj.SuperName != "item")
				{
					ret.push(_obj.SuperName);
					_obj = _obj[_obj.SuperName];
				}
				return ret;
			}

			local baseItem = ::new(this.m.BaseItemScript);

			// During the call on `onEquip` with this as env variable, any parents of baseItem which are not our parents will throw an error,
			// so we add them to us temporarily. This is basically a failsafe for the situations when the base item inherits from a class other
			// than what the named version of this object inherits from. E.g. usually base weapon inherits from `weapon` and named weapon inherits
			// from `named_weapon` which also inherits from `weapon`. So, in this case nothing needs to be done. However, if a base weapon inherits
			// from another child of `weapon` then we need to ensure that we have access to that parent's onEquip function.
			local myParents = getParents(this);
			// The filter is so that we don't overwrite any parent with identical name between baseItem and this object. In usual circumstances
			// this will lead to baseItemParents being an empty array e.g. if the base item inherits from `weapon` and named inherits from `named_weapon`
			// which in turn inherits from `weapon` resulting in `weapon` being one of myParents as well.
			local baseItemParents = getParents(baseItem).filter(@(_, _p) myParents.find(_p) == null);
			foreach (p in baseItemParents)
			{
				this[p] <- baseItem[p];
				this[p].onEquip = this[p].onEquip.bindenv(this);
			}

			local topParent = myParents.pop(); // this will be one step below "item" class

			// We want the top parent's onEquip e.g. this.weapon.onEquip to run at the end (during base item onEquip)
			// so we switcheroo it with a null function for now.
			// This is important to keep the sequence of function calls correct i.e. from bottom up towards parents.
			local topParent_onEquip = this[topParent].onEquip;
			this[topParent].onEquip = @() null;

			// This will call this object's parent's onEquip which in the case of named weapons will almost always be named_weapon
			// That in turn will call its parent's e.g. this.weapon.onEquip but we have already nullified that above.
			this[this.SuperName].onEquip();

			// Revert the switcheroo so that during the call to base item's onEquip below, the top parent's onEquip will properly run
			this[topParent].onEquip = topParent_onEquip;

			// We have to switcheroo BaseItemScript to be null otherwise a stack overflow will occur
			// as we are calling the function with `this` as the env.
			local baseItemScript = this.m.BaseItemScript;
			this.m.BaseItemScript = null;

			baseItem.onEquip.call(this);

			this.m.BaseItemScript = baseItemScript;

			foreach (p in baseItemParents)
			{
				delete this[p];
			}
		}
	});
});
