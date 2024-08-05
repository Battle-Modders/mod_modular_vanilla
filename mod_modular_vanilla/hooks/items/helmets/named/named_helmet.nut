::ModularVanilla.MH.hook("scripts/items/helmets/named/named_helmet", function(q) {
	// MV: Part of framework: base item for named items
	q.getBaseItemFields = @() function()
	{
		return [
			// The following fields are used in vanilla randomizeValues()
			"Condition",
			"ConditionMax",
			"StaminaModifier",

			// The following fields aren't used in vanilla randomizeValues() but we copy them
			// for the sake of completion so that named items can be based on base items properly
			"Armor", // This field is actually redundant and is unused in vanilla
			"ArmorMax", // This field is actually redundant and is unused in vanilla
			"Vision",
		];
	}
});
