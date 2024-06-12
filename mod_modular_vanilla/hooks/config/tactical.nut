// Used in skill.attackEntity to carry and pass around information
// about the attack to various functions called from that function
// (can be considered an analogue to the vanilla HitInfo but for attacks)
::Const.Tactical.MV_AttackInfo <- {
	ChanceToHit = null,
	Roll = null,
	AllowDiversion = true,
	IsAstray = false,
	User = null,
	Target = null
	UserProperties = null,
	TargetProperties = null
}
