::ModularVanilla.MH.hook("scripts/entity/world/player_party", function (q) {
	// MV: Modularized and Changed
	// Part of player_party.updateStrength modularization.
	// Extracted the calculation of bro strength.
	// Sort by strength instead of level.
	// Added multiplier for Origin.
	q.updateStrength = @() function()
	{
		this.m.Strength = 0.0;

		// Vanilla sorts by level and then checks for exceeding getBrothersScaleMax or being below getBrothersScaleMin.
		// We sort by strength because in MV the strength may not necessarily be a linear function of Level.

		local strengths = ::World.getPlayerRoster().getAll().map(@(_bro) _bro.MV_getStrength());

		if (strengths.len() < ::World.Assets.getBrothersScaleMin())
		{
			// MV: Extracted the strength of empty slot into a separate function
			this.m.Strength += this.MV_getEmptyBroStrength() * (::World.Assets.getBrothersScaleMin() - strengths.len());
		}

		if (strengths.len() > ::World.Assets.getBrothersScaleMax())
		{
			// sort descending
			strengths.sort(@(_a, _b) -_a <=> -_b);
			strengths = strengths.slice(0, ::World.Assets.getBrothersScaleMax());
		}

		// roster length can be 0 during deserialization and with 0 len array.reduce returns null
		if (strengths.len() != 0)
			this.m.Strength += strengths.reduce(@(_str1, _str2) _str1 + _str2);

		// Added call to new starting_scenario event for getting strength mult
		if (!::MSU.isNull(::World.Assets.getOrigin()))
		{
			this.m.Strength *= ::World.Assets.getOrigin().MV_getPlayerPartyStrengthMult();
		}
	}

	// MV: Added
	// Part of player_party.updateStrength modularization
	q.MV_getEmptyBroStrength <- function()
	{
		return 10.0;
	}
});
