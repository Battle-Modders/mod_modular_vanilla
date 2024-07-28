// Add a new morale check type for being surrounded. Is used during
// actor.onMovementFinish
::Const.MoraleCheckType.Surround <- ::Const.MoraleCheckType.len();
::Const.CharacterProperties.MoraleCheckBravery.push(0);
::Const.CharacterProperties.MoraleCheckBraveryMult.push(1.0);
