::ModularVanilla.MH.hook("scripts/skills/actives/voice_of_davkul_skill", function(q) {
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/764060301066826191/
	// Missing null check for Background. Relevant for player characters without background e.g. `envoy` and `firstborn`.
	q.onUse = @() { function onUse( _user, _targetTile )
	{
		foreach (a in ::Tactical.Entities.getAllInstancesAsArray())
		{
			if (a.getID() == _user.getID() || a.getFatigue() == 0)
			{
				continue;
			}

			// Add null check for background
			if (a.getType() == ::Const.EntityType.Cultist || a.isPlayerControlled() && !::MSU.isNull(a.getBackground()) && (a.getBackground().getID() == "background.cultist" || a.getBackground().getID() == "background.converted_cultist"))
			{
				a.getSkills().add(::new("scripts/skills/effects/voice_of_davkul_effect"));
			}
		}

		return true;
	}}.onUse;
});
