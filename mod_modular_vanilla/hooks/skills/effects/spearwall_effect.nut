::ModularVanilla.MH.hook("scripts/skills/effects/spearwall_effect", function(q) {
	// Part of the actor.interrupt framework
	q.onActorInterrupted = @() function()
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
