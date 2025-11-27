::ModularVanilla.MH.hook("scripts/skills/actives/hail_skill", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsSpecializedInFlails)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
			this.m.IsShieldRelevant = false;
		}
		else
		{
			this.m.IsShieldRelevant = true;
		}
	}}.onAfterUpdate;

	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/604158579076817361/
	// Missing null check for active entity before trying to access its ID.
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/684112727828878904/
	// Missing `_user.isAlive()` check in the scheduled functions.
	q.onUse = @() { function onUse( _user, _targetTile )
	{
		this.spawnAttackEffect(_targetTile, ::Const.Tactical.AttackEffectChop);
		local target = _targetTile.getEntity();
		local ret = this.attackEntity(_user, target);

		local activeEntity = ::Tactical.TurnSequenceBar.getActiveEntity();

		if (activeEntity != null && activeEntity.getID() == _user.getID() && (!_user.isHiddenToPlayer() || _targetTile.IsVisibleForPlayer))
		{
			this.m.IsDoingAttackMove = false;
			this.getContainer().setBusy(true);
			::Time.scheduleEvent(::TimeUnit.Virtual, 100, function ( _skill )
			{
				if (target.isAlive() && _user.isAlive())
				{
					_skill.attackEntity(_user, target);
				}
			}.bindenv(this), this);
			::Time.scheduleEvent(::TimeUnit.Virtual, 200, function ( _skill )
			{
				if (!_user.isAlive())
					return;

				if (target.isAlive())
				{
					_skill.attackEntity(_user, target);
				}

				_skill.m.IsDoingAttackMove = true;
				_skill.getContainer().setBusy(false);
			}.bindenv(this), this);
			return true;
		}
		else
		{
			if (target.isAlive() && _user.isAlive())
			{
				ret = this.attackEntity(_user, target) || ret;
			}

			if (target.isAlive() && _user.isAlive())
			{
				ret = this.attackEntity(_user, target) || ret;
			}

			return ret;
		}
	}}.onUse;
});
