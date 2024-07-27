::ModularVanilla.MH.hook("scripts/skills/actives/stab", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() function( _properties )
	{
		if (_properties.IsSpecializedInDaggers)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			if (this.m.ActionPointCost > 1)
			{
				this.m.ActionPointCost -= 1;
			}
		}
	}
});
