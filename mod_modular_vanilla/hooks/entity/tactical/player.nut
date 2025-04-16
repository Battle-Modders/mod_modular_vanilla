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

	// MV: Added
	// Part of modularization of player.setStartValuesEx
	q.MV_getMaxStartingTraits <- function()
	{
		return ::Math.rand(::Math.rand(0, 1) == 0 ? 0 : 1, 2);
	}

	// MV: Modularized
	// Copy of the vanilla function with the following changes:
	// Extracted the calculation of max traits to add
	// Change trait adding logic instead of the vanilla way of max 10 iterations
	q.setStartValuesEx = @() function( _backgrounds, _addTraits = true )
	{
		if (::isSomethingToSee() && ::World.getTime().Days >= 7)
		{
			_backgrounds = ::Const.CharacterPiracyBackgrounds;
		}

		local background = ::new("scripts/skills/backgrounds/" + _backgrounds[::Math.rand(0, _backgrounds.len() - 1)]);
		this.m.Skills.add(background);
		this.m.Background = background;
		this.m.Ethnicity = this.m.Background.getEthnicity();
		background.buildAttributes();
		background.buildDescription();

		if (this.m.Name.len() == 0)
		{
			this.m.Name = background.m.Names[::Math.rand(0, background.m.Names.len() - 1)];
		}

		if (_addTraits)
		{
			// MV: Extracted calculation of maxTraits into a new function
			local maxTraits = this.MV_getMaxStartingTraits();
			local traits = [
				this.getBackground()
			];

			// MV: Changed
			// VanillaFix: Vanilla iterates only 10 times and tries to add random traits from ::Const.CharacterTraits
			// and keeps rolling random traits until it finds one that returns false for isExcluded. This can
			// sometimes lead to fewer traits than desired. So we change this logic completely.
			local trait = traits[0];
			local potential = ::Const.CharacterTraits;

			for (local i = 0; i < maxTraits; i++)
			{
				potential = potential.filter(@(_, _entry) !trait.isExcluded(_entry[0]));

				if (potential.len() == 0)
					break;

				trait = ::new(::MSU.Array.rand(potential)[1]);
				traits.push(trait);
			}

			for (local i = 1; i < traits.len(); i++)
			{
				this.getSkills().add(traits[i]);
				if (traits[i].getContainer() != null)
				{
					traits[i].addTitle();
				}
			}
		}

		background.addEquipment();
		background.setAppearance();
		background.buildDescription(true);
		this.m.Skills.update();
		local p = this.m.CurrentProperties;
		this.m.Hitpoints = p.Hitpoints;

		if (_addTraits)
		{
			this.fillTalentValues();
			this.fillAttributeLevelUpValues(::Const.XP.MaxLevelWithPerkpoints - 1);
		}
	}
});
