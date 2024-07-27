::ModularVanilla.MH.hook("scripts/skills/actives/rotation", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() function( _properties )
	{
		if (_properties.IsFleetfooted)
		{
			this.m.FatigueCostMult *= 0.5;

			if (this.getContainer().hasSkill("effects.goblin_grunt_potion"))
			{
				if (this.m.ActionPointCost > 2)
				{
					this.m.ActionPointCost -= 2;
				}
			}
		}
	}
});
