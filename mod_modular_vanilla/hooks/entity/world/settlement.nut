::ModularVanilla.QueueBucket.VeryLate.push(function () {
	::ModularVanilla.MH.hook("scripts/entity/world/settlement", function (q) {
		// MV: Changed
		// Part of starting_scenario.MV_onUpdateShopList event
		q.onUpdateShopList = @(__original) { function onUpdateShopList( _buildingID, _list )
		{
			__original(_buildingID, _list);
			::World.Assets.getOrigin().MV_onUpdateShopList(this, _buildingID, _list);
		}}.onUpdateShopList;
	});
});
