::ModularVanilla.MH.hook("scripts/skills/actives/shoot_stake", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		this.m.AdditionalAccuracy = this.m.Item.getAdditionalAccuracy();
		if (_properties.IsSpecializedInCrossbows)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			this.m.DirectDamageMult += 0.2;
		}
	}}.onAfterUpdate;
});

::ModularVanilla.QueueBucket.Normal.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/actives/shoot_stake", function(q) {
		// Convert the vanilla method of "setting" certain fields to instead be incremental changes
		q.softReset = @(__original) { function softReset()
		{
			__original();
			this.resetField("DirectDamageMult");
		}}.softReset;
	});
});
