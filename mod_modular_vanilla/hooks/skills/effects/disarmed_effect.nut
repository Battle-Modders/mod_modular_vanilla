::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/effects/disarmed_effect", function(q) {
		// MV: Changed
		// Part of skill_container.onDisarmed event
		q.onAdded = @(__original) function()
		{
			__original();
			this.getContainer().MV_onDisarmed();
		}
	});
});
