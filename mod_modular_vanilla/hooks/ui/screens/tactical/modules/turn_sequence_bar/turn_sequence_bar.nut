::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/ui/screens/tactical/modules/turn_sequence_bar/turn_sequence_bar", function(q) {
		// MV: Changed
		// part of affordability preview system
		q.setActiveEntityCostsPreview = @() function( _costsPreview )
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
				activeEntity.m.MV_PreviewSkill = activeEntity.getSkills().getSkillByID(_costsPreview.SkillID);
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
			if (this.m.ActiveEntityCostsPreview.actionPointsPreview < 0)
			{
				this.m.ActiveEntityCostsPreview.actionPointsPreview = activeEntity.getActionPoints();
			}
			this.m.ActiveEntityCostsPreview.actionPointsMaxPreview <- activeEntity.getActionPointsMax();

			this.m.ActiveEntityCostsPreview.fatiguePreview <- activeEntity.getFatigue() + _costsPreview.Fatigue;
			if (this.m.ActiveEntityCostsPreview.fatiguePreview > activeEntity.getFatigueMax())
			{
				this.m.ActiveEntityCostsPreview.fatiguePreview = activeEntity.getFatigueMax();
			}
			this.m.ActiveEntityCostsPreview.fatigueMaxPreview <- activeEntity.getFatigueMax();

			activeEntity.setPreviewActionPoints(this.m.ActiveEntityCostsPreview.actionPointsPreview);
			activeEntity.setPreviewFatigue(this.m.ActiveEntityCostsPreview.fatiguePreview);

			this.m.JSHandle.asyncCall("updateCostsPreview", this.m.ActiveEntityCostsPreview);

			activeEntity.m.MV_IsPreviewing = false;
			activeEntity.m.MV_IsDoingPreviewUpdate = true;
			activeEntity.getSkills().update();
			activeEntity.m.MV_IsDoingPreviewUpdate = false;
			activeEntity.m.MV_IsPreviewing = true;
		}

		// MV: Changed
		// part of affordability preview system
		q.resetActiveEntityCostsPreview = @(__original) function()
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
		}
	});
});
