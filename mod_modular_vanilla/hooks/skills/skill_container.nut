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

	// MV: Added
	// Part of the actor.MV_interruptSkills framework
	q.MV_onSkillsInterrupted <- function()
	{
		local wasUpdating = this.m.IsUpdating;
		this.m.IsUpdating = true;

		foreach (s in this.m.Skills)
		{
			if (!s.isGarbage())
				s.MV_onSkillsInterrupted();
		}

		this.m.IsUpdating = wasUpdating;
		this.update();
	}

	// MV: Added
	// triggered from onAdded of disarmed_effect
	// but modders can also manually call this from other places as necessary.
	q.MV_onDisarmed <- function()
	{
		local wasUpdating = this.m.IsUpdating;
		this.m.IsUpdating = true;

		foreach (s in this.m.Skills)
		{
			if (!s.isGarbage())
				s.MV_onDisarmed();
		}

		this.m.IsUpdating = wasUpdating;
		this.update();
	}
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/skill_container", function (q) {
		q.m.__MV_InterruptionFrame <- 0; // Part of the actor.MV_interruptSkills framework
		q.m.__MV_InterruptionCount <- 0; // Part of the actor.MV_interruptSkills framework

		// Part of actor.MV_interruptSkills framework
		// In vanilla skills which "interrupt" a character remove: effects.shieldwall, effects.spearwall, effects.riposte
		// immediately one after the other i.e. it happens within a single frame. So we check if all 3 effects were
		// removed in a single frame and assume that the vanilla intention is to trigger an interruption of the actor.
		// This is done instead of hooking every single vanilla file which triggers these kinds of interruptions.
		// This implementation should also cover all mods which followed the vanilla style of removing those 3 effects only.
		// An exception is the disarmed_effect which doesn't remove shieldwall. For that we trigger a new event MV_onDisarmed
		// from disarmed_effect.onAdded directly.
		q.removeByID = @(__original) function( _skillID )
		{
			switch (_skillID)
			{
				case "effects.shieldwall":
				case "effects.spearwall":
				case "effects.riposte":
					local frame = ::Time.getFrame();
					if (frame != this.m.__MV_InterruptionFrame)
					{
						this.m.__MV_InterruptionCount = 0;
						this.m.__MV_InterruptionFrame = frame;
					}
					else
					{
						this.m.__MV_InterruptionCount++;
					}
					break;
			}

			__original(_skillID);

			if (this.m.__MV_InterruptionCount == 3)
			{
				this.m.__MV_InterruptionCount = 0;
				this.getActor().MV_interruptSkills();
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
