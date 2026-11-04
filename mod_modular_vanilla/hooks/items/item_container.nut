::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/items/item_container", function(q) {
		// MV: Changed
		// Part of ::ModularVanilla.Simulation: no structural changes while simulating
		foreach (name in ["equip", "unequip", "addToBag", "removeFromBag"])
		{
			q[name] = @(__original) function( ... )
			{
				if (::ModularVanilla.Simulation.isActive())
					return false;

				::ModularVanilla.Simulation.StateVersion++;
				vargv.insert(0, this);
				return __original.acall(vargv);
			}
		}
	});
});
