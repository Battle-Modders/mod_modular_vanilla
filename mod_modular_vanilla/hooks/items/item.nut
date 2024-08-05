::ModularVanilla.MH.hook("scripts/items/item", function(q) {
	// MV: Added part of framework: base item for named items
	q.m.BaseItemScript <- null;

	// MV: Added part of framework: base item for named items
	q.getBaseItemFields <- function()
	{
		return [];
	}

	// MV: Added part of framework: base item for named items
	q.setValuesBeforeRandomize <- function( _baseItem )
	{
		if (_baseItem != null)
		{
			foreach (field in this.getBaseItemFields())
			{
				this.m[field] = _baseItem.m[field];
			}
		}
	}

	// MV: Added part of framework: base item for named items
	q.randomizeValues <- function()
	{
	}
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hookTree("scripts/items/item", function(q) {
		// MV: Part of framework: base item for named items
		q.create = @(__original) function()
		{
			// Prevent the vanilla call to this.randomizeValues() within create() from randomizing anything
			// because we want to set the values from the base item first.
			local randomizeValues = this.randomizeValues;
			this.randomizeValues = @() null;
			__original();
			this.randomizeValues = randomizeValues;

			this.setValuesBeforeRandomize(this.m.BaseItemScript == null ? null : ::new(this.m.BaseItemScript));
			this.randomizeValues();
		}

		// MV: Part of framework: base item for named items
		q.setValuesBeforeRandomize = @(__original) function( _baseItem )
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
		}
	});
});
