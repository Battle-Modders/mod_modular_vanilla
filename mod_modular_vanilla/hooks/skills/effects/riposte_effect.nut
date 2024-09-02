::ModularVanilla.MH.hook("scripts/skills/effects/riposte_effect", function(q) {
// Modular Vanilla Functions
	// Part of the actor.interrupt framework
	q.onActorInterrupted = @() function()
	{
		if (_offensive)
			this.removeSelf();
	}
});
