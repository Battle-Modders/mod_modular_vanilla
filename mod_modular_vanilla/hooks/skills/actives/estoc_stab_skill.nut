::ModularVanilla.MH.hook("scripts/skills/actives/estoc_stab_skill", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsSpecializedInDaggers)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			this.m.ActionPointCost -= 1;
		}
	}}.onAfterUpdate;
});
