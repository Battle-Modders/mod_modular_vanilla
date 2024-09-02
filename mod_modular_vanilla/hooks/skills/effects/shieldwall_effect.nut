::ModularVanilla.MH.hook("scripts/skills/effects/shieldwall_effect", function(q) {
	// Part of the actor.interrupt framework
	q.onActorInterrupted = @() function()
	{
		this.removeSelf();
	}
});
