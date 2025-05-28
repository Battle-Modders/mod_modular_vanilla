::ModularVanilla.MH.hook("scripts/skills/actives/throw_smoke_bomb_skill", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsSpecializedInThrowing)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}}.onAfterUpdate;
});
