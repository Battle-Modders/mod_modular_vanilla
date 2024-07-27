::ModularVanilla.MH.hook("scripts/skills/actives/aimed_shot", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() function( _properties )
	{
		this.m.AdditionalAccuracy = this.m.Item.getAdditionalAccuracy();
		if (_properties.IsSpecializedInBows)
		{
			this.m.MaxRange += 1;
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/actives/aimed_shot", function(q) {
		q.onAdded = @(__original) function()
		{
			local weapon = this.getItem();
			if (!::MSU.isNull(weapon))
			{
				this.setBaseValue("MaxRange", weapon.getRangeMax());
			}

			__original();
		}
	});
});
