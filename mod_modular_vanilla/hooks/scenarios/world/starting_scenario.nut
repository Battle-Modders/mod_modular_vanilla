::ModularVanilla.MH.hook("scripts/scenarios/world/starting_scenario", function (q) {
	// MV: Added
	// part of player_party.updateStrength modularization
	q.MV_getPlayerPartyStrengthMult <- function()
	{
		return 1.0;
	}
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hookTree("scripts/scenarios/world/starting_scenario", function (q) {
		// part of player_party.updateStrength modularization
		// During loading a save game, the player_party.updateStrength is called before the origin
		// is instantiated, therefore the multiplier from the origin doesn't apply. So, we manually
		// trigger player_party.updateStrength once again after the origin's onInit.
		q.onInit = @(__original) function()
		{
			__original();
			::World.State.getPlayer().updateStrength();
		}
	});
});
