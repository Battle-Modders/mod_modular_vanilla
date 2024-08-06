::ModularVanilla <- {
	ID = "mod_modular_vanilla",
	Name = "Modular Vanilla",
	Version = "0.3.0",
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
::ModularVanilla.MH.require("mod_msu");

::ModularVanilla.MH.queue("<mod_msu", function()
{
	foreach (file in ::IO.enumerateFiles("mod_modular_vanilla/config"))
	{
		::include(file);
	}

	foreach (file in ::IO.enumerateFiles("mod_modular_vanilla/hooks"))
	{
		::include(file);
	}
}, ::Hooks.QueueBucket.VeryEarly);

::ModularVanilla.MH.queue(">mod_msu", function() {
	::ModularVanilla.Mod <- ::MSU.Class.Mod(::ModularVanilla.ID, ::ModularVanilla.Version, ::ModularVanilla.Name);
	::ModularVanilla.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::ModularVanilla.GitHubURL);
	::ModularVanilla.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
});

::ModularVanilla.MH.queue(function() {
	foreach (fn in ::ModularVanilla.QueueBucket.VeryLate)
	{
		fn();
	}
}, ::Hooks.QueueBucket.VeryLate);

::ModularVanilla.MH.queue(function() {
	foreach (fn in ::ModularVanilla.QueueBucket.FirstWorldInit)
	{
		fn();
	}
	delete ::ModularVanilla.QueueBucket;
}, ::Hooks.QueueBucket.FirstWorldInit);
