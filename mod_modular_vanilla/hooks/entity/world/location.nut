::ModularVanilla.QueueBucket.VeryLate.push(function () {
	::ModularVanilla.MH.hook("scripts/entity/world/location", function (q) {
		q.createDefenders = @(__original) { function createDefenders()
		{
			__original();
			::World.Assets.getOrigin().MV_onLocationCreateDefenders(this);
		}}.createDefenders;

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
