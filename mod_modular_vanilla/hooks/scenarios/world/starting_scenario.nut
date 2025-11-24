::ModularVanilla.MH.hook("scripts/scenarios/world/starting_scenario", function (q) {
	// MV: Added
	// part of player_party.updateStrength modularization
	q.MV_getPlayerPartyStrengthMult <- { function MV_getPlayerPartyStrengthMult()
	{
		return 1.0;
	}}.MV_getPlayerPartyStrengthMult;

	// MV: Added
	// Part of starting_scenario.MV_onWorldEntitySpawned event
	// Called from ::World.spawnEntity and ::World.spawnLocation
	q.MV_onWorldEntitySpawned <- { function MV_onWorldEntitySpawned( _entity )
	{
	}}.MV_onWorldEntitySpawned;

	// MV: Added
	// Part of starting_scenario.MV_onLocationEntered event
	// Called from location.onEnter
	q.MV_onLocationEntered <- { function MV_onLocationEntered( _location )
	{
	}}.MV_onLocationEntered;
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hookTree("scripts/scenarios/world/starting_scenario", function (q) {
		// MV: Changed
		// part of player_party.updateStrength modularization
		// During loading a save game, the player_party.updateStrength is called before the origin
		// is instantiated, therefore the multiplier from the origin doesn't apply. So, we manually
		// trigger player_party.updateStrength once again after the origin's onInit.
		q.onInit = @(__original) function()
		{
			__original();
			// Null check is necessary because `World.State.getPlayer()` is null during `onBeforeDeserialize` which happens when loading a
			// saved game while already having loaded a saved game previously. This leads to `asset_manager.resetToDefaults` being called
			// which calls `onInit` on the Origin but at this point the player party doesn't exist.
			if (!::MSU.isNull(::World.State.getPlayer()))
				::World.State.getPlayer().updateStrength();
		}
	});
});
