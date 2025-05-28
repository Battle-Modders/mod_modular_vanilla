::ModularVanilla.MH.hook("scripts/skills/actives/decapitate", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (this.m.ApplySwordMastery)
		{
			if (_properties.IsSpecializedInSwords)
			{
				this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			}
		}
		else if (_properties.IsSpecializedInCleavers)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}}.onAfterUpdate;
});
