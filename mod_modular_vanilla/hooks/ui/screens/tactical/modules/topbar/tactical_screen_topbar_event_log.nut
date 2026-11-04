::ModularVanilla.MH.hook("scripts/ui/screens/tactical/modules/topbar/tactical_screen_topbar_event_log", function(q) {
	// MV: Changed
	// Part of ::ModularVanilla.Simulation: no event log entries while simulating
	foreach (name in ["log", "logEx", "log_newline"])
	{
		q[name] = @(__original) function( ... )
		{
			if (::ModularVanilla.Simulation.isActive())
				return;

			vargv.insert(0, this);
			return __original.acall(vargv);
		}
	}
});
