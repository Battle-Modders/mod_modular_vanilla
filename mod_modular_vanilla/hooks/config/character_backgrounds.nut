::MSU.Table.merge(::Const, {
	// List of all backgrounds that are hireable in towns.
	// Is populated automatically on demand so backgrounds from mods are also covered.
	// Mods can still add to this array manually, but ideally should do so before FirstWorldInit.
	MV_HireableCharacterBackgrounds = [],
	__MV_hasGeneratedHireableCharacterBackgrounds = false,

	// Generate the list on demand.
	// Has to be done like this because FirstWorldInit is called by Modern Hooks too late (end of world_state.onInit).
	// This results in being unable to start origin from the main menu which try to access MV_HireableCharacterBackgrounds
	// during `onSpawnAssets` of the origin, because the FirstWorldInit hasn't run yet.
	// We are requesting Modern Hooks to change it to call it at `start of world_state.init()`.
	// Note: This function must not be used before locations/settlements etc. can be safely instantiated.
	function MV_getHireableCharacterBackgrounds()
	{
		if (!this.__MV_hasGeneratedHireableCharacterBackgrounds)
		{
			this.MV_HireableCharacterBackgrounds.extend(this.__MV_generateHireableCharacterBackgroundsList());
			this.MV_HireableCharacterBackgrounds = ::MSU.Array.uniques(this.MV_HireableCharacterBackgrounds);
			this.__MV_hasGeneratedHireableCharacterBackgrounds = true;
		}
		return this.MV_HireableCharacterBackgrounds;
	}

	function __MV_generateHireableCharacterBackgroundsList()
	{
		local ret = [];
		foreach (script in ::IO.enumerateFiles("scripts/entity/world"))
		{
			local obj = ::new(script);
			if (::isKindOf(obj, "settlement"))
			{
				ret.extend(obj.m.DraftList);
			}
			else if (::isKindOf(obj, "attached_location") || ::isKindOf(obj, "building") || ::isKindOf(obj, "situation"))
			{
				// Pass clone of list in case backgrounds are being removed, then only push bg from clone to original
				// if it is a new kind of bg so we don't double the list on every iteration.
				// Note: an alternative is to keep extending the original array, but it crashes (seems squirrel has a limit on array length)
				// If we try to prevent this crash by extending with an array of uniques only, it is still significantly slower than this implementation
				local clonedList = clone ret;
				obj.onUpdateDraftList(clonedList);
				foreach (bg in clonedList)
				{
					if (ret.find(bg) == null)
					{
						ret.push(bg);
					}
				}
			}
		}

		return ::MSU.Array.uniques(ret);
	}
});
