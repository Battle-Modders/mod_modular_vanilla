::ModularVanilla.MH.hook("scripts/skills/traits/oath_of_valor_trait", function(q) {
	q.onUpdate = @(__original) { function onUpdate( _properties )
	{
		__original(_properties);
		_properties.MV_ForbiddenMoraleStates.push(::Const.MoraleState.Fleeing);
	}}.onUpdate;
});
