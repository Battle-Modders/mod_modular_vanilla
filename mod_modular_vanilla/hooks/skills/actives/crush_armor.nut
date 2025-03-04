::ModularVanilla.MH.hook("scripts/skills/actives/crush_armor", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() function( _properties )
	{
		if (_properties.IsSpecializedInHammers)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}

	// VanillaFix: see documentation of helper function
	::ModularVanilla.HooksHelper.fixGetTooltipProperties(q);
});
