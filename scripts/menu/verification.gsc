SetAccess(access, player, msg)
{
    player notify("access");
    player.access = access;
    player.menu["Cursor"] = [];
    // player.submenu = "none";
    status = level.menuStatus[player getVerification()];

    if(player.access)
    {
        if(player IsHost() || isDefined(msg))
            player iPrintLnBold("Access Set: " + verificationToColor(status));
        player thread MenuMonitor();
    }
}

setVerification(a, player, msg, force)
{
    if(player isHost() || player getVerification() == a || player == self)
    {
        if(isDefined(msg))
        {
            if(player isHost() && !isDefined(force))
                return self iPrintlnBold("^1Error: ^7You Can't Change The Status Of The ^2Host");
            
            if(player getVerification() == a)
                return self iPrintlnBold("^1Error: ^7Verification Already Set To " + verificationToColor(level.menuStatus[a]));
            
            if(player == self && !isDefined(force))
                return self iPrintlnBold("^1Eror: ^7You Can't Change Your Own Status");
                
            if(self getVerification() < 3)
                return self iPrintlnBold("^1Error: ^7Not Enough Privileges");
            
            if(player getVerification() >= self getVerification())
                return self iPrintlnBold("^1Error: ^7Can't Change " + verificationToColor(level.menuStatus[player getVerification()]) + " Access\nNot Enough Privileges");

            if(self getVerification() <= a && self getVerification() < 4 || self getVerification() < 4)
                return self iPrintlnBold("^1Error: ^7You Can't Set Players To Same or Higher Access Level Than You");

            if(a > 4 && !self getVerification() > 4)
                return self iPrintlnBold("^1Error: ^7You Can't Set Host Access Level");
        }
        return;
    }
    
    if(player isInMenu())
        player CloseMenu();
    hadMenu = player getVerification();
    player.menu["Verification"] = level.menuStatus[a];
    // player iPrintlnBold("Your Status Has Been Set To ^2" + player.menu["Verification"]);
    
    player.menu["CurrentMenu"] = "none";
    // player.menu["Cursor"]["Main"] = 0;
    player RunMenu();
    self thread refreshTitle(self getCurrentMenu());
    
    if(player HasMenu())
    {
        if(!isDefined(player.welcomeShowed))
        {
            self iPrintLnBold("Showing Welcome Message for: " + CleanName(player getName()));
            player WelcomeMessage();
            player.welcomeShowed = true;
        }
        player SetAccess(true, player);
        if(isDefined(player.menu["Instructions"]))
            player thread MenuInstructions();
    }
    else
    {
        if(player isInMenu())
            player CloseMenu();

        self iPrintLnBold(hadMenu);
        if(hadMenu != 0)
            player thread UnverifyChecks();
        
        player SetAccess(undefined, player);
    }
}

UnverifyChecks()
{
    // self iPrintLnBold("Entered checks");
    if(isDefined(self.menu["Instructions"]))
    {
        self thread SetMenuInstructions();    //  To Turn them off
        self notify("EndAccess");
    }
    
    if(isDefined(self.HealthBar))
        self thread HealthBar(self);

    
    if(isDefined(self.Noclip))
    {
        self bot::tap_melee_button();
        self.Noclip = undefined;
    }
    if(isDefined(self.NoclipBind))
        self thread BindNoclip(self);
    
    if(isDefined(self.UFOMode))
    {
        self bot::tap_melee_button();
        self.UFOMode = undefined;
    }

    if(isDefined(self.keepPerks))
        self thread Keep_Perks(self);

    self.NoTarget = undefined;
    self.DemiGod = undefined;
    self.permagrenade = undefined;
    self.ignoreme = false;
    self notify("EndUnlimitedAmmo");
    self DisableInvulnerability();
}

SetVerificationAllPlayers(a, msg)
{
    foreach(player in level.players)
        self setVerification(a, player);
    
    if(isDefined(msg))
        self iPrintlnBold("All Players Verification Set To ^2" + level.menuStatus[a]);
}

getVerification()
{
    if(!isDefined(self.menu["Verification"]) || self.menu["Verification"] == "None")
        return 0;

    for(a = 0; a < level.menuStatus.size; a++)
        if(self.menu["Verification"] == level.menuStatus[a])
            return a;
}

verificationToColor(status)
{
    if (status == "None")
        return "None";
    if (status == "Verified")
        return "^3Verified";
    if (status == "VIP")
        return "^5VIP";
    if (status == "Admin")
        return "^9Admin";
    if (status == "Co-Host")
        return "^6Co-Host";
    if (status == "Host")
        return "^2Host";
}

getStatus(player)
{
    status = level.menuStatus[player getVerification()];

    if(player == self)
        return "Status: " + verificationToColor(status);
    else
        return CleanName(player getName()) + " [" + verificationToColor(status) + "^7]";
}

HasMenu()
{
    return (self getVerification() > 0);
}
