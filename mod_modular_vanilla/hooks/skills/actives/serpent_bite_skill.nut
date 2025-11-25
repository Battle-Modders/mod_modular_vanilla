::ModularVanilla.MH.hook("scripts/skills/actives/serpent_bite_skill", function(q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/604158579076817361/
	// missing null check for active entity.
	q.onUse = @() { function onUse( _user, _targetTile )
	{
		local tag = {
			Skill = this,
			User = _user,
			TargetTile = _targetTile
		};

		// Use MSU isActiveEntity function which includes a null check for the active entity
		if ((!_user.isHiddenToPlayer() || _targetTile.IsVisibleForPlayer) && ::Tactical.TurnSequenceBar.isActiveEntity(this.getContainer().getActor().getID()))
		{
			this.getContainer().setBusy(true);
			local d = _user.getTile().getDirectionTo(_targetTile) + 3;
			d = d > 5 ? d - 6 : d;

			if (_user.getTile().hasNextTile(d))
			{
				::Tactical.getShaker().shake(_user, _user.getTile().getNextTile(d), 6);
			}

			::Time.scheduleEvent(::TimeUnit.Virtual, 500, this.onPerformAttack.bindenv(this), tag);
			return true;
		}
		else
		{
			return this.attackEntity(_user, _targetTile.getEntity());
		}
	}}.onUse;
});
