::ModularVanilla.MH.hook("scripts/skills/effects/riposte_effect", function(q) {
	// Part of the actor.MV_interrupt framework
	q.MV_onActorInterrupted = @() function()
	{
		this.removeSelf();
	}
	
	// Part of the skill_container.MV_onDisarmed framework
	q.MV_onDisarmed = @() function()
	{
		this.removeSelf();
	}
});
