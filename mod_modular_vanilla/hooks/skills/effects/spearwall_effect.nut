::ModularVanilla.MH.hook("scripts/skills/effects/spearwall_effect", function(q) {
// Modular Vanilla Functions
	// Part of the actor.interrupt framework
	q.onActorInterrupted = @() function()
	{
		this.removeSelf();
	}
});
