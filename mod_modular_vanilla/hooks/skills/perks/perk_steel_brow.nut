::ModularVanilla.MH.hook("scripts/skills/perks/perk_steel_brow", function (q) {
	q.create = @(__original) function()
	{
		__original();
		// Set the order to VeryLast so this skill's `onBeforeDamageReceived` is the last
		// function in order and any changes on `BodyDamageMult` by earlier skills are
		// properly overwritten by this skill.
		this.m.Order = ::Const.SkillOrder.VeryLast;
	}

	q.onBeforeDamageReceived = @(__original) function( _attacker, _skill, _hitInfo, _properties )
	{
		__original(_attacker, _skill, _hitInfo, _properties);
		_hitInfo.BodyDamageMult = 1.0;
	}
});
