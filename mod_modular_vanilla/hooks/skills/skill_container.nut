::ModularVanilla.MH.hook("scripts/skills/skill_container", function(q) {
	// MV: Added
	// called from behavior.queryTargetValue
	q.getQueryTargetValueMult <- { function getQueryTargetValueMult( _entity, _target, _skill )
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
	}}.getQueryTargetValueMult;

	q.onCostsPreview <- { function onCostsPreview( _costsPreview )
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
	}}.onCostsPreview;

	// MV: Added
	// part of MV_onBeforeAnySkillAdded skill_container event.
	// The event is triggered via skill_container.add BEFORE the skill is added.
	// If any existing skill returns `false`, then the skill will not be added to the container.
	q.MV_onBeforeAnySkillAdded <- { function MV_onBeforeAnySkillAdded( _skill )
	{
		local wasUpdating = this.m.IsUpdating;
		this.m.IsUpdating = true;
		local ret = true;
		foreach (skill in this.m.Skills)
		{
			if (!skill.isGarbage())
			{
				if (!skill.MV_onBeforeAnySkillAdded(_skill))
				{
					ret = false;
					break;
				}
			}
		}
		this.m.IsUpdating = wasUpdating;
		return ret;
	}}.MV_onBeforeAnySkillAdded;
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/skill_container", function (q) {
		// MV: Changed
		// part of affordability preview system
		// Prevent collectGarbage from running during a preview type skill_container.update
		q.collectGarbage = @(__original) { function collectGarbage( _performUpdate = true )
		{
			if (!this.getActor().m.MV_IsDoingPreviewUpdate)
				return __original(_performUpdate);
		}}.collectGarbage;

		// MV: Changed
		// part of affordability preview system
		q.onTurnEnd = @(__original) { function onTurnEnd()
		{
			this.getActor().resetPreview();
			return __original();
		}}.onTurnEnd;

		// MV: Changed
		// part of affordability preview system
		q.onWaitTurn = @(__original) { function onWaitTurn()
		{
			this.getActor().resetPreview();
			return __original();
		}}.onWaitTurn;

		// MV: Changed
		// part of affordability preview system
		q.onCombatFinished = @(__original) { function onCombatFinished()
		{
			this.getActor().resetPreview();
			return __original();
		}}.onCombatFinished;

		// MV: Changed
		// part of MV_onBeforeAnySkillAdded skill_container event.
		q.add = @(__original) { function add( _skill, _order = 0 )
		{
			if (this.MV_onBeforeAnySkillAdded(_skill))
			{
				__original(_skill, _order);
			}
		}}.add;
	});
});
