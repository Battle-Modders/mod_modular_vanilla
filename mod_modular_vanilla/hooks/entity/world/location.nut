::ModularVanilla.QueueBucket.VeryLate.push(function () {
	::ModularVanilla.MH.hook("scripts/entity/world/location", function (q) {
		// MV: Changed
		// Part of starting_scenario.MV_onLocationEntered event
		q.onEnter = @(__original) { function onEnter()
		{
			local ret = __original();
			if (ret)
			{
				::World.Assets.getOrigin().MV_onLocationEntered(this);
			}
			return ret;
		}}.onEnter;
	});
});
