::ModularVanilla.MH.hook("scripts/skills/effects/shieldwall_effect", function(q) {
	// Part of the actor.interrupt framework
	q.onActorInterrupted = @() function( _offensive, _defensive )
	{
		if (_defensive)
			this.removeSelf();
	}
});
