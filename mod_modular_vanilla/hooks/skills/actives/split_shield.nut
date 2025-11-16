::ModularVanilla.MH.hook("scripts/skills/actives/split_shield", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		if (_properties.IsSpecializedInAxes)
		{
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}}.onAfterUpdate;

	// Vanilla sets the AP cost to 6 during onAfterUpdate which breaks the ability to do incremental changes.
	// We use the vanilla onItemSet function to accomplish this instead. This is similarly used by vanilla in
	// certain skills e.g. fire_handgonne_skill to set the MaxRange of the skill to that of the item.
	q.onItemSet = @(__original) { function onItemSet()
	{
		if (this.getItem().getBlockedSlotType() != null)
		{
			this.m.ActionPointCost = 6;
		}
		__original();
	}}.onItemSet;
});
