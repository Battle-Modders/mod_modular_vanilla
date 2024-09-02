::ModularVanilla.MH.hook("scripts/skills/effects/sleeping_effect", function(q) {
	// Part of the actor.interrupt framework
	q.onActorInterrupted = @() function()
	{
		this.removeSelf();	// Sleeping is now removed by any interruption
	}
});
