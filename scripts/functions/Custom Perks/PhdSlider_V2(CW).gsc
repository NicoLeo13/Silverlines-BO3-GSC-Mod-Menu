//PhD Flopper
DoPhdExplosionV2()
{
    damage = 1500;
	start = self.origin;
	
    self.PhdAirborne = undefined;
    
    while(self IsSliding())
	{
        if(!self IsOnGround())
        {
            // self iPrintLnBold("In Air");
			dif = start[2] - self.origin[2];
            damage = damage + int(dif * 2);
            self.PhdAirborne = true;
        }
        airborne = ((isDefined(self.PhdAirborne) && self.PhdAirborne) ? true : undefined);
        
        distance = Distance(start, self.origin);
        self.PhdSlideDist = self.PhdSlideDist + distance;
		if(self.PhdSlideDist >= 64)
        {
			// a_zombies = zombie_utility::get_round_enemy_array();
			// a_zombies = util::get_array_of_closest(self.origin, a_zombies, undefined, a_zombies.size, 96);
			a_zombies = getaiteamarray(level.zombie_team);
			a_zombies = arraysortclosest(a_zombies, self.origin, a_zombies.size, 0, 96);
            if(isarray(a_zombies) && a_zombies.size >= 1)
            {
                if(isalive(a_zombies[0]))
				{
					self iPrintLnBold("Enemy Close");
					// self iPrintLnBold(self.PhdSlideDist);
					self setvelocity((0, 0, 0));
					self slide_explosion(self.PhdSlideDist, airborne, damage);
					return;
				}
            }
        }
		wait 0.05;
	}
}


slide_explosion(SlideDistance, jumpDone, baseDamage)
{
	start = self getOrigin();

	while(self IsSliding())
	{
		if(!self IsOnGround())
        {
            // self iPrintLnBold("In Air");
			dif = start[2] - self.origin[2];
            baseDamage = baseDamage + int(dif * 2);
            jumpDone = true;
        }
		distance = Distance(start, self.origin);
		SlideDistance = SlideDistance + distance;
		wait 0.05;
	}
	
	if(!isdefined(jumpDone))
	{
		jumpDone = 0;
	}
	damage = 0;
	explosion_radius = 0;

	if(SlideDistance < 64)
	{
		explosion_radius = 96;
		damage = 150;
	}
	else
	{
		if(SlideDistance < 128 && SlideDistance >= 64)
		{
			explosion_radius = 128;
			damage = 200;
		}
		else
		{
			if(SlideDistance < 256 && SlideDistance >= 128)
			{
				explosion_radius = 176;
				damage = 250;
			}
			else
			{
				if(SlideDistance < 512 && SlideDistance >= 256)
				{
					explosion_radius = 256;
					damage = 300;
				}
				else if(SlideDistance >= 512)
				{
					explosion_radius = 350;
					damage = 350;
				}
			}
		}
	}
    damage = damage + baseDamage;
	if(!isDefined(self.PhdExplosionPlaying))
	{
		self iPrintLnBold("Radius: ^5" + explosion_radius);
		self thread CwPhdExplosion(damage, explosion_radius, jumpDone);
	}
}

CwPhdExplosion(damage, explosion_radius, jumpDone)
{
	start = self.origin;

	if(!isdefined(damage))
	{
		damage = 25;
	}
	if(!isdefined(explosion_radius))
	{
		explosion_radius = 64;
	}
	if(!isdefined(jumpDone))
	{
		jumpDone = 0;
	}
	self endon("death");
	self notify("PhdExplosion");
	self endon("PhdExplosion");
	self.PhdExplosionPlaying = 1;

	while(self IsSliding())
	{
		if(!self IsOnGround())
        {
            dif = start[2] - self.origin[2];
            damage = damage + int(dif * 2);
            jumpDone = true;
        }
		wait 0.05;
	}

    // self setvelocity((0, 0, 0));
	explosion_pos = (self.origin[0], self.origin[1], self.origin[2] + 25);
	forward = anglestoforward(self.angles);
	forward = vectornormalize(forward);
	forward = vectorscale(forward, 64);
	explosion_pos = explosion_pos + forward;
	playsoundatposition("zmb_bgb_powerup_burnedout", explosion_pos + vectorscale((0, 0, 1), 30));

	a_zombies = getaiteamarray(level.zombie_team);
	a_zombies = arraysortclosest(a_zombies, self GetOrigin(), a_zombies.size, 0, explosion_radius);
	// self iPrintLnBold("^6" + a_zombies.size);
	if(a_zombies.size < 1 || !isDefined(a_zombies.size))
	{
		self.PhdExplosionPlaying = undefined;
		return;
	}

    foreach(zombie in a_zombies)
	{
		if(isalive(zombie))
		{
			zombieKillable = 0;
            currDamage = 0;
            multiplier = (self.PhdSlideDist / 1000) + 1;
            currDamage = damage + ((damage / 2) * multiplier);
			if(currDamage >= zombie.health)
			{
				if(zombie.archetype === "zombie")
				{
					zombieKillable = 1;
				}
				zombie.isspecial = 1;
			}
			zombie DoDamage(currDamage, zombie.origin, self, undefined, "none", "MOD_UNKNOWN", 0, level.weaponnone);    //MOD_EXPLOSIVE
            if(zombieKillable)
			{
                ZombieLaunch(zombie);
				// zombie clientfield::increment("zm_aat_blast_furnace" + "_explosion");
                zombie clientfield::increment(("zm_bgb_burned_out" + "_fire_torso") + "_actor");
                zombie thread PhdZombieGibber();
				self zm_score::add_to_player_score(20);
			}
			else if(isalive(zombie))
			{
				zombie zombie_utility::setup_zombie_knockdown(zombie);
			}
		}
	}

	self thread clientfield::increment(("zm_bgb_burned_out" + "_3p") + "_allplayers");
	PlayFX("zombie/fx_powerup_nuke_zmb", explosion_pos, forward, (0, 0, 1));
	// PlayFX("zombie/fx_bgb_burned_out_fire_torso_zmb", explosion_pos, forward, (0, 0, 1));
	// self thread clientfield::increment_to_player(("zm_bgb_burned_out" + "_1p") + "toplayer");
	if(jumpDone)
	{
		// self iPrintLnBold("Jump Done");
		a_zombies = getaiteamarray(level.zombie_team);
		a_zombies = arraysortclosest(a_zombies, self GetOrigin(), a_zombies.size, 0, explosion_radius * 2);
		foreach(zombie in a_zombies)
		{
			if(isalive(zombie) && !(zombie.isspecial))
			{
				zombie zombie_utility::setup_zombie_knockdown(zombie);
			}
		}
	}

	self.PhdConsecutiveUses += 1;
	self.PhdExplosionPlaying = undefined;
}

ZombieLaunch(zombie)
{
    attackerPos = self.origin;
	zombiePos = zombie getcentroid();
	
	n_random_x = RandomIntRange(-300, 300);
	n_random_y = RandomIntRange(75, 300);
	height = randomIntRange(100, 350);

	dir = vectornormalize((zombie.origin - self.origin) + (n_random_x, n_random_y, height));
    zombie StartRagdoll(1);
    zombie LaunchRagdoll((100 * dir), "j_ankle_ri");
    // zombie LaunchRagdoll((120 * dir), attackerPos);
}

PhdZombieGibber()
{
	util::wait_network_frame();
	if(isdefined(self))
	{
		if(self.health < -300)
		{
			if(math::cointoss())
			{
				wait 0.5;
				gibserverutils::annihilate(self);
			}
			else
			{
				self zombie_utility::gib_random_parts();
			}
		}
		else
		{
			self zombie_utility::gib_random_parts();
		}
	}
}

// DoPhdExplosionV2()
// {
//     damage = 2000;
// 	start = self.origin;
// 	while(self IsSliding())
// 	{
// 		a_zombies = zombie_utility::get_round_enemy_array();
// 		a_zombies = util::get_array_of_closest(self.origin, a_zombies, undefined, undefined, 250);			
// 		if(distance(a_zombies[0].origin, self.origin) < 70)
// 		{
// 			if(self.origin[2] > start[2])
// 			{
// 				dif = start[2] - self.origin[2];
// 				damage = damage + int(dif * 2);
// 			}
// 			self.PhdSliderPower = 0;
			
//             for(i = 0; i < a_zombies.size; i++)
// 			{
// 				if (IsAlive(self) && IsAlive(a_zombies[i]))
// 				{
// 					wait 0.01;					
// 					if(isDefined(a_zombies[i]) && IsAlive(a_zombies[i]))
// 					{
// 						if(a_zombies[i].health > damage)
// 							a_zombies[i] zm_weap_thundergun::zombie_knockdown(self, true);
// 						else
// 						{
// 							a_zombies[i] zombie_utility::gib_random_parts();		
// 							a_zombies[i] zombie_utility::gib_random_parts();		
// 							GibServerUtils::Annihilate(a_zombies[i]);			
// 							a_zombies[i] zm_spawner::zombie_explodes_intopieces(false);
// 						}
// 						playfxontag(level._effect["zm_bgb_burned_out" + "_fire_torso"], a_zombies[i], "tag_body");
// 						a_zombies[i] DoDamage(damage, a_zombies[i].origin, self, self, "none");
// 					}
// 				}
// 			}
// 		}
// 		wait 0.05;
// 	}
// }

