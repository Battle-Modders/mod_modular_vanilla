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
			return __original(_activeEntity, _targetTile);
		}}.executeEntitySkill;

		// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/590691400522293303/
		// Vanilla does not trigger a skill container update for bros after they have been removed
		// from the combat map. This can lead to lingering effects on bros after the combat. We fix
		// this by adding an extra update after the bros are removed from combat.
		q.onFinish = @(__original) { function onFinish()
		{
			__original();
			foreach (bro in ::World.getPlayerRoster().getAll())
			{
				bro.getSkills().update();
			}
		}}.onFinish;
	});
});
