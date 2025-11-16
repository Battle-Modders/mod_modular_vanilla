::ModularVanilla.MH.hook("scripts/skills/actives/quick_shot", function(q) {
	// Convert the vanilla method of "setting" certain fields to instead be incremental changes
	q.onAfterUpdate = @() { function onAfterUpdate( _properties )
	{
		this.m.AdditionalAccuracy = this.m.Item.getAdditionalAccuracy();
		if (_properties.IsSpecializedInBows)
		{
			this.m.MaxRange += 1;
			this.m.FatigueCostMult *= ::Const.Combat.WeaponSpecFatigueMult;
		}
	}}.onAfterUpdate;

	// Vanilla sets the range during onAfterUpdate which breaks the ability to do incremental changes.
	// We use the vanilla onItemSet function to accomplish this instead. This is similarly used by vanilla in
	// certain skills e.g. fire_handgonne_skill to set the MaxRange of the skill to that of the item.
	q.onItemSet = @(__original) { function onItemSet()
	{
		this.m.MaxRange = this.getItem().getRangeMax();
		__original();
	}}.onItemSet;
});
