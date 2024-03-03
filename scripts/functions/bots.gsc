// BOTS
BotRevivePlayers()
{
	level.bot_revive = isDefined(level.bot_revive) ? undefined : true;

    if(isDefined(level.bot_revive))
        self iPrintLnBold("Bot Revive Players ^2ON");
    else
        self iPrintLnBold("Bot Revive Players ^1OFF");

    while(isDefined(level.bot_revive))
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


	while(1)
	{
		foreach(player in level.player)
		{
			if(player IsTestClient())
				if(player botsighttrace(player.bot.threat.entity))
					player.bot.threat.visible = 1;
		}
		wait 0.1;
	}
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
