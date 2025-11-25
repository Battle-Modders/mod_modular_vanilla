::ModularVanilla <- {
	ID = "mod_modular_vanilla",
	Name = "Modular Vanilla",
	Version = "0.6.0",
	GitHubURL = "https://github.com/Battle-Modders/mod_modular_vanilla",
	QueueBucket = {
		Early = [],
		Normal = [],
		Late = [],
		VeryLate = [],
		AfterHooks = [],
		FirstWorldInit = []
	}
}

::ModularVanilla.MH <- ::Hooks.register(::ModularVanilla.ID, ::ModularVanilla.Version, ::ModularVanilla.Name);
::ModularVanilla.MH.require([
	"vanilla >= 1.5.1-6",
	"dlc_lindwurm",
	"dlc_unhold",
	"dlc_wildmen",
	"dlc_desert",
	"dlc_paladins",
	"mod_msu"
]);

::ModularVanilla.MH.conflictWith([
	"tnf_modRNG [Overwrites attackEntity and getHitchance vanilla functions]" // Part of Tweaks and Fixes by LeVilainJoueur. https://www.nexusmods.com/battlebrothers/mods/69
]);

::ModularVanilla.MH.queue("<mod_msu", function()
{
	::include("mod_modular_vanilla/hooks_helper.nut");

	foreach (file in ::IO.enumerateFiles("mod_modular_vanilla/config"))
	{
		::include(file);
	}

	foreach (file in ::IO.enumerateFiles("mod_modular_vanilla/hooks"))
	{
		::include(file);
	}
}, ::Hooks.QueueBucket.VeryEarly);

::ModularVanilla.MH.queue("<mod_msu", function() {
	foreach (fn in ::ModularVanilla.QueueBucket.Early)
	{
		fn();
	}
}, ::Hooks.QueueBucket.Early);

::ModularVanilla.MH.queue(">mod_msu", function() {
	::ModularVanilla.Mod <- ::MSU.Class.Mod(::ModularVanilla.ID, ::ModularVanilla.Version, ::ModularVanilla.Name);
	::ModularVanilla.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::ModularVanilla.GitHubURL);
	::ModularVanilla.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, "https://www.nexusmods.com/battlebrothers/mods/768");
	::ModularVanilla.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	foreach (fn in ::ModularVanilla.QueueBucket.Normal)
	{
		fn();
	}
});

::ModularVanilla.MH.queue("<mod_msu", function() {
	foreach (fn in ::ModularVanilla.QueueBucket.VeryLate)
	{
		fn();
	}
}, ::Hooks.QueueBucket.VeryLate);

::ModularVanilla.MH.queue("<mod_msu", function() {
	foreach (fn in ::ModularVanilla.QueueBucket.AfterHooks)
	{
		fn();
	}
}, ::Hooks.QueueBucket.AfterHooks);

::ModularVanilla.MH.queue(function() {
	foreach (fn in ::ModularVanilla.QueueBucket.FirstWorldInit)
	{
		fn();
	}
	delete ::ModularVanilla.QueueBucket;
	delete ::ModularVanilla.HooksHelper;
}, ::Hooks.QueueBucket.FirstWorldInit);
