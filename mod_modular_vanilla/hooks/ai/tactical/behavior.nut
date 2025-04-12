::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hookTree("scripts/ai/tactical/behavior", function(q) {
		// MV: Changed
		// Add skill_container events to allow skills to modify the queried value
		q.queryTargetValue = @(__original) function( _entity, _target, _skill = null )
		{
			return __original(_entity, _target, _skill) * _entity.getSkills().getQueryTargetValueMult(_entity, _target, _skill) * _target.getSkills().getQueryTargetValueMult(_entity, _target, _skill);
		}
	});
});
