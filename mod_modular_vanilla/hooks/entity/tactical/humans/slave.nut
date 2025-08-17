::ModularVanilla.MH.hook("scripts/entity/tactical/humans/slave/", function (q) {
	// Part of actor.onOtherActorDeath modularization
	// Vanilla stops morale checks from dying allies by overwriting the `onOtherActorDeath` of individual entities e.g. assassin, conscript etc.
	// In Modular Vanilla we hook all those functions to always trigger morale checks but add functions to control whether a dying entity triggers them.
	// So we stop slaves from triggering it for their allies via these new functions.
	q.MV_isMoraleCheckValid = @(__original) { function MV_isMoraleCheckValid( _change, _type, _source, _info = null )
	{
		switch (_type)
		{
			case ::Const.MoraleCheckType.MV_DeathAlly:
			case ::Const.MoraleCheckType.MV_FleeAlly:
				return _source.getID() == this.getID() && !_target.isAlliedWith(this) && __original(_change, _type, _source, _info);

			default:
				return __original(_change, _type, _source, _info);
		}
	}}.MV_isMoraleCheckValid;
});
