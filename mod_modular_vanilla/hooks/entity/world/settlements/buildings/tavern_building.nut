::ModularVanilla.QueueBucket.VeryLate.push(function () {
	::ModularVanilla.MH.hook("scripts/entity/world/settlements/buildings/tavern_building", function (q) {
		q.m.MV_LastRumorFlag <- "MV_LastRumorFlag";

		q.onSettlementEntered = @(__original) { function onSettlementEntered()
		{
			__original();

			// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/570415959124302855/
			// Serialize the value of this.m.LastRumor in the settlement flags. Vanilla sets this field to `""` upon
			// entering the settlement if a certain amount of time has passed. So we need to update our flag accordingly.
			// We cannot set the LastRumor flag during onSerialize, because world_entity flags are serialized before buildings are serialized.
			this.getSettlement().getFlags().set(this.m.MV_LastRumorFlag, this.m.LastRumor);
		}}.onSettlementEntered;

		q.getRumor = @(__original) { function getRumor( _isPaidFor = false )
		{
			local ret = __original(_isPaidFor);

			// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/570415959124302855/
			// Serialize the value of this.m.LastRumor in the settlement flags, whenever it is changed by the tavern.
			// We cannot do that during onSerialize, because world_entity flags are serialized before buildings are serialized.
			this.getSettlement().getFlags().set(this.m.MV_LastRumorFlag, this.m.LastRumor);

			return ret;
		}}.getRumor;

		q.onDeserialize = @(__original) { function onDeserialize( _in )
		{
			__original(_in);

			// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/570415959124302855/
			// Deserialize the value of this.m.LastRumor from the settlement flags.
			if (this.getSettlement().getFlags().has(this.m.MV_LastRumorFlag))
			{
				this.m.LastRumor = this.getSettlement().getFlags().get(this.m.MV_LastRumorFlag);
			}
		}}.onDeserialize;
	});
});
