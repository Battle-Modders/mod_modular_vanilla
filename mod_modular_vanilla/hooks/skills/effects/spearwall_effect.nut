::ModularVanilla.MH.hook("scripts/skills/effects/spearwall_effect", function(q) {
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
	
	// MV: Added
	// Part of modularization of actor.setMoraleState
	q.MV_onMoraleStateChanged = @() { function MV_onMoraleStateChanged( _oldState )
	{
		if (this.getContainer().getActor().getMoraleState() == ::Const.MoraleState.Fleeing)
		{
			this.removeSelf();
		}
	}}.MV_onMoraleStateChanged;
});
