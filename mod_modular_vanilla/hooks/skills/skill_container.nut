::ModularVanilla.MH.hook("scripts/skills/skill_container", function(q) {
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
	});
});
