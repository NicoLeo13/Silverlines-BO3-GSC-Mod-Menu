//Functions
Godmode(player)
{
    if(isDefined(player.DemiGod))
        player DemiGod(player);

    player.godmode = isDefined(player.godmode) ? undefined : true;

    if(isDefined(player.godmode))
    {
        player endon("disconnect");
        player EnableInvulnerability();
        
        if(player IsHost())
            player.godModeCalled = true;
    }
    else
    {
        player DisableInvulnerability();
        if(player IsHost())
        {
            player.godModeCalled = false;
        }
    }
}

DemiGod(player)
{
    if(isDefined(player.godmode))
        player Godmode(player);

    player.DemiGod = isDefined(player.DemiGod) ? undefined : true;
}

NoTarget(player)
{   
    player.NoTarget = isDefined(player.NoTarget) ? undefined : true;

    if(isDefined(player.NoTarget))
    {
        player endon("disconnect");
        player.ignoreme = true;
    }
    else
        player.ignoreme = false;
}

InfiniteAmmo(type, player)
{
    player notify("EndUnlimitedAmmo");
    player endon("EndUnlimitedAmmo");

    if(type != "Disable")
    {
        self iPrintLnBold("Infinite Ammo Type: ^5" + type);
        player endon("disconnect");

        while(1)
        {
            player GiveMaxAmmo(player GetCurrentWeapon());

            if(type == "Non-Stop")
                player SetWeaponAmmoClip(player GetCurrentWeapon(), player GetCurrentWeapon().clipsize);

            wait 0.1;
        }
    }
    else
        self iPrintLnBold("Infinite Ammo ^1OFF");
}

PermaGrenade(player)    //  Grenades, equipment, widow, etc
{
    if(!IsDefined(player.permagrenade))
    {
        player.permagrenade = true;
        self iPrintLnBold("Unlimited Grenades ^2ON");
        while(IsDefined(player.permagrenade)) 
        {
            player setWeaponAmmoClip(player.current_lethal_grenade, 99);
            wait 2;
        }
    }
    else
    {
        player.permagrenade = undefined;
        self iPrintLnBold("Unlimited Grenades ^1OFF");
    }
}

ModifyScore(score, player)
{
    score = Int(score);

    if(score >= 0)
    {
        player zm_score::add_to_player_score(score);
        self iPrintLnBold("Added: ^2" + score + "^7 to " + CleanName(player getName()));
    }
    else if(score <= 0)
    {
        player zm_score::minus_to_player_score((score * -1));
        self iPrintLnBold("Removed: ^1" + (score * -1) + "^7 from " + CleanName(player getName()));
    }
    else
    {
        player.score = 0;
        player.pers["score"] = 0;
    }
}

Keep_Perks(player)
{
    if(!isDefined(player.keepPerks))
    {
        self iPrintlnBold("Keep all Perks on death ^2ON");
        player.keepPerks = true;
        player._retain_perks = true;   
    }
    else
    {
        self iPrintlnBold("Keep all Perks on death ^1OFF");
        player.keepPerks = undefined;
        player._retain_perks = undefined;
        player._retain_perks_array = undefined;

        for(a = 0; a < level.CustomPerks.size; a++)
            if(player HasPerk(level.CustomPerks[a]) || player zm_perks::has_perk_paused(level.CustomPerks[a]))
                player thread zm_perks::perk_think(level.CustomPerks[a]);
    }
}

GiveAllPerks(player)
{
    player endon("disconnect");

    if(player.perks_active.size != level.CustomPerks.size)
    {
        for(a = 0; a < level.CustomPerks.size; a++)
            if(!player HasPerk(level.CustomPerks[a]) && !player zm_perks::has_perk_paused(level.CustomPerks[a]))
                player thread zm_perks::give_perk(level.CustomPerks[a]);
    }
    else
    {
        for(a = 0; a < level.CustomPerks.size; a++)
            if(player HasPerk(level.CustomPerks[a]) || player zm_perks::has_perk_paused(level.CustomPerks[a]))
            {
                if(isDefined(player.keepPerks))
                    return self iPrintLnBold("^1Error: ^7Deactivate Keep Perks on Death ^1First!");
                player notify(level.CustomPerks[a] + "_stop");
            }
    }
}

GivePerk(perk, player)
{
    if(player HasPerk(perk) || player zm_perks::has_perk_paused(perk))
    {
        if(isDefined(player.keepPerks))
            return self iPrintLnBold("^1Error: ^7Deactivate Keep Perks on Death ^1First!");
        player notify(perk + "_stop");
    }
    else
        player zm_perks::give_perk(perk);
}

GiveGobblegum(gum, player)
{
    player endon("disconnect");
    
    if(player.bgb != gum)
    {
        if(isDefined(player.bgb))
            player thread bgb::take();
        player.bgb = gum;
        saved = player GetCurrentWeapon();
        weapon = GetWeapon("zombie_bgb_grab");
        player GiveWeapon(weapon, player CalcWeaponOptions(level.bgb[gum].camo_index, 0, 0));
        player SwitchToWeapon(weapon);
        player playsound("zmb_bgb_powerup_default");
    
        evt = player util::waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete", "disconnect");
        if(evt == "weapon_change_complete")
        {
            player takeWeapon(weapon);
            player zm_weapons::switch_back_primary_weapon(saved);
            bgb::give(gum);
        }
    }
    else
        player bgb::take();
}

Noclip(player)
{
    if(!isDefined(player.Noclip) && player isPlayerLinked())
        return self iPrintlnBold("^1Error: ^7Player Is Linked To An Entity");
    
    player.Noclip = isDefined(player.Noclip) ? undefined : true;
    
    if(isDefined(player.Noclip))
    {
        player endon("disconnect");

        if(player HasMenu() && player isInMenu())
            player CloseMenu(true);

        player DisableWeapons();
        player DisableOffHandWeapons();

        player.nocliplinker = SpawnScriptModel(player.origin, "tag_origin");
        player PlayerLinkTo(player.nocliplinker, "tag_origin");
        player.menu["ControlsLock"] = true;

        if(!isDefined(player.menu["Instructions"]))
            player thread AuxInstructions("NoClip");
        
        player EnableInvulnerability();
        
        while(isDefined(player.Noclip) && Is_Alive(player) && !player isPlayerLinked(player.nocliplinker))
        {
            if(player AttackButtonPressed())
                player.nocliplinker.origin = player.nocliplinker.origin + AnglesToForward(player GetPlayerAngles()) * 60;
            else if(player AdsButtonPressed())
                player.nocliplinker.origin = player.nocliplinker.origin - AnglesToForward(player GetPlayerAngles()) * 60;

            if(player MeleeButtonPressed() && !player AttackButtonPressed() && !player AdsButtonPressed())
                break;

            wait 0.01;
        }

        if(isDefined(player.Noclip))
            player Noclip(player);
    }
    else
    {
        if(!isDefined(self.menu["Instructions"]))
            player thread AuxInstructions("NoClip");

        player Unlink();
        player.nocliplinker delete();

        player EnableWeapons();
        player EnableOffHandWeapons();
        if(!isDefined(player.GodMode))
            player disableInvulnerability();

        player.menu["ControlsLock"] = undefined;
    }
}

BindNoclip(player)
{
    if(isDefined(player.Jetpack) && !isDefined(player.NoclipBind))
        return self iPrintlnBold("^1Error: ^7Player Has Jetpack Enabled");
    
    if(isDefined(player.SpecNade) && !isDefined(player.NoclipBind))
        return self iPrintlnBold("^1Error: ^7Player Has Spec-Nade Enabled");
    
    player.NoclipBind = isDefined(player.NoclipBind) ? undefined : true;
    
    player endon("disconnect");

    while(isDefined(player.NoclipBind))
    {
        if(player ActionSlotTwoButtonPressed() && !isDefined(player.menu["ControlsLock"]))
        {
            player thread Noclip(player);
            wait 0.2;
        }

        wait 0.025;
    }
}

UFOMode(player)
{
    if(!isDefined(player.UFOMode) && player isPlayerLinked())
        return self iPrintlnBold("^1Error: ^7Player Is Linked To An Entity");
    
    player.UFOMode = isDefined(player.UFOMode) ? undefined : true;
     
    if(isDefined(player.UFOMode))
    {
        player endon("disconnect");

        if(player HasMenu() && player isInMenu())
            player CloseMenu(true);

        player DisableWeapons();
        player DisableOffHandWeapons();

        player.ufolinker = SpawnScriptModel(player.origin, "tag_origin");
        player PlayerLinkTo(player.ufolinker, "tag_origin");
        player.menu["ControlsLock"] = true;

        if(!isDefined(player.menu["Instructions"]))
            player thread AuxInstructions("UFO");
        // player SetMenuInstructions("[{+attack}] - Move Up\n[{+speed_throw}] - Move Down\n[{+frag}] - Move Forward\n[{+melee}] - Exit");
        
        player EnableInvulnerability();
        
        while(isDefined(player.UFOMode) && Is_Alive(player) && !player isPlayerLinked(player.ufolinker))
        {
            player.ufolinker.angles = (player.ufolinker.angles[0], player GetPlayerAngles()[1], player.ufolinker.angles[2]);

            if(player AttackButtonPressed())
                player.ufolinker.origin = player.ufolinker.origin + AnglesToUp(player.ufolinker.angles) * 60;
            else if(player AdsButtonPressed())
                player.ufolinker.origin = player.ufolinker.origin - AnglesToUp(player.ufolinker.angles) * 60;

            if(player FragButtonPressed())
                player.ufolinker.origin = player.ufolinker.origin + AnglesToForward(player.ufolinker.angles) * 60;
            
            if(player MeleeButtonPressed())
                break;

            wait 0.01;
        }

        if(isDefined(player.UFOMode))
            player thread UFOMode(player);
    }
    else
    {
        if(!isDefined(player.menu["Instructions"]))
            player thread AuxInstructions("UFO");
        
        player Unlink();
        player.ufolinker delete();

        player EnableWeapons();
        player EnableOffHandWeapons();
        if(!isDefined(player.GodMode))
            player disableInvulnerability();

        player.menu["ControlsLock"] = undefined;
    }
}

