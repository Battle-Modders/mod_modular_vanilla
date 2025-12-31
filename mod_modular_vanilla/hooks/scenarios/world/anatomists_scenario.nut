::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hookTree("scripts/scenarios/world/anatomists_scenario", function (q) {
		q.onInit = @(__original) { function onInit()
		{
			__original();
			foreach (bro in ::World.getPlayerRoster().getAll())
			{
				bro.getBaseProperties().MV_ForbiddenMoraleStates.push(::Const.MoraleState.Confident);
			}
		}}.onInit;

		q.onHired = @(__original) { function onHired( _bro )
		{
			_bro.getBaseProperties().MV_ForbiddenMoraleStates.push(::Const.MoraleState.Confident);
			__original(_bro);
		}}.onHired;
	});
});
