function add_zombie_special_drop(powerup_name)
{
	if(!isdefined(level.zombie_special_drop_array))
	{
		level.zombie_special_drop_array = [];
	}
	level.zombie_special_drop_array[level.zombie_special_drop_array.size] = powerup_name;
}

PowerUpSpawnLocation(location)
{
    self.PowerUpSpawnLocation = location;
}

SpawnPowerUp(powerup, loc)
{
    if(!isDefined(loc))
        loc = (self.PowerUpSpawnLocation == "Self") ? self.origin : self TraceBullet();
    
    if(powerup == "Spawn All")
    {
        self thread zm_bgb_reign_drops::activation();
        return;
    }
    
    drop = level zm_powerups::specific_powerup_drop(powerup, loc);

    if(isDefined(level.powerup_drop_count) && level.powerup_drop_count)
        level.powerup_drop_count--;
}