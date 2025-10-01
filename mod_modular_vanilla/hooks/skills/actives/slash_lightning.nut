::ModularVanilla.MH.hook("scripts/skills/actives/slash_lightning", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsSpecializedInSwords)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}}.onAfterUpdate;

	// VanillaFix: missing null check for active entity causing bug when slash lightning attack kills someone via riposte.
	// Bug report: https://steamcommunity.com/app/365360/discussions/1/604158579076817361/
	// This is a copy of the vanilla function except we fix the missing null check and rewrite a couple of for loops for better readability
	q.onUse = @() { function onUse( _user, _targetTile )
	{
		this.spawnAttackEffect(_targetTile, ::Const.Tactical.AttackEffectSlash);
		local success = this.attackEntity(_user, _targetTile.getEntity());

		// We replace the vanilla turn sequence bar active entity check with the MSU added `isActiveEntity` function
		// so that null cases are handled properly.
		if (success && _user.isAlive() && ::Tactical.TurnSequenceBar.isActiveEntity(_user))
		{
			local myTile = _user.getTile();
			local selectedTargets = [];
			local potentialTargets = [];
			local potentialTiles = [];
			local target;
			local targetTile = _targetTile;

			if (this.m.SoundOnLightning.len() != 0)
			{
				::Sound.play(this.m.SoundOnLightning[::Math.rand(0, this.m.SoundOnLightning.len() - 1)], ::Const.Sound.Volume.Skill * 2.0, _user.getPos());
			}

			if (!targetTile.IsEmpty && targetTile.getEntity().isAlive())
			{
				target = targetTile.getEntity();
				selectedTargets.push(target.getID());
			}

			local data = {
				Skill = this,
				User = _user,
				TargetTile = targetTile,
				Target = target
			};
			this.applyEffect(data, 100);
			potentialTargets = [];
			potentialTiles = [];

			// Rewrite vanilla for loop with a foreach loop using MSU getNeighbors function
			foreach (tile in ::MSU.Tile.getNeighbors(targetTile))
			{
				if (tile.ID != myTile.ID)
				{
					potentialTiles.push(tile);
				}

				if (!tile.IsOccupiedByActor || !tile.getEntity().isAttackable() || tile.getEntity().isAlliedWith(_user) || selectedTargets.find(tile.getEntity().getID()) != null)
				{
					continue;
				}

				potentialTargets.push(tile);
			}

			if (potentialTargets.len() != 0)
			{
				target = potentialTargets[::Math.rand(0, potentialTargets.len() - 1)].getEntity();
				selectedTargets.push(target.getID());
				targetTile = target.getTile();
			}
			else
			{
				target = null;
				targetTile = potentialTiles[::Math.rand(0, potentialTiles.len() - 1)];
			}

			local data = {
				Skill = this,
				User = _user,
				TargetTile = targetTile,
				Target = target
			};
			this.applyEffect(data, 350);
			potentialTargets = [];
			potentialTiles = [];

			// Rewrite vanilla for loop with a foreach loop using MSU getNeighbors function
			foreach (tile in ::MSU.Tile.getNeighbors(targetTile))
			{
				if (tile.ID != myTile.ID)
				{
					potentialTiles.push(tile);
				}

				if (!tile.IsOccupiedByActor || !tile.getEntity().isAttackable() || tile.getEntity().isAlliedWith(_user) || selectedTargets.find(tile.getEntity().getID()) != null)
				{
					continue;
				}

				potentialTargets.push(tile);
			}

			if (potentialTargets.len() != 0)
			{
				target = potentialTargets[::Math.rand(0, potentialTargets.len() - 1)].getEntity();
				selectedTargets.push(target.getID());
				targetTile = target.getTile();
			}
			else
			{
				target = null;
				targetTile = potentialTiles[::Math.rand(0, potentialTiles.len() - 1)];
			}

			local data = {
				Skill = this,
				User = _user,
				TargetTile = targetTile,
				Target = target
			};
			this.applyEffect(data, 550);
		}

		return success;
	}}.onUse;
});
