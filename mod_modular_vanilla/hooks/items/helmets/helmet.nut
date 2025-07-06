::ModularVanilla.MH.hook("scripts/items/helmets/helmet", function(q) {
	// MV: Custom implementation of the function added in item.nut
	// see the full comments there.
	// Part of MV_Variant framework for items
	q.MV_updateVariant = @() { function MV_updateVariant()
	{
		// We temporarily switcheroo the Variant and VariantString
		// to our custom ones before calling the vanilla updateVariant.
		local variant = this.m.Variant;
		local variantString = this.m.VariantString;
		this.m.Variant = this.getFlags().get("MV_Variant");
		this.m.VariantString = this.getFlags().get("MV_VariantString");
		this.updateVariant();

		// We revert the Variant and VariantString back to their original
		// values so that they are serialized as such. This helps ensure
		// that if the mod providing the new variants is removed, then
		// the item can show its originally rolled vanilla variant until
		// that mod is added back.
		this.m.Variant = variant;
		this.m.VariantString = variantString;
	}}.MV_updateVariant;

	// MV: Custom implementation of the function added in item.nut
	// see the full comments there.
	// Part of MV_Variant framework for items
	q.__MV_isVariantInstalled = @() { function __MV_isVariantInstalled()
	{
		return ::doesBrushExist("bust_" + this.__MV_getFormattedVariantString());
	}}.__MV_isVariantInstalled;
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/items/helmets/helmet", function(q) {
		// MV: Changed
		// Part of MV_Variant framework for items
		// We remove our custom variant from the flag container when setting
		// it back to the plain variant so that the plain variant is retained
		// upoon deserialization.
		q.setPlainVariant = @(__original) { function setPlainVariant()
		{
			__original();
			if (this.getFlags().has("MV_Variant"))
			{
				this.getFlags().remove("MV_Variant");
				this.getFlags().remove("MV_VariantString");
			}
		}}.setPlainVariant;
	});
});
