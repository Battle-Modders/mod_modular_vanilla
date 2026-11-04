// MV: Changed
// Part of ::ModularVanilla.Simulation: suppress effects while simulating
foreach (name in ["spawnEntity", "addEntityToMap", "getShaker", "spawnIconEffect", "spawnParticleEffect", "spawnHeadEffect", "spawnProjectileEffect", "spawnAttackEffect", "spawnSpriteEffect", "spawnPoolEffect"])
{
	::ModularVanilla.Simulation.suppressNative(::Tactical, name);
}
