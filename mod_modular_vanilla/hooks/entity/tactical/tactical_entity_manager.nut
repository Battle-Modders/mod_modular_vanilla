::ModularVanilla.MH.hook("scripts/entity/tactical/tactical_entity_manager", function (q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/685239622575459972/
	// Change vanilla function to use RealTimeF for the delay between idle sounds instead of VirtualTimeF.
	// The rest is the same as vanilla.
	q.update = @() { function update()
	{
		this.checkCombatFinished();

		if (this.isCombatFinished())
		{
			return;
		}

		// We add isPaused() check because otherwise idle sounds play even when the game is paused
		// because we have changed them to play off of `getRealTimeF`.
		if (!::Tactical.State.isPaused() && (::Tactical.TurnSequenceBar.getActiveEntity() == null || ::Tactical.TurnSequenceBar.getActiveEntity().isPlayerControlled()))
		{
			local instances = [];

			for (local i = ::Const.Faction.Player + 1; i != this.m.Instances.len(); i++)
			{
				for (local j = 0; j != this.m.Instances[i].len(); j++)
				{
					instances.push(this.m.Instances[i][j]);
				}
			}

			// Change vanilla `getVirtualTimeF()` with `getRealTimeF()`
			if (instances.len() != 0 && this.m.LastIdleSound + ::Math.maxf(::Const.Sound.IdleSoundMinDelay, ::Const.Sound.IdleSoundBaseDelay - ::Const.Sound.IdleSoundReducedDelay * instances.len()) < ::Time.getRealTimeF())
			{
				this.m.LastIdleSound = ::Time.getRealTimeF();
				::MSU.Array.rand(instances).playIdleSound();
			}
		}

		if (this.m.IsDirty)
		{
			this.m.IsDirty = false;
			::Tactical.TopbarRoundInformation.update();
		}
	}}.update;
});
