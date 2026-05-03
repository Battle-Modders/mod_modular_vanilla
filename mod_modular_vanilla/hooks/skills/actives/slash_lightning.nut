::ModularVanilla.MH.hook("scripts/skills/actives/slash_lightning", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsSpecializedInSwords)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}}.onAfterUpdate;

	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/841752762653941021/
	// Slash Lightning is not meant to trigger lightning during riposte attacks, but
	// in vanilla if the attacker dies to a riposte hit, then it triggers lightning.
	q.onUse = @(__original) { function onUse( _user, _targetTile )
	{
		// Vanilla allows lightning strikes to trigger when the active entity is null.
		// When the active entity dies, it is always immediately removed from spot of
		// the active entity, causing it to be null. We fix that by running a very simple
		// implementation of the original skill, if it is NOT the users turn.
		if (!::Tactical.TurnSequenceBar.isActiveEntity(this.getContainer().getActor()))
		{
			this.spawnAttackEffect(_targetTile, ::Const.Tactical.AttackEffectSlash);
			return this.attackEntity(_user, _targetTile.getEntity());
		}

		return __original(_user, _targetTile);
	}}.onUse;
});
