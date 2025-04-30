::ModularVanilla.MH.hook("scripts/entity/tactical/enemies/lindwurm_tail", function (q) {
	// Is set to true during onDamageReceived so that getSkills() returns the skills of this.m.Body
	// because in vanilla the tail's onDamageReceived calls events on the Body's skill container
	q.m.__MV_IsDuringOnDamageReceived <- false;

	q.getSkills = @() function()
	{
		return this.m.__MV_IsDuringOnDamageReceived && this.getBody() != null ? this.getBody().getSkills() : this.m.Skills;
	}

	// MV added function in actor.nut
	q.MV_onInjuryReceived = @(__original) function( _injury )
	{
		this.m.Body.MV_onInjuryReceived(_injury);
	}

	// MV: Modularized
	// This is part of the actor.onDamageReceived modularization but vanilla has a custom implementation
	// for this enemy, so overwrite the function to redirect it to use our modularized actor function
	q.onDamageReceived = @() function( _attacker, _skill, _hitInfo )
	{
		_hitInfo.BodyPart = ::Const.BodyPart.Body;
		_hitInfo.BodyDamageMult = 1.0;

		// This is explicitely done in the Vanilla implementation and it is needed to make Acid be applied correctly.
		// The head is often too far (2+ tiles) away to apply acid with its own racial effect
		// In Vanilla this call is more in the middle of the replicated onDamageReceived code. Not sure how much difference that makes
		this.m.Racial.onDamageReceived(_attacker, _hitInfo.DamageInflictedHitpoints, _hitInfo.DamageInflictedArmor);

		this.m.__MV_IsDuringOnDamageReceived = true;
		local ret = this.actor.onDamageReceived(_attacker, _skill, _hitInfo);
		this.m.__MV_IsDuringOnDamageReceived = false;

		return ret;
	}
});
