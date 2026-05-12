::ModularVanilla.MH.hook("scripts/skills/actives/fire_mortar_skill", function(q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/841753826211060610/
	// Vanilla uses TimeUnit.Real to schedule stuff during skill usage, which can lead
	// to issues. We fix it by using TimeUnit.Virtual instead.
	q.onUse = @() { function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 2;
		this.m.AffectedTiles = this.getAffectedTiles(_targetTile);

		foreach( tile in this.m.AffectedTiles )
		{
			tile.Properties.IsMarkedForImpact = true;
			tile.spawnDetail(this.getImpactSprite(), ::Const.Tactical.DetailFlag.SpecialOverlay, false, true);
		}

		// This is the fix i.e. we use TimeUnit.Virtual instead of vanilla TimeUnit.Real
		::Time.scheduleEvent(::TimeUnit.Virtual, 1000, this.onSpawnFireEffect.bindenv(this), this);

		if (!_user.isHiddenToPlayer())
		{
			::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_user) + " fires a shell high in the air");
		}

		return true;
	}}.onUse;

	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/841753826211060610/
	// Vanilla uses TimeUnit.Real to schedule stuff during skill usage, which can lead
	// to issues. We fix it by using TimeUnit.Virtual instead.
	q.updateImpact = @() { function updateImpact()
	{
		if (this.m.AffectedTiles.len() != 0)
		{
			this.getContainer().getActor().setActionPoints(0);
			// Change to use MSU.Array.rand for better readability
			::Sound.play(::MSU.Array.rand(this.m.SoundOnHit), 1.0, this.m.AffectedTiles[0].Pos);
			// This is the fix i.e. we use TimeUnit.Virtual instead of vanilla TimeUnit.Real
			::Time.scheduleEvent(::TimeUnit.Virtual, 1400, this.onImpact.bindenv(this), this);
		}
	}}.updateImpact;
});
