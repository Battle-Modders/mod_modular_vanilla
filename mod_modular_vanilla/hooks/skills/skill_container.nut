::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/skill_container", function (q) {
		// MV: Changed
		// part of affordability preview system
		// Prevent collectGarbage from running during a preview type skill_container.update
		q.collectGarbage = @(__original) function( _performUpdate = true )
		{
			if (!this.getActor().isPreviewing())
				return __original(_performUpdate);
		}

		// MV: Changed
		// part of affordability preview system
		q.onTurnEnd = @(__original) function()
		{
			this.getActor().resetPreview();
			return __original();
		}

		// MV: Changed
		// part of affordability preview system
		q.onWaitTurn = @(__original) function()
		{
			this.getActor().resetPreview();
			return __original();
		}

		// MV: Changed
		// part of affordability preview system
		q.onCombatFinished = @(__original) function()
		{
			this.getActor().resetPreview();
			return __original();
		}
	});
});
