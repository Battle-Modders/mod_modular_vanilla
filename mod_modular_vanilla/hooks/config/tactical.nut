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
		PropertiesForUse = null,
		PropertiesForDefense = null
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
	MV_CurrentHitInfo = null,

	// MV: Added
	// Part of skill.onScheduledTargetHit modularization
	// Similar to the vanilla instantiation and calculation of HitInfo in onScheduledTargetHit,
	// this is meant to return the HitInfo from the perspective of the attacker i.e. outgoing damage.
	// We use our MV functions to calculate damage to keep things DRY.
		// _propertiesForUse and _propertiesForDefense parameters are just there so that when called from
		//  onScheduledTargetHit we don't have to calculate the properties again.
	function MV_initHitInfo( _skill, _targetEntity, _propertiesForUse = null, _propertiesForDefense = null )
	{
		if (_propertiesForUse == null)
			_propertiesForUse = _skill.getContainer().buildPropertiesForUse(_skill, _targetEntity);
		if (_propertiesForDefense == null && _targetEntity != null)
			_propertiesForDefense = _targetEntity.getSkills().buildPropertiesForDefense(_skill.getContainer().getActor(), _skill);

		local bodyPart = ::Math.rand(1, 100) <= _propertiesForUse.getHitchance(::Const.BodyPart.Head) ? ::Const.BodyPart.Head : ::Const.BodyPart.Body;
		local bodyPartDamageMult = _propertiesForUse.DamageAgainstMult[bodyPart];

		local injuries;

		if (_skill.m.InjuriesOnBody != null && bodyPart == ::Const.BodyPart.Body)
		{
			injuries = _skill.m.InjuriesOnBody;
		}
		else if (_skill.m.InjuriesOnHead != null && bodyPart == ::Const.BodyPart.Head)
		{
			injuries = _skill.m.InjuriesOnHead;
		}

		local hitInfo = clone ::Const.Tactical.HitInfo;

		// MV: Added
		hitInfo.MV_PropertiesForUse = _propertiesForUse;
		hitInfo.MV_PropertiesForDefense = _propertiesForDefense;

		// MV: Extracted the calculation of DamageRegular, DamageArmor, DamageDirect
		hitInfo.DamageRegular = _skill.MV_getDamageRegular(_propertiesForUse, _targetEntity);
		hitInfo.DamageArmor = _skill.MV_getDamageArmor(_propertiesForUse, _targetEntity);
		hitInfo.DamageDirect = _skill.MV_getDamageDirect(_propertiesForUse, _targetEntity);
		hitInfo.DamageFatigue = ::Const.Combat.FatigueReceivedPerHit * _propertiesForUse.FatigueDealtPerHitMult;
		hitInfo.DamageMinimum = _propertiesForUse.DamageMinimum;
		hitInfo.BodyPart = bodyPart;
		hitInfo.BodyDamageMult = bodyPartDamageMult;
		hitInfo.FatalityChanceMult = _propertiesForUse.FatalityChanceMult;
		hitInfo.Injuries = injuries;
		hitInfo.InjuryThresholdMult = _propertiesForUse.ThresholdToInflictInjuryMult;
		hitInfo.Tile = _targetEntity == null ? null : _targetEntity.getTile();

		return hitInfo;
	}
});

// MV: Modularized
// We add several new fields to HitInfo to make more information
// available in the functions where it is passed
::MSU.Table.merge(::Const.Tactical.HitInfo, {
	MV_ArmorRemaining = 0,
	MV_PropertiesForUse = null, // attacker skill_container.buildPropertiesForUse
	MV_PropertiesForDefense = null, // target skill_container.buildPropertiesForDefense
	MV_PropertiesForBeingHit = null // target skill_container.buildPropertiesForBeingHit
});
