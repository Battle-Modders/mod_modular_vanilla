::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hookTree("scripts/entity/tactical/actor", function(q) {
		q.onInit = @(__original) function()
		{
			__original();
			this.getBaseProperties().CanReceiveTemporaryInjuries = this.getBaseProperties().IsAffectedByInjuries;
			this.getSkills().update();
		}

		q.onDamageReceived = @(__original) function( _attacker, _skill, _hitInfo )
		{
			local p = this.getCurrentProperties();
			local isAffectedByInjuries = p.IsAffectedByInjuries;
			p.IsAffectedByInjuries = p.CanReceiveTemporaryInjuries;

			local ret = __original(_attacker, _skill, _hitInfo);

			p.IsAffectedByInjuries = isAffectedByInjuries;

			return ret;
		}
	});
});

