::ModularVanilla.MH.hook("scripts/skills/effects/riposte_effect", function(q) {
	// Part of the actor.interrupt framework
	q.onActorInterrupted = @() function()
	{
		this.removeSelf();
	}
});
