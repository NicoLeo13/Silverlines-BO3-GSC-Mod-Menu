ThirdPerson(player)
{
    player.ThirdPerson = isDefined(player.ThirdPerson) ? undefined : true;
    player SetClientThirdPerson(isDefined(player.ThirdPerson));
}

HealthBar(player)
{
    if(!isDefined(player.HealthBar) && (isDefined(player.DemiGod) || isDefined(player.godmode)))
        return self iPrintLnBold("^1Error: God Mode or Demi God Active");

    player.HealthBar = isDefined(player.HealthBar) ? undefined : true;

    if(isDefined(player.HealthBar))
    {
        if((!player hasMenu() && !player isInMenu()) || !player hasMenu())
            player thread DrawHealthBar();
        else
            return self iPrintLnBold("Health will show once you exit menu");
    }
    else
    {
        player DeleteHealthBar();
        player notify("end_health_bar");
    }
}

DrawHealthBar()
{
    self endon("death");
    self endon("disconnect");
    self endon("end_health_bar");

    //  CONSTANTS
    HEALTH = "Health: ";

    self CalcHealthSteps();     //  Watches for Jugg or No Jugg

    // createRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
    // createText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
    bgHeight = 20;
    fillHeight = 16;
    x = 20;
    y = -64;
    textX = x + 55;
    textY = y + 14;
    self.healthBar = [];
    self.healthBar[0] = self createRectangle("BOTTOM LEFT", "BOTTOM LEFT", x, y, self.healthBarWidth + 4, bgHeight, (0, 0, 0), 0, 0, "progress_bar_bg");
    self.healthBar[1] = self createRectangle("BOTTOM LEFT", "BOTTOM LEFT", x + 2, y - 2, self.healthBarWidth, fillHeight, (0, 0, 0), 1, 0, "progress_bar_fill");
    self.healthBar[2] = self createText("objective", 1.3, 1, HEALTH, "BOTTOM LEFT", "BOTTOM LEFT", textX, textY, 0, (1, 1, 1));
    self.healthBar[3] = self createText("objective", 1.3, 1, self.health, "BOTTOM LEFT", "BOTTOM LEFT", textX + 32, textY, 0, (1, 1, 1));

    for(i = 0; i < self.healthBar.size; i++)
        self.healthBar[i] thread hudFade(0.7, 0.5);

    if(!isDefined(self.prevMaxHealth))
        self.prevMaxHealth = self.maxhealth;

    for(;;)
    {
        if(isDefined(self.DemiGod) || isDefined(self.godmode))  //  Removes Health Bar if either gets activated
        {
            self DeleteHealthBar();
            self.HealthBar = undefined;
            self notify("end_health_bar");
        }

        if(self.prevMaxHealth != self.maxhealth)    //  Jugg Monitor for steps
        {
            self CalcHealthSteps();
            self.healthBar[0] thread hudScaleOverTime(0.2, self.healthBarWidth + 4, bgHeight);
            self.healthBar[3] setValue(self.health);
            self.prevMaxHealth = self.maxhealth;
        }

        healthPercentage = (self.health / self.maxhealth);
        
        width = int(Max((healthPercentage * self.healthBarWidth), 1));   //  Health Percentage * Max Width
        if(self.healthBar[1].width != width || !isDefined(self.healthBar[1].width))
        {
            self.healthBar[1] thread hudScaleOverTime(0.2, width, fillHeight);
            self.healthBar[3] setValue(self.health);
        }

        currStep = ceil(healthPercentage * (self.healthBarSteps - 1));
        index = int(Max(0, currStep));
        // index = int(Min((self.healthBarSteps - 1), currStep));
        color = self.healthBarColors[index];
        if(self.healthBar[1].color != color || !isDefined(self.healthBar[1].color))
            self.healthBar[1] thread fadeToColor(color, 0.2);
        
        wait 0.05;  //  Frame
    }
}

CalcHealthSteps()
{
    //  Health 45 to 45 (hits)
    // Colors for each step
    if(self.maxhealth == 100)
    {
        self.healthBarColors = undefined;
        self.healthBarWidth = 100;
        self.healthBarSteps = 4;                    //  Total number of color steps
        self.healthBarColors = [];
        self.healthBarColors[0] = (0, 0, 0);        //  Black (No Life)
        self.healthBarColors[1] = (1, 0, 0);      //  Red (Minimum Health)
        self.healthBarColors[2] = (1, 1, 0);    //  Yellow (Intermediate step)
        self.healthBarColors[3] = (0, 0.5, 0);      //  Green (Max Life)
    }
    else if(self.maxhealth == 200)
    {
        self.healthBarColors = undefined;
        self.healthBarWidth = 150;
        self.healthBarSteps = 6;                    //  Total number of color steps
        self.healthBarColors = [];
        self.healthBarColors[0] = (0, 0, 0);        //  Black (No Life)
        self.healthBarColors[1] = (1, 0, 0);      //  Red (Minimum Health)
        self.healthBarColors[2] = (1, 0.65, 0);    //  Orange (Intermediate step)
        self.healthBarColors[3] = (1, 1, 0);    //  Yellow (Intermediate step)
        self.healthBarColors[4] = (1, 1, 0);    //  Yellow (Intermediate step)
        self.healthBarColors[5] = (0, 0.5, 0);      //  Green (Max Life)
    }
}

DeleteHealthBar()
{
    if(!isDefined(self.HealthBar))
        return;

    for(i = 0; i < self.healthBar.size; i++)
        self.healthBar[i] thread hudFadenDestroy(0, 0.5);

    self.prevMaxHealth = undefined;
    self.healthBarColors = undefined;
}

ZombieCounter(player)
{
    player.ZombieCounter = isDefined(player.ZombieCounter) ? undefined : true;

    if(isDefined(player.ZombieCounter))
    {
        player thread DrawZombieCounter();
    }
    else
    {
        player notify("end_zombie_counter");
        player thread DeleteZombieCounter();
    }
}

DrawZombieCounter()
{
    //  CONSTANTS
    SKULL = "menu_zm_rank_3";
    SKULLON = "menu_zm_rank_3_ded";
    SKULLKNIFE = "menu_zm_rank_4";
    SKULLKNIFEON = "menu_zm_rank_4_ded";
    SHOTGUNS = "menu_zm_rank_5_ded";
    
    self endon("end_zombie_counter");
    self endon("disconnect");
    self endon("death");

    if(level.round_number <= 5)
        self.ZmCounterShader = SKULL;
    else if(level.round_number > 5 && level.round_number <= 10)
        self.ZmCounterShader = SKULLON;
    else if(level.round_number > 10 && level.round_number <= 15)
        self.ZmCounterShader = SKULLKNIFE;
    else if(level.round_number > 15 && level.round_number <= 20)
        self.ZmCounterShader = SKULLKNIFEON;
    else if(level.round_number >= 25)
        self.ZmCounterShader = SHOTGUNS;

    currZombies = zombie_utility::get_current_zombie_count();
    self.prevZmShader = self.ZmCounterShader;
    self.prevRound = level.round_number;
    self.prevZmTotal = level.zombie_total;

    textX = 50;
    textY = 12;
    self.ZmCounter = [];   
    self.ZmCounter[0] = self LUI_createRectangle( 4, 40, 15, 150, 55, (0, 0, 0), "white", 0, 0);
    self.ZmCounter[1] = self LUI_createRectangle( 4, 10, 10, 60, 60, (1, 1, 1), self.ZmCounterShader, 0, 1);
    self.ZmCounter[2] = self createText("hudsmall", 1.3, 1, "Alive: ", "TOP_LEFT", "TOP_LEFT", textX, textY + 15, 0, (1, 1, 1));
    self.ZmCounter[3] = self createText("hudsmall", 1.3, 1, currZombies, "TOP_LEFT", "TOP_LEFT", textX + 25, textY + 15, 0, (1, 1, 1));
    self.ZmCounter[4] = self createText("hudsmall", 1.3, 1, "Zombies Left: ", "TOP_LEFT", "TOP_LEFT", textX, textY, 0, (1, 1, 1));
    self.ZmCounter[5] = self createText("hudsmall", 1.3, 1, level.zombie_total + currZombies, "TOP_LEFT", "TOP_LEFT", textX + 60, textY, 0, (1, 1, 1));

    for(i = 0; i < self.ZmCounter.size; i++)
    {
        if(i == 0)
            self thread LuiFade(self.ZmCounter[i], 0.4, 0.5);
        else
        {
            if(isLui(self.ZmCounter[i]))
                self thread LuiFade(self.ZmCounter[i], 0.8, 0.5);
            else
                self.ZmCounter[i] thread hudFade(0.8, 0.5);
        }
    }

    for(;;)
    {
        if(currZombies != zombie_utility::get_current_zombie_count())
        {
            currZombies = zombie_utility::get_current_zombie_count();
            self.prevZmTotal = level.zombie_total;
            self.ZmCounter[3] setValue(currZombies);
            self.ZmCounter[5] setValue(level.zombie_total + currZombies);
        }
        self CheckZmCounterShader();
        if(self.ZmCounterShader != self.prevZmShader)
        {
            // self iPrintLnBold("^3Changing Shader");
            self LuiFade(self.ZmCounter[1], 0, 0.5);
            self SetLUIMenuData(self.ZmCounter[1], "material", self.ZmCounterShader);
            self LuiFade(self.ZmCounter[1], 0.8, 0.5);
            self.prevZmShader = self.ZmCounterShader;
        }
        wait 0.5;
    }
}

CheckZmCounterShader()
{
    SKULL = "menu_zm_rank_3";
    SKULLON = "menu_zm_rank_3_ded";
    SKULLKNIFE = "menu_zm_rank_4";
    SKULLKNIFEON = "menu_zm_rank_4_ded";
    SHOTGUNS = "menu_zm_rank_5_ded";

    if(!isDefined(self.prevRound))
        self.prevRound = level.round_number;

    if(level.round_number == self.prevRound)
        return;
    else
    {
        // self iPrintLnBold("^6" + self.prevRound);
        // self iPrintLnBold("^2" + level.round_number);
        self.prevRound = level.round_number;
        if(level.round_number <= 5)
            self.ZmCounterShader = SKULL;
        if(level.round_number > 5 && level.round_number <= 10)
            self.ZmCounterShader = SKULLON;
        if(level.round_number > 10 && level.round_number <= 15)
            self.ZmCounterShader = SKULLKNIFE;
        if(level.round_number > 15 && level.round_number <= 20)
            self.ZmCounterShader = SKULLKNIFEON;
        if(level.round_number >= 25)
            self.ZmCounterShader = SHOTGUNS;
        
        // self iPrintLnBold(self.ZmCounterShader);
    }
}

DeleteZombieCounter()
{
    for(i = 0; i < self.ZmCounter.size; i++)
    {
        if(i == 0)
            self thread CloseLUIMenuAfterFade(self.ZmCounter[i], 0, 0.5);
        else
        {
            if(isLui(self.ZmCounter[i]))
                self thread CloseLUIMenuAfterFade(self.ZmCounter[i], 0, 0.5);
            else
                self.ZmCounter[i] thread hudFadenDestroy(0, 0.5);
        }
    }
}

SetMovementSpeed(scale, player)
{
    player endon("disconnect");
    
    player.movespeedscale = scale;
    player SetMoveSpeedScale(scale);
}

Invisibility(player)
{
    player.invisibility = isDefined(player.invisibility) ? undefined : true;
    
    if(IsDefined(player.invisibility))
    {
        player.invisibility = true;
        player hide();
    }
    else 
    {
        player.invisibility = undefined;
        player show();
    }
}

NoSpread(player)
{
    player endon("disconnect");

    player.NoSpread = isDefined(player.NoSpread) ? undefined : true;

    if(isDefined(player.NoSpread))
    {
        if(player.spreadvalue != 1)
            player.spreadvalue = 1;
        player SetSpreadOverride(1);
    }
    else
        player ResetSpreadOverride();
}

ModdedSpread(value, player)
{
    if(isDefined(player.NoSpread))
        player NoSpread(player);

    if(value == 0)
    {
        player.spreadvalue = value;
        player ResetSpreadOverride();
        return;    
    }

    player.spreadvalue = value;
    player SetSpreadOverride(value);
}

ExoSuit(player)
{
    player endon("disconnect");

    if(!isDefined(level.MenuExoSuits))
        return self iPrintLnBold("^1Error^7: Exo suits not enabled");
    
    player.ExoSuit = isDefined(player.ExoSuit) ? undefined : true;

    if(isDefined(player.ExoSuit))
    {
        player SetDoubleJumpEnergy(200);
        player AllowDoubleJump(1);
        player iPrintLnBold("Exo Suit ^2ON");
    }
    else
    {
        player SetDoubleJumpEnergy(0);
        player AllowDoubleJump(0);
        player iPrintLnBold("Exo Suit ^1OFF");
    }
}

DoubleJump(player)
{    
    if(isDefined(player.FrogJump))
        player thread FrogJump();
    
    player.DoubleJump = isDefined(player.DoubleJump) ? undefined : true;

    player endon("disconnect");

    while(isDefined(player.DoubleJump))
    {
        if(player JumpButtonPressed() && !player IsOnGround())
        {
            wait 0.1;
            
            while(!player JumpButtonPressed() && !player IsOnGround())
                wait 0.01;
            
            if(player JumpButtonPressed())
                player SetVelocity(player GetVelocity() + (0, 0, 250));

            while(!player IsOnGround())
                wait 0.01;
        }
        wait 0.05;
    }
}

CommonVision(vision, player)
{
    player endon("disconnect");

    switch(vision)
    {
        case "Default":
            player UseServerVisionSet(false);    
        break;

        case "LastStand":
            player UseServerVisionSet(true);
            player SetVisionSetForPlayer("zombie_last_stand", 0);
        break;

        case "Death":
            player UseServerVisionSet(true);
            player SetVisionSetForPlayer("zombie_death", 0);
        break;

        default:
            break;
    }
}

SetVision(type, vision, player)
{
    player notify("vision_changed");
    
    if( player.currentVision == vision )
    {
        player.currentVision = "None";
        return;
    }
        
    player.currentVision = vision;
    waittillframeend;

    visionset_mgr::activate_per_player( type, vision, player, 1.25 );
    player waittill("vision_changed");
    visionset_mgr::deactivate_per_player( type, vision, player );
}

ZombieChams(color, player)
{
    player endon("disconnect");

    switch(color)
    {
        case "None":
            color = 0;
            break;
        
        case "Orange":
            color = 1;
            break;
        
        case "Green":
            color = 2;
            break;
        
        case "Purple":
            color = 3;
            break;
        
        case "Blue":
            color = 4;
            break;
        
        default:
            color = 0;
            break;
    }
    player thread clientfield::set_to_player("eye_candy_render", color);
}

HideHUD(player)
{
    player endon("disconnect");

    player.HideHud = isDefined(player.HideHud) ? undefined : true;

    if(isDefined(player.HideHud))
    {
        player SetClientUIVisibilityFlag("hud_visible", 0);
    }
    else
        player SetClientUIVisibilityFlag("hud_visible", 1);
}

SetCharacterModel(name, player, fx)
{
    player endon("disconnect");

    if(!isDefined(fx) || !fx)
    {
        PlayFX(level._effect["teleport_splash"], player.origin);
        PlayFX(level._effect["teleport_aoe_kill"], player GetTagOrigin("j_spineupper"));
    }

    for(i = 0; i < level.MenuCharacterNames.size; i++)
    {
        if(level.MenuCharacterNames[i] == name)
        {
            player.characterIndex = i;
            player SetCharacterBodyType(i);
            player zm_audio::setexertvoice(i);
            return;
        }
    }
}

SprintnShoot(player)
{
    player endon("disconnect");
    player.SprintnShoot = isDefined(player.SprintnShoot) ? undefined : true;

    if(isDefined(player.SprintnShoot))
        if(!player HasPerk("specialty_sprintfire"))
            player SetPerk("specialty_sprintfire");
    else
        player UnSetPerk("specialty_sprintfire");
}

UnlimitedSprint(player)
{
    player endon("disconnect");
    player.UnlimitedSprint = isDefined(player.UnlimitedSprint) ? undefined : true;

    if(isDefined(player.UnlimitedSprint))
    {
        if(!player HasPerk("specialty_unlimitedsprint"))
            player SetPerk("specialty_unlimitedsprint");
    }
    else
    {
        player unsetPerk("specialty_unlimitedsprint");
        player setsprintduration(4);
	    player setsprintcooldown(0);
    }
}

ChasquiBoom(player)
{
    player endon("disconnect");
    
    if(isDefined(player.PhdFlopper))
        return self iPrintLnBold("^1Error^7: PhD Flopper active");

    player.ChasquiBoom = isDefined(player.ChasquiBoom) ? undefined : true;

    if(isDefined(player.ChasquiBoom))
        player.NoExplosiveDamage = true;    //  Works witch override
    else
        player.NoExplosiveDamage = undefined;    //  Works witch override
}