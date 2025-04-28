::ModularVanilla.MH.hook("scripts/skills/effects/spearwall_effect", function(q) {
	// Part of the actor.MV_interrupt framework
	q.MV_onActorInterrupted = @() function()
	{
		this.removeSelf();
	}
});
