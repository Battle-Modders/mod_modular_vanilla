::ModularVanilla.MH.hook("scripts/skills/actives/shieldwall", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() function( _properties )
	{
		if (_properties.IsProficientWithShieldWall || _properties.IsProficientWithShieldSkills)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			if (this.m.ActionPointCost > 5)
			{
				this.m.ActionPointCost -= 1;
			}
		}
	}
});