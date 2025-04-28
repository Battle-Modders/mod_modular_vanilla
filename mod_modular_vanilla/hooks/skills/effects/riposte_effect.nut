::ModularVanilla.MH.hook("scripts/skills/effects/riposte_effect", function(q) {
	// Part of the actor.MV_interrupt framework
	q.MV_onActorInterrupted = @() function()
	{
		this.removeSelf();
	}
});
