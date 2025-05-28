::ModularVanilla.MH.hook("scripts/skills/actives/shoot_bolt", function(q) {
	q.create = @(__original) { function create()
	{
		__original();
		// Vanilla Fix: shoot_bolt has a wrong penetration value, compared to what appears in the tooltip of the crossbows
		if (this.m.DirectDamageMult == 0.45)	// If another mod fixes or changes this value, then we don't want to interfer
		{
			this.m.DirectDamageMult = 0.5;
		}
	}}.create;

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
	::ModularVanilla.MH.hook("scripts/skills/actives/shoot_bolt", function(q) {
		// Convert the vanilla method of "setting" certain fields to instead be incremental changes
		q.softReset = @(__original) { function softReset()
		{
			__original();
			this.resetField("DirectDamageMult");
		}}.softReset;
	});
});
