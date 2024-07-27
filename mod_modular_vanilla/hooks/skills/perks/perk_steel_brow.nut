::ModularVanilla.MH.hook("scripts/skills/perks/perk_steel_brow", function (q) {
	q.onBeforeDamageReceived = @(__original) function( _attacker, _skill, _hitInfo, _properties )
	{
		__original(_attacker, _skill, _hitInfo, _properties);
		_hitInfo.BodyDamageMult = 1.0;
	}
});
