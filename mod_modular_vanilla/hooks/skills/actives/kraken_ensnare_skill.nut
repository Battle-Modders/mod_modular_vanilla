::ModularVanilla.MH.hook("scripts/skills/actives/kraken_ensnare_skill", function(q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/841753826211060610/
	// Vanilla uses TimeUnit.Real to schedule stuff during skill usage, which can lead
	// to issues. We fix it by using TimeUnit.Virtual instead.
	q.onUse = @() { function onUse( _user, _targetTile )
	{
		_user.sinkIntoGround(0.75);
		_user.getSkills().setBusy(true);
		_user.m.IsAbleToDie = false;
		// This is the fix i.e. we use TimeUnit.Virtual instead of vanilla TimeUnit.Real
		::Time.scheduleEvent(::TimeUnit.Virtual, 800, this.onNetSpawn.bindenv(this), {
			User = _user,
			Skill = this,
			TargetEntity = _targetTile.getEntity(),
			LoseHitpoints = true
		});
		return true;
	}}.onUse;
});
