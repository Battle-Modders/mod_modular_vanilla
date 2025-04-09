::ModularVanilla.MH.hook("scripts/entity/tactical/player", function (q) {
	// MV: Extracted
	// part of player_party.updateStrength modularization
	q.MV_getStrength <- function()
	{
		// Same as vanilla in player_party.updateStrength
		return 10 + (this.getLevel() - 1) * 2.0;
	}
});
