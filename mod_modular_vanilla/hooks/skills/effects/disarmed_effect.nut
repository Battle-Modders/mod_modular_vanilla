::ModularVanilla.MH.hook("scripts/skills/effects/disarmed_effect", function(q) {
	// Part of the actor.interrupt framework
	// Because this effect doesn't remove shieldwall_effect, we don't want to catch it in auto-interrupt detection
	// in skill_container.removeByID. Instead we trigger a manual interruption here for offensive effects only.
	q.onAdded = @(__original) function()
	{
		__original();
		if (!this.isGarbage())
		{
			this.getContainer().getActor().interrupt(true, false);
		}
	}
});
