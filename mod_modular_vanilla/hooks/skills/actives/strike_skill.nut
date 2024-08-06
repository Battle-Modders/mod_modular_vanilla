::ModularVanilla.MH.hook("scripts/skills/actives/strike_skill", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() function( _properties )
	{
		if (this.m.ApplyAxeMastery)
		{
			if (_properties.IsSpecializedInAxes)
			{
				this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			}
		}
		else if (_properties.IsSpecializedInPolearms)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			if (this.getBaseValue("ActionPointCost") > 5)
			{
				this.m.ActionPointCost -= 1;
			}
		}
	}
});
