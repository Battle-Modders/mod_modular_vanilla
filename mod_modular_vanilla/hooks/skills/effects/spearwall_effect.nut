::ModularVanilla.MH.hook("scripts/skills/effects/spearwall_effect", function(q) {
	// Part of the actor.interrupt framework
	q.onActorInterrupted = @() function()
	{
		this.removeSelf();
	}
});
