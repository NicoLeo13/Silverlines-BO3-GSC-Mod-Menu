//Air Fryer
AirFryer(player)
{
    if(isDefined(player.godmode) || isDefined(player.DemiGod))
        return self iPrintLnBold("^1Error: God Mode or Demi God Active");
    
    player.AirFryer = isDefined(player.AirFryer) ? undefined : true;

    if(!isDefined(player.virtualperks))
        player.virtualperks = [];

    if(isDefined(player.AirFryer))
    {
        array::add(player.virtualperks, "AirFryer", 0);
        player CustomPerkDrink("specialty_doubletap2");
        player thread DoAirFryer();
        player zm_equipment::show_hint_text("^9Air Fryer^7: When there are 5 or more zombies around you and your health is minimal\nemit a large fire burst to ignite them and save you.\n^3Cooldown for 3 minutes.", 10, 1.3, 70);
        // player hud_message::hintmessage("Air Fryer Ready");
        // player hud_message::notifymessage(notifydata);
        // self SetHintString("Air Fryer Set");
    }
    else
    {
        ArrayRemoveValue(player.virtualperks, "AirFryer");
        player notify("end_air_fryer");
        player thread RemoveAirFryer();
        player.AirFryerReady = undefined;
    }
}

DoAirFryer()
{
    self endon("end_air_fryer");
    self endon("disconnect");
    // self endon("death");

    if(!isDefined(self.perkMonitorOn))
        self thread CustomPerksMonitor();
    
    x = VirtualPerksPos("AirFryer"); //  Air Fryer
    y = 658;
    width = 38;
    height = 38;

    self.AirFryerHud = [];
    self.AirFryerHud[0] = self LUI_createRectangle( 0, x, y, width, height, (1, 1, 0), "specialty_doublepoints_zombies", 0, 0);
    self.AirFryerHud[1] = self LUI_createRectangle( 0, x + 5, y + 5, width - 10, height - 18, (0.1, 0.1, 0), "white", 0, 1);
    self.AirFryerHud[2] = self LUI_createRectangle( 0, x + 5, y + 3, width - 5, height - 5, (1, 1, 1), "dualoptic_22", 0, 2);    //  dualoptic_22, hud_obit_crate

    for(i = 0; i < self.AirFryerHud.size; i++)
    {
        if(i == 1)
            self thread LuiFade(self.AirFryerHud[i], 1, 0.3);
        else
            self thread LuiFade(self.AirFryerHud[i], 1, 0.3);
    }
    
    if(!isDefined(self.prevMaxHealth))
        self.prevMaxHealth = self.maxhealth;

    if(!isDefined(self.HealthBar))
        self CalcHealthSteps();

    self.AirFryerReady = true;
    self thread AirFryerHudWatcher();

    while(isDefined(self.AirFryer))
    {
        self waittill("damage", amount, attacker, direction_vec, point, type);  //  Checks for zombie damage and triggers iteration
		if("MOD_MELEE" != type || !isai(attacker))                              //  This is so that perk only works just when getting hit and not also after and health is low
			continue;

        if(self.prevMaxHealth != self.maxhealth && !isDefined(self.HealthBar))    //  Jugg Monitor for steps
        {
            self CalcHealthSteps();
            self.prevMaxHealth = self.maxhealth;
        }

        healthPercentage = (self.health / self.maxhealth);
        currStep = ceil(healthPercentage * (self.healthBarSteps - 1));

        if(currStep == 1 && self.AirFryerReady)
        {
            zombies = zombie_utility::get_round_enemy_array();
            zombies = util::get_array_of_closest(self.origin, zombies, undefined, undefined, 250);

            if(zombies.size < 5)
            {
                wait 0.01;
                continue;
            }
            self.health = self.maxhealth;
            self enableInvulnerability();
            
            priorSize = zombies.size;
            zombiesToKill = [];
            
            self clientfield::increment_to_player(("zm_bgb_burned_out" + "_1p") + "toplayer");
            self clientfield::increment(("zm_bgb_burned_out" + "_3p") + "_allplayers");
            for(i = 0; i < zombies.size; i++)           //  Zombies mark and FX
            {
                if(isDefined(zombies[i].marked_for_death) && zombies[i].marked_for_death)
                    continue;
                if(zm_utility::is_magic_bullet_shield_enabled(zombies[i]))
                    continue;

                zombies[i].marked_for_death = 1;
                if(isvehicle(zombies[i]))
                {
                    zombies[i] clientfield::increment(("zm_bgb_burned_out" + "_fire_torso") + "_vehicle");
                }
                else
                {
                    zombies[i] clientfield::increment(("zm_bgb_burned_out" + "_fire_torso") + "_actor");
                }
                zombiesToKill[zombiesToKill.size] = zombies[i];
            }
            self playsound("zmb_bgb_powerup_burnedout");
            playfx(level._effect["teleport_aoe_kill"], self.origin + vectorscale((0, 0, 1), 30));

            for(i = 0; i < zombiesToKill.size; i++)     //  Zombies kill
            {
                util::wait_network_frame();
                if(!isdefined(zombiesToKill[i]))
                {
                    continue;
                }
                if(zm_utility::is_magic_bullet_shield_enabled(zombiesToKill[i]))
                {
                    continue;
                }
                // zombiesToKill[i] dodamage(zombiesToKill[i].health + 666, zombiesToKill[i].origin);
                zombiesToKill[i] dodamage(zombiesToKill[i].health + 666, zombiesToKill[i].origin, self, undefined, "none", "MOD_UNKNOWN", 0);
                self zm_score::add_to_player_score(20);
                // playfx(level._effect["teleport_aoe_kill"], zombiesToKill[i].origin + vectorscale((0, 0, 1), 30));
            }

            self disableInvulnerability();
            cooldown = 60 * 3;             //  Seconds
            minutes = cooldown / 60;    //  Minutes
            self zm_equipment::show_hint_text("Saved you from: ^9" + priorSize + " ^7Zombies!", 3, 1.3, 70);
            // self iPrintLnBold("Saved you from: ^5" + priorSize + " ^7Zombies!");
            self iPrintLnBold("Cooling down for ^6" + minutes + " minutes");
            self thread AirFryerCooldown();
            self.AirFryerReady = false;
        }
        wait 0.05;
    }
}

AirFryerHudWatcher()
{
    self endon("end_air_fryer");
    self endon("disconnect");

    if(self.perks_active.size <= 0 || !isDefined(self.perks_active.size) || !isDefined(self.perks_active))
        activePerks = 0;
    else
        activePerks = self.perks_active.size;
    
    virtualPerks = self.virtualperks.size;  //  -1 because this actual perks doesn't need to be taken into account

    y = 658;
    
    // while(isDefined(self.AirFryer))
    while(true)
    {
        if(isDefined(self.godmode) || isDefined(self.DemiGod))
        {
            ArrayRemoveValue(self.virtualperks, "AirFryer");
            self thread RemoveAirFryer();
            self.AirFryerReady = undefined;
            self.AirFryer = undefined;
            self notify("end_air_fryer");
            break;
        }
        
        if((activePerks != self.perks_active.size && isDefined(self.perks_active.size)) || virtualPerks != self.virtualperks.size)
        {
            virtualPerks = self.virtualperks.size;
            if(activePerks != self.perks_active.size && isDefined(self.perks_active.size))
                activePerks = self.perks_active.size;
            
            x = VirtualPerksPos("AirFryer"); //  Air Fryer
            self thread LuiMoveOverTime(self.AirFryerHud[0], x, y, 0.05);
            self thread LuiMoveOverTime(self.AirFryerHud[1], x + 5, y + 5, 0.05);
            self thread LuiMoveOverTime(self.AirFryerHud[2], x + 5, y + 3, 0.05);
        }
        wait 0.2;
    }
}

AirFryerCooldown()
{
    self endon("end_air_fryer");
    self endon("disconnect");
    cooldown = 60;             //  Seconds
    minutes = cooldown / 60;    //  Minutes
    
    for(i = 0; i < self.AirFryerHud.size; i++)
    {
        if(i == 1)
            self thread LuiFade(self.AirFryerHud[i], 1, 0.3);
        else
            self thread LuiFade(self.AirFryerHud[i], 0.4, 0.3);
    }
    wait cooldown;
    for(i = 0; i < self.AirFryerHud.size; i++)
    {
        if(i == 1)
            self thread LuiFade(self.AirFryerHud[i], 1, 0.3);
        else
            self thread LuiFade(self.AirFryerHud[i], 1, 0.3);
    }
    self.AirFryerReady = true;
    // self iPrintLnBold("Air Fryer ^2Active!");
    self zm_equipment::show_hint_text("Air Fryer Ready", 3, 1.3, 70);
}

RemoveAirFryer()
{
    for(i = 0; i < self.AirFryerHud.size; i++)
        self thread CloseLUIMenuAfterFade(self.AirFryerHud[i], 0, 0.3);
}
//Air Fryer
