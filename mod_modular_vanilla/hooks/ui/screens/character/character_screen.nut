::ModularVanilla.MH.hook("scripts/ui/screens/character/character_screen", function(q) {
	q.helper_isActionAllowed = @(__original) function( _entity, _items, _putIntoBags )
	{
		if (::MSU.Utils.hasState("tactical_state"))
		{
			// Vanilla Fix: Check all items for isChangeableInBattle, instead of just the source item
			foreach (index, item in _items)
			{
				if (item != null && !item.isChangeableInBattle())
				{
					if (index == 0)	// This is always the source item as per vanilla standard
					{
						return {
							error = "Source Item is not changable in battle.",	// We replace the less informative vanilla error "Item is not changable in battle." here
							code = ::Const.CharacterScreen.ErrorCode.ItemIsNotChangableInBattle
						};
					}
					else
					{
						return {
							error = "Destination Item is not changable in battle.",
							code = ::Const.CharacterScreen.ErrorCode.ItemIsNotChangableInBattle
						};
					}
				}
			}
		}

		return __original(_entity, _items, _putIntoBags);
	}
});
