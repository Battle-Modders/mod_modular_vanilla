// List of all backgrounds that are hireable in towns.
// Is populated automatically AfterHooks so backgrounds from mods are also covered.
// Mods can still add to this array manually.
::Const.MV_HireableCharacterBackgrounds <- [];

::ModularVanilla.QueueBucket.AfterHooks.push(function() {
	// This is required in vanilla in the create function of settlements as that function calls
	// getRandomName() which tries to access this. So we instantiate it temporarily.
	::World.EntityManager <- ::new("scripts/entity/world/entity_manager");

	// We instantiate all the other things which are usually instantiated in world_state.onInit
	// as some settlements etc. (from mods) may try to access them during their create function.
	::World.Factions <- ::new("scripts/factions/faction_manager");
	::World.Combat <- ::new("scripts/entity/world/combat_manager");
	::World.Contracts <- ::new("scripts/contracts/contract_manager");
	::World.Events <- ::new("scripts/events/event_manager");
	::World.Ambitions <- ::new("scripts/ambitions/ambition_manager");
	::World.Retinue <- ::new("scripts/retinue/retinue_manager");
	::World.Crafting <- ::new("scripts/crafting/crafting_manager");
	::World.Statistics <- ::new("scripts/statistics/statistics_manager");
	::World.Flags <- ::new("scripts/tools/tag_collection");
	::World.Assets <- ::new("scripts/states/world/asset_manager");

	foreach (script in ::IO.enumerateFiles("scripts/entity/world"))
	{
		local obj = ::new(script);
		if (::isKindOf(obj, "settlement"))
		{
			::Const.MV_HireableCharacterBackgrounds.extend(obj.m.DraftList);
		}
		else if (::isKindOf(obj, "attached_location") || ::isKindOf(obj, "building") || ::isKindOf(obj, "situation"))
		{
			// Pass clone of list in case backgrounds are being removed, then only push bg from clone to original
			// if it is a new kind of bg so we don't double the list on every iteration.
			// Note: an alternative is to keep extending the original array, but it crashes (seems squirrel has a limit on array length)
			// If we try to prevent this crash by extending with an array of uniques only, it is still significantly slower than this implementation
			local clonedList = clone ::Const.MV_HireableCharacterBackgrounds;
			obj.onUpdateDraftList(clonedList);
			foreach (bg in clonedList)
			{
				if (::Const.MV_HireableCharacterBackgrounds.find(bg) == null)
				{
					::Const.MV_HireableCharacterBackgrounds.push(bg);
				}
			}
		}
	}

	delete ::World.EntityManager;
	delete ::World.Factions;
	delete ::World.Combat;
	delete ::World.Contracts;
	delete ::World.Events;
	delete ::World.Ambitions;
	delete ::World.Retinue;
	delete ::World.Crafting;
	delete ::World.Statistics;
	delete ::World.Flags;
	delete ::World.Assets;

	::Const.MV_HireableCharacterBackgrounds = ::MSU.Array.uniques(::Const.MV_HireableCharacterBackgrounds);
});
