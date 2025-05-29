//toDo: Enhance the bot system, pathfinding, and add more features

// BOTS
BotRevivePlayers()
{
	level.BotRevive = isDefined(level.BotRevive) ? undefined : true;

    if(isDefined(level.BotRevive))
        self iPrintLnBold("Bot Revive Players ^2ON");
    else
        self iPrintLnBold("Bot Revive Players ^1OFF");

    while(isDefined(level.BotRevive))
    {
        foreach(bot in level.players)
        {
            if(bot IsTestClient())
            {
                bot bot::revive_players();
                revive_ret = bot bot::revive_players();
                while(revive_ret == true)
                {
                    bot.health = 999;
                    bot bot::revive_players();
                    revive_ret = bot bot::revive_players();
                    wait 0.025;
                }   
            }
            wait 0.1;
        }
    }
    bot = undefined;
    revive_ret = undefined;
}

AddBots(count)
{
    // if(!isDefined(level.botprecombat))
    //         self iPrintLnBold("^1undefined");
    for(i = 0;i < count; i++)
    {
        if(level.players.size == 4)
            return self iPrintLnBold("Max Player Count Reached");

        bot = BotAdd();
        wait .1;
        bot thread BotSpawn();

    }
}

BotAdd()
{
    bot = AddTestClient();
    if(!isdefined(bot))
        return;
    bot.pers["isBot"] = 1;
    return bot;
}

BotSpawn()
{
    while(self.sessionstate != "spectator")
        wait .1;
    self [[level.spawnPlayer]]();
}

RemoveBots()
{
    foreach( bot in level.players )
    {
        if(!bot IsTestClient())
            continue;
        Kick( bot getEntityNumber() );
    }
}

CustomBotConfig()
{
    level.botConfigTest = isDefined(level.botConfigTest) ? undefined : true;

    self NewBotSettings();

    setdvar("bot_AllowMelee", (isdefined(level.botsettings.allowmelee) ? level.botsettings.allowmelee : 0));
	setdvar("bot_AllowGrenades", (isdefined(level.botsettings.allowgrenades) ? level.botsettings.allowgrenades : 0));
	setdvar("bot_AllowKillstreaks", (isdefined(level.botsettings.allowkillstreaks) ? level.botsettings.allowkillstreaks : 0));
	setdvar("bot_AllowHeroGadgets", (isdefined(level.botsettings.allowherogadgets) ? level.botsettings.allowherogadgets : 0));
	setdvar("bot_Fov", (isdefined(level.botsettings.fov) ? level.botsettings.fov : 0));
	setdvar("bot_FovAds", (isdefined(level.botsettings.fovads) ? level.botsettings.fovads : 0));
	setdvar("bot_PitchSensitivity", level.botsettings.pitchsensitivity);
	setdvar("bot_YawSensitivity", level.botsettings.yawsensitivity);
	setdvar("bot_PitchSpeed", (isdefined(level.botsettings.pitchspeed) ? level.botsettings.pitchspeed : 0));
	setdvar("bot_PitchSpeedAds", (isdefined(level.botsettings.pitchspeedads) ? level.botsettings.pitchspeedads : 0));
	setdvar("bot_YawSpeed", (isdefined(level.botsettings.yawspeed) ? level.botsettings.yawspeed : 0));
	setdvar("bot_YawSpeedAds", (isdefined(level.botsettings.yawspeedads) ? level.botsettings.yawspeedads : 0));
	setdvar("pitchAccelerationTime", (isdefined(level.botsettings.pitchaccelerationtime) ? level.botsettings.pitchaccelerationtime : 0));
	setdvar("yawAccelerationTime", (isdefined(level.botsettings.yawaccelerationtime) ? level.botsettings.yawaccelerationtime : 0));
	setdvar("pitchDecelerationThreshold", (isdefined(level.botsettings.pitchdecelerationthreshold) ? level.botsettings.pitchdecelerationthreshold : 0));
	setdvar("yawDecelerationThreshold", (isdefined(level.botsettings.yawdecelerationthreshold) ? level.botsettings.yawdecelerationthreshold : 0));
	meleerange = getdvarint("player_meleeRangeDefault") * (isdefined(level.botsettings.meleerangemultiplier) ? level.botsettings.meleerangemultiplier : 0);
	level.botsettings.meleerange = int(meleerange);
	level.botsettings.meleerangesq = meleerange * meleerange;
	level.botsettings.threatradiusminsq = level.botsettings.threatradiusmin * level.botsettings.threatradiusmin;
	level.botsettings.threatradiusmaxsq = level.botsettings.threatradiusmax * level.botsettings.threatradiusmax;
	lethaldistancemin = (isdefined(level.botsettings.lethaldistancemin) ? level.botsettings.lethaldistancemin : 0);
	level.botsettings.lethaldistanceminsq = lethaldistancemin * lethaldistancemin;
	lethaldistancemax = (isdefined(level.botsettings.lethaldistancemax) ? level.botsettings.lethaldistancemax : 1024);
	level.botsettings.lethaldistancemaxsq = lethaldistancemax * lethaldistancemax;
	tacticaldistancemin = (isdefined(level.botsettings.tacticaldistancemin) ? level.botsettings.tacticaldistancemin : 0);
	level.botsettings.tacticaldistanceminsq = tacticaldistancemin * tacticaldistancemin;
	tacticaldistancemax = (isdefined(level.botsettings.tacticaldistancemax) ? level.botsettings.tacticaldistancemax : 1024);
	level.botsettings.tacticaldistancemaxsq = tacticaldistancemax * tacticaldistancemax;
	level.botsettings.swimverticalspeed = getdvarfloat("player_swimVerticalSpeedMax");
	level.botsettings.swimtime = getdvarfloat("player_swimTime", 5) * 1000;


	// while(level.botConfigTest)
	// {
	// 	foreach(player in level.player)
	// 	{
	// 		if(player IsTestClient())
	// 			if(player botsighttrace(player.bot.threat.entity))
	// 				player.bot.threat.visible = 1;
	// 	}
	// 	wait 0.1;
	// }
}

NewBotSettings()
{
        level.botsettings.changeclassweight = 20;
		level.botsettings.fov = 360;
		level.botsettings.rocketlauncherfire = 0.985;
		level.botsettings.allowmelee = 1;
		level.botsettings.mgfire = 0.985;
		level.botsettings.mgads = 0.94;
		level.botsettings.damagewandermax = 512;
		level.botsettings.damagewandermin = 256;
		level.botsettings.smgads = 0.94;
		level.botsettings.threatradiusmax = 550;
		// level.botsettings.threatradiusmax = 550;
		level.botsettings.threatradiusmin = 200;
		level.botsettings.yawaccelerationtime = 2;
		level.botsettings.chasethreattime = 5.0;
		level.botsettings.tacticalweight = 30;
		level.botsettings.defaultads = 0.766;
		level.botsettings.sniperrange = 5000;
		level.botsettings.damagewanderfwddot = 0.87;
		level.botsettings.mgrangeclose = 300;
		level.botsettings.rifleads = 0.94;
		level.botsettings.yawsensitivity = 9.0;
		level.botsettings.rocketlauncherrangeclose = 300;
		level.botsettings.allowkillstreaks = 1;
		level.botsettings.pitchspeedads = 300.0;
		level.botsettings.pitchaccelerationtime = 2;
		level.botsettings.wanderfwddot = 0.87;
		level.botsettings.riflerange = 1500;
		level.botsettings.lethaldistancemax = 800;
		level.botsettings.lethaldistancemin = 550;
		level.botsettings.smgrange = 800;
		level.botsettings.defaultrange = 900;
		level.botsettings.spreadrangeclose = 30;
		level.botsettings.allowherogadgets = 1;
		level.botsettings.yawspeedads = 300.0;
		level.botsettings.riflefire = 0.985;
		level.botsettings.sniperads = 0.94;
		level.botsettings.strafespacing = 64;
		level.botsettings.yawspeed = 300.0;
		level.botsettings.meleedot = 0.5;
		level.botsettings.thinkinterval = 0.1;
		level.botsettings.spreadfire = 0.9;
		level.botsettings.pistolads = 0.94;
		level.botsettings.sniperrangeclose = 300;
		level.botsettings.pistolrangeclose = 40;
		level.botsettings.strafemax = 400;
		level.botsettings.strafemin = 200;
		level.botsettings.rocketlauncherrange = 900;
		level.botsettings.wanderspacing = 128;
		level.botsettings.pitchspeed = 300.0;
		level.botsettings.chasewanderspacing = 64;
		level.botsettings.allowgrenades = 1;
		level.botsettings.sniperfire = 0.985;
		level.botsettings.smgfire = 0.985;
		level.botsettings.meleerangemultiplier = 1.0;
		level.botsettings.wandermax = 1500;
		level.botsettings.wandermin = 256;
		level.botsettings.headshotweight = 50;
		level.botsettings.pistolrange = 600;
		level.botsettings.defaultfire = 0.985;
		level.botsettings.mgrange = 5000;
		level.botsettings.spreadrange = 100;
		level.botsettings.pistolfire = 0.985;
		level.botsettings.tacticaldistancemax = 800;
		level.botsettings.tacticaldistancemin = 550;
		level.botsettings.pitchsensitivity = 9.0;
		level.botsettings.damagewanderspacing = 64;
		level.botsettings.rocketlauncherads = 0.766;
		level.botsettings.spreadads = 0.94;
		level.botsettings.lethalweight = 40;
		level.botsettings.riflerangeclose = 300;
		level.botsettings.defaultrangeclose = 100;
		level.botsettings.chasewandermax = 512;
		level.botsettings.chasewandermin = 256;
		level.botsettings.smgrangeclose = 300;
		level.botsettings.igdtseqnum = 4;
		level.botsettings.strafesidedotmax = 0.5;
		level.botsettings.strafesidedotmin = -0.174;
		level.botsettings.chasewanderfwddot = 0.87;
		level.botsettings.fovads = 360;

        //  Aim Error
        level.botsettings.aimerrorminpitch = 0;
        level.botsettings.aimerrormaxpitch = 0;
        level.botsettings.aimerrorminyaw = 0;
        level.botsettings.aimerrormaxyaw = 0;
}

MoveBotToPos(bot, self, distance = 100) 
{
    posb = bot.origin;
    posp = self.origin;

    if(!isDefined(bot)) 
        return;
    if(bot CanPath(posb, posp))
    {
        bot BotSetGoal(posp, distance);
        // self iPrintLnBold(bot.name + " is pathing to you...");
    }
    else
    {
        self iPrintLnBold("Bot Could Not find Path");
    }
}

BotFollowHost()
{
    level.BotFollowHost = isDefined(level.BotFollowHost) ? undefined : true;

        while(isDefined(level.BotFollowHost))
        {
            foreach( bot in level.players )
                {
                    if(!bot IsTestClient())
                        continue;
                    MoveBotToPos(bot, self);
                }
            wait 1;
        }
}

BotHunting()
{
    level.BotHunt = isDefined(level.BotHunt) ? undefined : true;

	bot_paths = InitBotPaths();
    
    while(isDefined(level.BotHunt))
	{
		foreach( bot in level.players )
			{
				if(!bot IsTestClient())
					continue;
				// if(!bot.move_called)
				MoveBotToRandom(bot, bot_paths);
			}
		wait randomIntRange(15, 20);
	}
}

InitBotPaths()
{
    //PERKS
    perks = GetEntArray("zombie_vending", "targetname");
    if(!isdefined(perk_ent))
    {
        perk_ent = [];
    }
    else if(!isarray(perk_ent))
    {
        perk_ent = array(perk_ent);
    }
    foreach(perk in perks)
    {
        ent = perk.machine;
        perk_ent[perk_ent.size] = ent;
    }
    //BGB MACHINE

    // if(perk_ent.size > 0)
    // {
    //     self iPrintLnBold("defined");
    //     foreach(i in perk_ent)
    //     {
    //         self iPrintLnBold(i.origin);
    //         self SetOrigin(i.origin + (AnglesToRight(i.angles) * 70));
    //         // self SetPlayerAngles(i.angles);
    //         wait 10;
    //     }
    // }
    
    bot_paths = ArrayCombine(level.MapSpawnPoints, perk_ent, 0, 1);
    return bot_paths;
}

MoveBotToRandom(bot, bot_paths, distance = 10) 
{
    if(!isDefined(bot)) 
        return;
    
    posb = bot.origin;
    posp = array::random(bot_paths);
    
    if(bot CanPath(posb, (posp.origin + (AnglesToRight(posp.angles) * 50))))
    {
        self iPrintLnBold("^5" + CleanName(bot getName()) + " ^7Pathing...");
        bot BotSetGoal(posp.origin + (AnglesToRight(posp.angles) * 50));
        // self iPrintLnBold(bot.name + " is pathing to you...");
    }
    else
    {
        self iPrintLnBold("^5" + CleanName(bot getName()) + " ^1 Could Not find Path");
        while(!bot CanPath(posb, (posp.origin + (AnglesToRight(posp.angles) * 50))))
        {
            posb = bot.origin;
            posp = array::random(bot_paths);
            wait .02;
        }

        if(bot CanPath(posb, (posp.origin + (AnglesToRight(posp.angles) * 50))))
        {
            self iPrintLnBold("^5" + CleanName(bot getName()) + " ^7New Path Set!");
            bot BotSetGoal(posp.origin + (AnglesToRight(posp.angles) * 50));
            // self iPrintLnBold(bot.name + " is pathing to you...");
        }
    }
}

BotsAllPerks()
{
    level.BotAllPerks = isDefined(level.BotAllPerks) ? undefined : true;

    if(isDefined(level.BotAllPerks))
    {
        foreach( bot in level.players )
        {
            if(!bot IsTestClient())
                continue;

            GiveAllPerks(bot);
            Keep_Perks(bot);
        }
        
        self iPrintLnBold("Bots All Perks ^2ON");
    }
    else
    {
        foreach( bot in level.players )
        {
            if(!bot IsTestClient())
                continue;

            GiveAllPerks(bot);
            Keep_Perks(bot);
        }
        self iPrintLnBold("Bots All Perks ^1OFF");
    }
}

BotGodmode()
{
    level.BotGodmode = isDefined(level.BotGodmode) ? undefined : true;

    if(isDefined(level.BotGodmode))
    {
        foreach( bot in level.players )
			if(!bot IsTestClient())
                continue;
        
            bot EnableInvulnerability();
            
        self iPrintLnBold("^2Enabled^7 Bot Godmode");
    }
    else
    {
        foreach( bot in level.players )
            if(!bot IsTestClient())
                continue;
        
            bot DisableInvulnerability();
            
        self iPrintLnBold("^1Disabled^7 Bot Godmode");
    }   
     
}

BotDistributePoints()
{
    level.BotDistributePoints = isDefined(level.BotDistributePoints) ? undefined : true;
    
    if(isDefined(level.BotDistributePoints))
    {
        self iPrintLnBold("Bot Score Distribution ^2ON");
        botsize = [];
        foreach(player in level.players)
            {
                if(player IsTestClient())
                {
                    botsize[botsize.size] = player;
                }
            }
        // self iPrintLnBold(botsize.size);
        // self iPrintLnBold(self.score);
        while(isDefined(level.BotDistributePoints))
        {
            foreach(bot in level.players)
            {
                if(bot IsTestClient())
                {
                    if(bot.score >= 7000)
                    {
                        foreach(player in level.players)
                        {
                            if(!player IsTestClient())
                            {
                                player zm_score::add_to_player_score(bot.score / (level.players.size - botsize.size));
                            }
                            bot zm_score::minus_to_player_score((bot.score - 500));
                        }
                    }
                }
            }
            wait 3;    
        }    
    }
    else
    {
        self iPrintLnBold("Bot Score Distribution ^1OFF");
    }
}

BotGiveWeapon()
{
    foreach( bot in level.players )
    {
        if(!bot IsTestClient())
            continue;

        GivePlayerRandomWeapon(bot);
    }
}

GivePlayerRandomWeapon(player)
{
        // iPrintLnBold("^1" + level.zombie_weapons.size);

        weaponsList_array = getArrayKeys(level.zombie_weapons);

        weapsize3 = weaponsList_array.size;
        weapsize3 = randomInt(weapsize3);
        weapname = weaponsList_array[weapsize3].name;

        if(IsSubStr(weapname, "knife") || IsSubStr(weapname, "frag_grenade") || IsSubStr(weapname, "cymbal_monkey") || IsSubStr(weapname, "hero_annihilator") || IsSubStr(weapname, "hero") || IsSubStr(weapname, "bouncingbetty"))
        {
            while(true)
            {
                weapsize3 = randomInt(weapsize3);
                weapname = weaponsList_array[weapsize3].name;

                if(!IsSubStr(weapname, "knife") || !IsSubStr(weapname, "frag_grenade") || !IsSubStr(weapname, "cymbal_monkey") || !IsSubStr(weapname, "hero") || !IsSubStr(weapname, "bouncingbetty"))
                {
                    // iPrintLnBold("new weapon rand = ^5" + weapname);
                    break;
                }
                wait .02;
            }
        }

        player TakeWeapon(player GetCurrentWeapon());
        weapon = GetWeapon(weapname);
        player GiveWeapon(weapon);
        player GiveMaxAmmo(weapon);
        player SwitchToWeapon(weapon);

        // ToLower(CleanString(zm_utility::GetWeaponClassZM(weapon)));
            self iPrintLnBold(MakeLocalizedString(weapon.displayname) + " ^7Given to: ^3" + CleanName(player getName()));
}

PapBotWeapons()
{
    //CAMO
    camo = [15, 16, 17, 64, 66, 68, 75, 76, 77, 78, 79, 81, 83, 84, 85, 86, 87, 88, 89, 119, 120, 121, 122, 123, 124, 125, 126, 133, 134, 135, 136, 137, 138, level.pack_a_punch_camo_index];
    if(!IsArray(camo))
        camo = array(camo);

    //AAT
    keys = GetArrayKeys(level.aat);
    if(!IsArray(keys))
        keys = array(keys);

    foreach(bot in level.players)
    {
        if(!bot IsTestClient())
            continue;
        
        if(!bot zm_weapons::is_weapon_upgraded(bot GetCurrentWeapon()))
        {
            PackCurrentWeapon(bot);
            wait .2;
            weapon = bot GetCurrentWeapon();
            
            aat = array::random(keys);
            randcamo = array::random(camo);
            
            GiveWeaponAAT(aat, bot);
            SetPlayerCamo(randcamo, bot);
            
            self iPrintLnBold(MakeLocalizedString(weapon.displayname) + " ^7Given to: ^3" + CleanName(bot getName()));
        }
        else
        {
            // camo = RandomIntRange(1, 138);
            randcamo = array::random(camo);
            SetPlayerCamo(randcamo, bot);

            // aat = array::random(keys);
            // GiveWeaponAAT(aat, bot);
        }
    }
}

GiveBotsWeaponAAT(aat)
{
    aatName = aat;
    
    if(!isSubStr(aat, "aat_") || !isSubStr(aat, "zm_"))
    {
        keys = GetArrayKeys(level.aat);

        foreach(key, value in level.aatNames)
        {
            if(aat == value)
            {
                aat = keys[key];  //Uses the key to pass the real aat
                break;
            }
        }
    }

    foreach(bot in level.players)
    {
        if(!bot IsTestClient())
            continue;

        if(bot.aat[bot aat::get_nonalternate_weapon(bot GetCurrentWeapon())] != aat)
            bot aat::acquire(bot GetCurrentWeapon(), aat);
        else
        {
            bot aat::remove(bot GetCurrentWeapon());
            bot clientfield::set_to_player("aat_current", 0);
        }
    }

    self iPrintLnBold(aatName + " given to all Bots");
}

BotUnlimitedAmmo()
{
    level.BotAmmo = isDefined(level.BotAmmo) ? undefined : true;

    if(isDefined(level.BotAmmo))
    {
        self iPrintLnBold("Bot Unlimited Ammo ^2ON");
        while(level.BotAmmo)
        {
            foreach(bot in level.players)
            {
                if(!bot IsTestClient())
                    continue;
                
                bot InfiniteAmmo("Reload", bot);
            }
        }
    }
    else
    {
        foreach(bot in level.players)
        {
            if(!bot IsTestClient())
                    continue;
            
            bot InfiniteAmmo("Disable", bot);
        }
        self iPrintLnBold("Bot Unlimited Ammo ^1OFF");
    }
}

ReviveBots()
{
    foreach( bot in level.players )
    {
        if(!bot IsTestClient())
            continue;

        PlayerRevive(bot);
    }    
}