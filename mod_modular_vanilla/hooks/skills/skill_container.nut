// MV: Added
// Part of the actor.interrupt framework
// The `onActorInterrupted` event is designed to allow skills to react to the actor experiencing an interruption. For example by removing themselves or losing stacks.
// This event can be triggered by various factors such as stagger, stuns, knock backs, or other mechanics that disrupt an actor for at least a few seconds.
// As a rule of thumb. If an effect is the representation of something that the actor is currently actively doing, then it should be removed when that actor is interrupted.
// List of Vanilla skills which can be interrupted:
// - riposte, spearwall, shieldwall
::MSU.Skills.addEvent("onActorInterrupted", function() {});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/skill_container", function(q) {
		q.m.MV_InterruptionFrame <- 0; // Part of the actor.interrupt framework
		q.m.MV_InterruptionCount <- 0; // Part of the actor.interrupt framework

		// Part of actor.interrupt framework
		// In vanilla skills which "interrupt" a character remove: effects.shieldwall, effects.spearwall, effects.riposte
		// immediately one after the other i.e. it happens within a single frame. So we check if all 3 effects were
		// removed in a single frame and assume that the vanilla intention is to trigger an interruption of the actor.
		// This is done instead of hooking every single vanilla file which triggers these kinds of interruptions.
		// This implementation should also cover all mods which followed the vanilla style of removing those 3 effects only.
		q.removeByID = @(__original) function( _skillID )
		{
			switch (_skillID)
			{
				case "effects.shieldwall":
				case "effects.spearwall":
				case "effects.riposte":
					local frame = ::Time.getFrame();
					if (frame != this.m.MV_InterruptionFrame)
					{
						this.m.MV_InterruptionCount = 0;
						this.m.MV_InterruptionFrame = frame;
					}
					else
					{
						this.m.MV_InterruptionCount++;
					}
					break;
			}

			__original(_skillID);

			if (this.m.MV_InterruptionCount >= 2)
			{
				this.m.MV_InterruptionCount = 0;
				this.getActor().interrupt();
			}
		}
	});
});
