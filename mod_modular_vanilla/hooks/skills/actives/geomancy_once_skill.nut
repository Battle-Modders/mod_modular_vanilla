::ModularVanilla.MH.hook("scripts/skills/actives/geomancy_once_skill", function(q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/841753826211060610/
	// Vanilla uses TimeUnit.Real to schedule stuff during skill usage, which can lead
	// to issues. We fix it by using TimeUnit.Virtual instead.
	q.updateTiles = @(__original) { function updateTiles()
	{
		if (this.m.AffectedTiles.len() != 0)
		{
			// Change to use MSU.Array.rand for better readability
			::Sound.play(::MSU.Array.rand(this.m.SoundOnHit), 1.0, this.m.AffectedTiles[0].Pos);
			// This is the fix i.e. we use TimeUnit.Virtual instead of vanilla TimeUnit.Real
			::Time.scheduleEvent(::TimeUnit.Virtual, 100, this.onLowerTiles.bindenv(this), this);
		}
	}}.updateTiles;
});
