::ModularVanilla.MH.hook("scripts/items/weapons/goedendag", function(q) {
	q.create = @(__original) function()
	{
		__original();
		this.m.IsAoE = false;	// Vanilla Fix: Goedendag has no AoE effect but is still somehow marked as an AoE weapon
	}
});
