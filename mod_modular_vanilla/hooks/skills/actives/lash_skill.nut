::ModularVanilla.MH.hook("scripts/skills/actives/lash_skill", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
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
	}}.onAfterUpdate;
});
