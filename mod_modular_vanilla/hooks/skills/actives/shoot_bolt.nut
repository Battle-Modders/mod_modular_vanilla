::ModularVanilla.MH.hook("scripts/skills/actives/shoot_bolt", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() function( _properties )
	{
		this.m.AdditionalAccuracy = this.m.Item.getAdditionalAccuracy();
		if (_properties.IsSpecializedInCrossbows)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			this.m.DirectDamageMult += 0.2;
		}
	}
});

::ModularVanilla.QueueBucket.Normal.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/actives/shoot_bolt", function(q) {
		// Convert the vanilla method of "setting" certain fields to instead be incremental changes
		q.softReset = @(__original) function()
		{
			__original();
			this.resetField("DirectDamageMult");
		}
	});
});
