::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/ui/screens/tactical/modules/turn_sequence_bar/turn_sequence_bar", function(q) {
		q.m.__MV_FirstSlotEntityID <- null;
		q.create = @(__original) function()
		{
			__original();
			this.m.MV_JSHandle <- {
				__JSHandle = null,
				function asyncCall( _funcName, ... )
				{
					if (_funcName == "updateCostsPreview")
						return;

					vargv.insert(0, _funcName);
					vargv.insert(0, this);
					this.__JSHandle.asyncCall.acall(vargv);
				}
			}
			this.m.MV_JSHandle.setdelegate({
				function _get( _key )
				{
					if (_key in this.__JSHandle)
						return this.__JSHandle[_key];
					throw null;
				}
			});
		}

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
		q.setActiveEntityCostsPreview = @(__original) { function setActiveEntityCostsPreview( _costsPreview )
		{
			local activeEntity = this.getActiveEntity();
			if (activeEntity == null || ::getModSetting("mod_msu", "ExpandedSkillTooltips").getValue() == false)
				return __original(_costsPreview);

			// The original function also updates the UI, but we don't want to do that yet,
			// we want to do that after our skill container affordability event has run.
			// If we don't switcheroo to disable it here, then we'd need to manually call `updateCostsPreview`
			// on the JSHandle at the end again, and this can lead to slightly glitchy UI animation due to double updating.
			this.m.MV_JSHandle.__JSHandle = this.m.JSHandle;
			this.m.JSHandle = this.m.MV_JSHandle;
			__original(_costsPreview);
			this.m.JSHandle = this.m.MV_JSHandle.__JSHandle;

			if ("SkillID" in _costsPreview)
			{
				activeEntity.m.MV_PreviewSkill = ::MSU.asWeakTableRef(activeEntity.getSkills().getSkillByID(_costsPreview.SkillID));
			}
			else
			{
				activeEntity.m.MV_PreviewMovement = ::Tactical.getNavigator().getCostForPath(activeEntity, ::Tactical.getNavigator().getLastSettings(), activeEntity.getActionPoints(), activeEntity.getFatigueMax() - activeEntity.getFatigue());
			}

			activeEntity.m.MV_CostsPreview = _costsPreview;
			activeEntity.m.MV_IsPreviewing = true;

			activeEntity.getSkills().MV_runBetweenPreviewUpdates(this.MV_doCostsPreview, this, activeEntity);
		}}.setActiveEntityCostsPreview;

		q.MV_doCostsPreview <- { function MV_doCostsPreview( _activeEntity )
		{
			_activeEntity.getSkills().onCostsPreview(this.m.ActiveEntityCostsPreview);

			this.m.ActiveEntityCostsPreview.actionPointsMaxPreview = ::Math.max(0, this.m.ActiveEntityCostsPreview.actionPointsMaxPreview);
			this.m.ActiveEntityCostsPreview.fatigueMaxPreview = ::Math.max(0, this.m.ActiveEntityCostsPreview.fatigueMaxPreview);

			if (this.m.ActiveEntityCostsPreview.actionPointsPreview < 0)
			{
				this.m.ActiveEntityCostsPreview.actionPointsPreview = _activeEntity.getActionPoints();
			}

			if (this.m.ActiveEntityCostsPreview.fatiguePreview > this.m.ActiveEntityCostsPreview.fatigueMaxPreview)
			{
				this.m.ActiveEntityCostsPreview.fatiguePreview = this.m.ActiveEntityCostsPreview.fatigueMaxPreview;
			}

			_activeEntity.setPreviewActionPoints(this.m.ActiveEntityCostsPreview.actionPointsPreview);
			_activeEntity.setPreviewFatigue(this.m.ActiveEntityCostsPreview.fatiguePreview);

			this.m.JSHandle.asyncCall("updateCostsPreview", this.m.ActiveEntityCostsPreview);
		}}.MV_doCostsPreview;

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
