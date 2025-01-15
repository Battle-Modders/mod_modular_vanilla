// List of all vanilla backgrounds that are hireable in towns
// Mods which add new backgrounds need to add them to this list
::Const.HireableCharacterBackgrounds <- [
	"adventurous_noble_background",
	"anatomist_background",		// In Vanilla this background can always appear, even if the DLC is not active
	"apprentice_background",
	"bastard_background",
	"beggar_background",
	"bowyer_background",
	"brawler_background",
	"butcher_background",
	"caravan_hand_background",
	"cripple_background",
	"cultist_background",
	"daytaler_background",
	"deserter_background",
	"disowned_noble_background",
	"eunuch_background",
	"farmhand_background",
	"fisherman_background",
	"flagellant_background",
	"gambler_background",
	"gladiator_background",
	"gravedigger_background",
	"graverobber_background",
	"hedge_knight_background",
	"historian_background",
	"houndmaster_background",
	"hunter_background",
	"juggler_background",
	"killer_on_the_run_background",
	"lumberjack_background",
	"mason_background",
	"messenger_background",
	"militia_background",
	"miller_background",
	"miner_background",
	"minstrel_background",
	"monk_background",
	"paladin_background",	// In Vanilla this background can always appear, even if the DLC is not active
	"peddler_background",
	"poacher_background",
	"ratcatcher_background",
	"raider_background",
	"refugee_background",
	"retired_soldier_background",
	"sellsword_background",
	"servant_background",
	"shepherd_background",
	"squire_background",
	"swordmaster_background",
	"tailor_background",
	"thief_background",
	"vagabond_background",
	"witchhunter_background",
	"wildman_background"
];

if (::Const.DLC.Unhold)
{
	::Const.HireableCharacterBackgrounds.extend([
		"beast_hunter_background"
	]);
}

if (::Const.DLC.Desert)
{
	::Const.HireableCharacterBackgrounds.extend([
		"assassin_southern_background",
		"beggar_southern_background",
		"butcher_southern_background",
		"caravan_hand_southern_background",
		"cripple_southern_background",
		"daytaler_southern_background",
		"eunuch_southern_background",
		"fisherman_southern_background",
		"gambler_southern_background",
		"historian_southern_background",
		"juggler_southern_background",
		"manhunter_background",
		"nomad_background",
		"nomad_ranged_background",
		"peddler_southern_background",
		"servant_southern_background",
		"shepherd_southern_background",
		"slave_background",
		"slave_southern_background",
		"tailor_southern_background",
		"thief_southern_background"
	]);
}

::ModularVanilla.QueueBucket.AfterHooks.push(function() {
	// Removes all duplicate CharacterBackgrounds, just in case some mod added duplicate backgrounds
	::Const.HireableCharacterBackgrounds = ::MSU.Array.uniques(::Const.HireableCharacterBackgrounds);
});
