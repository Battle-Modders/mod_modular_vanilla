::ModularVanilla.MH.hook("scripts/states/tactical_state", function(q) {
	// Each element in this array is a weakref to an instance of MV_AttackInfo during skill.attackEntity.
	// The purpose is to allow access to the attackInfo from all functions which
	// do not get it passed directly e.g. onTargetMissed.
	q.m.__MV_CurrentAttackInfos <- [];
	// Each element in this array is a weakref to an instance of HitInfo during actor.onDamageReceived.
	// The purpose is to allow access to the HitInfo from all functions which
	// do not get it passed directly.
	// Note: We populate it during actor.onDamageReceived only. However, during regular skill attack
	// HitInfo is also first passed to onBeforeTargetHit (in skill.onScheduledTargetHit).
	q.m.__MV_CurrentHitInfos <- [];

	q.MV_getCurrentHitInfo <- { function MV_getCurrentHitInfo()
	{
		for (local i = this.m.__MV_CurrentHitInfos.len() - 1; i >= 0; i--)
		{
			local info = this.m.__MV_CurrentHitInfos[i];
			if (info != null)
			{
				return info;
			}
		}
	}}.MV_getCurrentHitInfo;

	q.MV_getCurrentAttackInfo <- { function MV_getCurrentAttackInfo()
	{
		for (local i = this.m.__MV_CurrentAttackInfos.len() - 1; i >= 0; i--)
		{
			local info = this.m.__MV_CurrentAttackInfos[i];
			if (info != null)
			{
				return info;
			}
		}
	}}.MV_getCurrentAttackInfo;
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/states/tactical_state", function(q) {
		// MV: Changed
		// part of affordability preview system
		q.executeEntityTravel = @(__original) { function executeEntityTravel( _activeEntity, _mouseEvent )
		{
			_activeEntity.resetPreview();
			return __original(_activeEntity, _mouseEvent);
		}}.executeEntityTravel;

		// MV: Changed
		// part of affordability preview system
		q.executeEntitySkill = @(__original) { function executeEntitySkill( _activeEntity, _targetTile )
		{
			_activeEntity.resetPreview();

			// Skills may have varying costs depending on their selected target. So, before skill execution
			// we check the affordability of the skill by setting the selected target to _targetTile.
			local skill = _activeEntity.getSkills().getSkillByID(this.m.SelectedSkillID);
			if (skill != null && skill.isTargeted() && skill.verifyTargetAndRange(_targetTile))
			{
				// skill.m.MV_SelectedTarget is expected to be null here because
				// target gets deselected before skill execution, so we have to set it again
				// here so that the isAffordable check gets the correct costs.
				local original_SelectedTarget = skill.m.MV_SelectedTarget;
				skill.m.MV_SelectedTarget = _targetTile;

				if (!skill.isAffordable())
				{
					// This is a copy of how vanilla does flashing and sound in `tactical_state.setActionStateByMouseEvent`.
					::Tactical.TurnSequenceBar.flashProgressbars(!skill.isAffordableBasedOnAP(), !skill.isAffordableBasedOnFatigue());
					if (this.m.LastFatigueSoundTime + 3.0 < ::Time.getVirtualTimeF())
					{
						_activeEntity.playSound(::Const.Sound.ActorEvent.Fatigue, ::Const.Sound.Volume.Actor * _activeEntity.m.SoundVolume[::Const.Sound.ActorEvent.Fatigue]);
						this.m.LastFatigueSoundTime = ::Time.getVirtualTimeF();
					}

					// We reset the affordability preview at the start of this function
					// (to ensure we get costs for usage instead of preview)
					// therefore, we have to restore it here by selecting the target again.
					skill.onTargetSelected(_targetTile);
					return;
				}

				skill.m.MV_SelectedTarget = original_SelectedTarget;
			}

			return __original(_activeEntity, _targetTile);
		}}.executeEntitySkill;
	});
});
