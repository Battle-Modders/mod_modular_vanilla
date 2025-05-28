::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/states/tactical_state", function(q) {
		// MV: Changed
		// part of affordability preview system
		q.executeEntityTravel = @(__original) { function executeEntityTravel( _activeEntity, _mouseEvent )
		{
			_activeEntity.resetPreview();
			return __original(_activeEntity, _mouseEvent);
		}}.executeEntityTravel;

		// MV: Changed
		// part of affordability preview system
		q.executeEntitySkill = @(__original) { function executeEntitySkill( _activeEntity, _targetTile )
		{
			_activeEntity.resetPreview();
			return __original(_activeEntity, _targetTile);
		}}.executeEntitySkill;
	});
});
