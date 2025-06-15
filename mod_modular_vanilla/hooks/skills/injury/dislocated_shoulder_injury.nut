::ModularVanilla.MH.hook("scripts/skills/injury/dislocated_shoulder_injury", function (q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/555745444093769921/
	// This fix is composed of changes to both `onUpdate` and `onAfterUpdate`.
	// We move the `setActionPoints` to `onAfterUpdate` so that all changes to `_properties.ActionPoints`
	// from all skills are properly accounted for.
	q.onUpdate = @() { function onUpdate( _properties )
	{
		this.injury.onUpdate(_properties);

		if (!_properties.IsAffectedByInjuries || this.m.IsFresh && !_properties.IsAffectedByFreshInjuries)
		{
			return;
		}

		_properties.ActionPoints -= 3;
	}}.onUpdate;

	q.onAfterUpdate = @(__original) { function onAfterUpdate( _properties )
	{
		__original(_properties);
		this.getContainer().getActor().setActionPoints(::Math.min(_properties.ActionPoints, this.getContainer().getActor().getActionPoints()));
	}}.onAfterUpdate;
});
