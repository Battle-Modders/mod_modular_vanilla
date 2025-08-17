local function addNewMoraleCheckType( _key )
{
	::Const.MoraleCheckType[_key] <- ::Const.MoraleCheckType.len();
	::Const.CharacterProperties.MoraleCheckBravery.push(0);
	::Const.CharacterProperties.MoraleCheckBraveryMult.push(1.0);
}

addNewMoraleCheckType("MV_Surround"); // Is used during actor.onMovementFinish
addNewMoraleCheckType("MV_DeathAlly"); // Is used during actor.onOtherActorDeath
addNewMoraleCheckType("MV_DeathEnemy"); // Is used during actor.onOtherActorDeath
addNewMoraleCheckType("MV_FleeAlly"); // Is used during actor.onOtherActorFleeing
addNewMoraleCheckType("MV_FleeEnemy"); // Is used during actor.onOtherActorFleeing

::MSU.Table.merge(::Const.Morale, {
	// Is used in actor.onOtherActorDeath where vanilla checks for _victim.getXPValue() <= 1.
	// A victim with this or less XP value will not trigger a morale check on death
	MV_NoMoraleCheckOnDeathXP = 1,
	// Is used in actor.onOtherActorDeath where vanilla checks for TargetAttractionMult >= 0.5
	// to exclude certain allies from triggering morale checks for their allies on death.
	MV_DeathAllyMinTargetAttractionMult = 0.5
};

::MSU.Table.merge(::Const.Combat, {
	MV_HitChanceMin = 5,
	MV_HitChanceMax = 95,
	MV_DiversionHitChanceAdd = -15,
	MV_DiversionDamageMult = 0.75
});

::MSU.Table.merge(::Const.CharacterProperties, {
	// Part of modularization of player_party.updateStrength
	MV_StrengthMult = 1.0
});
