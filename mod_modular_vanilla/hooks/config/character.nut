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
	MV_HeadshotInjuryThresholdMult = 1.25, // Part of actor.onDamageReceived modularization (injury application)
	MV_HitChanceMin = 5,
	MV_HitChanceMax = 95,
	MV_DiversionHitChanceAdd = -15,
	MV_DiversionDamageMult = 0.75
});

local original_getClone = ::Const.CharacterProperties.getClone;
::MSU.Table.merge(::Const.CharacterProperties, {
	function getClone()
	{
		local ret = original_getClone();
		ret.MV_MoraleCheckBraveryCallbacks = clone this.MV_MoraleCheckBraveryCallbacks;
		ret.MV_ForbiddenMoraleStates = clone this.MV_ForbiddenMoraleStates;
		return ret;
	},

	// Part of modularization of player_party.updateStrength
	MV_StrengthMult = 1.0
	/*
	You push functions to this array during `skill.onUpdate` or `skill.onAfterUpdate`.
	These are then used to modify the Bravery during actor.checkMorale.
	The functions pushed look like this:
		function( _change, _type )
		_change is the _change parameter in `actor.checkMorale`.
		_type is the _type parameter in `actor.checkMorale`.
	The functions return a table with this signature:
	{
		Add = <integer>
		Mult = <float>
	}
	// Add is then added to Bravery during actor.checkMorale
	// whereas Mult is multiplied with the BraveryMult.
	*/
	MV_MoraleCheckBraveryCallbacks = [],
	// During actor.setMoraleState if the passed morale state is found in this
	// array, the morale state will not be set to that value..
	MV_ForbiddenMoraleStates = []
});
