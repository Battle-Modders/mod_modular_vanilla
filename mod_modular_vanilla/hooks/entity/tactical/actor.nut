::ModularVanilla.MH.hook("scripts/entity/tactical/actor", function (q) {
// part of affordability preview system START
	// MV: Added
	q.m.MV_IsPreviewing <- false;
	q.m.MV_CostsPreview <- null;
	q.m.MV_PreviewSkill <- null;
	q.m.MV_PreviewMovement <- null;

	// MV: Added
	q.resetPreview <- function()
	{
		this.m.MV_IsPreviewing = false;
		this.m.MV_CostsPreview = null;
		this.m.MV_PreviewSkill = null;
		this.m.MV_PreviewMovement = null;
		this.getSkills().update();
	}

	// MV: Added
	q.isPreviewing <- function()
	{
		return this.m.MV_IsPreviewing;
	}

	// MV: Added
	q.getPreviewSkill <- function()
	{
		return this.m.MV_PreviewSkill;
	}

	// MV: Added
	q.getPreviewMovement <- function()
	{
		return this.m.MV_PreviewMovement;
	}

	// MV: Added
	q.getCostsPreview <- function()
	{
		return this.m.MV_CostsPreview;
	}

	// MV: Changed
	// We modify all these below functions to prevent them
	// from setting the fields during the skill_container.update() function
	// during a preview type update -- part of the affordability preview system
	q.setActionPoints = @(__original) function( _a )
	{
		if (!this.isPreviewing())
			return __original(_a);
	}

	q.setFatigue = @(__original) function( _f )
	{
		if (!this.isPreviewing())
			return __original(_f);
	}

	q.setHitpointsPct = @(__original) function( _h )
	{
		if (!this.isPreviewing())
			return __original(_h);
	}

	q.onSkillsUpdated = @(__original) function()
	{
		if (!this.isPreviewing())
			return __original();
	}

	q.updateOverlay = @(__original) function()
	{
		if (!this.isPreviewing())
			return __original();
	}

	q.setDirty = @(__original) function( _value )
	{
		if (!this.isPreviewing())
			return __original(_value);
	}
// part of affordability preview system END

	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.calcArmorDamageReceived <- function( _skill, _hitInfo )
	{
		local p = _hitInfo.PropertiesForBeingHit;
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
			// MV: ArmorRemaining is a new field added by us
			_hitInfo.ArmorRemaining = p.Armor[_hitInfo.BodyPart] * p.ArmorMult[_hitInfo.BodyPart];
			armorDamage = this.Math.min(_hitInfo.ArmorRemaining, _hitInfo.DamageArmor);
			_hitInfo.ArmorRemaining -= armorDamage;
			_hitInfo.DamageInflictedArmor = this.Math.max(0, armorDamage);
		}

		return _hitInfo.DamageInflictedArmor;
	}

	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.calcHitpointsDamageReceived <- function( _skill, _hitInfo )
	{
		local p = _hitInfo.PropertiesForBeingHit;
		local dmgMult = p.DamageReceivedTotalMult;
		if (_skill != null)
		{
			dmgMult *= _skill.isRanged() ? p.DamageReceivedRangedMult : p.DamageReceivedMeleeMult;
		}

		_hitInfo.DamageRegular -= p.DamageRegularReduction;
		_hitInfo.DamageRegular *= p.DamageReceivedRegularMult * dmgMult;

		local damage = 0;
		damage += this.Math.maxf(0.0, _hitInfo.DamageRegular * _hitInfo.DamageDirect * p.DamageReceivedDirectMult - _hitInfo.ArmorRemaining * this.Const.Combat.ArmorDirectDamageMitigationMult);

		if (_hitInfo.ArmorRemaining <= 0 || _hitInfo.DamageDirect >= 1.0)
		{
			damage += this.Math.max(0, _hitInfo.DamageRegular * this.Math.maxf(0.0, 1.0 - _hitInfo.DamageDirect * p.DamageReceivedDirectMult) - _hitInfo.DamageInflictedArmor);
		}

		damage *= _hitInfo.BodyDamageMult;
		_hitInfo.DamageInflictedHitpoints = this.Math.max(0, this.Math.max(this.Math.round(damage), this.Math.min(this.Math.round(_hitInfo.DamageMinimum), this.Math.round(_hitInfo.DamageMinimum * p.DamageReceivedTotalMult))));

		return _hitInfo.DamageInflictedHitpoints;
	}

	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.calcFatigueDamageReceived <- function( _skill, _hitInfo )
	{
		local p = _hitInfo.PropertiesForBeingHit;
		_hitInfo.DamageFatigue *= p.FatigueEffectMult;
		return _hitInfo.DamageFatigue * p.FatigueReceivedPerHitMult * this.getCurrentProperties().FatigueLossOnAnyAttackMult;
	}

	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.getFatalityType <- function( _skill, _hitInfo )
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
	}

	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.onInjuryReceived <- function( _injury )
	{
		if (this.isPlayerControlled() && this.isKindOf(this, "player"))
		{
			this.worsenMood(this.Const.MoodChange.Injury, "Suffered an injury");

			if (("State" in this.World) && this.World.State != null && this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.oath_of_sacrifice")
			{
				this.World.Statistics.getFlags().increment("OathtakersInjuriesSuffered");
			}
		}
	}

	// Returns the injury if an injury is successfully applied, otherwise returns null
	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.applyInjury <- function( _skill, _hitInfo )
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
				this.onInjuryReceived(injury);
				return injury;
			}
			else
			{
				potentialInjuries.remove(r);
			}
		}
	}

	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.onBeforeDeathConfirmed <- function( _attacker, _skill, _hitInfo )
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
	}

	// Extraction of part of vanilla logic from actor.onDamageReceived
	q.checkMoraleOnDamageReceived <- function( _skill, _attacker, _hitInfo )
	{
		if (this.getMoraleState() != this.Const.MoraleState.Ignore && _hitInfo.DamageInflictedHitpoints >= this.Const.Morale.OnHitMinDamage && this.getCurrentProperties().IsAffectedByLosingHitpoints)
		{
			if (!this.isPlayerControlled() || !this.getSkills().hasSkill("effects.berserker_mushrooms"))
			{
				this.checkMorale(-1, this.Const.Morale.OnHitBaseDifficulty * (1.0 - this.getHitpoints() / this.getHitpointsMax()) - (_attacker != null && _attacker.getID() != this.getID() ? _attacker.getCurrentProperties().ThreatOnHit : 0), this.Const.MoraleCheckType.Default, "", true);
			}
		}
	}

	// MV: Modularized
	// Note: We also hook and redirect lindwurm_tail's custom onDamageReceived implementation
	// to use this modularized version to keep things DRY
	// We also use getter/setter functions for properties, attributes etc instead of the vanilla style of .m.CurrentProperties or .m.Hitpoints
	// so that lindwurm_tail properly accessess the correct fields from the Body instead of itself
	q.onDamageReceived = @() function( _attacker, _skill, _hitInfo )
	{
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

		// MV: Extracted - Steel Brow part from vanilla has been moved to perk_steel_brow.onBeforeDamageReceived

		local p = this.getSkills().buildPropertiesForBeingHit(_attacker, _skill, _hitInfo);
		_hitInfo.PropertiesForBeingHit = p; // MV: Added

		this.getItems().onBeforeDamageReceived(_attacker, _skill, _hitInfo, p);

		this.calcArmorDamageReceived(_skill, _hitInfo); // MV: Extracted
		this.calcHitpointsDamageReceived(_skill, _hitInfo);// MV: Extracted

		// MV: Extracted calcFatigueDamageReceived
		this.setFatigue(this.Math.min(this.getFatigueMax(), this.Math.round(this.getFatigue() + this.calcFatigueDamageReceived(_skill, _hitInfo))));

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
			this.onBeforeDeathConfirmed(_attacker, _skill, _hitInfo);
		}

		local fatalityType = this.Const.FatalityType.None;

		if (this.getHitpoints() <= 0)
		{
			this.m.IsDying = true;
			fatalityType = this.getFatalityType(_skill, _hitInfo);
		}

		// TODO: Extract into a separate function?
		if (_hitInfo.DamageDirect < 1.0)
		{
			local overflowDamage = _hitInfo.DamageArmor;

			if (this.getBaseProperties().Armor[_hitInfo.BodyPart] != 0)
			{
				overflowDamage -= this.getBaseProperties().Armor[_hitInfo.BodyPart] * this.getBaseProperties().ArmorMult[_hitInfo.BodyPart];
				this.getBaseProperties().Armor[_hitInfo.BodyPart] = this.Math.max(0, this.getBaseProperties().Armor[_hitInfo.BodyPart] * this.getBaseProperties().ArmorMult[_hitInfo.BodyPart] - _hitInfo.DamageArmor);
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
				local injury = this.applyInjury(_skill, _hitInfo);

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
			this.checkMoraleOnDamageReceived(_skill, _attacker, _hitInfo);

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
	}

	// Extraction of part of vanilla logic from actor.onMovementFinish
	q.onMovementFinish_checkMorale <- function( _tile )
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
						// MV: Changed morale check type to the new added MV Surround type
						otherActor.checkMorale(-1, difficulty, ::Const.MoraleCheckType.Surround);
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
				// MV: Changed morale check type to the new added MV Surround type
				this.checkMorale(-1, difficulty, ::Const.MoraleCheckType.Surround);
			}
		}
	}

	// MV: Modularized
	q.onMovementFinish = @() function( _tile )
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
		this.onMovementFinish_checkMorale(_tile);

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

		this.getSkills().update();
		this.getItems().onMovementFinished();
		this.setDirty(true);
		this.m.IsMoving = false;
	}
});
