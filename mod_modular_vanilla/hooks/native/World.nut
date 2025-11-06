local function worldEntitySpawnedCallback( _entity )
{
	::World.Assets.getOrigin().MV_onWorldEntitySpawned(_entity);
}

local spawnEntity = ::World.spawnEntity;
::World.spawnEntity <- { function spawnEntity( ... )
{
	vargv.insert(0, this);
	local ret = spawnEntity.acall(vargv);
	if (::World.Assets.getOrigin() != null)
	{
		worldEntitySpawnedCallback(ret);
	}
	else
	{
		// ScheduleEvent because during New Campaign, world entities are spawned before
		// the Origin is loaded, so getOrigin() will return null.
		// Using TimeUnit.Virtual here doesn't work during New Campaign when world is being
		// generated, but works after that normally. TimeUnit.Real works in both situations - no idea why.
		::Time.scheduleEvent(::TimeUnit.Real, 1, worldEntitySpawnedCallback, ret);
	}
	return ret;
}}.spawnEntity;

local spawnLocation = ::World.spawnLocation;
::World.spawnLocation <- { function spawnLocation( ... )
{
	vargv.insert(0, this);
	local ret = spawnLocation.acall(vargv);
	if (::World.Assets.getOrigin() != null)
	{
		worldEntitySpawnedCallback(ret);
	}
	else
	{
		// ScheduleEvent because during New Campaign, world entities are spawned before
		// the Origin is loaded, so getOrigin() will return null.
		// Using TimeUnit.Virtual here doesn't work during New Campaign when world is being
		// generated, but works after that normally. TimeUnit.Real works in both situations - no idea why.
		::Time.scheduleEvent(::TimeUnit.Real, 1, worldEntitySpawnedCallback, ret);
	}
	return ret;
}}.spawnLocation;
