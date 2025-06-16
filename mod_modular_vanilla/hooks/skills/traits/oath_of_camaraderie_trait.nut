::ModularVanilla.MH.hook("scripts/skills/traits/oath_of_camaraderie_trait", function(q) {
	q.MV_onMoraleStateChanged = @() { function MV_onMoraleStateChanged( _oldState )
	{
		if (this.getContainer().getActor().getMoraleState() == ::Const.MoraleState.Confident && _oldState != ::Const.MoraleState.Confident && this.isPlacedOnMap() && ::Time.getRound() >= 1 && ("State" in ::World) && ::World.State != null && ::World.Ambitions.hasActiveAmbition() && ::World.Ambitions.getActiveAmbition().getID() == "ambition.oath_of_camaraderie")
		{
			::World.Statistics.getFlags().increment("OathtakersBrosConfident");
		}
	}}.MV_onMoraleStateChanged;
});
