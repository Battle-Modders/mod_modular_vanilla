::ModularVanilla.MH.hook("scripts/skills/traits/insecure_trait", function(q) {
	q.onUpdate = @(__original) { function onUpdate( _properties )
	{
		__original(_properties);
		_properties.MV_ForbiddenMoraleStates.push(::Const.MoraleState.Confident);
	}}.onUpdate;
});
