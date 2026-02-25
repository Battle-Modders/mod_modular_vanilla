::ModularVanilla.MH.conflictWith([
	"tnf_modRNG [Overwrites attackEntity and getHitchance vanilla functions]" // Part of Tweaks and Fixes by LeVilainJoueur. https://www.nexusmods.com/battlebrothers/mods/69
]);

// Below are conflicts by mod filename (necessary for mods that don't register with hooks)
// Key: filename, Value: Reason for incompatibility
local conflicts = {
	// Better Combat Log by AllanniaBB. https://www.nexusmods.com/battlebrothers/mods/105
	// Overwrites actor.checkMorale which breaks our systems.
	"mod_better_combat_log": "Better Combat Log is incompatible with Modular Vanilla as it overwrites actor.checkMorale and breaks Modular Vanilla functionality. For a compatible mod that shows morale checks in the combat log use MoraleCheck Log by UnauthorizedShell from https://www.nexusmods.com/battlebrothers/mods/663"
};
foreach (path in ::IO.enumerateFiles("data/"))
{
	foreach (filename, reason in conflicts)
	{
		// Add "data/" because we don't want to check inside subfolders
		if (path.find("data/" + filename) != null)
		{
			::Hooks.errorAndQuit(reason);
		}
	}
}
