::ModularVanilla.MH.hook("scripts/skills/effects/shieldwall_effect", function(q) {
	// Part of the actor.MV_interruptSkills framework
	q.MV_onSkillsInterrupted = @() { function MV_onSkillsInterrupted()
	{
		this.removeSelf();
	}}.MV_onSkillsInterrupted;
	
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
