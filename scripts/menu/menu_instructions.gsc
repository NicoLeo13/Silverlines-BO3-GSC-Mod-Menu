MenuInstructions()
{
    //  CONSTANTS
    HUD = "hud";
    //4 - LEFT | 1 - RIGHT | 2 - CENTER
    // LUI_createRectangle( alignment, x, y, width, height, rgb, shader, alpha, sort, rotation)
    // LUI_createText(text, align, x, y, width, color, alpha)
    self endon("EndInstructions");

    if(isDefined(self.menu["Instructions"]))
    {
        if(self.perks_active.size > 5)
            self.instructionsY = 5;
        else
            self.instructionsY = 680;

        self.instructions = [];
        self.instructions[0] = self LUI_createRectangle( 0, 460, self.instructionsY, 360, 34, (0, 0, 0), "white", 0, 1);
        self.instructions[1] = self LUI_createRectangle( 0, 462, self.instructionsY + 2, 356, 30, (0, 0, 0), "white", 0, 2);
        //  Created static hud strings to prevent posible overflow. Each text hud alpha will be 0 and will get set wit fades to show each text 
        self.instructions[2] = self LUI_createText("Hold [{+speed_throw}] & [{+melee}] to Open Menu", 2, 340, self.instructionsY + 3, 600, (1, 1, 1), 0);
        self.instructions[3] = self LUI_createText("[{+attack}]/[{+speed_throw}] to Scroll || [{+activate}] to Select", 2, 340, self.instructionsY + 3, 600, (1, 1, 1), 0);
        self.instructions[4] = self LUI_createText("[{+actionslot 3}]/[{+actionslot 4}] Slider Left/Right || [{+melee}] to Go Back/Exit", 2, 340, self.instructionsY + 3, 600, (1, 1, 1), 0);
        self thread RandomFade(self.instructions[0], 4, "instructions");

        self.insBgalpha = (self.instructionsY == 680 ? 0.6 : 0.3);
        self.insFgalpha = (self.instructionsY == 680 ? 0.8 : 0.5);
        for(i = 0; i < 2; i++)
        {
            alpha = ((i == 0) ? self.insBgalpha : self.insFgalpha);
            self thread LuiFade(self.instructions[i], alpha, 1);
        }
        
        if(!isDefined(self.perks_active))               //  Arrays initialize
            self.perks_active = [];
        else if(!IsArray(self.perks_active))
            self.perks_active = array(self.perks_active);

        if(!isDefined(self.virtualperks))               //  Arrays initialize
            self.virtualperks = [];
        else if(!IsArray(self.virtualperks))
            self.virtualperks = array(self.virtualperks);

        // lastActivePerks = self.perks_active.size;
        lastActivePerks = self.perks_active.size + self.virtualperks.size;

        while(isDefined(self.menu["Instructions"]))
        {
            // if((self.perks_active.size > 5 && lastActivePerks != self.perks_active.size) || (self.perks_active.size <= 5 && lastActivePerks != self.perks_active.size))
            if(((self.perks_active.size + self.virtualperks.size) > 5 && lastActivePerks != (self.perks_active.size + self.virtualperks.size)) || ((self.perks_active.size + self.virtualperks.size) <= 5 && lastActivePerks != (self.perks_active.size + self.virtualperks.size)))
            {
                // lastActivePerks = self.perks_active.size;
                lastActivePerks = self.perks_active.size + self.virtualperks.size;
                self PerkPosWatcher();
            }
            
            if(self isInMenu() && !isDefined(self.inMenuTextCalled) && !isDefined(self.Noclip) && !isDefined(self.UFOMode))
                self thread InMenuText();
            
            if(!self isInMenu() && !isDefined(self.outMenuTextCalled) && !isDefined(self.Noclip) && !isDefined(self.UFOMode))
                self thread OutMenuText();

            if(!self isInMenu() && !isDefined(self.noClipMenuTextCalled) && isDefined(self.Noclip))
                self thread NoClipText();

            if(!self isInMenu() && !isDefined(self.UFOMenuTextCalled) && isDefined(self.UFOMode))
                self thread UFOText();
            
            wait 0.1;
        }
    }
}

PerkPosWatcher()
{
    // if(self.perks_active.size > 5)
    if((self.perks_active.size + self.virtualperks.size) > 5)
        self.instructionsY = 5;
    else
        self.instructionsY = 680;
    
    if(self GetLUIMenuData(self.instructions[0], "y") == self.instructionsY)
        return;
    
    self notify("OutMenu");
    self notify("inMenu");
    self notify("NoClip");
    self notify("UFO");

    // if(self.perks_active.size > 5)
    if((self.perks_active.size + self.virtualperks.size) > 5)
    {
        self.instructionsY = 5;
        for(i = 0; i < self.instructions.size; i++)
        {
            self thread LuiFade(self.instructions[i], 0, 0.3);
        }
        wait 0.3;
        for(i = 0; i < self.instructions.size; i++)
        {
            if(i == 0)
                self SetLUIMenuData(self.instructions[i], "y", self.instructionsY);
            else if(i == 1)
                self SetLUIMenuData(self.instructions[i], "y", self.instructionsY + 2);
            else
                self SetLUIMenuData(self.instructions[i], "y", self.instructionsY + 3);
        }
        self.insBgalpha = 0.3;
        self.insFgalpha = 0.5;
    }
    else
    {
        self.instructionsY = 680;
        for(i = 0; i < self.instructions.size; i++)
        {
            self thread LuiFade(self.instructions[i], 0, 0.3);
        }
        wait 0.3;
        for(i = 0; i < self.instructions.size; i++)
        {
            if(i == 0)
            
                self SetLUIMenuData(self.instructions[i], "y", self.instructionsY);
            else if(i == 1)
                self SetLUIMenuData(self.instructions[i], "y", self.instructionsY + 2);
            else
                self SetLUIMenuData(self.instructions[i], "y", self.instructionsY + 3);
        }
        self.insBgalpha = 0.6;
        self.insFgalpha = 0.8;
    }

    self.inMenuTextCalled = undefined;
    self.outMenuTextCalled = undefined;
    self.UFOMenuTextCalled = undefined;
    self.noClipMenuTextCalled = undefined;
    self thread LuiFade(self.instructions[0], self.insBgalpha, 0.3);
    self thread LuiFade(self.instructions[1], self.insFgalpha, 0.3);
}

SetMenuInstructions()
{
    self.menu["Instructions"] = isDefined(self.menu["Instructions"]) ? undefined : true;

    if(!isDefined(self.menu["Instructions"]))
    {
        for(i = 0; i < self.instructions.size; i++)
        {
            self thread CloseLUIMenuAfterFade(self.instructions[i], 0, 0.5);
        }
        self.inMenuTextCalled = undefined;
        self.outMenuTextCalled = undefined;
        self.UFOMenuTextCalled = undefined;
        self.noClipMenuTextCalled = undefined;
        self notify("EndInstructions");
        self thread RandomFade(self.instructions[0], 4, "instructions");   //  Adjust depending on Fade Type
    }
    else
        self thread MenuInstructions();

}

DeleteInstructions()
{
        // self notify("StopRandomFade" + self.instructions[0]);
        // self.RainbowType["instructions"] = undefined;
        // self.hudopen["instructions"] = undefined;   //  For some reason, calling the function again does not work
        self RandomFade(self.instructions[0], 4, "instructions");   //  REVISAR ISLUI
        for(i = 0; i < self.instructions.size; i++)
        {
            self CloseLUIMenu(self.instructions[i]);
        }
        self.inMenuTextCalled = undefined;
        self.outMenuTextCalled = undefined;
        self.UFOMenuTextCalled = undefined;
        self.noClipMenuTextCalled = undefined;
        self notify("EndInstructions");
}

InMenuText()
{
    self endon("OutMenu");
    self endon("NoClip");
    self endon("UFO");
    self endon("EndAccess");
    self endon("EndInstructions");
    self notify("inMenu");

    self.outMenuTextCalled = undefined;
    self.UFOMenuTextCalled = undefined;
    self.noClipMenuTextCalled = undefined;
    self.inMenuTextCalled = true;

    while(self isInMenu() && isDefined(self.menu["Instructions"]))
    {
        if(self GetLUIMenuData(self.instructions[2], "alpha") != 0)
        {
            self HideSpecialTextCalled();
            self LuiFade(self.instructions[2], 0, 0.5); //  After Menu Open/Closed Switch
        } 
        
        self LuiFade(self.instructions[3], self.insFgalpha, 1);
        wait 3;
        self LuiFade(self.instructions[3], 0, 1);
        self LuiFade(self.instructions[4], self.insFgalpha, 1);
        wait 3;
        self LuiFade(self.instructions[4], 0, 1);
    }
}

OutMenuText()
{
    self endon("inMenu");
    self endon("NoClip");
    self endon("UFO");
    self endon("EndAccess");
    self endon("EndInstructions");
    self notify("OutMenu");

    self.inMenuTextCalled = undefined;
    self.UFOMenuTextCalled = undefined;
    self.noClipMenuTextCalled = undefined;
    self.outMenuTextCalled = true;

    while(!self isInMenu() && isDefined(self.menu["Instructions"]))
    {
        if(self GetLUIMenuData(self.instructions[2], "alpha") != self.insFgalpha)
        {
            self HideSpecialTextCalled();
            self LuiFade(self.instructions[3], 0, 0.5);   //  Fade InMenuText alpha to 0
            self LuiFade(self.instructions[4], 0, 0.5);   //  Fade InMenuText alpha to 0

            self LuiFade(self.instructions[2], self.insFgalpha, 1);
        }
        wait 0.2;
    }
}

NoClipText()
{
    self endon("inMenu");
    self endon("OutMenu");
    self endon("EndAccess");
    self endon("EndInstructions");
    self notify("NoClip");

    self.inMenuTextCalled = undefined;
    self.outMenuTextCalled = undefined;    
    self.noClipMenuTextCalled = true;

    if(!self isInMenu() && isDefined(self.menu["Instructions"]) && isDefined(self.Noclip))
    {
        if(!isDefined(self.instructions["NoClip"]))
            self.instructions["NoClip"] = self LUI_createText("[{+attack}] Move Forward || [{+speed_throw}] Move Backwards || [{+melee}] Exit", 2, 370, self.instructionsY + 3, 600, (1, 1, 1), 0);
        
        if(self GetLUIMenuData(self.instructions["NoClip"], "y") != (self.instructionsY + 3))
            self SetLUIMenuData(self.instructions["NoClip"], "y", self.instructionsY + 3);
        
        if(self GetLUIMenuData(self.instructions["NoClip"], "alpha") != self.insFgalpha)
        {
            self thread LuiMoveOverTime(self.instructions[0], 400, self.instructionsY, 0.5);
            self thread LuiMoveOverTime(self.instructions[1], 402, self.instructionsY + 2, 0.5);
            self thread LuiWidthOverTime(self.instructions[0], 540, 0.5);
            self thread LuiWidthOverTime(self.instructions[1], 536, 0.5);
            self LuiFade(self.instructions[2], 0, 0.5);   //  Fade InMenuText alpha to 0
            self LuiFade(self.instructions[3], 0, 0.5);   //  Fade InMenuText alpha to 0
            self LuiFade(self.instructions[4], 0, 0.5);   //  Fade InMenuText alpha to 0
            
            self LuiFade(self.instructions["NoClip"], self.insFgalpha, 1);
        }
    }    
}

UFOText()
{
    self endon("inMenu");
    self endon("OutMenu");
    self endon("EndAccess");
    self endon("EndInstructions");
    self notify("UFO");

    self.inMenuTextCalled = undefined;
    self.outMenuTextCalled = undefined;    
    self.UFOMenuTextCalled = true;

    if(!self isInMenu() && isDefined(self.menu["Instructions"]) && isDefined(self.UFOMode))
    {
        if(!isDefined(self.instructions["Ufo"]))
            self.instructions["Ufo"] = self LUI_createText("[{+attack}] Move Up || [{+speed_throw}] Move Down || [{+frag}] Move Forward || [{+melee}] Exit", 2, 320, self.instructionsY + 3, 750, (1, 1, 1), 0);
        
        if(self GetLUIMenuData(self.instructions["Ufo"], "y") != (self.instructionsY + 3))
            self SetLUIMenuData(self.instructions["Ufo"], "y", self.instructionsY + 3);
        
        if(self GetLUIMenuData(self.instructions["Ufo"], "alpha") != self.insFgalpha)
        {
            self thread LuiMoveOverTime(self.instructions[0], 340, self.instructionsY, 0.5);
            self thread LuiMoveOverTime(self.instructions[1], 342, self.instructionsY + 2, 0.5);
            self thread LuiWidthOverTime(self.instructions[0], 700, 0.5);
            self thread LuiWidthOverTime(self.instructions[1], 696, 0.5);
            // self thread LuiWidthOverTime(self.instructions[0], 480, 0.5);
            // self thread LuiWidthOverTime(self.instructions[1], 476, 0.5);
            self LuiFade(self.instructions[2], 0, 0.5);   //  Fade InMenuText alpha to 0
            self LuiFade(self.instructions[3], 0, 0.5);   //  Fade InMenuText alpha to 0
            self LuiFade(self.instructions[4], 0, 0.5);   //  Fade InMenuText alpha to 0
            
            self LuiFade(self.instructions["Ufo"], self.insFgalpha, 1);
        }
    }    
}

HideSpecialTextCalled()
{
    if((self GetLUIMenuData(self.instructions["NoClip"], "alpha") == 0 || !isDefined(self.instructions["NoClip"])) && (self GetLUIMenuData(self.instructions["Ufo"], "alpha") == 0 || !isDefined(self.instructions["Ufo"])))    //  NoClip Text, UFO Text
        return;

    if(isDefined(self.instructions["NoClip"]) && self GetLUIMenuData(self.instructions["NoClip"], "alpha") != 0)
        self LuiFade(self.instructions["NoClip"], 0, 0.5);  //  Fade NoClipText alpha to 0
    
    if(isDefined(self.instructions["Ufo"]) &&self GetLUIMenuData(self.instructions["Ufo"], "alpha") != 0)
        self LuiFade(self.instructions["Ufo"], 0, 0.5);  //  Fade UFOText alpha to 0

    if(self GetLUIMenuData(self.instructions[0], "x") != 460)
    {
        self thread LuiMoveOverTime(self.instructions[0], 460, self.instructionsY, 0.5);
        self thread LuiMoveOverTime(self.instructions[1], 462, self.instructionsY + 2, 0.5);
    }

    self thread LuiWidthOverTime(self.instructions[0], 360, 0.5);
    self thread LuiWidthOverTime(self.instructions[1], 356, 0.5);
}

AuxInstructions(case)
{
    switch(case)
    {
        case "NoClip":
                if(isDefined(self.Noclip))
                {
                    self.NoClipHelp = [];
                    self.NoClipHelp[0] = self LUI_createText("[{+attack}] Move Forward\n[{+speed_throw}] Move Backwards\n[{+melee}] Exit", 4, 950, 20, 300, (1, 1, 1), 0);
                    self thread LuiFade(self.NoClipHelp[0], 0.6, 0.3);
                }
                else
                    self thread CloseLUIMenuAfterFade(self.NoClipHelp[0], 0, 0.3);
            break;

        case "UFO":
                if(isDefined(self.UFOMode))
                {
                    self.UFOHelp = [];
                    self.UFOHelp[0] = self LUI_createText("[{+attack}] Move Up\n[{+speed_throw}] Move Down\n[{+frag}] Move Forward\n[{+melee}] Exit", 4, 950, 20, 300, (1, 1, 1), 0);
                    self thread LuiFade(self.UFOHelp[0], 0.6, 0.3);
                }
                else
                    self thread CloseLUIMenuAfterFade(self.UFOHelp[0], 0, 0.3);
            break;

        default:
            break;
    }
}