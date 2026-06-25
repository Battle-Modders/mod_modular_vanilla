::ModularVanilla.MH.hook("scripts/skills/actives/smite_skill", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (this.m.IsPolearm)
		{
			if (_properties.IsSpecializedInPolearms)
			{
				this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
				if (this.getBaseValue("ActionPointCost") > 5)
				{
					this.m.ActionPointCost -= 1;
				}
			}
		}
		else if (_properties.IsSpecializedInHammers)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}}.onAfterUpdate;
});
