::ModularVanilla.MH.hook("scripts/skills/effects/ancient_priest_potion", function(q) {
	q.onUpdate = @(__original) { function onUpdate( _properties )
	{
		__original(_properties);
		_properties.MV_ForbiddenMoraleStates.push(::Const.MoraleState.Fleeing);
	}}.onUpdate;
});
