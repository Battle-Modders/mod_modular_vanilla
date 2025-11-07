::ModularVanilla.MH.hook("scripts/skills/effects/shieldwall_effect", function(q) {
	// Part of the actor.MV_interruptSkills framework
	q.MV_onSkillsInterrupted = @() function()
	{
		this.removeSelf();
	}
});
