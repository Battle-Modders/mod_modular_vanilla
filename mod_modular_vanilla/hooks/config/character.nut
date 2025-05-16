// Add a new morale check type for being surrounded. Is used during
// actor.onMovementFinish
::Const.MoraleCheckType.MV_Surround <- ::Const.MoraleCheckType.len();
::Const.CharacterProperties.MoraleCheckBravery.push(0);
::Const.CharacterProperties.MoraleCheckBraveryMult.push(1.0);

::MSU.Table.merge(::Const.Combat, {
	MV_HitChanceMin = 5,
	MV_HitChanceMax = 95,
	MV_DiversionHitChanceAdd = -15,
	MV_DiversionDamageMult = 0.75
});

::MSU.Table.merge(::Const.CharacterProperties, {
	MV_HitChanceMin = ::Const.Combat.MV_HitChanceMin,
	MV_HitChanceMax = ::Const.Combat.MV_HitChanceMax
});
