::ModularVanilla.MH.hook("scripts/skills/effects/riposte_effect", function(q) {
	// Part of the actor.interrupt framework
	q.onActorInterrupted = @() function( _offensive, _defensive )
	{
		if (_offensive)
			this.removeSelf();
	}
});
