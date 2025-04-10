::ModularVanilla.MH.hook("scripts/entity/world/player_party", function (q) {
	// MV: Modularized
	q.updateStrength = @() function()
	{
		this.m.Strength = 0.0;
		local roster = ::World.getPlayerRoster().getAll();

		if (roster.len() > ::World.Assets.getBrothersScaleMax())
		{
			roster.sort(this.onLevelCompare);
		}

		if (roster.len() < ::World.Assets.getBrothersScaleMin())
		{
			// Extracted the strength of empty slot into a separate function
			this.m.Strength += this.MV_getEmptyBroStrength() * (::World.Assets.getBrothersScaleMin() - roster.len());
		}

		foreach (i, bro in roster)
		{
			if (i >= ::World.Assets.getBrothersScaleMax())
			{
				break;
			}

			// Extracted the logic of adding each bro's contribution to the strength
			// and added call to new skill_container event for getting strength mult
			this.m.Strength += bro.MV_getStrength();
		}

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
