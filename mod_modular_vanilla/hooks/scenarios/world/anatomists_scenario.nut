::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hookTree("scripts/scenarios/world/anatomists_scenario", function (q) {
		q.onSpawnPlayer = @(__original) { function onSpawnPlayer()
		{
			__original();
			foreach (bro in ::World.getPlayerRoster().getAll())
			{
				bro.getBaseProperties().MV_ForbiddenMoraleStates.push(::Const.MoraleState.Confident);
			}
		}}.onSpawnPlayer;

		q.onHired = @(__original) { function onHired( _bro )
		{
			_bro.getBaseProperties().MV_ForbiddenMoraleStates.push(::Const.MoraleState.Confident);
			__original(_bro);
		}}.onHired;
	});
});
