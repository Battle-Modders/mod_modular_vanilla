::ModularVanilla.MH.hook("scripts/entity/tactical/enemies/lindwurm_tail", function (q) {
	// Is set to true during onDamageReceived so that getSkills() returns the skills of this.m.Body
	// because in vanilla the tail's onDamageReceived calls events on the Body's skill container
	q.m.MV_IsDuringOnDamageReceived <- false;

	q.getSkills = @() function()
	{
		return this.m.MV_IsDuringOnDamageReceived && this.getBody() != null ? this.getBody().getSkills() : this.m.Skills;
	}

	// MV added function in actor.nut
	q.onInjuryReceived = @(__original) function( _injury )
	{
		this.m.Body.onInjuryReceived(_injury);
	}

	// MV: Modularized
	// This is part of the actor.onDamageReceived modularization but vanilla has a custom implementation
	// for this enemy, so overwrite the function to redirect it to use our modularized actor function
	q.onDamageReceived = @() function( _attacker, _skill, _hitInfo )
	{
		_hitInfo.BodyPart = ::Const.BodyPart.Body;

		this.m.MV_IsDuringOnDamageReceived = true;
		local ret = this.actor.onDamageReceived(_attacker, _skill, _hitInfo);
		this.m.MV_IsDuringOnDamageReceived = false;

		return ret;
	}
});
