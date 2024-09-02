// Add a new morale check type for being surrounded. Is used during
// actor.onMovementFinish
::Const.MoraleCheckType.Surround <- ::Const.MoraleCheckType.len();
::Const.CharacterProperties.MoraleCheckBravery.push(0);
::Const.CharacterProperties.MoraleCheckBraveryMult.push(1.0);

// Interruptions on this actor will cause no onActorInterrupted events to fire, while this is true
::Const.CharacterProperties.IsImmuneToInterrupt <- false;
