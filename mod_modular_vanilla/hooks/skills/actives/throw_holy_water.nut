::ModularVanilla.MH.hook("scripts/skills/actives/throw_holy_water", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsSpecializedInThrowing)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}}.onAfterUpdate;

	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/841753826211060610/
	// Vanilla uses TimeUnit.Real to schedule stuff during skill usage, which can lead
	// to issues. We fix it by using TimeUnit.Virtual instead.
	q.onUse = @() { function onUse( _user, _targetTile )
	{
		local targetEntity = _targetTile.getEntity();

		// Minor "fix": We sync the scheduleEvent delay to be exactly the delay from spawnProjectileEffect
		// This also ensures that if Projectile is not shown, then there is no delay.
		// vanilla delay is 200.
		local delay = 1;
		if (this.m.IsShowingProjectile && this.m.ProjectileType != 0)
		{
			if (_user.getTile().getDistanceTo(targetEntity.getTile()) >= ::Const.Combat.SpawnProjectileMinDist)
			{
				local flip = !this.m.IsProjectileRotated && targetEntity.getPos().X > _user.getPos().X;
				delay = ::Tactical.spawnProjectileEffect(::Const.ProjectileSprite[this.m.ProjectileType], _user.getTile(), targetEntity.getTile(), 1.0, this.m.ProjectileTimeScale, this.m.IsProjectileRotated, flip);
			}
		}

		_user.getItems().unequip(_user.getItems().getItemAtSlot(::Const.ItemSlot.Offhand));
		// This is the fix i.e. we use TimeUnit.Virtual instead of vanilla TimeUnit.Real
		::Time.scheduleEvent(::TimeUnit.Virtual, delay, this.onApplyEffect.bindenv(this), {
			Skill = this,
			TargetTile = _targetTile
		});
	}}.onUse;
});
