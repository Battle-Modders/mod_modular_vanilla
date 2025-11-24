::ModularVanilla.MH.hook("scripts/skills/actives/flurry_skill", function(q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/652585529159895032/
	// Missing isAlive check for user causes crash when user dies to Riposte
	// This function uses the same logic as vanilla but rewritten for clarity and with the isAlive check added.
	q.onUse = @() { function onUse( _user, _targetTile )
	{
		::Sound.play(::MSU.Array.rand(this.m.SoundOnHit), 1.0, _targetTile.Pos);
		::Tactical.EventLog.log(::Const.UI.getColorizedEntityName(_user) + " unleashes a flurry of blows around it");
		local ownTile = _user.getTile();
		local numAttacks = 6;
		local targetTiles = ::MSU.Tile.getNeighbors(ownTile);
		local attackDelay = 0;
		local currentTileIndex = 0;

		while (numAttacks > 0)
		{
			local tile = targetTiles[currentTileIndex];

			if (!tile.IsEmpty && tile.getEntity().isAttackable() && ::Math.abs(tile.Level - ownTile.Level) <= 1 && !_user.isAlliedWith(tile.getEntity()))
			{
				this.m.Container.setBusy(true);
				::Time.scheduleEvent(::TimeUnit.Virtual, attackDelay, function ( _skill )
				{
					if (_user.isAlive() && tile.IsOccupiedByActor && tile.getEntity().isAlive())
					{
						this.spawnAttackEffect(tile, ::Const.Tactical.AttackEffectChop);
						_skill.attackEntity(_user, tile.getEntity());

						if (numAttacks == 1)
						{
							_skill.getContainer().setBusy(false);
						}
					}
				}.bindenv(this), this);
				attackDelay = attackDelay + 200;
				numAttacks--;
			}

			currentTileIndex++;

			if (currentTileIndex >= targetTiles.len() && numAttacks != 6)
			{
				currentTileIndex = 0;
			}
		}

		return true;
	}}.onUse;
});
