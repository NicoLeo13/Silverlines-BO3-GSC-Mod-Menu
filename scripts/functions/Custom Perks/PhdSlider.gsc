//PhD Flopper
PhdFlopper(player, version)
{
    if(!isDefined(player.virtualperks))
        player.virtualperks = [];

    // if(player.var_abd23dd0 > 0)
    if(player.bgb == "zm_bgb_slaughter_slide")
        return self iPrintLnBold("^1Error^7: Slaughter Slide BGB Active");

    if(isDefined(player.PhdFlopper) && isDefined(version) && player.PhdFlopper != version)
    {
        player.PhdFlopper = version;
        self.PhdCooldown = undefined;
        
        string = (version == "Flopper" ? "^6Flopper" : "^9Slider");
        return self iPrintLnBold("Version Set to: " + string);
    }

    player.PhdFlopper = isDefined(player.PhdFlopper) ? undefined : true;

    if(isDefined(player.PhdFlopper))
    {
        array::add(player.virtualperks, "PhdFlopper", 0);
        player.NoExplosiveDamage = true;    //  Works witch override
        player.PhdFlopper = version;
        if(isDefined(level._custom_perks["specialty_widowswine"]))
            player CustomPerkDrink("specialty_widowswine");
        else
            player CustomPerkDrink("specialty_quickrevive");
        player thread DoPhdFlopper();
        
        // player clientfield::set_player_uimodel("bgb_activations_remaining", 5);

        // self luinotifyevent(&"zombie_bgb_notification", 1, level.bgb[name].item_index);
        if(version == "Flopper")
            player thread zm_equipment::show_hint_text("^6PhD Flopper^7: When sliding, emit an explosion damaging enemies around you.\nConsecutive uses: ^55\n^3Cooldown for 1 minute.", 7, 1.3, 70);
        else
            player thread zm_equipment::show_hint_text("^9PhD Slider^7: When sliding, if enemies are around you, unleash a radioactive wave damaging them.\nSlide speed improved. Longer slide distances produces a bigger explosion radius.\nConsecutive uses: ^55\n^3After cooldown, slide to refill energy.", 10, 1.3, 70);

    }
    else
    {
        ArrayRemoveValue(player.virtualperks, "PhdFlopper");
        if(!isDefined(player.ChasquiBoom))
            player.NoExplosiveDamage = undefined;
        player notify("end_phd_flopper");
        // player clientfield::set_player_uimodel("bgb_activations_remaining", 0);
        player thread RemovePhdFlopper();
    }
}

DoPhdFlopper()
{
    self endon("end_phd_flopper");
    self endon("disconnect");

    if(!isDefined(self.perkMonitorOn))
        self thread CustomPerksMonitor();
    
    if(self.perks_active.size <= 0 || !isDefined(self.perks_active.size) || !isDefined(self.perks_active))
        activePerks = 0;
    else
        activePerks = self.perks_active.size;
    
    x = VirtualPerksPos("PhdFlopper"); //  PhD Flopper
    y = 658;
    width = 38;
    height = 38;

    self.PhdFlopperHud = [];
    self.PhdFlopperHud[0] = self LUI_createRectangle( 0, x, y, width, height, (0.63, 0, 1), "specialty_doublepoints_zombies", 0, 0);
    self.PhdFlopperHud[1] = self LUI_createRectangle( 0, x + 5, y + 5, width - 10, height - 15, (0.1, 0, 0.1), "white", 0, 1);
    self.PhdFlopperHud[2] = self LUI_createRectangle( 0, x + 5, y + 3, width - 10, height - 10, (1, 1, 0.9), "acog_12", 0, 2);
    

    for(i = 0; i < self.PhdFlopperHud.size; i++)
    {
        if(i == 1)
            self thread LuiFade(self.PhdFlopperHud[i], 1, 0.3);
        else
            self thread LuiFade(self.PhdFlopperHud[i], 1, 0.3);
    }

    self.PhdCooldown = undefined;
    self.PhdConsecutiveUses = 0;
    self.PhdSliderPower = 100;

    while(isDefined(self.PhdFlopper))
    {
        if(self.var_abd23dd0 > 0)
            self PhdFlopper(self);   //  Exits if Explosive BGB is given
        
        if((activePerks != self.perks_active.size && isDefined(self.perks_active.size)) || virtualPerks != self.virtualperks.size)
        {
            virtualPerks = self.virtualperks.size;
            if(activePerks != self.perks_active.size && isDefined(self.perks_active.size))
                activePerks = self.perks_active.size;
            
            x = VirtualPerksPos("PhdFlopper"); //  PhD Flopper
            self thread LuiMoveOverTime(self.PhdFlopperHud[0], x, y, 0.05);
            self thread LuiMoveOverTime(self.PhdFlopperHud[1], x + 5, y + 5, 0.05);
            self thread LuiMoveOverTime(self.PhdFlopperHud[2], x + 5, y + 3, 0.05);
        }

        if(self.PhdConsecutiveUses > 5 && !isDefined(self.PhdCooldown) && self.PhdFlopper == "Flopper")
            self thread PhdCooldown();

        // if(self.PhdSliderPower < 100 && !isDefined(self.PhdCooldown) && self.PhdFlopper == "Slider")
        if(self.PhdConsecutiveUses > 5 && !isDefined(self.PhdCooldown) && self.PhdFlopper == "Slider")
            self thread PhdCooldown();

        self.PhdSlideDist = 0;
        if(self IsSliding())    //  Sliding
        {
            self thread DoPhdFX();
            if(self.PhdFlopper == "Slider") //  Slider
            {
                self thread DoPhdSliderBoost();
                self.PhdSlideLenght = 0;
                // if(self.PhdSliderPower >= 100 && !isDefined(self.PhdCooldown))
                if(self.PhdConsecutiveUses <= 5 && !isDefined(self.PhdCooldown))
                    self thread DoPhdExplosionV2();
            }
            else    //  Flopper
            {
                if(self.PhdConsecutiveUses <= 5 && !isDefined(self.PhdCooldown))
                {
                    self thread DoPhdExplosion();
                    self.PhdConsecutiveUses += 1;
                }

            }

            while(self IsSliding())
            {
                // if(self.PhdFlopper == "Slider")
                if(self.PhdFlopper == "Slider" && isDefined(self.PhdCooldown))  //  Slider Cooldown
                {
                    self.PhdSliderPower += 1.3;
                    if(self.PhdSliderPower > 100)
                        self.PhdSliderPower = 100;
                    //  DO PROGRESS BAR ON BOTTOM RIGHT
                }
				wait 0.05;
            }
        }
        wait 0.05;
    }
}

DoPhdFX()
{
    if(isDefined(self.PhdFxOrigin))
        self.PhdFxOrigin Delete();

    while(self IsSliding())
    {
        // self.PhdFx[self.PhdFx.size] = playfx(level._effect["teleport_aoe_kill"], self.origin + vectorscale((0, 0, 1), 30));
        // fx::play("zombie/fx_dog_fire_trail_zmb", self.origin, (0, 0, 0), 2);
        fx::play("character_fire_death_torso", self.origin, (0, 0, 1), 2, 0, "j_head");
        wait 0.02;
    }
    if(!isDefined(self.PhdCooldown) && self.PhdFlopper == "Flopper")
    {
        PlaySoundAtPosition("zmb_bgb_powerup_burnedout", self.origin + vectorscale((0, 0, 1), 30));
        // self thread clientfield::increment_to_player(("zm_bgb_burned_out" + "_1p") + "toplayer");
        // self thread clientfield::increment(("zm_bgb_burned_out" + "_3p") + "_allplayers");
    }
}

DoPhdSliderBoost()
{
	angles = self getPlayerAngles();
	anglesForward = anglesToForward(angles);
	push = vectorScale(anglesForward, 500);
    
	while(self IsSliding())
	{
		// if(self.PhdSlideDist >= 32)
        //     return;
        self setVelocity(push);
		wait 0.05; 
	}
}

DoPhdExplosion()
{
    // magicGrenade = getweapon("frag_grenade_slaughter_slide");
    magicGrenade = level.PhdFlopperGrenade;
    launchOffset = vectorscale((0, 0, 1), 48);
	facing = anglestoforward(self.angles);
	right = anglestoright(self.angles);
	left = anglestoright(self.angles);
	// self magicgrenadetype(magicGrenade, self.origin + launchOffset, facing * 1000, 0.5);
	self magicgrenadetype(magicGrenade, self.origin + launchOffset, facing * 20, 0.01);
    // self MagicGrenadeType(magicGrenade, self.origin + launchOffset, right * 100, 0.3);
    // self MagicGrenadeType(magicGrenade, self.origin + launchOffset, left * -100, 0.3);
	util::wait_network_frame();
    while(self IsSliding())
        wait 0.05;
	self magicgrenadetype(magicGrenade, self.origin + launchOffset, (facing * -1) * 100, 0.05);
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

PhdCooldown()
{
    self endon("end_phd_flopper");
    self endon("disconnect");
    
    self.PhdCooldown = true;
    for(i = 0; i < self.PhdFlopperHud.size; i++)
        if(i == 1)
            self thread LuiFade(self.PhdFlopperHud[i], 1, 0.3);
        else
            self thread LuiFade(self.PhdFlopperHud[i], 0.4, 0.3);

    self iPrintLnBold("PhD " + self.PhdFlopper + " cooling down");
    
    if(self.PhdFlopper == "Slider")
    {
        self.PhdSliderPower = 0;
        while(self.PhdSliderPower < 100)
            wait 0.1;
        self.PhdConsecutiveUses = 0;
        self thread zm_equipment::show_hint_text("^9Phd Slider^7 Ready", undefined, 1.3, 240);
    }
    else
    {
        // if(self.PhdConsecutiveUses > 5)
        while(true)
        {
            wait 60;
            break;
        }
        self.PhdConsecutiveUses = 0;
        self thread zm_equipment::show_hint_text("^6Phd Flopper^7 Ready", undefined, 1.3, 240);
    }

    for(i = 0; i < self.PhdFlopperHud.size; i++)
        if(i == 1)
            self thread LuiFade(self.PhdFlopperHud[i], 1, 0.3);
        else
            self thread LuiFade(self.PhdFlopperHud[i], 1, 0.3);
    
    self.PhdCooldown = undefined;
}

RemovePhdFlopper()
{
    for(i = 0; i < self.PhdFlopperHud.size; i++)
        self thread CloseLUIMenuAfterFade(self.PhdFlopperHud[i], 0, 0.3);
}

// DoPhdFX()
// {
//     while(self IsSliding())
//     {
//         origin = self.origin;
//         self.PhdFxOrigin = util::spawn_model("tag_origin", origin);

//         // self.PhdFx[self.PhdFx.size] = playfx(level._effect["teleport_aoe_kill"], self.origin + vectorscale((0, 0, 1), 30));
//         self.PhdFx[self.PhdFx.size] = PlayFXOnTag(level._effect["character_fire_death_torso"], self.PhdFxOrigin, "tag_origin");
//         wait 0.01;
//     }
//     // if(isDefined(level._effect["dog_gib"]))
//     // {
//     //     origin = self.origin;
//     //     self.explosionFx = util::spawn_model("tag_origin", origin);
//     //     self.PhdFx[self.PhdFx.size] = PlayFXOnTag(level._effect["dog_gib"], self.explosionFx, "tag_origin");
//     // }
//     // else
//     // {
//         // self thread clientfield::increment("zm_aat_blast_furnace" + "_explosion");
//         // self clientfield::increment("projectile_vomit", 1);
//         if(!isDefined(self.PhdCooldown))
//         {
//             self thread clientfield::increment_to_player(("zm_bgb_burned_out" + "_1p") + "toplayer");
//             self thread clientfield::increment(("zm_bgb_burned_out" + "_3p") + "_allplayers");
//         }
//     // }
//     wait 2;
//     for(i = 0; i < self.PhdFx.size; i++)
//         self.PhdFx[i] Delete();
//     self.PhdFxOrigin Delete();
    
//     self.explosionFx Delete();
    
//     if(self.PhdFx.size > 0)
//     {
//         for(i = 0; i < self.PhdFx.size; i++)
//             self.PhdFx[i] Delete();
//         self.PhdFx = [];
//         self.PhdFxOrigin = undefined;
//     }
// }
//PhD Flopper

// self setmovespeedscale(1);
// self setsprintduration(4);
// self setsprintcooldown(0);
