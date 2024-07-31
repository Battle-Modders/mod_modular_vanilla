// MV: Added
// Part of the actor.interrupt framework
::MSU.Skills.addEvent("onActorInterrupted", function( _offensive, _defensive ) {});

::ModularVanilla.MH.hook("scripts/skills/skill_container", function(q) {
	// MV: Added
	// part of player_party.updateStrength modularization
	q.MV_getPlayerPartyStrengthMult <- function()
	{
		local ret = 1.0;

		local wasUpdating = this.m.IsUpdating;
		this.m.IsUpdating = true;
		foreach (s in this.m.Skills)
		{
			if (!s.isGarbage())
				ret *= s.MV_getPlayerPartyStrengthMult();
		}
		this.m.IsUpdating = wasUpdating;

		return ret;
	}
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/skill_container", function (q) {
		q.m.MV_InterruptionFrame <- 0; // Part of the actor.interrupt framework
		q.m.MV_InterruptionCount <- 0; // Part of the actor.interrupt framework

		// Part of actor.interrupt framework
		// In vanilla skills which "interrupt" a character remove: effects.shieldwall, effects.spearwall, effects.riposte
		// immediately one after the other i.e. it happens within a single frame. So we check if all 3 effects were
		// removed in a single frame and assume that the vanilla intention is to trigger an interruption of the actor.
		// This is done instead of hooking every single vanilla file which triggers these kinds of interruptions.
		// This implementation should also cover all mods which followed the vanilla style of removing those 3 effects only.
		// An exception is the disarmed_effect which doesn't remove shieldwall. For that we hook that effect directly and do
		// offensive interrupt only.
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

		// MV: Changed
		// part of affordability preview system
		// Prevent collectGarbage from running during a preview type skill_container.update
		q.collectGarbage = @(__original) function( _performUpdate = true )
		{
			if (!this.getActor().m.MV_IsDoingPreviewUpdate)
				return __original(_performUpdate);
		}

		// MV: Changed
		// part of affordability preview system
		q.onTurnEnd = @(__original) function()
		{
			this.getActor().resetPreview();
			return __original();
		}

		// MV: Changed
		// part of affordability preview system
		q.onWaitTurn = @(__original) function()
		{
			this.getActor().resetPreview();
			return __original();
		}

		// MV: Changed
		// part of affordability preview system
		q.onCombatFinished = @(__original) function()
		{
			this.getActor().resetPreview();
			return __original();
		}

		// MV: Added
		// called from behavior.queryTargetValue
		q.getQueryTargetValueMult <- function( _entity, _target, _skill )
		{
			local ret = 1.0;

			local wasUpdating = this.m.IsUpdating;
			this.m.IsUpdating = true;
			foreach (skill in this.m.Skills)
			{
				if (!skill.isGarbage())
				{
					ret *= skill.getQueryTargetValueMult(_entity, _target, _skill);
				}
			}
			this.m.IsUpdating = wasUpdating;

			return ret;
		}

		q.onCostsPreview <- function( _costsPreview )
		{
			local wasUpdating = this.m.IsUpdating;
			this.m.IsUpdating = true;
			foreach (skill in this.m.Skills)
			{
				if (!skill.isGarbage())
				{
					skill.onCostsPreview(_costsPreview);
				}
			}
			this.m.IsUpdating = wasUpdating;
		}
	});
});
