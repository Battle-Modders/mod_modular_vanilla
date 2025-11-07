::ModularVanilla.MH.hook("scripts/skills/effects/riposte_effect", function(q) {
	// Part of the actor.MV_interruptSkills framework
	q.MV_onSkillsInterrupted = @() function()
	{
		this.removeSelf();
	}
	
	// Part of the skill_container.MV_onDisarmed framework
	q.MV_onDisarmed = @() function()
	{
		this.removeSelf();
	}
});
