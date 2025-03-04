::ModularVanilla.HooksHelper <- {
	// VanillaFix: vanilla manually calculates the damage range for this tooltip using CurrentProperties
	// whereas it should be using buildPropertiesForUse because otherwise it misses the damage buffs
	// which are applied during onAnySkillUsed from perks etc. Relevant for vanilla skills such as decapitate.
	function fixGetTooltipProperties(q)
	{
		q.getTooltip = @(__original) function()
		{
			local actor = this.getContainer().getActor();
			if (actor instanceof ::WeakTableRef)
			{
				actor = actor.get();
			}

			// Vanilla calls getCurrentProperties at the start of the __original function, so we switcheroo it
			// so that the first call to it returns the buildPropertiesForUse instead.
			local actor_getCurrentProperties = actor.getCurrentProperties;
			local skill = this;
			actor.getCurrentProperties = function()
			{
				this.getCurrentProperties = actor_getCurrentProperties;
				return this.getSkills().buildPropertiesForUse(skill, null);
			}

			local ret = __original();

			// Even though the switcheroo should've been reverted in the switcherooed function above, we manually
			// revert it just in case someone changed __original to never call getCurrentProperties.
			actor.getCurrentProperties = actor_getCurrentProperties;

			return ret;
		}
	}
};
