::ModularVanilla.MH.hook("scripts/items/shields/named/named_shield", function(q) {
	// MV: Part of framework: base item for named items
	q.getBaseItemFields = @() { function getBaseItemFields()
	{
		return [
			// The following fields are used in vanilla randomizeValues()
			"Condition",
			"ConditionMax",
			"MeleeDefense",
			"RangedDefense",
			"StaminaModifier",
			"FatigueOnSkillUse"

			// The following fields aren't used in vanilla randomizeValues() but we copy them
			// for the sake of completion so that named items can be based on base items properly
			// -- No such fields for this particular named item type --
		];
	}}.getBaseItemFields;
});
