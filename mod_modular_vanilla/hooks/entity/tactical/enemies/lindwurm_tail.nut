::ModularVanilla.MH.hook("scripts/entity/tactical/enemies/lindwurm_tail", function (q) {
	// Is set to true during onDamageReceived so that getSkills() returns the skills of this.m.Body
	// because in vanilla the tail's onDamageReceived calls events on the Body's skill container
	q.m.__MV_IsDuringOnDamageReceived <- false;
	// We use this to store a weakref to the _hitInfo from onDamageReceived. Then in the `kill`
	// function we use it to manually trigger the `m.Racial.onDamageReceived` to apply acid.
	q.m.__MV_HitInfo <- null;

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

		_hitInfo.__MV_LindwurmTailAttacker <- _attacker;
		this.m.__MV_HitInfo = _hitInfo.weakref();

		this.m.__MV_IsDuringOnDamageReceived = true;
		local ret = this.actor.onDamageReceived(_attacker, _skill, _hitInfo);
		this.m.__MV_IsDuringOnDamageReceived = false;

		// This is explicitely done in the Vanilla implementation and it is needed to make Acid be applied correctly.
		// The head is often too far (2+ tiles) away to apply acid with its own racial effect
		// In Vanilla this call is more in the middle of the replicated onDamageReceived code. Not sure how much difference that makes.
		// This must be done after the _hitInfo.DamageInflictedHitpoints value has been properly populated, which happens during
		// actor.onDamageReceived. Therefore, it must be done after that.
		if (this.isAlive())
		{
			// We only apply it like this when actor is alive. If the actor died in the `actor.onDamageReceived` call above
			// then this will crash here. So we need the `isAlive()` check. In this case, we apply the acid from the `kill` function
			// using the stored weakref to `this.m.__MV_HitInfo`.
			this.m.Racial.onDamageReceived(_attacker, _hitInfo.DamageInflictedHitpoints, _hitInfo.DamageInflictedArmor);
		}

		return ret;
	}}.onDamageReceived;

	// VanillaFix: Keep a strong reference to the body while the lindwurm_tail is being killed and only
	// nullify it with a delayed event. Otherwise attempts to call `_targetEntity.getCurrentProperties()`
	// in things such as `skill.onTargetHit` result in an exception because `m.Body` has become null.
	// Vanilla gets around this issue by manually checking for `isKindOf(target, "lindwurm_tail")`
	// in `cleave.nut` which is ugly.
	q.kill = @(__original) { function kill( _killer = null, _skill = null, _fatalityType = ::Const.FatalityType.None, _silent = false )
	{
		// The `kill` function is triggered from within `onDamageReceived` if HP <= 0.
		// Because we have completely overwritten the vanilla implementation of `onDamageReceived` for lindwurm_tail
		// we call the Racial.onDamageReceived AFTER the `actor.onDamageReceived`. But the actor may die before the code
		// reaches that point. So, we also call `Racial.onDamageReceived` from within the `kill` function using a stored
		// weakref to the hitInfo that is triggering the death.
		if (_killer != null && this.m.__MV_HitInfo != null && ::MSU.isEqual(_killer, this.m.__MV_HitInfo.__MV_LindwurmTailAttacker))
		{
			this.m.Racial.onDamageReceived(_killer, this.m.__MV_HitInfo.DamageInflictedHitpoints, this.m.__MV_HitInfo.DamageInflictedArmor);
		}

		local body = this.m.Body.get();
		__original(_killer, _skill, _fatalityType, _silent);
		this.m.Body = body;
		::Time.scheduleEvent(::TimeUnit.Virtual, 1, @(_a) _a.m.Body = null, this);
	}}.kill;
});
