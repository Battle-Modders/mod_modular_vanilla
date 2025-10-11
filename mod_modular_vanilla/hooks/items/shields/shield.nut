::ModularVanilla.MH.hook("scripts/items/shields/shield", function(q) {
	// MV: Custom implementation of the function added in item.nut
	// see the full comments there.
	// Part of MV_Variant framework for items
	q.MV_updateVariant = @() { function MV_updateVariant()
	{
		// The entire logic in this function is basically calling the vanilla
		// updateVariant and then replacing parts in the strings to now
		// use the variant strings from our variant.
		// This ensures that the entire folder path structure is kept the same
		// as the vanilla variant without requiring the modder to specify this.
		// This is because in vanilla the gfx folders sometimes have subfolders
		// for different types e.g. in weapons we have melee/ ranged/ etc.

		this.updateVariant();

		local str = this.__MV_getFormattedVariantString();

		local arr = split(this.m.IconLarge, "/");
		arr.pop();
		local iconPath = arr.reduce(@(_a, _b) _a + "/" + _b);

		this.m.Sprite = str;
		this.m.SpriteDamaged = str + "_damaged";
		this.m.ShieldDecal = str + "_destroyed";
		this.m.IconLarge = iconPath + "/inventory_" + str + ".png";
		this.m.Icon = iconPath + "/icon_" + str + ".png";
	}}.MV_updateVariant;

	// MV: Custom implementation of the function added in item.nut
	// see the full comments there.
	// Part of MV_Variant framework for items
	q.__MV_isVariantInstalled = @() { function __MV_isVariantInstalled()
	{
		return ::doesBrushExist(this.__MV_getFormattedVariantString());
	}}.__MV_isVariantInstalled;
});
