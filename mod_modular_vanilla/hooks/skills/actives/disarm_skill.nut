::ModularVanilla.MH.hook("scripts/skills/actives/disarm_skill", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsSpecializedInCleavers)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			this.m.HitChanceBonus += 10;
		}
	}}.onAfterUpdate;
});

::ModularVanilla.QueueBucket.Normal.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/actives/disarm_skill", function(q) {
		// Convert the vanilla method of "setting" certain fields to instead be incremental changes
		q.softReset = @(__original) { function softReset()
		{
			__original();
			this.resetField("HitChanceBonus");
		}}.softReset;
	});
});
