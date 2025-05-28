::ModularVanilla.MH.hook("scripts/skills/actives/reload_handgonne_skill", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsSpecializedInCrossbows)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			this.m.ActionPointCost = ::Math.min(this.m.ActionPointCost, ::Math.max(1, this.m.ActionPointCost - 3));
		}
	}}.onAfterUpdate;
});
