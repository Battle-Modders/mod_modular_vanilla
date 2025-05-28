::ModularVanilla.MH.hook("scripts/skills/actives/footwork", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsFleetfooted)
		{
			this.m.FatigueCostMult *= 0.5;

			if (this.getContainer().hasSkill("effects.goblin_grunt_potion"))
			{
				this.m.ActionPointCost = ::Math.min(this.m.ActionPointCost, ::Math.max(1, this.m.ActionPointCost - 2));
			}
		}
	}}.onAfterUpdate;
});
