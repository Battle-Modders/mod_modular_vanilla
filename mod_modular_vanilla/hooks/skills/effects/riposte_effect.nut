::ModularVanilla.MH.hook("scripts/skills/effects/riposte_effect", function(q) {
	// This skill is dependent on a weapon being present
	q.onAfterUpdate = @(__original) function( _properties )
	{
		__original(_properties);
		if (this.getContainer().getActor().isDisarmed())
		{
			this.removeSelf();
		}
	}

// Modular Vanilla Functions
	// Part of the actor.interrupt framework
	q.onActorInterrupted = @() function()
	{
		if (_offensive)
			this.removeSelf();
	}
});
