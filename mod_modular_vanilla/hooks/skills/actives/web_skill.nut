::ModularVanilla.MH.hook("scripts/skills/actives/web_skill", function(q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/841753826211060610/
	// Vanilla uses TimeUnit.Real to schedule stuff during skill usage, which can lead
	// to issues. We fix it by using TimeUnit.Virtual instead.
	q.onUse = @() { function onUse( _user, _targetTile )
	{
		this.m.Cooldown = 3;
		local targetEntity = _targetTile.getEntity();

		if (!targetEntity.getCurrentProperties().IsImmuneToRoot)
		{
			if (this.m.SoundOnHit.len() != 0)
			{
				// Change to use MSU.Array.rand for better readability
				::Sound.play(::MSU.Array.rand(this.m.SoundOnHit), ::Const.Sound.Volume.Skill, targetEntity.getPos());
			}

			targetEntity.getSkills().add(::new("scripts/skills/effects/web_effect"));
			local breakFree = ::new("scripts/skills/actives/break_free_skill");
			breakFree.setDecal("web_destroyed");
			breakFree.m.Icon = "skills/active_113.png";
			breakFree.m.IconDisabled = "skills/active_113_sw.png";
			breakFree.m.Overlay = "active_113";
			breakFree.m.SoundOnUse = this.m.SoundOnHitHitpoints;
			targetEntity.getSkills().add(breakFree);
			local effect = ::Tactical.spawnSpriteEffect("bust_web2", ::createColor("#ffffff"), _targetTile, 0, 4, 1.0, targetEntity.getSprite("status_rooted").Scale, 100, 100, 0);
			local flip = !targetEntity.isAlliedWithPlayer();
			effect.setHorizontalFlipping(flip);
			// This is the fix i.e. we use TimeUnit.Virtual instead of vanilla TimeUnit.Real
			::Time.scheduleEvent(::TimeUnit.Virtual, 200, this.onNetSpawn.bindenv(this), targetEntity);
		}
		else
		{
			if (this.m.SoundOnMiss.len() != 0)
			{
				// Change to use MSU.Array.rand for better readability
				::Sound.play(::MSU.Array.rand(this.m.SoundOnMiss), ::Const.Sound.Volume.Skill, targetEntity.getPos());
			}

			return false;
		}
	}}.onUse;
});
