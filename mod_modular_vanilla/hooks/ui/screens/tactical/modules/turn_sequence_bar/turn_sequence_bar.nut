::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/ui/screens/tactical/modules/turn_sequence_bar/turn_sequence_bar", function(q) {
		q.m.__MV_FirstSlotEntityID <- null;

		// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/604155219069147354/
		// Vanilla calls this function whenever an entity who is visible in the turn sequence bar is pushed back in
		// the sequence resulting in calling `entity.onTurnResumed` on the currently active actor prematurely.
		// Our fix is a bandaid which returns early when calling this function on an entity already in the first slot.
		q.onEntityEntersFirstSlot = @(__original) { function onEntityEntersFirstSlot( _entityId )
		{
			if (_entityId == this.m.__MV_FirstSlotEntityID)
			{
				local entity = this.findEntityByID(this.m.AllEntities, _entityId);
				if (entity != null)
				{
					return this.convertEntityToUIData(entity.entity, entity.index == this.m.CurrentEntities.len() - 1);
				}
			}
			this.m.__MV_FirstSlotEntityID = _entityId;
			return __original(_entityId);
		}}.onEntityEntersFirstSlot;

		q.initNextRound = @(__original) { function initNextRound()
		{
			local tp = this.m.TurnPosition;
			__original();
			if (tp != this.m.TurnPosition)
			{
				this.m.__MV_FirstSlotEntityID = null;
			}
		}}.initNextRound;

		q.initNextTurn = @(__original) { function initNextTurn( _force = false )
		{
			// initNextTurn is called from tactical_state.onUpdate multiple times even
			// after onEntityEntersFirstSlot has been called. Therefore, we need to check
			// if the call actually resulted in changing the TurnPosition and only
			// set the __MV_FirstSlotEntityID to null in that case.
			local tp = this.m.TurnPosition;
			__original(_force);
			if (tp != this.m.TurnPosition)
			{
				this.m.__MV_FirstSlotEntityID = null;
			}
		}}.initNextTurn;

		q.initNextTurnBecauseOfWait = @(__original) { function initNextTurnBecauseOfWait()
		{
			local tp = this.m.TurnPosition;
			__original();
			if (tp != this.m.TurnPosition)
			{
				this.m.__MV_FirstSlotEntityID = null;
			}
			__original();
		}}.initNextTurnBecauseOfWait;

		// MV: Changed
		// part of affordability preview system
		q.setActiveEntityCostsPreview = @() { function setActiveEntityCostsPreview( _costsPreview )
		{
			local activeEntity = this.getActiveEntity();
			if (activeEntity == null || ::getModSetting("mod_msu", "ExpandedSkillTooltips").getValue() == false)
				return;

			if (this.m.ActiveEntityCostsPreview == null)
				this.m.ActiveEntityCostsPreview = {};

			this.m.ActiveEntityCostsPreview.id <- activeEntity.getID();

			if (!("ActionPoints" in _costsPreview))
				_costsPreview.ActionPoints <- 0;
			if (!("Fatigue" in _costsPreview))
				_costsPreview.Fatigue <- 0;

			if ("SkillID" in _costsPreview)
			{
				activeEntity.m.MV_PreviewSkill = ::MSU.asWeakTableRef(activeEntity.getSkills().getSkillByID(_costsPreview.SkillID));
				activeEntity.setPreviewSkillID(_costsPreview.SkillID);
			}
			else
			{
				activeEntity.setPreviewSkillID("");
				activeEntity.m.MV_PreviewMovement = ::Tactical.getNavigator().getCostForPath(activeEntity, ::Tactical.getNavigator().getLastSettings(), activeEntity.getActionPoints(), activeEntity.getFatigueMax() - activeEntity.getFatigue());
			}

			// Compatibility patch to run MSU affordability preview system because we overwrite this function completely
			activeEntity.getSkills().m.IsPreviewing = true;
			activeEntity.getSkills().onAffordablePreview(activeEntity.m.MV_PreviewSkill, activeEntity.m.MV_PreviewMovement == null ? null : activeEntity.m.MV_PreviewMovement.End);
			// --

			activeEntity.m.MV_CostsPreview = _costsPreview;
			activeEntity.m.MV_IsPreviewing = true;
			activeEntity.m.MV_IsDoingPreviewUpdate = true;
			activeEntity.getSkills().update();
			activeEntity.m.MV_IsDoingPreviewUpdate = false;

			this.m.ActiveEntityCostsPreview.actionPointsPreview <- activeEntity.getActionPoints() - _costsPreview.ActionPoints;
			this.m.ActiveEntityCostsPreview.actionPointsMaxPreview <- activeEntity.getActionPointsMax();
			this.m.ActiveEntityCostsPreview.fatiguePreview <- activeEntity.getFatigue() + _costsPreview.Fatigue;
			this.m.ActiveEntityCostsPreview.fatigueMaxPreview <- activeEntity.getFatigueMax();

			activeEntity.getSkills().onCostsPreview(this.m.ActiveEntityCostsPreview);

			this.m.ActiveEntityCostsPreview.actionPointsMaxPreview = ::Math.max(0, this.m.ActiveEntityCostsPreview.actionPointsMaxPreview);
			this.m.ActiveEntityCostsPreview.fatigueMaxPreview = ::Math.max(0, this.m.ActiveEntityCostsPreview.fatigueMaxPreview);

			if (this.m.ActiveEntityCostsPreview.actionPointsPreview < 0)
			{
				this.m.ActiveEntityCostsPreview.actionPointsPreview = activeEntity.getActionPoints();
			}

			if (this.m.ActiveEntityCostsPreview.fatiguePreview > this.m.ActiveEntityCostsPreview.fatigueMaxPreview)
			{
				this.m.ActiveEntityCostsPreview.fatiguePreview = this.m.ActiveEntityCostsPreview.fatigueMaxPreview;
			}

			activeEntity.setPreviewActionPoints(this.m.ActiveEntityCostsPreview.actionPointsPreview);
			activeEntity.setPreviewFatigue(this.m.ActiveEntityCostsPreview.fatiguePreview);

			this.m.JSHandle.asyncCall("updateCostsPreview", this.m.ActiveEntityCostsPreview);

			activeEntity.m.MV_IsPreviewing = false;
			activeEntity.m.MV_IsDoingPreviewUpdate = true;
			activeEntity.getSkills().update();
			activeEntity.m.MV_IsDoingPreviewUpdate = false;
			activeEntity.m.MV_IsPreviewing = true;
		}}.setActiveEntityCostsPreview;

		// MV: Changed
		// part of affordability preview system
		q.resetActiveEntityCostsPreview = @(__original) { function resetActiveEntityCostsPreview()
		{
			local activeEntity = this.getActiveEntity();
			if (activeEntity != null)
			{
				// Compatibility patch for MSU affordability preview system
				activeEntity.getSkills().m.IsPreviewing = false;
				// --
				activeEntity.resetPreview();
			}
			__original();
		}}.resetActiveEntityCostsPreview;
	});
});
