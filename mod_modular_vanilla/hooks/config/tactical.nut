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

// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/841753627754294975/
// In some cases in vanilla (e.g. `arena_contract` the LocationTemplate.Template array inside
// is not properly cloned and ends up having an overwritten value. We fix this by overwriting
// the _cloned metamethod to recursively deepclone the entire template.
::Const.Tactical.LocationTemplate.setdelegate({
	function _cloned( _original )
	{
		foreach (k, v in _original)
		{
			this[k] = ::MSU.deepClone(v);
		}
	}
});
