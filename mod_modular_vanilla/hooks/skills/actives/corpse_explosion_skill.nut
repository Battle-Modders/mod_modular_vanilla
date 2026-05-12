::ModularVanilla.MH.hook("scripts/skills/actives/corpse_explosion_skill", function(q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/841753826211060610/
	// Vanilla uses TimeUnit.Real to schedule stuff during skill usage, which can lead
	// to issues. We fix it by using TimeUnit.Virtual instead.
	q.onUse = @() { function onUse( _user, _targetTile )
	{
		local isFleshCradle = _targetTile.getEntity() != null && _targetTile.getEntity().getType() == ::Const.EntityType.FleshCradle && !_targetTile.getEntity().getIsDestroyed();

		if (isFleshCradle)
		{
			// This is the fix i.e. we use TimeUnit.Virtual instead of vanilla TimeUnit.Real
			::Time.scheduleEvent(::TimeUnit.Virtual, 250, this.onDestroyFleshCradle.bindenv(this), {
				FleshCradle = _targetTile.getEntity()
			});
		}
		else
		{
			this.onRemoveCorpse(_targetTile);
		}

		// This is the fix i.e. we use TimeUnit.Virtual instead of vanilla TimeUnit.Real
		::Time.scheduleEvent(::TimeUnit.Virtual, 250, this.onApply.bindenv(this), {
			Skill = this,
			TargetTile = _targetTile,
			User = _user
		});
		return true;
	}}.onUse;
});
