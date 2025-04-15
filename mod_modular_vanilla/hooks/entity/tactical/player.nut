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
		return this.Math.rand(this.Math.rand(0, 1) == 0 ? 0 : 1, 2);
	}

	// MV: Modularized
	// Copy of the vanilla function with the following changes:
	// Extracted the calculation of max traits to add
	q.setStartValuesEx = @() function( _backgrounds, _addTraits = true )
	{
		if (::isSomethingToSee() && ::World.getTime().Days >= 7)
		{
			_backgrounds = this.Const.CharacterPiracyBackgrounds;
		}

		local background = ::new("scripts/skills/backgrounds/" + _backgrounds[this.Math.rand(0, _backgrounds.len() - 1)]);
		this.m.Skills.add(background);
		this.m.Background = background;
		this.m.Ethnicity = this.m.Background.getEthnicity();
		background.buildAttributes();
		background.buildDescription();

		if (this.m.Name.len() == 0)
		{
			this.m.Name = background.m.Names[this.Math.rand(0, background.m.Names.len() - 1)];
		}

		if (_addTraits)
		{
			// MV: Extracted calculation of maxTraits into a new function
			local maxTraits = this.MV_getMaxTraits();
			local traits = [
				background
			];

			for( local i = 0; i < maxTraits; i = ++i )
			{
				for( local j = 0; j < 10; j = ++j )
				{
					local trait = this.Const.CharacterTraits[this.Math.rand(0, this.Const.CharacterTraits.len() - 1)];
					local nextTrait = false;

					for( local k = 0; k < traits.len(); k = ++k )
					{
						if (traits[k].getID() == trait[0] || traits[k].isExcluded(trait[0]))
						{
							nextTrait = true;
							break;
						}
					}

					if (!nextTrait)
					{
						traits.push(this.new(trait[1]));
						break;
					}
				}
			}

			for( local i = 1; i < traits.len(); i = ++i )
			{
				this.m.Skills.add(traits[i]);

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
			this.fillAttributeLevelUpValues(this.Const.XP.MaxLevelWithPerkpoints - 1);
		}
	}
});
