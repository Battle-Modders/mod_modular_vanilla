::ModularVanilla.MH.hook("scripts/skills/character_background", function (q) {
	// MV: Added
	// Allows this background to return a different ID during events so that new backgrounds
	// added by mods work seamlessly with events that check for particular background IDs in their conditions
	q.MV_getIDForEvent <- function( _eventID )
	{
		return this.m.ID;
	}
});

::ModularVanilla.QueueBucket.VeryLate.push(function() {
	::ModularVanilla.MH.hook("scripts/skills/character_background", function (q) {
		// MV: Changed
		// part of character_background.MV_getIDForEvent framework
		// Return the ID from MV_getIDForEvent during events being set up
		q.getID  = @(__original) function()
		{
			return ::ModularVanilla.__EventIDForBGProxy != null ? this.MV_getIDForEvent(::ModularVanilla.__EventIDForBG) : __original();
		}
	});
});
