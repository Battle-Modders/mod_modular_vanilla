::ModularVanilla.MH.hook("scripts/items/weapons/named/named_weapon", function(q) {
	// MV: Part of framework: base item for named items
	q.getBaseItemFields = @() function()
	{
		return [
			// The following fields are used in vanilla randomizeValues()
			"Condition",
			"ConditionMax",
			"StaminaModifier",
			"RegularDamage",
			"RegularDamageMax",
			"ArmorDamageMult",
			"ChanceToHitHead",
			"DirectDamageMult",
			"DirectDamageAdd",
			"StaminaModifier",
			"ShieldDamage",
			"AdditionalAccuracy",
			"FatigueOnSkillUse",

			// The following fields aren't used in vanilla randomizeValues() but we copy them
			// for the sake of completion so that named items can be based on base items properly
			"Ammo",
			"AmmoMax",
			"AmmoCost",
			"IsAoE",
			"SlotType",
			"BlockedSlotType",
			"ItemType",
			"WeaponType",
			"IsDoubleGrippable",
			"IsAgainstShields",
			"RangeMin",
			"RangeMax",
			"RangeIdeal",
		];
	}

	q.setValuesBeforeRandomize = @(__original) function( _baseItem )
	{
		// Part of what setValuesBeforeRandomize does is copying all weapon types over without adjusting the weapontype-string
		// If a mod changes those weapon types during the create function, then those new type combination won't show up correctly
		// We fix that by building categories manually for any named weapon after that transfer happened
		__original(_baseItem);
		this.buildCategoriesFromWeaponType();
	}
});
