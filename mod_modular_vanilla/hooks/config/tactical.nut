local additionalHitInfo = {
	AttackerProperties = null,
	DefenderProperties = null,

	function init( _info )
	{
		local damageMult = _info.Properties.DamageTotalMult * (this.m.IsRanged ? _info.Properties.RangedDamageMult : _info.Properties.MeleeDamageMult);
		local damageRegular = this.Math.rand(_info.Properties.DamageRegularMin, _info.Properties.DamageRegularMax) * _info.Properties.DamageRegularMult;
		local damageArmor = this.Math.rand(_info.Properties.DamageRegularMin, _info.Properties.DamageRegularMax) * _info.Properties.DamageArmorMult;
		damageRegular = this.Math.max(0, damageRegular + _info.DistanceToTarget * _info.Properties.DamageAdditionalWithEachTile);
		damageArmor = this.Math.max(0, damageArmor + _info.DistanceToTarget * _info.Properties.DamageAdditionalWithEachTile);
		local damageDirect = this.Math.minf(1.0, _info.Properties.DamageDirectMult * (this.m.DirectDamageMult + _info.Properties.DamageDirectAdd + (this.m.IsRanged ? _info.Properties.DamageDirectRangedAdd : _info.Properties.DamageDirectMeleeAdd)));
		local injuries;
		if (this.m.InjuriesOnBody != null && bodyPart == this.Const.BodyPart.Body)
		{
			injuries = this.m.InjuriesOnBody;
		}
		else if (this.m.InjuriesOnHead != null && bodyPart == this.Const.BodyPart.Head)
		{
			injuries = this.m.InjuriesOnHead;
		}

		this.AttackerProperties = _info.Properties;
		this.DefenderProperties = _info.DefenderProperties;

		this.DamageRegular = damageRegular * damageMult;
		this.DamageArmor = damageArmor * damageMult;
		this.DamageDirect = damageDirect;
		this.DamageFatigue = this.Const.Combat.FatigueReceivedPerHit * _info.Properties.FatigueDealtPerHitMult;
		this.DamageMinimum = _info.Properties.DamageMinimum;
		this.BodyPart = this.Math.rand(1, 100) <= _info.Properties.getHitchance(this.Const.BodyPart.Head) ? this.Const.BodyPart.Head : this.Const.BodyPart.Body;
		this.BodyDamageMult = _info.Properties.DamageAgainstMult[this.BodyPart];
		this.FatalityChanceMult = _info.Properties.FatalityChanceMult;
		this.Injuries = injuries;
		this.InjuryThresholdMult = _info.Properties.ThresholdToInflictInjuryMult;
		this.Tile = _info.TargetEntity.getTile();
	}
};

foreach (key, value in additionalHitInfo)
{
	if (!(key in ::Const.Tactical.HitInfo))
		::Const.Tactical.HitInfo[key] <- value;
}
