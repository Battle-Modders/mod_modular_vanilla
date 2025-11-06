::ModularVanilla.MH.hook("scripts/entity/world/location", function (q) {
	// MV: Extracted
	// Part of location.createDefenders modularization
	// This function should ideally be left unchanged by mods unless they want to modify resource scaling logic.
	// For modifying the effect of various things that can scale resources, its better to hook MV_getResourcesScalingMults instead.
	q.MV_getScaledResources <- { function MV_getScaledResources() {
		local ret = this.m.Resources;
		foreach (mult in this.MV_getResourcesScalingMults)
		{
			ret *= mult;
		}
		if (::Time.getVirtualTimeF() - this.m.LastSpawnTime <= ::Const.World.Settings.MV_LastSpawnResourcesTime)
		{
			ret *= ::Const.World.Settings.MV_LastSpawnResourcesMult;
		}
		return ret;
	}}.MV_getScaledResources;

	// MV: Added
	// Part of location.createDefenders modularization
	// Returns a table with various multipliers, all of which are applied to the resources.
	q.MV_getResourcesScalingMults <- { function MV_getResourcesScalingMults()
	{
		return {
			Time = this.m.IsScalingDefenders ? ::Math.minf(3.0, 1.0 + ::World.getTime().Days * 0.0075) : 1.0,
			Difficulty = !this.isAlliedWithPlayer() ? ::Const.Difficulty.EnemyMult[::World.Assets.getCombatDifficulty()] : 1.0,
			Strength = 1.0
		};
	}}.MV_getResourcesScalingMults;

	// MV: Extracted
	// Part of location.createDefenders modularization
	// The logic is the same as in vanilla location.createDefenders.
	q.MV_selectPartyFromSpawnList <- { function MV_selectPartyFromSpawnList( _resources )
	{
		local best;
		local bestCost = -9000;

		foreach (party in this.m.DefenderSpawnList)
		{
			if (party.Cost > resources)
			{
				continue;
			}

			if (best == null || party.Cost > bestCost)
			{
				best = party;
				bestCost = party.Cost;
			}
		}

		local potential = [];

		foreach (party in this.m.DefenderSpawnList)
		{
			if (party.Cost > resources || party.Cost < bestCost * 0.75)
			{
				continue;
			}

			potential.push(party);
		}

		if (potential.len() != 0)
		{
			best = ::MSU.Array.rand(potential);
		}

		if (best == null)
		{
			bestCost = 9000;

			foreach (party in this.m.DefenderSpawnList)
			{
				if (::Math.abs(party.Cost - resources) < bestCost)
				{
					best = party;
					bestCost = ::Math.abs(party.Cost - resources);
				}
			}
		}

		return best;
	}}.MV_selectPartyFromSpawnList;

	// MV: Modularized
	// - Extracted the calculation of scaled resources into MV_getScaledResources and MV_getResourcesScalingMults
	// - Extracted the logic of party selection into MV_selectPartyFromSpawnList
	q.createDefenders = @() { function createDefenders()
	{
		local party = this.MV_selectPartyFromSpawnList(this.MV_getScaledResources());
		if (party != null)
		{
			this.m.Troops = [];

			if (::Time.getVirtualTimeF() - this.m.LastSpawnTime <= 60.0)
			{
				this.m.DefenderSpawnDay = ::World.getTime().Days - 7;
			}
			else
			{
				this.m.DefenderSpawnDay = ::World.getTime().Days;
			}

			foreach (t in party.Troops )
			{
				for (local i = 0; i != t.Num; i++)
				{
					::Const.World.Common.addTroop(this, t, false);
				}
			}

			this.updateStrength();
		}
	}}.createDefenders;
});
