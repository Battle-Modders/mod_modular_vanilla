::ModularVanilla.MH.hook("scripts/entity/tactical/player", function (q) {
	// MV: Extracted
	// part of player_party.updateStrength modularization
	// The raw function represents this character's strength based on his own features
	// and does not include any multipliers.
	q.MV_getStrengthRaw <- { function MV_getStrengthRaw()
	{
		// Same as vanilla in player_party.updateStrength
		return 10 + (this.getLevel() - 1) * 2.0;
	}}.MV_getStrengthRaw;

	// Returns the actual strength of this character, using raw strength and any multipliers
	q.MV_getStrength <- { function MV_getStrength()
	{
		return this.MV_getStrengthRaw() * this.getCurrentProperties().MV_StrengthMult;
	}}.MV_getStrength;

	// MV: Added
	// Part of modularization of player.setStartValuesEx
	q.MV_getMaxStartingTraits <- { function MV_getMaxStartingTraits()
	{
		return ::Math.rand(::Math.rand(0, 1) == 0 ? 0 : 1, 2);
	}}.MV_getMaxStartingTraits;

	// MV: Added
	// Part of modularization of player.setStartValuesEx
	// Adds new traits to the character up to _amount, properly filtering traits based on existing traits and background.
	q.MV_addTraits <- { function MV_addTraits( _amount )
	{
		// MV: Changed
		// VanillaFix: Vanilla iterates only 10 times and tries to add random traits from ::Const.CharacterTraits
		// and keeps rolling random traits until it finds one that returns false for isExcluded. This can
		// sometimes lead to fewer traits than desired. So we change this logic completely.

		// We use isKindOf to filter because vanilla applies Trait SkillType even to skills which are neither
		// character_background nor character_trait which leads to the later call to .isExcluded to throw an error.
		local presentTraits = this.getSkills().getSkillsByFunction(@(_s) ::isKindOf(_s, "character_background") || ::isKindOf(_s, "character_trait"));
		local potential = ::Const.CharacterTraits.filter(function(_, _entry) {
			foreach (t in presentTraits)
			{
				if (t.getID() == _entry[0] || t.isExcluded(_entry[0]))
					return false;
			}
			return true;
		});

		local addedTraits = [];
		local trait;
		for (local i = 0; i < _amount; i++)
		{
			if (i != 0)
				potential = potential.filter(@(_, _entry) !trait.isExcluded(_entry[0]));

			if (potential.len() == 0)
				break;

			trait = ::new(potential.remove(::Math.rand(0, potential.len() - 1))[1]);
			addedTraits.push(trait);

			this.getSkills().add(trait);
		}

		return addedTraits;
	}}.MV_addTraits;

	// MV: Modularized
	// Copy of the vanilla function with the following changes:
	// Extracted the calculation of max traits to add
	// Change trait adding logic instead of the vanilla way of max 10 iterations
	q.setStartValuesEx = @() { function setStartValuesEx( _backgrounds, _addTraits = true )
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
			// MV: Extracted adding traits into a new function
			foreach (t in this.MV_addTraits(this.MV_getMaxStartingTraits()))
			{
				t.addTitle();
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
	}}.setStartValuesEx;

	q.setMoraleState = @() { function setMoraleState( _m )
	{
		if (this.getCurrentProperties().MV_ForbiddenMoraleStates.find(_m) != null)
		{
			return;
		}

	/*
	This has been implemented in hooks on these skills using the properties.MV_ForbiddenMoraleStates

		if (_m == this.Const.MoraleState.Confident && this.m.Skills.hasSkill("trait.insecure"))
		{
			return;
		}
	*/

	/*
	This has been implemented via mv_manager_skill_for_player using the skill.MV_onMoraleStateChanged event

		if (_m == this.Const.MoraleState.Confident && ("State" in this.World) && this.World.State != null && this.World.Assets.getOrigin().getID() == "scenario.anatomists")
		{
			return;
		}
	*/

	/*
	This has been implemented in hooks on these skills

		if (_m == this.Const.MoraleState.Fleeing && this.m.Skills.hasSkill("effects.ancient_priest_potion"))
		{
			return;
		}

		if (_m == this.Const.MoraleState.Fleeing && this.m.Skills.hasSkill("trait.oath_of_valor"))
		{
			return;
		}


		if (_m == this.Const.MoraleState.Confident && this.getMoraleState() != this.Const.MoraleState.Confident && this.isPlacedOnMap() && this.Time.getRound() >= 1 && ("State" in this.World) && this.World.State != null && this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.oath_of_camaraderie")
		{
			this.World.Statistics.getFlags().increment("OathtakersBrosConfident");
		}
	*/

		this.actor.setMoraleState(_m);
	}}.setMoraleState;
});
