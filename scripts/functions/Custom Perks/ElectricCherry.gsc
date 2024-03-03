//Electric Cherry
ElectricCherry(player, version)
{
    if(!isDefined(player.virtualperks))
        player.virtualperks = [];
    
    if(isDefined(player.ElectricCherry) && player.ElectricCherry != version)
        player.ElectricCherry = version;
    else if(!isDefined(player.ElectricCherry))
    {
        array::add(player.virtualperks, "ElectricCherry", 0);
        player.ElectricCherry = version;
        player CustomPerkDrink("specialty_quickrevive");
        player thread DoElectricCherry(player.ElectricCherry);
        
    }
    else
    {
        ArrayRemoveValue(player.virtualperks, "ElectricCherry");
        player.ElectricCherry = undefined;
        player thread RemoveElectricCherry();
        player notify("end_electric_cherry");
    }
}

DoElectricCherry(version)
{
    self endon("end_electric_cherry");
    self endon("disconnect");
    // self endon("death");

    if(!isDefined(self.perkMonitorOn))
        self thread CustomPerksMonitor();
    
    if(self.perks_active.size <= 0 || !isDefined(self.perks_active.size) || !isDefined(self.perks_active))
        activePerks = 0;
    else
        activePerks = self.perks_active.size;
    
    virtualPerks = self.virtualperks.size;  //  -1 because this actual perks doesn't need to be taken into account
    
    x = VirtualPerksPos("ElectricCherry"); //  Electric Cherry
    y = 658;
    width = 38;
    height = 38;

    self.ElectricCherryHud = [];
    self.ElectricCherryHud[0] = self LUI_createRectangle( 0, x, y, width, height, (0, 1, 1), "specialty_doublepoints_zombies", 0, 0);
    self.ElectricCherryHud[1] = self LUI_createRectangle( 0, x + 5, y + 5, width - 10, height - 18, (0, 0.1, 0.1), "white", 0, 1);
    self.ElectricCherryHud[2] = self LUI_createRectangle( 0, x, y + 3, width + 2, height + 2, (1, 1, 1), "dualoptic_39", 0, 2);    //  dualoptic_39, hud_obit_crate
    // self.ElectricCherryHud[2] = self LUI_createRectangle( 0, x + 3, y + 3, width - 3, height - 3, (0.82, 0.01, 0.17), "dualoptic_39", 0, 2);    //  dualoptic_39, hud_obit_crate

    for(i = 0; i < self.ElectricCherryHud.size; i++)
    {
        if(i == 1)
            self thread LuiFade(self.ElectricCherryHud[i], 1, 0.3);
        else
            self thread LuiFade(self.ElectricCherryHud[i], 1, 0.3);
    }

    // boneTags = ["tag_weapon_right", "j_ankle_le", "j_ankle_ri", "j_spinelower", "j_shoulder_le", "j_shoulder_ri", "j_head"];
    self.eCherryboneTags = ["j_ankle_le", "j_ankle_ri", "j_spinelower", "tag_weapon_right"];

    while(isDefined(self.ElectricCherry))
    {
        if((activePerks != self.perks_active.size && isDefined(self.perks_active.size)) || virtualPerks != self.virtualperks.size)
        {
            virtualPerks = self.virtualperks.size;
            if(activePerks != self.perks_active.size && isDefined(self.perks_active.size))
                activePerks = self.perks_active.size;
            
            x = VirtualPerksPos("ElectricCherry"); //  Electric Cherry
            self thread LuiMoveOverTime(self.ElectricCherryHud[0], x, y, 0.05);
            self thread LuiMoveOverTime(self.ElectricCherryHud[1], x + 5, y + 5, 0.05);
            self thread LuiMoveOverTime(self.ElectricCherryHud[2], x, y + 3, 0.05);
        }

        if(self isReloading() && !self isDown())
        {
            self thread ElectricCherryFX();
            self thread ElectrifyZombie(version);
            self playsound("zmb_cherry_explode");

            reloadTime = 0.25;
            if(self hasperk("specialty_fastreload"))
            {
                reloadTime = reloadTime * getdvarfloat("perk_weapReloadMultiplier");
            }
            
			wait reloadTime + 0.75;
            while(self isReloading())
                wait 0.2;
        }
        wait 0.05;
    }
}

ElectrifyZombie(version)
{
    a_zombies = zombie_utility::get_round_enemy_array();
    a_zombies = util::get_array_of_closest(self.origin, a_zombies, undefined, undefined, 150);

    if(version == "v2")
    {
        if(a_zombies.size < 1)
            return;
        
        self.tesla_enemies = undefined;
        self.tesla_enemies_hit = 1;
        self.tesla_firing = 1;

        closest = ArrayGetClosest(self.origin, a_zombies);
        closest lightning_chain::arc_damage(closest, self, 1, level._lightning_params);
        self playsound("zmb_elec_jib_zombie");

        self.tesla_enemies_hit = 0;
        self.tesla_firing = 0;
    }
    else 
    {
        if(a_zombies.size < 1)
            return;
            
        self playsound("zmb_elec_jib_zombie");
        foreach(zombie in a_zombies)
        {
            if(isalive(self) && isalive(zombie))
            {
                zombie lightning_chain::arc_damage_ent(self, 1, level._lightning_params);
                self zm_score::add_to_player_score(40);
            }
        }
    }
}

ElectricCherryFX()
{
    reloadTime = 0.25;
    if(self hasperk("specialty_fastreload"))
    {
        reloadTime = reloadTime * getdvarfloat("perk_weapReloadMultiplier");
    }
    
    fx::play("teleport_aoe", self GetTagOrigin("j_ankle_le"), undefined, reloadTime + 0.75, true, "j_ankle_le");
    fx::play("teleport_aoe", self GetTagOrigin("j_ankle_ri"), undefined, reloadTime + 0.75, true, "j_ankle_ri");
    fx::play("tesla_shock", self GetTagOrigin("j_spinelower"), undefined, reloadTime + 0.75, true, "j_spinelower");
    fx::play("tesla_bolt", self GetTagOrigin("tag_weapon_right"), undefined, reloadTime + 0.75, true, "tag_weapon_right");
    fx::play("tesla_bolt", self GetTagOrigin("j_head"), undefined, reloadTime + 0.75, true, "j_head");
}

RemoveElectricCherry()
{
    for(i = 0; i < self.ElectricCherryHud.size; i++)
        self thread CloseLUIMenuAfterFade(self.ElectricCherryHud[i], 0, 0.3);
}
//Electric Cherry
