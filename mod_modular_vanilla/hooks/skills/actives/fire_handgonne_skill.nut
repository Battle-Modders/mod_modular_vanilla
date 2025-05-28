::ModularVanilla.MH.hook("scripts/skills/actives/fire_handgonne_skill", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsSpecializedInCrossbows)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}}.onAfterUpdate;
});
