::ModularVanilla.MH.hook("scripts/skills/actives/lightning_storm_skill", function(q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/841753826211060610/
	// Vanilla uses TimeUnit.Real to schedule stuff during skill usage, which can lead
	// to issues. We fix it by using TimeUnit.Virtual instead.
	q.updateImpact = @() { function updateImpact()
	{
		if (this.m.AffectedTiles.len() != 0)
		{
			// Change to use MSU.Array.rand for better readability
			::Sound.play(::MSU.Array.rand(this.m.SoundOnHit), 0.8);
			// This is the fix i.e. we use TimeUnit.Virtual instead of vanilla TimeUnit.Real
			::Time.scheduleEvent(::TimeUnit.Virtual, 600, this.onImpact.bindenv(this), this);
		}
	}}.updateImpact;

	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/841753826211060610/
	// Vanilla uses TimeUnit.Real to schedule stuff during skill usage, which can lead
	// to issues. We fix it by using TimeUnit.Virtual instead.
	q.onImpact = @() { function onImpact( _tag )
	{
		::Tactical.EventLog.log("Lightning strikes the battlefield");
		::Tactical.getCamera().quake(::createVec(0, -1.0), 6.0, 0.16, 0.35);
		local actor = this.getContainer().getActor();

		foreach (i, t in _tag.m.AffectedTiles)
		{
			::Time.scheduleEvent(::TimeUnit.Virtual, i * 30, function ( _data )
			{
				local tile = _data.Tile;

				for( local i = 0; i < ::Const.Tactical.LightningParticles.len(); i = ++i )
				{
					::Tactical.spawnParticleEffect(true, ::Const.Tactical.LightningParticles[i].Brushes, tile, ::Const.Tactical.LightningParticles[i].Delay, ::Const.Tactical.LightningParticles[i].Quantity, ::Const.Tactical.LightningParticles[i].LifeTimeQuantity, ::Const.Tactical.LightningParticles[i].SpawnRate, ::Const.Tactical.LightningParticles[i].Stages);
				}

				tile.clear(::Const.Tactical.DetailFlag.SpecialOverlay);
				tile.Properties.IsMarkedForImpact = false;

				if ((tile.IsEmpty || tile.IsOccupiedByActor) && tile.Type != ::Const.Tactical.TerrainType.ShallowWater && tile.Type != ::Const.Tactical.TerrainType.DeepWater)
				{
					tile.clear(::Const.Tactical.DetailFlag.Scorchmark);
					tile.spawnDetail("impact_decal", ::Const.Tactical.DetailFlag.Scorchmark, false, true);
				}

				if (tile.IsOccupiedByActor && !_data.User.isAlliedWith(tile.getEntity()))
				{
					local target = tile.getEntity();
					local hitInfo = clone ::Const.Tactical.HitInfo;
					hitInfo.DamageRegular = ::Math.rand(25, 50);
					hitInfo.DamageArmor = hitInfo.DamageRegular * 1.0;
					hitInfo.DamageDirect = 0.75;
					hitInfo.BodyPart = 0;
					hitInfo.FatalityChanceMult = 0.0;
					hitInfo.Injuries = ::Const.Injury.BurningBody;
					target.onDamageReceived(_data.User, _data.Skill, hitInfo);
				}
			}, {
				Tile = t,
				Skill = this,
				User = actor
			});
		}

		_tag.m.AffectedTiles = [];

		if (_tag.m.HasCooldownAfterImpact)
		{
			_tag.m.Cooldown = 1;
		}

		::Tactical.Entities.getFlags().set("LightningStrikesActive", ::Math.max(0, ::Tactical.Entities.getFlags().getAsInt("LightningStrikesActive") - 1));
	}}.onImpact;
});
