::ModularVanilla.MH.hook("scripts/entity/tactical/player", function (q) {
	// MV: Extracted
	// part of player_party.updateStrength modularization
	// The raw function represents this character's strength based on his own features
	// and does not include any multipliers.
	q.MV_getStrengthRaw <- function()
	{
		// Same as vanilla in player_party.updateStrength
		return 10 + (this.getLevel() - 1) * 2.0;
	}

	// Returns the actual strength of this character, using raw strength and any multipliers
	q.MV_getStrength <- function()
	{
		return this.MV_getStrengthRaw() * this.getSkills().MV_getPlayerPartyStrengthMult();
	}
});
