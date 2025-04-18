::MSU.Table.merge(::Const.Tactical, {
	// Used in skill.attackEntity to carry and pass around information
	// about the attack to various functions called from that function
	// (can be considered an analogue to the vanilla HitInfo but for attacks)
	MV_AttackInfo = {
		ChanceToHit = null,
		Roll = null,
		AllowDiversion = true,
		IsAstray = false,
		User = null,
		Target = null
		UserProperties = null,
		TargetProperties = null
	},
	// Contains a weakref to an instance of MV_AttackInfo during skill.attackEntity.
	// The purpose is to allow access to the attackInfo from all functions which
	// do not get it passed directly e.g. onTargetMissed.
	MV_CurrentAttackInfo = null,
	// Contains a weakref to an instance of HitInfo during actor.onDamageReceived.
	// The purpose is to allow access to the HitInfo from all functions which
	// do not get it passed directly.
	// Note: We populate it during actor.onDamageReceived only. However, during regular skill attack
	// HitInfo is also first passed to onBeforeTargetHit (in skill.onScheduledTargetHit).
	MV_CurrentHitInfo = null
});

// MV: Modularized
// We add several new fields to HitInfo to make more information
// available in the functions where it is passed
::MSU.Table.merge(::Const.Tactical.HitInfo, {
	ArmorRemaining = 0,
	PropertiesForUse = null, // attacker skill_container.buildPropertiesForUse
	PropertiesForDefense = null, // target skill_container.buildPropertiesForDefense
	PropertiesForBeingHit = null // target skill_container.buildPropertiesForBeingHit
});
