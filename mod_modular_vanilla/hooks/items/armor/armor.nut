::ModularVanilla.MH.hook("scripts/items/armor/armor", function(q) {
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
	q.__MV_isVariantInstalled = @() { function __MV_isVariantInstalled()
	{
		return ::doesBrushExist("bust_" + this.__MV_getFormattedVariantString());
	}}.__MV_isVariantInstalled;
});
