::ModularVanilla.MH.hook("scripts/skills/actives/split_shield", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsSpecializedInAxes)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}}.onAfterUpdate;
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/actives/split_shield", function(q) {
		q.onAdded = @(__original) { function onAdded()
		{
			local weapon = this.getContainer().getActor().getMainhandItem();
			if (weapon != null && weapon.getBlockedSlotType() != null)
			{
				this.setBaseValue("ActionPointCost", 6);
			}

			__original();
		}}.onAdded;
	});
});
