::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hookTree("scripts/entity/tactical/actor", function (q) {
	// part of affordability preview system START
		// MV: Changed
		// We modify all these below functions to prevent them
		// from setting the fields during the skill_container.update() function
		// during a preview type update -- part of the affordability preview system
		// Note: Done inside a hookTree because vanilla overwrites these functions for e.g. lindwurm_tail
		q.setActionPoints = @(__original) { function setActionPoints( _a )
		{
			if (!this.m.MV_IsDoingPreviewUpdate)
				return __original(_a);
		}}.setActionPoints;

		q.setFatigue = @(__original) { function setFatigue( _f )
		{
			if (!this.m.MV_IsDoingPreviewUpdate)
				return __original(_f);
		}}.setFatigue;

		q.setHitpointsPct = @(__original) { function setHitpointsPct( _h )
		{
			if (!this.m.MV_IsDoingPreviewUpdate)
				return __original(_h);
		}}.setHitpointsPct;

		q.onSkillsUpdated = @(__original) { function onSkillsUpdated()
		{
			if (!this.m.MV_IsDoingPreviewUpdate)
				return __original();
		}}.onSkillsUpdated;

		q.updateOverlay = @(__original) { function updateOverlay()
		{
			if (!this.m.MV_IsDoingPreviewUpdate)
				return __original();
		}}.updateOverlay;

		q.setDirty = @(__original) { function setDirty( _value )
		{
			if (!this.m.MV_IsDoingPreviewUpdate)
				return __original(_value);
		}}.setDirty;
	// part of affordability preview system END
	});
});

::ModularVanilla.MH.hook("scripts/entity/tactical/actor", function (q) {
// part of affordability preview system START
	// MV: Added
	q.m.MV_IsDoingPreviewUpdate <- false;
	q.m.MV_IsPreviewing <- false;
	q.m.MV_CostsPreview <- null;
	q.m.MV_PreviewSkill <- null;
	q.m.MV_PreviewMovement <- null;

	// MV: Added
	q.resetPreview <- { function resetPreview()
	{
		this.m.MV_IsPreviewing = false;
		this.m.MV_CostsPreview = null;
		this.m.MV_PreviewSkill = null;
		this.m.MV_PreviewMovement = null;
		this.getSkills().update();
	}}.resetPreview;

	// MV: Added
	q.isPreviewing <- { function isPreviewing()
	{
		return this.m.MV_IsPreviewing && (!::MSU.isNull(this.getPreviewSkill()) || !::MSU.isNull(this.getPreviewMovement()));
	}}.isPreviewing;

	// MV: Added
	q.getPreviewSkill <- { function getPreviewSkill()
	{
		return ::MSU.isNull(this.m.MV_PreviewSkill) ? null : this.m.MV_PreviewSkill.get();
	}}.getPreviewSkill;

	// MV: Added
	q.getPreviewMovement <- { function getPreviewMovement()
	{
		return this.m.MV_PreviewMovement;
	}}.getPreviewMovement;

	// MV: Added
	q.getCostsPreview <- { function getCostsPreview()
	{
		return this.m.MV_CostsPreview;
	}}.getCostsPreview;
// part of affordability preview system END

	// MV: Added
	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.MV_calcArmorDamageReceived <- { function MV_calcArmorDamageReceived( _skill, _hitInfo )
	{
		local p = _hitInfo.MV_PropertiesForBeingHit;
		local dmgMult = p.DamageReceivedTotalMult;
		if (_skill != null)
		{
			dmgMult *= _skill.isRanged() ? p.DamageReceivedRangedMult : p.DamageReceivedMeleeMult;
		}

		_hitInfo.DamageArmor -= p.DamageArmorReduction;
		_hitInfo.DamageArmor *= p.DamageReceivedArmorMult * dmgMult;

		local armorDamage = 0;

		if (_hitInfo.DamageDirect < 1.0)
		{
			_hitInfo.MV_ArmorRemaining = p.Armor[_hitInfo.BodyPart] * p.ArmorMult[_hitInfo.BodyPart];
			armorDamage = this.Math.min(_hitInfo.MV_ArmorRemaining, _hitInfo.DamageArmor);
			_hitInfo.MV_ArmorRemaining -= armorDamage;
			_hitInfo.DamageInflictedArmor = this.Math.max(0, armorDamage);
		}

		return _hitInfo.DamageInflictedArmor;
	}}.MV_calcArmorDamageReceived;

	// MV: Added
	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.MV_calcHitpointsDamageReceived <- { function MV_calcHitpointsDamageReceived( _skill, _hitInfo )
	{
		local p = _hitInfo.MV_PropertiesForBeingHit;
		local dmgMult = p.DamageReceivedTotalMult;
		if (_skill != null)
		{
			dmgMult *= _skill.isRanged() ? p.DamageReceivedRangedMult : p.DamageReceivedMeleeMult;
		}

		_hitInfo.DamageRegular -= p.DamageRegularReduction;
		_hitInfo.DamageRegular *= p.DamageReceivedRegularMult * dmgMult;

		local damage = 0;
		damage += this.Math.maxf(0.0, _hitInfo.DamageRegular * _hitInfo.DamageDirect * p.DamageReceivedDirectMult - _hitInfo.MV_ArmorRemaining * this.Const.Combat.ArmorDirectDamageMitigationMult);

		if (_hitInfo.MV_ArmorRemaining <= 0 || _hitInfo.DamageDirect >= 1.0)
		{
			damage += this.Math.max(0, _hitInfo.DamageRegular * this.Math.maxf(0.0, 1.0 - _hitInfo.DamageDirect * p.DamageReceivedDirectMult) - _hitInfo.DamageInflictedArmor);
		}

		damage *= _hitInfo.BodyDamageMult;
		_hitInfo.DamageInflictedHitpoints = this.Math.max(0, this.Math.max(this.Math.round(damage), this.Math.min(this.Math.round(_hitInfo.DamageMinimum), this.Math.round(_hitInfo.DamageMinimum * p.DamageReceivedTotalMult))));

		return _hitInfo.DamageInflictedHitpoints;
	}}.MV_calcHitpointsDamageReceived;

	// MV: Added
	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.MV_calcFatigueDamageReceived <- { function MV_calcFatigueDamageReceived( _skill, _hitInfo )
	{
		local p = _hitInfo.MV_PropertiesForBeingHit;
		_hitInfo.DamageFatigue *= p.FatigueEffectMult;
		return _hitInfo.DamageFatigue * p.FatigueReceivedPerHitMult * this.getCurrentProperties().FatigueLossOnAnyAttackMult;
	}}.MV_calcFatigueDamageReceived;

	// MV: Added
	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.MV_getFatalityType <- { function MV_getFatalityType( _skill, _hitInfo )
	{
		if (_skill != null)
		{
			if (_skill.getChanceDecapitate() >= 100 || _hitInfo.BodyPart == this.Const.BodyPart.Head && this.Math.rand(1, 100) <= _skill.getChanceDecapitate() * _hitInfo.FatalityChanceMult)
			{
				return this.Const.FatalityType.Decapitated;
			}
			else if (_skill.getChanceSmash() >= 100 || _hitInfo.BodyPart == this.Const.BodyPart.Head && this.Math.rand(1, 100) <= _skill.getChanceSmash() * _hitInfo.FatalityChanceMult)
			{
				return this.Const.FatalityType.Smashed;
			}
			else if (_skill.getChanceDisembowel() >= 100 || _hitInfo.BodyPart == this.Const.BodyPart.Body && this.Math.rand(1, 100) <= _skill.getChanceDisembowel() * _hitInfo.FatalityChanceMult)
			{
				return this.Const.FatalityType.Disemboweled;
			}
		}

		return this.Const.FatalityType.None;
	}}.MV_getFatalityType;

	// MV: Added
	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.MV_onInjuryReceived <- { function MV_onInjuryReceived( _injury )
	{
		if (this.isPlayerControlled() && this.isKindOf(this, "player"))
		{
			this.worsenMood(this.Const.MoodChange.Injury, "Suffered an injury");

			if (("State" in this.World) && this.World.State != null && this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.oath_of_sacrifice")
			{
				this.World.Statistics.getFlags().increment("OathtakersInjuriesSuffered");
			}
		}
	}}.MV_onInjuryReceived;

	// MV: Added
	// Returns the injury if an injury is successfully applied, otherwise returns null
	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.MV_applyInjury <- { function MV_applyInjury( _skill, _hitInfo )
	{
		local potentialInjuries = [];
		local bonus = _hitInfo.BodyPart == this.Const.BodyPart.Head ? 1.25 : 1.0;

		foreach( inj in _hitInfo.Injuries )
		{
			if (inj.Threshold * _hitInfo.InjuryThresholdMult * this.Const.Combat.InjuryThresholdMult * this.getCurrentProperties().ThresholdToReceiveInjuryMult * bonus <= _hitInfo.DamageInflictedHitpoints / (this.getHitpointsMax() * 1.0))
			{
				// vanilla lindwurm_tail is missing the this.m.ExcludedInjuries check here
				if (!this.getSkills().hasSkill(inj.ID) && this.m.ExcludedInjuries.find(inj.ID) == null)
				{
					potentialInjuries.push(inj.Script);
				}
			}
		}

		while (potentialInjuries.len() != 0)
		{
			local r = this.Math.rand(0, potentialInjuries.len() - 1);
			local injury = this.new("scripts/skills/" + potentialInjuries[r]);

			if (injury.isValid(this))
			{
				this.getSkills().add(injury);
				this.MV_onInjuryReceived(injury);
				return injury;
			}
			else
			{
				potentialInjuries.remove(r);
			}
		}
	}}.MV_applyInjury;

	// MV: Added
	// Extraction of part of vanilla logic from actor.onDamageReceived.
	// The use case seems to be to prevent the actor from dying.
	// TODO: Instead of this, perhaps this can simply be a skill_container.onBeforeDeath event?
	q.MV_onBeforeDeathConfirmed <- { function MV_onBeforeDeathConfirmed( _attacker, _skill, _hitInfo )
	{
		local lorekeeperPotionEffect = this.getSkills().getSkillByID("effects.lorekeeper_potion");

		if (lorekeeperPotionEffect != null && (!lorekeeperPotionEffect.isSpent() || lorekeeperPotionEffect.getLastFrameUsed() == this.Time.getFrame()))
		{
			this.getSkills().removeByType(this.Const.SkillType.DamageOverTime);
			this.setHitpoints(this.getHitpointsMax());
			lorekeeperPotionEffect.setSpent(true);
			this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + " is reborn by the power of the Lorekeeper!");
		}
		else
		{
			local nineLivesSkill = this.getSkills().getSkillByID("perk.nine_lives");

			if (nineLivesSkill != null && (!nineLivesSkill.isSpent() || nineLivesSkill.getLastFrameUsed() == this.Time.getFrame()))
			{
				this.getSkills().removeByType(this.Const.SkillType.DamageOverTime);
				this.setHitpoints(this.Math.rand(11, 15));
				nineLivesSkill.setSpent(true);
				this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + " has nine lives!");
			}
		}
	}}.MV_onBeforeDeathConfirmed;

	// MV: Added
	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.MV_checkMoraleOnDamageReceived <- { function MV_checkMoraleOnDamageReceived( _skill, _attacker, _hitInfo )
	{
		if (this.getMoraleState() != this.Const.MoraleState.Ignore && _hitInfo.DamageInflictedHitpoints >= this.Const.Morale.OnHitMinDamage && this.getCurrentProperties().IsAffectedByLosingHitpoints)
		{
			if (!this.isPlayerControlled() || !this.getSkills().hasSkill("effects.berserker_mushrooms"))
			{
				this.checkMorale(-1, this.Const.Morale.OnHitBaseDifficulty * (1.0 - this.getHitpoints() / this.getHitpointsMax()) - (_attacker != null && _attacker.getID() != this.getID() ? _attacker.getCurrentProperties().ThreatOnHit : 0), this.Const.MoraleCheckType.Default, "", true);
			}
		}
	}}.MV_checkMoraleOnDamageReceived;

	// MV: Modularized
	// Note: We also hook and redirect lindwurm_tail's custom onDamageReceived implementation
	// to use this modularized version to keep things DRY
	// We also use getter/setter functions for properties, attributes etc instead of the vanilla style of .m.CurrentProperties or .m.Hitpoints
	// so that lindwurm_tail properly accessess the correct fields from the Body instead of itself
	q.onDamageReceived = @() { function onDamageReceived( _attacker, _skill, _hitInfo )
	{
		// MV: Added
		// To allow the current HitInfo to be globally accessible.
		::Const.Tactical.MV_CurrentHitInfo = _hitInfo.weakref();

		if (!this.isAlive() || !this.isPlacedOnMap())
		{
			return 0;
		}

		if (_hitInfo.DamageRegular == 0 && _hitInfo.DamageArmor == 0)
		{
			return 0;
		}

		if (typeof _attacker == "instance")
		{
			_attacker = _attacker.get();
		}

		// TODO: Perhaps extract this into a separate function
		if (_attacker != null && _attacker.isAlive() && _attacker.isPlayerControlled() && !this.isPlayerControlled())
		{
			this.setDiscovered(true);
			this.getTile().addVisibilityForFaction(this.Const.Faction.Player);
			this.getTile().addVisibilityForCurrentEntity();
		}

		if (this.getCurrentProperties().IsImmuneToCriticals || this.getCurrentProperties().IsImmuneToHeadshots)
		{
			_hitInfo.BodyDamageMult = 1.0;
		}

		local p = this.getSkills().buildPropertiesForBeingHit(_attacker, _skill, _hitInfo);
		_hitInfo.MV_PropertiesForBeingHit = p; // MV: Added

		this.getItems().onBeforeDamageReceived(_attacker, _skill, _hitInfo, p);

		this.MV_calcArmorDamageReceived(_skill, _hitInfo); // MV: Extracted
		this.MV_calcHitpointsDamageReceived(_skill, _hitInfo);// MV: Extracted

		// MV: Extracted MV_calcFatigueDamageReceived
		this.setFatigue(this.Math.min(this.getFatigueMax(), this.Math.round(this.getFatigue() + this.MV_calcFatigueDamageReceived(_skill, _hitInfo))));

		this.getSkills().onDamageReceived(_attacker, _hitInfo.DamageInflictedHitpoints, _hitInfo.DamageInflictedArmor);
		// vanilla lindwurm_tail also calls this.m.Racial.onDamageReceived here but I believe that
		// is redundant because the skill_container event should already call that - Midas

		local damage = _hitInfo.DamageInflictedHitpoints;
		local armorDamage = _hitInfo.DamageInflictedArmor;

		if (armorDamage > 0 && !this.isHiddenToPlayer() && _hitInfo.IsPlayingArmorSound)
		{
			local armorHitSound = this.getItems().getAppearance().ImpactSound[_hitInfo.BodyPart];

			if (armorHitSound.len() > 0)
			{
				this.Sound.play(armorHitSound[this.Math.rand(0, armorHitSound.len() - 1)], this.Const.Sound.Volume.ActorArmorHit, this.getPos());
			}

			if (damage < this.Const.Combat.PlayPainSoundMinDamage)
			{
				this.playSound(this.Const.Sound.ActorEvent.NoDamageReceived, this.Const.Sound.Volume.Actor * this.m.SoundVolume[this.Const.Sound.ActorEvent.NoDamageReceived] * this.m.SoundVolumeOverall);
			}
		}

		if (damage > 0)
		{
			if (!this.m.IsAbleToDie && damage >= this.getHitpoints())
			{
				this.setHitpoints(1);
			}
			else
			{
				this.setHitpoints(this.Math.round(this.getHitpoints() - damage));
			}
		}

		// lindwurm_tail does not have this part in vanilla
		if (this.getHitpoints() <= 0)
		{
			// MV: Extracted
			this.MV_onBeforeDeathConfirmed(_attacker, _skill, _hitInfo);
		}

		local fatalityType = this.Const.FatalityType.None;

		if (this.getHitpoints() <= 0)
		{
			this.m.IsDying = true;
			fatalityType = this.MV_getFatalityType(_skill, _hitInfo);
		}

		// TODO: Extract into a separate function?
		if (_hitInfo.DamageDirect < 1.0)
		{
			local overflowDamage = _hitInfo.DamageArmor;

			if (this.getBaseProperties().Armor[_hitInfo.BodyPart] != 0)
			{
				overflowDamage -= this.getBaseProperties().Armor[_hitInfo.BodyPart] * this.getBaseProperties().ArmorMult[_hitInfo.BodyPart];
				local newArmor = this.getBaseProperties().Armor[_hitInfo.BodyPart] * p.ArmorMult[_hitInfo.BodyPart] - _hitInfo.DamageArmor;
				newArmor /= p.ArmorMult[_hitInfo.BodyPart];
				this.getBaseProperties().Armor[_hitInfo.BodyPart] = this.Math.max(0, newArmor);
				// vanilla lindwurm_tail says "natural armor is hit" here
				this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + "\'s armor is hit for [b]" + this.Math.floor(_hitInfo.DamageArmor) + "[/b] damage");
			}

			if (overflowDamage > 0)
			{
				this.getItems().onDamageReceived(overflowDamage, fatalityType, _hitInfo.BodyPart == this.Const.BodyPart.Body ? this.Const.ItemSlot.Body : this.Const.ItemSlot.Head, _attacker);
			}
		}

		// TODO: Extract into a separate function?
		if (this.getFaction() == this.Const.Faction.Player && _attacker != null && _attacker.isAlive())
		{
			this.Tactical.getCamera().quake(_attacker, this, 5.0, 0.16, 0.3);
		}

		if (damage <= 0 && armorDamage >= 0)
		{
			if ((this.m.IsFlashingOnHit || this.getCurrentProperties().IsStunned || this.getCurrentProperties().IsRooted) && !this.isHiddenToPlayer() && _attacker != null && _attacker.isAlive())
			{
				local layers = this.m.ShakeLayers[_hitInfo.BodyPart];
				local recoverMult = 1.0;
				this.Tactical.getShaker().cancel(this);
				this.Tactical.getShaker().shake(this, _attacker.getTile(), this.m.IsShakingOnHit ? 2 : 3, this.Const.Combat.ShakeEffectArmorHitColor, this.Const.Combat.ShakeEffectArmorHitHighlight, this.Const.Combat.ShakeEffectArmorHitFactor, this.Const.Combat.ShakeEffectArmorSaturation, layers, recoverMult);
			}

			this.getSkills().update();
			this.setDirty(true);
			return 0;
		}

		if (damage >= this.Const.Combat.SpawnBloodMinDamage)
		{
			this.spawnBloodDecals(this.getTile());
		}

		if (this.getHitpoints() <= 0)
		{
			this.spawnBloodDecals(this.getTile());
			this.kill(_attacker, _skill, fatalityType);
		}
		else
		{
			if (damage >= this.Const.Combat.SpawnBloodEffectMinDamage)
			{
				local mult = this.Math.maxf(0.75, this.Math.minf(2.0, damage / this.getHitpointsMax() * 3.0));
				this.spawnBloodEffect(this.getTile(), mult);
			}

			// TODO: Extract into a new onDamageReceived function in tactical_state
			if (this.Tactical.State.getStrategicProperties() != null && this.Tactical.State.getStrategicProperties().IsArenaMode && _attacker != null && _attacker.getID() != this.getID())
			{
				local mult = damage / this.getHitpointsMax();

				if (mult >= 0.75)
				{
					this.Sound.play(this.Const.Sound.ArenaBigHit[this.Math.rand(0, this.Const.Sound.ArenaBigHit.len() - 1)], this.Const.Sound.Volume.Tactical * this.Const.Sound.Volume.Arena);
				}
				else if (mult >= 0.25 || this.Math.rand(1, 100) <= 20)
				{
					this.Sound.play(this.Const.Sound.ArenaHit[this.Math.rand(0, this.Const.Sound.ArenaHit.len() - 1)], this.Const.Sound.Volume.Tactical * this.Const.Sound.Volume.Arena);
				}
			}

			if (this.getCurrentProperties().IsAffectedByInjuries && this.m.IsAbleToDie && damage >= this.Const.Combat.InjuryMinDamage && this.getCurrentProperties().ThresholdToReceiveInjuryMult != 0 && _hitInfo.InjuryThresholdMult != 0 && _hitInfo.Injuries != null)
			{
				// MV: Extracted
				local injury = this.MV_applyInjury(_skill, _hitInfo);

				// In vanilla it checks for appliedInjury boolean here but we extracted the injury application into
				// a separate function which returns the injury so we check for the returned injury being null
				if (injury == null)
				{
					if (damage > 0 && !this.isHiddenToPlayer())
					{
						this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + "\'s " + this.Const.Strings.BodyPartName[_hitInfo.BodyPart] + " is hit for [b]" + this.Math.floor(damage) + "[/b] damage");
					}
				}
				else
				{
					if (this.isPlayerControlled() || !this.isHiddenToPlayer())
					{
						this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + "\'s " + this.Const.Strings.BodyPartName[_hitInfo.BodyPart] + " is hit for [b]" + this.Math.floor(damage) + "[/b] damage and suffers " + injury.getNameOnly() + "!");
					}
				}
			}
			else if (damage > 0 && !this.isHiddenToPlayer())
			{
				this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + "\'s " + this.Const.Strings.BodyPartName[_hitInfo.BodyPart] + " is hit for [b]" + this.Math.floor(damage) + "[/b] damage");
			}

			// MV: Extracted
			this.MV_checkMoraleOnDamageReceived(_skill, _attacker, _hitInfo);

			this.getSkills().onAfterDamageReceived();

			// TODO: Extract into a separate function
			if (damage >= this.Const.Combat.PlayPainSoundMinDamage && this.m.Sound[this.Const.Sound.ActorEvent.DamageReceived].len() > 0)
			{
				local volume = 1.0;

				if (damage < this.Const.Combat.PlayPainVolumeMaxDamage)
				{
					volume = damage / this.Const.Combat.PlayPainVolumeMaxDamage;
				}

				this.playSound(this.Const.Sound.ActorEvent.DamageReceived, this.Const.Sound.Volume.Actor * this.m.SoundVolume[this.Const.Sound.ActorEvent.DamageReceived] * this.m.SoundVolumeOverall * volume, this.m.SoundPitch);
			}

			this.getSkills().update();
			this.onUpdateInjuryLayer();

			if ((this.m.IsFlashingOnHit || this.getCurrentProperties().IsStunned || this.getCurrentProperties().IsRooted) && !this.isHiddenToPlayer() && _attacker != null && _attacker.isAlive())
			{
				local layers = this.m.ShakeLayers[_hitInfo.BodyPart];
				local recoverMult = this.Math.minf(1.5, this.Math.maxf(1.0, damage * 2.0 / this.getHitpointsMax()));
				this.Tactical.getShaker().cancel(this);
				this.Tactical.getShaker().shake(this, _attacker.getTile(), this.m.IsShakingOnHit ? 2 : 3, this.Const.Combat.ShakeEffectHitpointsHitColor, this.Const.Combat.ShakeEffectHitpointsHitHighlight, this.Const.Combat.ShakeEffectHitpointsHitFactor, this.Const.Combat.ShakeEffectHitpointsSaturation, layers, recoverMult);
			}

			this.setDirty(true);
		}

		return damage;
	}}.onDamageReceived;

	// MV: Added
	// Extraction of part of vanilla logic from actor.onMovementFinish
	q.MV_checkMoraleOnMovementFinish <- { function MV_checkMoraleOnMovementFinish( _tile )
	{
		local numOfEnemiesAdjacentToMe = _tile.getZoneOfControlCountOtherThan(this.getAlliedFactions());

		if (this.m.CurrentMovementType == this.Const.Tactical.MovementType.Default)
		{
			if (this.getMoraleState() != this.Const.MoraleState.Fleeing)
			{
				for (local i = 0; i < 6; i++)
				{
					if (!_tile.hasNextTile(i))
						continue;

					local otherTile = _tile.getNextTile(i);
					if (!otherTile.IsOccupiedByActor)
						continue;

					local otherActor = otherTile.getEntity();
					local numEnemies = otherTile.getZoneOfControlCountOtherThan(otherActor.getAlliedFactions());

					if (otherActor.m.MaxEnemiesThisTurn < numEnemies && !otherActor.isAlliedWith(this))
					{
						local difficulty = this.Math.maxf(10.0, 50.0 - this.getXPValue() * 0.1);
						// MV: Changed morale check type to the new added MV_Surround type
						otherActor.checkMorale(-1, difficulty, ::Const.MoraleCheckType.MV_Surround);
						otherActor.m.MaxEnemiesThisTurn = numEnemies;
					}
				}
			}
		}
		else if (this.m.CurrentMovementType == this.Const.Tactical.MovementType.Involuntary)
		{
			if (this.m.MaxEnemiesThisTurn < numOfEnemiesAdjacentToMe)
			{
				local difficulty = 40.0;
				// MV: Changed morale check type to the new added MV_Surround type
				this.checkMorale(-1, difficulty, ::Const.MoraleCheckType.MV_Surround);
			}
		}
	}}.MV_checkMoraleOnMovementFinish;

	// MV: Modularized
	q.onMovementFinish = @() { function onMovementFinish( _tile )
	{
		this.m.IsMoving = true;
		this.updateVisibility(_tile, this.getCurrentProperties().getVision(), this.getFaction());

		if (this.Tactical.TurnSequenceBar.getActiveEntity() != null && this.Tactical.TurnSequenceBar.getActiveEntity().getID() != this.getID())
		{
			this.Tactical.TurnSequenceBar.getActiveEntity().updateVisibilityForFaction();
		}

		this.setZoneOfControl(_tile, this.hasZoneOfControl());

		if (!this.m.IsExertingZoneOfOccupation)
		{
			_tile.addZoneOfOccupation(this.getFaction());
			this.m.IsExertingZoneOfOccupation = true;
		}

		if (this.Const.Tactical.TerrainEffect[_tile.Type].len() > 0 && !this.m.Skills.hasSkill(this.Const.Tactical.TerrainEffectID[_tile.Type]))
		{
			this.getSkills().add(this.new(this.Const.Tactical.TerrainEffect[_tile.Type]));
		}

		if (_tile.IsHidingEntity)
		{
			this.getSkills().add(this.new(this.Const.Movement.HiddenStatusEffect));
		}

		local numOfEnemiesAdjacentToMe = _tile.getZoneOfControlCountOtherThan(this.getAlliedFactions());

		// MV: Extracted
		this.MV_checkMoraleOnMovementFinish(_tile);

		this.m.CurrentMovementType = this.Const.Tactical.MovementType.Default;
		this.m.MaxEnemiesThisTurn = this.Math.max(1, numOfEnemiesAdjacentToMe);

		if (this.isPlayerControlled() && this.getMoraleState() > this.Const.MoraleState.Breaking && this.getMoraleState() != this.Const.MoraleState.Ignore && (_tile.SquareCoords.X == 0 || _tile.SquareCoords.Y == 0 || _tile.SquareCoords.X == 31 || _tile.SquareCoords.Y == 31))
		{
			local change = this.getMoraleState() - this.Const.MoraleState.Breaking;
			this.checkMorale(-change, -1000);
		}

		if (this.m.IsEmittingMovementSounds && this.Const.Tactical.TerrainMovementSound[_tile.Subtype].len() != 0)
		{
			local sound = this.Const.Tactical.TerrainMovementSound[_tile.Subtype][this.Math.rand(0, this.Const.Tactical.TerrainMovementSound[_tile.Subtype].len() - 1)];
			this.Sound.play("sounds/" + sound.File, sound.Volume * this.Const.Sound.Volume.TacticalMovement * this.Math.rand(90, 100) * 0.01, this.getPos(), sound.Pitch * this.Math.rand(95, 105) * 0.01);
		}

		this.spawnTerrainDropdownEffect(_tile);

		if (_tile.Properties.Effect != null && _tile.Properties.Effect.IsAppliedOnEnter)
		{
			_tile.Properties.Effect.Callback(_tile, this);
		}

		this.getSkills().onMovementFinished();
		this.getItems().onMovementFinished();
		this.setDirty(true);
		this.m.IsMoving = false;
	}}.onMovementFinish;

	// MV: Modularized
	// Extracted the removal of effects into a new skill_container.MV_onMoraleStateChanged event
	q.setMoraleState = @() { function setMoraleState( _m )
	{
		if (this.m.MoraleState == _m)
		{
			return;
		}

		/*
		This vanilla part is disabled because the removal of these skills is now handled
		directly within those skills thanks to our new skill_container.MV_onMoraleStateChanged event

		NOTE: return_favor_effect does not exist in vanilla codebase so we have not hooked it!

		if (_m == this.Const.MoraleState.Fleeing)
		{
			this.m.Skills.removeByID("effects.shieldwall");
			this.m.Skills.removeByID("effects.spearwall");
			this.m.Skills.removeByID("effects.riposte");
			this.m.Skills.removeByID("effects.return_favor");
			this.m.Skills.removeByID("effects.indomitable");
		}
		*/

		// MV: Added, store oldMoraleState in local var to later pass to skill_container.MV_onMoraleStateChanged
		local oldMoraleState = this.m.MoraleState;

		this.m.MoraleState = _m;
		local morale = this.getSprite("morale");

		if (this.Const.MoraleStateBrush[_m].len() != 0)
		{
			if (_m == this.Const.MoraleState.Confident)
			{
				morale.setBrush(this.m.ConfidentMoraleBrush);
			}
			else
			{
				morale.setBrush(this.Const.MoraleStateBrush[_m]);
			}

			morale.Visible = true;
		}
		else
		{
			morale.Visible = false;
		}

		// MV: Changed
		// vanilla does this.m.Skills.update() here but we trigger our new skill container event which calls update after it
		this.getSkills().MV_onMoraleStateChanged(oldMoraleState);
	}}.setMoraleState;

	// MV: Extracted
	// Part of modularization of actor.checkMorale
	// The logic is the same as the vanilla guard statements at the beginning of that function
	// but we have rewritten the code to be more optimized.
	q.MV_isMoraleCheckValid <- { function MV_isMoraleCheckValid( _change, _type )
	{
		if (this.getMoraleState() == this.Const.MoraleState.Ignore)
		{
			return false;
		}

		if (_change > 0)
		{
			// actor.getMaxMoraleState is an MSU-added function
			if (this.getMoraleState() == this.Const.MoraleState.Confident || this.getMoraleState() >= this.getMaxMoraleState())
			{
				return false;
			}

			if (this.isPlayerControlled())
			{
				local myTile = this.getTile();
				if (myTile.SquareCoords.X == 0 || myTile.SquareCoords.Y == 0 || myTile.SquareCoords.X == 31 || myTile.SquareCoords.Y == 31)
				{
					return false;
				}
			}
		}
		else if (_change < 0 || _change == 1)
		{
			return this.getMoraleState() != this.Const.MoraleState.Fleeing;
		}

		return true;
	}}.MV_isMoraleCheckValid;

	// MV: Extracted
	// Part of modularization of actor.checkMorale
	// The logic is the same as in vanilla to adjust the difficulty of the morale check
	// using the number of adjacent enemies and their Threat.
	q.MV_getMoraleCheckThreat <- { function MV_getMoraleCheckThreat( _change, _type )
	{
		local self = this;
		local adjacentOpponents = ::Tactical.Entities.getAdjacentActors(this.getTile()).filter(@(_, _a) !_a.isAlliedWith(self) && _a.getMoraleState() != ::Const.MoraleState.Fleeing);

		local threatBonus = 0;
		foreach (o in adjacentOpponents)
		{
			threatBonus += o.getCurrentProperties().Threat;
		}

		return adjacentOpponents.len() * ::Const.Morale.OpponentsAdjacentMult + threatBonus;
	}}.MV_getMoraleCheckThreat;

	// MV: Extracted
	// Part of modularization of actor.checkMorale
	// The logic is the same as in vanilla to adjust the difficulty of the morale check
	// using the number of adjacent allies.
	q.MV_getMoraleCheckSupport <- { function MV_getMoraleCheckSupport( _change, _type )
	{
		if (_change > 0)
			return 0;

		local self = this;
		return ::Tactical.Entities.getAdjacentActors(this.getTile()).filter(@(_, _a) _a.isAlliedWith(self) && _a.getMoraleState() != ::Const.MoraleState.Fleeing).len() * ::Const.Morale.AlliesAdjacentMult;
	}}.MV_getMoraleCheckSupport;

	// MV: Modularized
	q.checkMorale = @() { function checkMorale( _change, _difficulty, _type = this.Const.MoraleCheckType.Default, _showIconBeforeMoraleIcon = "", _noNewLine = false )
	{
		if (!this.isAlive() || this.isDying())
		{
			return false;
		}

		// MV: Extracted
		// All the various vanilla guard statements have been pulled into this extracted function
		if (!this.MV_isMoraleCheckValid(_change, _type))
		{
			return false;
		}

		local bravery = this.getBravery() + this.getCurrentProperties().MoraleCheckBravery[_type];
		local mult = this.getCurrentProperties().MoraleCheckBraveryMult[_type];

		// MV: Added we have added callbacks to character properties to modify the bravery
		// via functions based on the _change and _type. These functions are called and applied here.
		foreach (callback in this.getCurrentProperties().MV_MoraleCheckBraveryCallbacks)
		{
			local result = callback(_change, _type);
			bravery += result.Add;
			mult *= result.Mult;
		}
		bravery *= mult;

		// Weird vanilla edge case - no idea what it is for.
		if (bravery > 500)
		{
			if (_change != 0)
				return false;
			else
				return true;
		}

		/*
		This part has been extracted into MV_getMoraleCheckThreat and MV_getMoraleCheckSupport functions

		local myTile = this.getTile();
		local numOpponentsAdjacent = 0;
		local numAlliesAdjacent = 0;
		local threatBonus = 0;

		for( local i = 0; i != 6; i++ )
		{
			if (!myTile.hasNextTile(i))
				continue;

			local tile = myTile.getNextTile(i);

			if (tile.IsOccupiedByActor && tile.getEntity().getMoraleState() != this.Const.MoraleState.Fleeing)
			{
				if (tile.getEntity().isAlliedWith(this))
				{
					numAlliesAdjacent++;
				}
				else
				{
					numOpponentsAdjacent++;
					threatBonus += tile.getEntity().getCurrentProperties().Threat;
				}
			}
		}
		*/

		_difficulty *= this.getCurrentProperties().MoraleEffectMult;

		// MV: Changed
		// Vanilla rewrites the chance equation separately in each if/else block. We extract it out here for better readability
		local chance = ::Math.minf(95, bravery + _difficulty - this.MV_getMoraleCheckThreat(_change, _type) + this.MV_getMoraleCheckSupport(_change, _type));

		if (_change > 0)
		{
			if (this.Math.rand(1, 100) > chance)
			{
				if (this.Math.rand(1, 100) > this.m.CurrentProperties.RerollMoraleChance || this.Math.rand(1, 100) > chance)
				{
					return false;
				}
			}
		}
		else if (_change < 0)
		{
			if (this.Math.rand(1, 100) <= chance)
			{
				return false;
			}

			if (this.Math.rand(1, 100) <= this.m.CurrentProperties.RerollMoraleChance && this.Math.rand(1, 100) <= chance)
			{
				return false;
			}
		}
		else if (this.Math.rand(1, 100) <= chance)
		{
			return true;
		}
		else if (this.Math.rand(1, 100) <= this.m.CurrentProperties.RerollMoraleChance && chance)
		{
			return true;
		}
		else
		{
			return false;
		}

		local oldMoraleState = this.getMoraleState();

		// MV: Use setMoraleState instead of the vanilla this.m.MoraleState =
		this.setMoraleState(this.Math.min(this.Const.MoraleState.Confident, this.Math.max(0, oldMoraleState + _change)));
		// this.m.MoraleState = this.Math.min(this.Const.MoraleState.Confident, this.Math.max(0, this.getMoraleState() + _change));
		this.m.FleeingRounds = 0;

		/* MV: This vanilla part is unnecessary as it is triggered due to us using setMoraleState above

		// if (this.getMoraleState() == this.Const.MoraleState.Confident && oldMoraleState != this.Const.MoraleState.Confident && ("State" in this.World) && this.World.State != null && this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.oath_of_camaraderie")
		// {
		// 	this.World.Statistics.getFlags().increment("OathtakersBrosConfident");
		// }
		*/

		if (oldMoraleState == this.Const.MoraleState.Fleeing && this.m.IsActingEachTurn)
		{
			this.setZoneOfControl(this.getTile(), this.hasZoneOfControl());

			if (this.isPlayerControlled() || !this.isHiddenToPlayer())
			{
				if (_noNewLine)
				{
					this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + " has rallied");
				}
				else
				{
					this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + " has rallied");
				}
			}
		}

		/* MV: This vanilla part is unnecessary as it is triggered due to us using setMoraleState above

		else if (this.getMoraleState() == this.Const.MoraleState.Fleeing)
		{
			this.setZoneOfControl(this.getTile(), this.hasZoneOfControl());
			this.m.Skills.removeByID("effects.shieldwall");
			this.m.Skills.removeByID("effects.spearwall");
			this.m.Skills.removeByID("effects.riposte");
			this.m.Skills.removeByID("effects.return_favor");
			this.m.Skills.removeByID("effects.indomitable");
		}

		local morale = this.getSprite("morale");

		if (this.Const.MoraleStateBrush[this.getMoraleState()].len() != 0)
		{
			if (this.getMoraleState() == this.Const.MoraleState.Confident)
			{
				morale.setBrush(this.m.ConfidentMoraleBrush);
			}
			else
			{
				morale.setBrush(this.Const.MoraleStateBrush[this.getMoraleState()]);
			}

			morale.Visible = true;
		}
		else
		{
			morale.Visible = false;
		}
		*/

		if (this.isPlayerControlled() || !this.isHiddenToPlayer())
		{
			if (_noNewLine)
			{
				this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + this.Const.MoraleStateEvent[this.getMoraleState()]);
			}
			else
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + this.Const.MoraleStateEvent[this.getMoraleState()]);
			}

			if (_showIconBeforeMoraleIcon != "")
			{
				this.Tactical.spawnIconEffect(_showIconBeforeMoraleIcon, this.getTile(), this.Const.Tactical.Settings.SkillIconOffsetX, this.Const.Tactical.Settings.SkillIconOffsetY, this.Const.Tactical.Settings.SkillIconScale, this.Const.Tactical.Settings.SkillIconFadeInDuration, this.Const.Tactical.Settings.SkillIconStayDuration, this.Const.Tactical.Settings.SkillIconFadeOutDuration, this.Const.Tactical.Settings.SkillIconMovement);
			}

			if (_change > 0)
			{
				this.Tactical.spawnIconEffect(this.Const.Morale.MoraleUpIcon, this.getTile(), this.Const.Tactical.Settings.SkillIconOffsetX, this.Const.Tactical.Settings.SkillIconOffsetY, this.Const.Tactical.Settings.SkillIconScale, this.Const.Tactical.Settings.SkillIconFadeInDuration, this.Const.Tactical.Settings.SkillIconStayDuration, this.Const.Tactical.Settings.SkillIconFadeOutDuration, this.Const.Tactical.Settings.SkillIconMovement);
			}
			else
			{
				this.Tactical.spawnIconEffect(this.Const.Morale.MoraleDownIcon, this.getTile(), this.Const.Tactical.Settings.SkillIconOffsetX, this.Const.Tactical.Settings.SkillIconOffsetY, this.Const.Tactical.Settings.SkillIconScale, this.Const.Tactical.Settings.SkillIconFadeInDuration, this.Const.Tactical.Settings.SkillIconStayDuration, this.Const.Tactical.Settings.SkillIconFadeOutDuration, this.Const.Tactical.Settings.SkillIconMovement);
			}
		}

		// this.m.Skills.update(); // Unnecessary due to our use of setMoraleState above which does a skill container update
		this.setDirty(true);

		if (this.getMoraleState() == this.Const.MoraleState.Fleeing && this.Tactical.TurnSequenceBar.getActiveEntity() != this)
		{
			this.Tactical.TurnSequenceBar.pushEntityBack(this.getID());
		}

		if (this.getMoraleState() == this.Const.MoraleState.Fleeing)
		{
			local actors = this.Tactical.Entities.getInstancesOfFaction(this.getFaction());

			if (actors != null)
			{
				foreach( a in actors )
				{
					if (a.getID() != this.getID())
					{
						a.onOtherActorFleeing(this);
					}
				}
			}
		}

		return true;
	}}.checkMorale;
});
