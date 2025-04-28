::ModularVanilla.MH.hook("scripts/skills/skill", function (q) {
	// MV: Added
	// part of player_party.updateStrength modularization
	q.MV_getPlayerPartyStrengthMult <- function()
	{
		return 1.0;
	}

	// MV: Added
	// Part of the actor.interrupt framework
	q.onActorInterrupted <- function()
	{
	}

	// MV: Added
	// skill_container event that is triggered from onAdded of disarmed_effect
	// but modders can also manually call this from other places as necessary.
	q.MV_onDisarmed <- function()
	{
	}

	// MV: Added
	// Part of skill.onScheduledTargetHit modularization.
	// But useful on its own as well.
	q.MV_getDamageRegular <- function( _properties, _targetEntity = null )
	{
		local damage = ::Math.rand(_properties.DamageRegularMin, _properties.DamageRegularMax) * _properties.DamageRegularMult;
		if (_targetEntity != null && _targetEntity.isPlacedOnMap() && !::MSU.isNull(this.getContainer()) && this.getContainer().getActor().isPlacedOnMap())
		{
			damage = ::Math.max(0, damage + this.getContainer().getActor().getTile().getDistanceTo(_targetEntity.getTile()) * _properties.DamageAdditionalWithEachTile);
		}
		return damage * _properties.DamageTotalMult * (this.isRanged() ? _properties.RangedDamageMult : _properties.MeleeDamageMult);
	}

	// MV: Added
	// Part of skill.onScheduledTargetHit modularization.
	// But useful on its own as well.
	q.MV_getDamageArmor <- function( _properties, _targetEntity = null )
	{
		local damage = ::Math.rand(_properties.DamageRegularMin, _properties.DamageRegularMax) * _properties.DamageArmorMult;
		if (_targetEntity != null && _targetEntity.isPlacedOnMap() && !::MSU.isNull(this.getContainer()) && this.getContainer().getActor().isPlacedOnMap())
		{
			damage = ::Math.max(0, damage + this.getContainer().getActor().getTile().getDistanceTo(_targetEntity.getTile()) * _properties.DamageAdditionalWithEachTile);
		}
		return damage * _properties.DamageTotalMult * (this.isRanged() ? _properties.RangedDamageMult : _properties.MeleeDamageMult);
	}

	// MV: Added
	// Part of skill.onScheduledTargetHit modularization.
	// But useful on its own as well.
	q.MV_getDamageDirect <- function( _properties, _targetEntity = null )
	{
		return ::Math.minf(1.0, _properties.DamageDirectMult * (this.getDirectDamage() + _properties.DamageDirectAdd + (this.isRanged() ? _properties.DamageDirectRangedAdd : _properties.DamageDirectMeleeAdd)));
	}

	// MV: Added
	// Part of skill.attackEntity modularization.
	// But useful on its own as well.
	q.MV_getDiversionChance <- function( _targetEntity, _propertiesForUse = null, _propertiesForDefense = null )
	{
		if (!this.m.IsRanged || this.m.MaxRangeBonus <= 1)
			return 0.0;

		local user = this.getContainer().getActor();
		local userTile = user.getTile();

		if (userTile.getDistanceTo(_targetEntity.getTile()) <= 1)
			return 0.0;

		if (this.Const.Tactical.Common.getBlockedTiles(userTile, _targetEntity.getTile(), user.getFaction(), true).len() != 0)
		{
			if (_propertiesForUse == null)
				_propertiesForUse = this.getContainer().buildPropertiesForUse(this, _targetEntity);

			return this.Const.Combat.RangedAttackBlockedChance * _propertiesForUse.RangedAttackBlockedChanceMult;
		}

		return 0.0;
	}

	// MV: Added
	// Part of skill.attackEntity modularization.
	q.MV_getDiversionTarget <- function( _user, _targetEntity, _propertiesForUse = null )
	{
		if (_propertiesForUse == null)
			_propertiesForUse = this.getContainer().buildPropertiesForUse(this, _targetEntity);

		local blockedTiles = ::Const.Tactical.Common.getBlockedTiles(_user.getTile(), _targetEntity.getTile(), _user.getFaction());

		if (blockedTiles.len() != 0 && this.Math.rand(1, 100) <= this.Math.ceil(this.Const.Combat.RangedAttackBlockedChance * _propertiesForUse.RangedAttackBlockedChanceMult * 100))
		{
			return blockedTiles[this.Math.rand(0, blockedTiles.len() - 1)].getEntity();
		}
	}

	// MV: Added
	// Part of skill.attackEntity modularization.
	q.MV_printAttackToLog <- function( _attackInfo )
	{
		this.Tactical.EventLog.log_newline();
		if (_attackInfo.IsAstray)
		{
			if (this.isUsingHitchance())
			{
				if (_attackInfo.Roll <= _attackInfo.ChanceToHit)
				{
					this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(_attackInfo.User) + " uses " + this.getName() + " and the shot goes astray and hits " + this.Const.UI.getColorizedEntityName(_attackInfo.Target) + " (Chance: " + _attackInfo.ChanceToHit + ", Rolled: " + _attackInfo.Roll + ")");
				}
				else
				{
					this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(_attackInfo.User) + " uses " + this.getName() + " and the shot goes astray and misses " + this.Const.UI.getColorizedEntityName(_attackInfo.Target) + " (Chance: " + _attackInfo.ChanceToHit + ", Rolled: " + _attackInfo.Roll + ")");
				}
			}
			else
			{
				this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(_attackInfo.User) + " uses " + this.getName() + " and the shot goes astray and hits " + this.Const.UI.getColorizedEntityName(_attackInfo.Target));
			}
		}
		else if (this.isUsingHitchance())
		{
			if (_attackInfo.Roll <= _attackInfo.ChanceToHit)
			{
				this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(_attackInfo.User) + " uses " + this.getName() + " and hits " + this.Const.UI.getColorizedEntityName(_attackInfo.Target) + " (Chance: " + _attackInfo.ChanceToHit + ", Rolled: " + _attackInfo.Roll + ")");
			}
			else
			{
				this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(_attackInfo.User) + " uses " + this.getName() + " and misses " + this.Const.UI.getColorizedEntityName(_attackInfo.Target) + " (Chance: " + _attackInfo.ChanceToHit + ", Rolled: " + _attackInfo.Roll + ")");
			}
		}
		else
		{
			this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(_attackInfo.User) + " uses " + this.getName() + " and hits " + this.Const.UI.getColorizedEntityName(_attackInfo.Target));
		}
	}

	// MV: Added
	// Part of skill.attackEntity modularization.
	// TODO - this is temporary, will be moved to a modularization of shields
	q.MV_getShieldBonus <- function( _entity )
	{
		local ret = 0;

		local shield = _entity.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand);

		if (shield != null && shield.isItemType(this.Const.Items.ItemType.Shield))
		{
			ret = (this.m.IsRanged ? shield.getRangedDefense() : shield.getMeleeDefense()) * (_entity.getCurrentProperties().IsSpecializedInShields ? 1.25 : 1.0);

			if (_entity.getSkills().hasSkill("effects.shieldwall"))
			{
				ret = ret * 2;
			}
		}
		return ret;
	}

	// MV: Added
	// Part of skill.attackEntity modularization.
	// This is meant to be the definitive function to use by modders for getting a skill's hitchance.
		// In vanilla the skill.getHitchance function is primarily a cosmetic function used to display the
		// hitchance in the hit factors tooltip.
		// Therefore, for ranged skills it "considers the chance of diversion" and shows the hit chance based on that.
		// Vanilla calculates the actual hit chance manually using mostly duplicate code directly inside skill.attackEntity
		// with the main difference being that the diversion chance is not considered.
		// So we implement our own MV_getHitchance function which has additional parameters for considering diversion
		// and we redirect the vanilla function to our modular function by default. This keeps things DRY.
	q.MV_getHitchance <- function( _targetEntity, _considerDiversion = true, _propertiesForUse = null, _propertiesForDefense = null )
	{
		if (!_targetEntity.isAttackable())
		{
			return 0;
		}

		if (!this.isUsingHitchance())
		{
			return 100;
		}

		local user = this.m.Container.getActor();

		if (_propertiesForUse == null)
			_propertiesForUse = this.m.Container.buildPropertiesForUse(this, _targetEntity);

		if (_propertiesForDefense == null)
			_propertiesForDefense = _targetEntity.getSkills().buildPropertiesForDefense(user, this);

		local skill = this.m.IsRanged ? _propertiesForUse.RangedSkill * _propertiesForUse.RangedSkillMult : _propertiesForUse.MeleeSkill * _propertiesForUse.MeleeSkillMult;
		local defense = _targetEntity.getDefense(user, this, _propertiesForDefense);
		local levelDifference = _targetEntity.getTile().Level - user.getTile().Level;
		local distanceToTarget = user.getTile().getDistanceTo(_targetEntity.getTile());
		local toHit = skill - defense;

		if (this.m.IsRanged)
		{
			toHit = toHit + (distanceToTarget - this.m.MinRange) * _propertiesForUse.HitChanceAdditionalWithEachTile * _propertiesForUse.HitChanceWithEachTileMult;
		}

		if (levelDifference < 0)
		{
			toHit = toHit + this.Const.Combat.LevelDifferenceToHitBonus;
		}
		else
		{
			toHit = toHit + this.Const.Combat.LevelDifferenceToHitMalus * levelDifference;
		}

		toHit = toHit * _propertiesForUse.TotalAttackToHitMult;
		toHit = toHit + this.Math.max(0, 100 - toHit) * (1.0 - _propertiesForDefense.TotalDefenseToHitMult);

		local userTile = user.getTile();

		if (_considerDiversion)
		{
			toHit = ::Math.floor(toHit * (1.0 - this.MV_getDiversionChance(_targetEntity, _propertiesForUse, _propertiesForDefense)));
		}

		return this.Math.max(::Const.Combat.MV_HitChanceMin, this.Math.min(::Const.Combat.MV_HitChanceMax, toHit));
	}

	// MV: Changed
	// See comment on MV_getHitchance
	q.getHitchance = @() function( _targetEntity )
	{
		return this.MV_getHitchance(_targetEntity);
	}

	// MV: Added
	// Part of skill.attackEntity modularization.
	q.MV_onAttackEntityHit <- function( _attackInfo )
	{
		this.getContainer().setBusy(true);
		local distanceToTarget = _attackInfo.User.getTile().getDistanceTo(_attackInfo.Target.getTile());

		local info = {
			Skill = this,
			Container = this.getContainer(),
			User = _attackInfo.User,
			TargetEntity = _attackInfo.Target,
			Properties = _attackInfo.PropertiesForUse != null ? _attackInfo.PropertiesForUse : _attackInfo.User.buildPropertiesForUse(this, _attackInfo.Target),
			DefenderProperties = _attackInfo.PropertiesForDefense != null ? _attackInfo.PropertiesForDefense : _attackInfo.Target.buildPropertiesForDefense(_attackInfo.User, this),
			DistanceToTarget = distanceToTarget
		};

		if (this.m.IsShowingProjectile && this.m.ProjectileType != 0 && distanceToTarget >= this.Const.Combat.SpawnProjectileMinDist && (!_attackInfo.User.isHiddenToPlayer() || !_attackInfo.Target.isHiddenToPlayer()))
		{
			local flip = !this.m.IsProjectileRotated && _attackInfo.Target.getPos().X > _attackInfo.User.getPos().X;
			local time = this.Tactical.spawnProjectileEffect(this.Const.ProjectileSprite[this.m.ProjectileType], _attackInfo.User.getTile(), _attackInfo.Target.getTile(), 1.0, this.m.ProjectileTimeScale, this.m.IsProjectileRotated, flip);
			this.Time.scheduleEvent(this.TimeUnit.Virtual, time, this.onScheduledTargetHit, info);

			if (this.m.SoundOnHit.len() != 0)
			{
				this.Time.scheduleEvent(this.TimeUnit.Virtual, time + this.m.SoundOnHitDelay, this.onPlayHitSound.bindenv(this), {
					Sound = this.m.SoundOnHit[this.Math.rand(0, this.m.SoundOnHit.len() - 1)],
					Pos = _attackInfo.Target.getPos()
				});
			}
		}
		else
		{
			// TODO: Perhaps tactical state should have a new `.onAttackMissed` function which can be called here
			// and these arena sounds can be triggered from there.
			if (this.m.SoundOnHit.len() != 0)
			{
				this.Sound.play(this.m.SoundOnHit[this.Math.rand(0, this.m.SoundOnHit.len() - 1)], this.Const.Sound.Volume.Skill * this.m.SoundVolume, _attackInfo.Target.getPos());
			}

			if (this.Tactical.State.getStrategicProperties() != null && this.Tactical.State.getStrategicProperties().IsArenaMode && _attackInfo.ChanceToHit <= 15)
			{
				this.Sound.play(this.Const.Sound.ArenaShock[this.Math.rand(0, this.Const.Sound.ArenaShock.len() - 1)], this.Const.Sound.Volume.Tactical * this.Const.Sound.Volume.Arena);
			}

			this.onScheduledTargetHit(info);
		}
	}

	// MV: Added
	// Part of skill.attackEntity modularization.
	q.MV_onAttackEntityMissed <- function( _attackInfo )
	{
		local distanceToTarget = _attackInfo.User.getTile().getDistanceTo(_attackInfo.Target.getTile());
		local shield = _attackInfo.Target.getItems().getItemAtSlot(::Const.ItemSlot.Offhand);
		local shieldBonus = this.MV_getShieldBonus(_attackInfo.Target);

		_attackInfo.Target.onMissed(_attackInfo.User, this, this.m.IsShieldRelevant && shield != null && _attackInfo.Roll <= _attackInfo.ChanceToHit + shieldBonus * 2);
		this.m.Container.onTargetMissed(this, _attackInfo.Target);
		local prohibitDiversion = false;

		if (_attackInfo.AllowDiversion && this.m.IsRanged && !_attackInfo.User.isPlayerControlled() && this.Math.rand(1, 100) <= 25 && distanceToTarget > 2)
		{
			local targetTile = _attackInfo.Target.getTile();

			for (local i = 0; i < ::Const.Direction.COUNT; i++ )
			{
				if (targetTile.hasNextTile(i))
				{
					local tile = targetTile.getNextTile(i);
					if (!tile.IsEmpty && tile.IsOccupiedByActor && tile.getEntity().isAlliedWith(_attackInfo.User))
					{
						prohibitDiversion = true;
						break;
					}
				}
			}
		}

		// TODO: Everything from `local prohibitDiversion = false` to this if statement should be extracted into a new function e.g. `attackMissed_isGoingToDivert`
		if (!prohibitDiversion && _attackInfo.AllowDiversion && this.m.IsRanged && !(this.m.IsShieldRelevant && shield != null && _attackInfo.Roll <= _attackInfo.ChanceToHit + shieldBonus * 2) && distanceToTarget > 2)
		{
			this.divertAttack(_attackInfo.User, _attackInfo.Target);
		}
		// TODO: This should be extracted into a new `attackMissed_isGoingToHitShield` function
		else if (this.m.IsShieldRelevant && shield != null && _attackInfo.Roll <= _attackInfo.ChanceToHit + shieldBonus * 2)
		{
			// TODO: The contents of this if block should be extracted into a new `attackMissed_hitShield` function
			local info = {
				Skill = this,
				User = _attackInfo.User,
				TargetEntity = _attackInfo.Target,
				Shield = shield
			};

			if (this.m.IsShowingProjectile && this.m.ProjectileType != 0)
			{
				local divertTile = _attackInfo.Target.getTile();
				local flip = !this.m.IsProjectileRotated && _attackInfo.Target.getPos().X > _attackInfo.User.getPos().X;
				local time = 0;

				if (_attackInfo.User.getTile().getDistanceTo(divertTile) >= this.Const.Combat.SpawnProjectileMinDist)
				{
					time = this.Tactical.spawnProjectileEffect(this.Const.ProjectileSprite[this.m.ProjectileType], _attackInfo.User.getTile(), divertTile, 1.0, this.m.ProjectileTimeScale, this.m.IsProjectileRotated, flip);
				}

				this.Time.scheduleEvent(this.TimeUnit.Virtual, time, this.onShieldHit, info);
			}
			else
			{
				this.onShieldHit(info);
			}
		}
		// TODO: This should be extracted into a new `attackMissed_fullMiss` function
		else
		{
			if (this.m.SoundOnMiss.len() != 0)
			{
				this.Sound.play(this.m.SoundOnMiss[this.Math.rand(0, this.m.SoundOnMiss.len() - 1)], this.Const.Sound.Volume.Skill * this.m.SoundVolume, _attackInfo.Target.getPos());
			}

			if (this.m.IsShowingProjectile && this.m.ProjectileType != 0)
			{
				local divertTile = _attackInfo.Target.getTile();
				local flip = !this.m.IsProjectileRotated && _attackInfo.Target.getPos().X > _attackInfo.User.getPos().X;

				if (_attackInfo.User.getTile().getDistanceTo(divertTile) >= this.Const.Combat.SpawnProjectileMinDist)
				{
					this.Tactical.spawnProjectileEffect(this.Const.ProjectileSprite[this.m.ProjectileType], _attackInfo.User.getTile(), divertTile, 1.0, this.m.ProjectileTimeScale, this.m.IsProjectileRotated, flip);
				}
			}

			// TODO: Perhaps tactical state should have a new `.onAttackMissed` function which can be called here
			// and these arena sounds can be triggered from there.
			if (this.Tactical.State.getStrategicProperties() != null && this.Tactical.State.getStrategicProperties().IsArenaMode)
			{
				if (_attackInfo.ChanceToHit >= 90 || _attackInfo.Target.getHitpointsPct() <= 0.1)
				{
					this.Sound.play(this.Const.Sound.ArenaMiss[this.Math.rand(0, this.Const.Sound.ArenaBigMiss.len() - 1)], this.Const.Sound.Volume.Tactical * this.Const.Sound.Volume.Arena);
				}
				else if (this.Math.rand(1, 100) <= 20)
				{
					this.Sound.play(this.Const.Sound.ArenaMiss[this.Math.rand(0, this.Const.Sound.ArenaMiss.len() - 1)], this.Const.Sound.Volume.Tactical * this.Const.Sound.Volume.Arena);
				}
			}
		}
	}

	// MV: Added
	// Part of skill.attackEntity modularization.
	q.MV_onAttackRolled <- function( _attackInfo )
	{
		if (("Assets" in this.World) && this.World.Assets != null && this.World.Assets.getCombatDifficulty() == 0)
		{
			if (_attackInfo.User.isPlayerControlled())
			{
				_attackInfo.Roll = this.Math.max(1, _attackInfo.Roll - 5);
			}
			else if (_attackInfo.Target.isPlayerControlled())
			{
				_attackInfo.Roll = this.Math.min(100, _attackInfo.Roll + 5);
			}
		}
	}

	// MV: Added
	// Part of skill.attackEntity modularization.
	q.MV_doAttackShake <- function( _attackInfo )
	{
		if (this.m.IsDoingAttackMove && !_attackInfo.User.isHiddenToPlayer() && !_attackInfo.Target.isHiddenToPlayer())
		{
			this.Tactical.getShaker().cancel(_attackInfo.User);

			if (this.m.IsDoingForwardMove)
			{
				this.Tactical.getShaker().shake(_attackInfo.User, _attackInfo.Target.getTile(), 5);
			}
			else
			{
				local otherDir = _attackInfo.Target.getTile().getDirectionTo(_attackInfo.User.getTile());

				if (_attackInfo.User.getTile().hasNextTile(otherDir))
				{
					this.Tactical.getShaker().shake(_attackInfo.User, _attackInfo.User.getTile().getNextTile(otherDir), 6);
				}
			}
		}
	}

	// MV: Modularized
	// The logic has been extracted into several smaller functions.
	// A new MV_AttackInfo object is used and passed around to functions to carry and develop information about the attack.
	q.attackEntity = @() function( _user, _targetEntity, _allowDiversion = true )
	{
		if (_targetEntity != null && !_targetEntity.isAlive())
		{
			return false;
		}

		local attackInfo = clone ::Const.Tactical.MV_AttackInfo;
		::Const.Tactical.MV_CurrentAttackInfo = attackInfo.weakref();
		attackInfo.User = _user;
		attackInfo.Target = _targetEntity;
		attackInfo.AllowDiversion = _allowDiversion;

		local properties = this.m.Container.buildPropertiesForUse(this, _targetEntity);
		attackInfo.PropertiesForUse = properties;

		local userTile = _user.getTile();
		local astray = false;
		if (_allowDiversion && this.isRanged() && userTile.getDistanceTo(_targetEntity.getTile()) > 1)
		{
			local astrayTarget = this.MV_getDiversionTarget(_user, _targetEntity, properties);
			if (astrayTarget != null)
			{
				_allowDiversion = false;
				astray = true;
				_targetEntity = astrayTarget;

				attackInfo.AllowDiversion = false;
				attackInfo.IsAstray = true;
				attackInfo.Target = _targetEntity;
			}
		}

		if (!_targetEntity.isAttackable())
		{
			if (this.m.IsShowingProjectile && this.m.ProjectileType != 0)
			{
				local flip = !this.m.IsProjectileRotated && _targetEntity.getPos().X > _user.getPos().X;

				if (_user.getTile().getDistanceTo(_targetEntity.getTile()) >= this.Const.Combat.SpawnProjectileMinDist)
				{
					this.Tactical.spawnProjectileEffect(this.Const.ProjectileSprite[this.m.ProjectileType], _user.getTile(), _targetEntity.getTile(), 1.0, this.m.ProjectileTimeScale, this.m.IsProjectileRotated, flip);
				}
			}

			return false;
		}

		local defenderProperties = _targetEntity.getSkills().buildPropertiesForDefense(_user, this);
		attackInfo.PropertiesForDefense = defenderProperties;

		local defense = _targetEntity.getDefense(_user, this, defenderProperties);
		local levelDifference = _targetEntity.getTile().Level - _user.getTile().Level;
		local distanceToTarget = _user.getTile().getDistanceTo(_targetEntity.getTile());

		local toHit;
		if (!this.isUsingHitchance())
		{
			toHit = 100;
		}
		else if (!_targetEntity.isAbleToDie() && _targetEntity.getHitpoints() == 1)
		{
			toHit = 0;
		}
		else
		{
			toHit = this.MV_getHitchance(_targetEntity, false, properties, defenderProperties);

			if (this.m.IsRanged && !_allowDiversion && this.m.IsShowingProjectile)
			{
				toHit = this.Math.max(::Const.Combat.MV_HitChanceMin, this.Math.min(::Const.Combat.MV_HitChanceMax, toHit + ::Const.Combat.MV_DiversionHitChanceAdd));
				properties.DamageTotalMult *= ::Const.Combat.MV_DiversionDamageMult;
			}

			// if (defense > -100 && skill > -100)
			// {
			// 	toHit = this.Math.max(5, this.Math.min(95, toHit));
			// }
		}

		attackInfo.ChanceToHit = toHit;

		attackInfo.Roll = this.Math.rand(1, 100);

		this.MV_onAttackRolled(attackInfo);

		this.MV_doAttackShake(attackInfo);

		_targetEntity.onAttacked(_user);

		if (!_user.isHiddenToPlayer() && !_targetEntity.isHiddenToPlayer())
		{
			this.MV_printAttackToLog(attackInfo);
		}

		local isHit = attackInfo.Roll <= attackInfo.ChanceToHit;

		if (isHit && this.Math.rand(1, 100) <= _targetEntity.getCurrentProperties().RerollDefenseChance)
		{
			attackInfo.Roll = ::Math.rand(1, 100);
			isHit = attackInfo.Roll <= attackInfo.ChanceToHit;
		}

		if (isHit)
		{
			this.MV_onAttackEntityHit(attackInfo);
			return true;
		}
		else
		{
			this.MV_onAttackEntityMissed(attackInfo);
			return false;
		}
	}

	// MV: Modularized
	q.onScheduledTargetHit = @() function( _info )
	{
		_info.Container.setBusy(false);

		if (!_info.TargetEntity.isAlive())
		{
			return;
		}

		local partHit = this.Math.rand(1, 100);
		local bodyPart = this.Const.BodyPart.Body;
		local bodyPartDamageMult = 1.0;

		if (partHit <= _info.Properties.getHitchance(this.Const.BodyPart.Head))
		{
			bodyPart = this.Const.BodyPart.Head;
		}
		else
		{
			bodyPart = this.Const.BodyPart.Body;
		}

		bodyPartDamageMult = bodyPartDamageMult * _info.Properties.DamageAgainstMult[bodyPart];

		local injuries;

		if (this.m.InjuriesOnBody != null && bodyPart == this.Const.BodyPart.Body)
		{
			injuries = this.m.InjuriesOnBody;
		}
		else if (this.m.InjuriesOnHead != null && bodyPart == this.Const.BodyPart.Head)
		{
			injuries = this.m.InjuriesOnHead;
		}

		local hitInfo = clone this.Const.Tactical.HitInfo;

		// Added by MV
		hitInfo.MV_PropertiesForUse = _info.Properties;
		hitInfo.MV_PropertiesForDefense = _info.DefenderProperties;
		// --

		// MV: Extracted the calculation of DamageRegular, DamageArmor, DamageDirect
		hitInfo.DamageRegular = this.MV_getDamageRegular(_info.Properties, _info.TargetEntity);
		hitInfo.DamageArmor = this.MV_getDamageArmor(_info.Properties, _info.TargetEntity);
		hitInfo.DamageDirect = this.MV_getDamageDirect(_info.Properties, _info.TargetEntity);
		hitInfo.DamageFatigue = this.Const.Combat.FatigueReceivedPerHit * _info.Properties.FatigueDealtPerHitMult;
		hitInfo.DamageMinimum = _info.Properties.DamageMinimum;
		hitInfo.BodyPart = bodyPart;
		hitInfo.BodyDamageMult = bodyPartDamageMult;
		hitInfo.FatalityChanceMult = _info.Properties.FatalityChanceMult;
		hitInfo.Injuries = injuries;
		hitInfo.InjuryThresholdMult = _info.Properties.ThresholdToInflictInjuryMult;
		hitInfo.Tile = _info.TargetEntity.getTile();
		_info.Container.onBeforeTargetHit(_info.Skill, _info.TargetEntity, hitInfo);
		local pos = _info.TargetEntity.getPos();
		local hasArmorHitSound = _info.TargetEntity.getItems().getAppearance().ImpactSound[bodyPart].len() != 0;
		_info.TargetEntity.onDamageReceived(_info.User, _info.Skill, hitInfo);

		if (hitInfo.DamageInflictedHitpoints >= this.Const.Combat.PlayHitSoundMinDamage)
		{
			if (this.m.SoundOnHitHitpoints.len() != 0)
			{
				this.Sound.play(this.m.SoundOnHitHitpoints[this.Math.rand(0, this.m.SoundOnHitHitpoints.len() - 1)], this.Const.Sound.Volume.Skill * this.m.SoundVolume, pos);
			}
		}

		if (hitInfo.DamageInflictedHitpoints == 0 && hitInfo.DamageInflictedArmor >= this.Const.Combat.PlayHitSoundMinDamage)
		{
			if (this.m.SoundOnHitArmor.len() != 0)
			{
				this.Sound.play(this.m.SoundOnHitArmor[this.Math.rand(0, this.m.SoundOnHitArmor.len() - 1)], this.Const.Sound.Volume.Skill * this.m.SoundVolume, pos);
			}
		}

		if (typeof _info.User == "instance" && _info.User.isNull() || !_info.User.isAlive() || _info.User.isDying())
		{
			return;
		}

		_info.Container.onTargetHit(_info.Skill, _info.TargetEntity, hitInfo.BodyPart, hitInfo.DamageInflictedHitpoints, hitInfo.DamageInflictedArmor);
		_info.User.getItems().onDamageDealt(_info.TargetEntity, this, hitInfo);

		if (hitInfo.DamageInflictedHitpoints >= this.Const.Combat.SpawnBloodMinDamage && !_info.Skill.isRanged() && (_info.TargetEntity.getBloodType() == this.Const.BloodType.Red || _info.TargetEntity.getBloodType() == this.Const.BloodType.Dark))
		{
			_info.User.addBloodied();
			local item = _info.User.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand);

			if (item != null && item.isItemType(this.Const.Items.ItemType.MeleeWeapon))
			{
				item.setBloodied(true);
			}
		}
	}

	// MV: Added
	// Can be used to modify the result of behavior.queryTargetValue
	// Must return the new value
	q.getQueryTargetValueMult <- function( _entity, _target, _skill )
	{
		return 1.0;
	}

	q.onCostsPreview <- function( _costsPreview )
	{
	}
});


::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/skill", function(q) {
		// MV: Changed
		// part of affordability preview system
		q.getCostString = @(__original) function()
		{
			if (!this.getContainer().getActor().isPreviewing() || ::getModSetting("mod_msu", "ExpandedSkillTooltips").getValue() == false)
				return __original();

			local actor = this.getContainer().getActor();
			local previewFatigue = actor.getPreviewFatigue();
			local previewAP = actor.getPreviewActionPoints();

			actor.m.MV_IsDoingPreviewUpdate = true;
			this.getContainer().update();
			actor.m.MV_IsDoingPreviewUpdate = false;

			// TODO: Hook the js side to work properly with animations of skills which aren't usable
			// otherwise currently this isUsable thing doesn't work as intended
			// i.e. preview_unusable skills don't show disabled icon when previewing
			// local isUsablePreview = this.isUsable();

			local ret = __original();

			actor.m.MV_IsPreviewing = false;
			actor.m.MV_IsDoingPreviewUpdate = true;
			this.getContainer().update();
			actor.m.MV_IsDoingPreviewUpdate = false;
			actor.m.MV_IsPreviewing = true;

			// if (!isUsablePreview)
			// {
			// 	ret = ::MSU.String.replace(ret, "after ", "and will [color=" + ::Const.UI.Color.NegativeValue + "]not be usable[/color] after ");
			// }
			return ret;
		}
	});
});
