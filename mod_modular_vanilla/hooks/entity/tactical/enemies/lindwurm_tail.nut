::ModularVanilla.MH.hook("scripts/entity/tactical/enemies/lindwurm_tail", function (q) {
	// Is set to true during onDamageReceived so that getSkills() returns the skills of this.m.Body
	// because in vanilla the tail's onDamageReceived calls events on the Body's skill container
	q.m.__MV_IsDuringOnDamageReceived <- false;

	q.getSkills = @() { function getSkills()
	{
		return this.m.__MV_IsDuringOnDamageReceived && this.getBody() != null ? this.getBody().getSkills() : this.m.Skills;
	}}.getSkills;

	// MV added function in actor.nut
	q.MV_onInjuryReceived = @(__original) { function MV_onInjuryReceived( _injury )
	{
		this.m.Body.MV_onInjuryReceived(_injury);
	}}.MV_onInjuryReceived;

	// MV: Modularized
	// This is part of the actor.onDamageReceived modularization but vanilla has a custom implementation
	// for this enemy, so overwrite the function to redirect it to use our modularized actor function
	q.onDamageReceived = @() { function onDamageReceived( _attacker, _skill, _hitInfo )
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
	}}.onDamageReceived;

	// VanillaFix: Keep a strong reference to the body while the lindwurm_tail is being killed and only
	// nullify it with a delayed event. Otherwise attempts to call `_targetEntity.getCurrentProperties()`
	// in things such as `skill.onTargetHit` result in an exception because `m.Body` has become null.
	// Vanilla gets around this issue by manually checking for `isKindOf(target, "lindwurm_tail")`
	// in `cleave.nut` which is ugly.
	q.kill = @(__original) { function kill( _killer = null, _skill = null, _fatalityType = this.Const.FatalityType.None, _silent = false )
	{
		local body = this.m.Body.get();
		__original(_killer, _skill, _fatalityType, _silent);
		this.m.Body = body;
		::Time.scheduleEvent(::TimeUnit.Virtual, 1, @(_a) _a.m.Body = null, this);
	}}.kill;
});
