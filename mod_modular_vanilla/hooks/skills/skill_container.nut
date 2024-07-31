// MV: Added
// Part of the actor.interrupt framework
::MSU.Skills.addEvent("onActorInterrupted", function( _offensive, _defensive ) {});

::ModularVanilla.MH.hook("scripts/skills/skill_container", function(q) {
	// MV: Added
	// part of affordability preview system
	// Helper function to do a "preview" type update.
	// Each preview update with `_isPreviewing = true` must always be followed
	// by a preview update with `_isPreviewing = false` to ensure that the
	// properties of the character do not remain at the values for previewing.
	// Therefore, usually it is better to use the other `MV_runBetweenPreviewUpdates` function
	// and put your stuff in a function and pass it to that function.
	q.MV_doPreviewUpdate <- { function MV_doPreviewUpdate( _isPreviewing = true )
	{
		local actor = this.getActor();
		local wasPreviewing = actor.m.MV_IsPreviewing;

		actor.m.MV_IsPreviewing = _isPreviewing;

		actor.m.MV_IsDoingPreviewUpdate = true;
		this.update();
		actor.m.MV_IsDoingPreviewUpdate = false;

		actor.m.MV_IsPreviewing = wasPreviewing;
	}}.MV_doPreviewUpdate;

	// MV: Added
	// part of affordability preview system
	// Helper function to run some functionality between two preview updates. The goal is
	// that the passed _function will run assuming the "preview" state of the actor. E.g.
	// get the hit-chance of a skill against another depending on the previewed state instead
	// of current state.
	// _env must be the env with which to call _function.
	// _function can have arbitrary number of params.
	// vargv can be passed and they will all be passed to _function.
	// Returns the return of _function.
	q.MV_runBetweenPreviewUpdates <- { function MV_runBetweenPreviewUpdates( _function, _env, ... )
	{
		this.MV_doPreviewUpdate();
		vargv.insert(0, _env);
		local ret = _function.acall(vargv);
		this.MV_doPreviewUpdate(false);
		return ret;
	}}.MV_runBetweenPreviewUpdates;

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
	// Part of modularization of actor.setMoraleState
	q.MV_onMoraleStateChanged <- { function MV_onMoraleStateChanged( _oldState )
	{
		local wasUpdating = this.m.IsUpdating;
		this.m.IsUpdating = true;
		foreach (s in this.m.Skills)
		{
			if (!s.isGarbage())
				s.MV_onMoraleStateChanged(_oldState);
		}
		this.m.IsUpdating = wasUpdating;

		this.update();
	}}.MV_onMoraleStateChanged;
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
	});
});
