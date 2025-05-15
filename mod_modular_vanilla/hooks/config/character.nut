local function addMoraleCheckType( _key )
{
	::Const.MoraleCheckType[_key] <- ::Const.MoraleCheckType.len();
	::Const.CharacterProperties.MoraleCheckBravery.push(0);
	::Const.CharacterProperties.MoraleCheckBraveryMult.push(1.0);
}

// Add a new morale check type for being surrounded. Is used during
// actor.onMovementFinish
addMoraleCheckType("MV_Surround");

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
