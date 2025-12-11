::ModularVanilla.MH.hook("scripts/skills/actives/charm_skill", function(q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/685239996035115001/
	// Vanilla is missing an onVerifyTarget declaration in this skill, allowing Hexen to target invalid targets
	// e.g. those with MoraleState.Ignore.
	q.onVerifyTarget = @(__original) { function onVerifyTarget( _originTile, _targetTile )
	{
		return __original(_originTile, _targetTile) && _targetTile.IsOccupiedByActor && this.isViableTarget(this.getContainer().getActor(), _targetTile.getEntity());
	}}.onVerifyTarget;
});
