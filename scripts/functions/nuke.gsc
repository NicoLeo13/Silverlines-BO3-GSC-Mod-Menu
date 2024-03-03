//  CHECK SUBMENU CURSOR POS WHEN CHANGING SUBMENUS
//NUKE GAME
CommitSuicide(player)
{
    // if(player IsDown())
    //     return self iPrintlnBold("^1ERROR: ^7Player Is Already Down");
    
    if(isDefined(player.godmode))
        player Godmode(player);

    player DisableInvulnerability(); //Just to ensure that the player is able to be damaged.
    player DoDamage(player.health + 999, (0, 0, 0));
    player.bleedout_time = 0.1;
    player zm_laststand::bleed_out();
}

DoNuke()
{
    // self notify("NukeInbound");
    foreach(player in level.players)
    {
        if(player isInMenu())
        {
            player CloseMenu();
            if(isDefined(self.menu["Instructions"]))
                player thread SetMenuInstructions();
            // if(!player IsHost() && player getVerification() > 0)
            if(player getVerification() > 0)
            {
                player thread setVerification(0, player, undefined, true);
                // player notify("access");
                // player.access = undefined;
            }
            self notify("NukeInbound");
        }
    }

    huds = [];
    huds[0] = self createServerRectangle("CENTER", "TOPLEFT", 50, 50, 50, 50, (0,0,0), 2, 0, "white"); 
    huds[1] = self createServerRectangle("CENTER", "TOPLEFT", 154, 50, 150, 54, (0,0,0), 2, 0, "white"); 
    huds[2] = self createServerText("objective", 1.2, 3, "Nuke Inbound... Say your last wishes.\nRest in peace " + ReturnMapName(level.script) + ".\nYours sincerely " + self.name + ".", "LEFT", "TOPLEFT", 85, 35, 0, (1, 1, 1));
    huds[3] = self createServerRectangle("CENTER", "TOPLEFT", 36, 36, 25, 25, (1,0,0), 1, 0, "white"); 
    huds[4] = self createServerRectangle("CENTER", "TOPLEFT", 64, 36, 25, 25, (1,0,0), 1, 0, "white");
    huds[5] = self createServerRectangle("CENTER", "TOPLEFT", 64, 64, 25, 25, (1,0,0), 1, 0, "white"); 
    huds[6] = self createServerRectangle("CENTER", "TOPLEFT", 36, 64, 25, 25, (1,0,0), 1, 0, "white"); 
    huds thread NukeColor();
    
    for(i = 0; i < huds.size; i++)
        huds[i] thread hudFade(1, 0.1);
    countdown = self createServerText("bigfixed", 2, 3, 9, "CENTER", "TOPLEFT", 50, 50, 0, (1,1,1));
    countdown thread hudFade(1, 0.2);
    wait 0.1;

    for(i = 9; i > 0; i--)
    {
        countdown setValue(i);
        if(i == 1)
        {
            setSlowMotion( 1.0, 0.25, 0.5 );
            self PlaySoundToTeam( "zmb_bgb_shoppingfree_coinreturn", "allies" );
            wait 0.5;
            countdown setValue( 0 );
            wait 0.3;
            break;
        }
        else
        {
            self PlaySoundToTeam( "zmb_bgb_shoppingfree_coinreturn", "allies" );
            wait 1;
        }
    }

    destroyAll(huds);
    countdown destroy();

    thread LUI::screen_flash(0.2, 0.5, 1, 0.8, "white");
    self PlaySoundToTeam( "evt_nuked", "allies" );
    self PlaySoundToTeam( "evt_nuke_flash", "allies" );
    self killAllZombies();
    foreach(player in level.players)
    {
        earthquake(0.6, 7, player.origin, 100000);
        player thread commitSuicide(player);
    }
    wait 1;
    setSlowMotion( .25, 1, 2 );
}

NukeColor()
{
    self[0] endon("death");
    while( isDefined( self[0] ) )
    {
        for(e=3;e<self.size;e++)
        {
            self[e] thread DoNukeColor();
            wait .2;
        }
        wait .05;
    }
}

DoNukeColor()
{
    self endon("death");
    self fadeOverTime(.2);
    self.color = rgb(255, 240, 76); //yellow
    wait .2;
    self fadeOverTime(.2);
    self.color = rgb(255, 68, 4);  //orange 
    wait .2;
    self fadeOverTime(.2);
    self.color = rgb(203, 0, 2);  //red
    wait .2;
}

rgb(r, g, b)
{
    return (r/255, g/255, b/255);
}

killAllZombies()
{
    level notify("restart_round");
    zombies = getAIArray();

    if(isdefined(zombies))
    {
        for(i = 0; i < zombies.size; i++)
            zombies[i] DoDamage(zombies[i].health + 1, zombies[i].origin);
    }
}
