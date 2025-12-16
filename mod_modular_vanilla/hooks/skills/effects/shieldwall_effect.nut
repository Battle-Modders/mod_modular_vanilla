::ModularVanilla.MH.hook("scripts/skills/effects/shieldwall_effect", function(q) {
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
