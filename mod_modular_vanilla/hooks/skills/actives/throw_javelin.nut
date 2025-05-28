::ModularVanilla.MH.hook("scripts/skills/actives/throw_javelin", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		this.m.AdditionalAccuracy = this.m.Item.getAdditionalAccuracy();
		if (_properties.IsSpecializedInThrowing)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}}.onAfterUpdate;
});
