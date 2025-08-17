::ModularVanilla.MH.hook("scripts/entity/world/location", function (q) {
	// MV: Added
	// Used in this.createDefenders to apply difficulty scaling to locations.
	// The primary intent is to allow modders to apply Player Party Strength based scaling to locations,
	// similar to the vanilla functions with this name in faction_action, contract etc.
	q.MV_getScaledDifficultyMult <- function()
	{
		return 1.0;
	}

	// MV: Changed
	// Resources are scaled based on this.MV_getScaledDifficultyMult
	q.createDefenders = @(__original) function()
	{
		local original_Resources = this.m.Resources;
		this.m.Resources *= this.MV_getScaledDifficultyMult();
		__original();
		this.m.Resources = original_Resources;
	}
});
