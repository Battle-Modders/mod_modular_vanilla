::ModularVanilla.MH.hook("scripts/skills/actives/hail_skill", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() function( _properties )
	{
		if (_properties.IsSpecializedInFlails)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			this.m.IsShieldRelevant = false;
		}
		else
		{
			this.m.IsShieldRelevant = true;
		}
	}
});
