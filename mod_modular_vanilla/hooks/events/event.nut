::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hookTree("scripts/events/event", function (q) {
		// MV: Changed
		// part of character_background.MV_getIDForEvent framework
		q.onUpdateScore = @(__original) function()
		{
			::ModularVanilla.__EventIDForBG = this.getID();
			__original();
			::ModularVanilla.__EventIDForBG = null;
		}

		// MV: Changed
		// part of character_background.MV_getIDForEvent framework
		q.onPrepare = @(__original) function()
		{
			::ModularVanilla.__EventIDForBG = this.getID();
			__original();
			::ModularVanilla.__EventIDForBG = null;
		}
	});
});
