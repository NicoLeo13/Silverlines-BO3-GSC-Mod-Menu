MenuMonitor()
{
    self endon("access");
    self endon("disconnect");

    self.menu["CurrentMenu"] = "none";
    self.menu_open = false;
    
    while(isDefined(self.access))
    {
        if(!self isInMenu() && !isDefined(self.menu["ControlsLock"])) // If menu closed
        {
            // self iPrintLnBold("^1Closed");
            if(self AdsButtonPressed() && self MeleeButtonPressed() && !self isInMenu())
            {
                self OpenMenu();
                wait 0.3;
            }
        }
        else if(!isDefined(self.menu["ControlsLock"]))    //  You are in Menu
        {
            // if(self MeleeButtonPressed() && self.menu["CurrentMenu"] == "Main")
            if(self IsHost())
                if(!self.godModeCalled)
                    if(!self EnableInvulnerability())
                    {
                        self EnableInvulnerability();
                        self IPrintLnBold("Auto Godmode ^2ON ^7Until Close");
                    }
            if(self MeleeButtonPressed())
            {
                if(self.menu["CurrentMenu"] == "Main")
                {
                    self CloseMenu();
                    self playsoundtoplayer("cac_screen_hpan",self);
                    wait 0.3;
                }
                else
                {
                    self newMenu();
                    self playsoundtoplayer("cac_screen_hpan",self);
                    wait 0.15;
                }
            }

            if(self adsButtonPressed()) //  Scroll Up
            {
                // self.menu.curs[self.CurMenu]--;
                self ScrollingSystem("up");
                self playsoundtoplayer("cac_grid_nav",self);
                wait self.menu["ScrollDelay"];
            }

            if(self attackButtonPressed()) //  Scroll Down
            {
                // self.menu.curs[self.CurMenu]++;
                self ScrollingSystem("down");
                self playsoundtoplayer("cac_grid_nav",self);
                wait self.menu["ScrollDelay"];
            }

            if(self ActionSlotThreeButtonPressed() || self ActionSlotFourButtonPressed())
            {
                if(!self ActionSlotThreeButtonPressed() || !self ActionSlotFourButtonPressed())
                {
                    if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[self getCursor()]))
                    {
                        dir = self ActionSlotThreeButtonPressed() ? -1 : 1;
                        self SetIntSlider(dir);
                        self PlaySoundToPlayer("uin_alert_lockon", self);
                        wait 0.2;
                    }

                    if(isDefined(self.menu["items"][self getCurrentMenu()].slider[self getCursor()]))
                    {
                        dir = self ActionSlotThreeButtonPressed() ? -1 : 1;
                        self SetStringSlider(dir);
                        self PlaySoundToPlayer("uin_alert_lockon", self);
                        wait 0.2;
                    }
                }
            }

            if(self useButtonPressed())
            {
                wait 0.05;
                menu = self getCurrentMenu();
                cursor = self getCursor();
                menuarg = self.menu["items"][menu];
                menufunc = self.menu["items"][menu].func[cursor];
                bool = self.menu["items"][menu].bool[cursor];
                intslider = self.menu["items"][menu].intslider[cursor];
                stringslider = self.menu["items"][menu].slider[cursor];

                if(isDefined(intslider))
                {
                    self thread ExecFunc(menufunc, self.menu_SValue[menu][cursor], menuarg.arg1[cursor], menuarg.arg2[cursor], menuarg.arg3[cursor], menuarg.arg4[cursor], menuarg.arg5[cursor]);
                    wait 0.05;
                    self DoClickAnim();
                    self RefreshMenu();
                }
                else if(isDefined(stringslider))
                {
                    self thread ExecFunc(menufunc, self.menu_RealStrings[menu][cursor][self.menu_SValue[menu][cursor]], menuarg.arg1[cursor], menuarg.arg2[cursor], menuarg.arg3[cursor], menuarg.arg4[cursor], menuarg.arg5[cursor]);
                    wait 0.05;
                    self DoClickAnim();
                    self RefreshMenu();
                }
                else
                {
                    self thread ExecFunc(menufunc, menuarg.arg1[cursor], menuarg.arg2[cursor], menuarg.arg3[cursor], menuarg.arg4[cursor], menuarg.arg5[cursor]);
                    wait 0.05;
                    if(menufunc != ::newMenu)
                    {
                        if(!isDefined(bool))
                            self thread DoClickAnim();
                        self RefreshMenu();
                    }
                    else
                        wait 0.3;
                }
                wait 0.15;
            }
        }
        wait 0.07;
    }
}

OpenMenu()
{
    if(isDefined(self.HealthBar))
    {
        self thread DeleteHealthBar();
        waittillframeend;
    }
    
    if(self IsHost())
    {
        self EnableInvulnerability();
        self IPrintLnBold("Auto Godmode ^2ON");
    }
    
    if(self getCurrentMenu() == "none")
        self.menu["CurrentMenu"] = "Main";
    // else
    //     self.menu["CurrentMenu"] = self getCurrentMenu();

    self RunMenu();
    self DrawHuds();
    self thread DoHudColors("Open");
    self thread DoFadeAnim("Open");
    self DoBackgroundSize();
    self thread TypeWriterFXText(level.menuName, self.menu["hud"]["MenuTitle"]);
    self thread SetMenuText();
    self DrawText();
    self thread DoBottomFade();
    if(isDefined(self.menu["ShaderRotation"]))
    {
        self thread SetShaderRotationAnim(self.menu["hud"]["LUI_Shad"]);
        self thread SetShaderRotationAnim(self.menu["hud"]["LUI_Shad2"]);
    }
    self.menu_open = true;
}

CloseMenu(Soft)
{
    HudFadeoutTime = self.menu["ScrollDelay"];  //  Same as scroll delay
    
    self.menu_open = false;
    if(self IsHost())
    { 
        if(!self.godModeCalled)
        {
            self DisableInvulnerability();
            self IPrintLnBold("Auto Godmode ^1OFF");
        }
        else
            self IPrintLnBold("Auto Godmode ^1OFF");
    }
    
    if(!isDefined(Soft))
        self.menu["CurrentMenu"] = "none";

    self thread DoHudColors("Close");
    self thread DoFadeAnim("Close");
    wait HudFadeoutTime;
    self destroyAll(self.menu["hud"]);              //  HUDS
    if(isDefined(self.menu["ShaderRotation"]))
    {
        self thread SetShaderRotationAnim(self.menu["hud"]["LUI_Shad"], true);
        self thread SetShaderRotationAnim(self.menu["hud"]["LUI_Shad2"], true);
    }

    self notify("StopTypeWriter");
    self notify("menuClosed");

    if(isDefined(self.HealthBar))
    {
        waittillframeend;
        self thread DrawHealthBar();
    }
}

DrawHuds()
{
    // createRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
    // createText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
    // LUI_createRectangle( alignment, x, y, width, height, rgb, shader, alpha, sort, rotation)
    //  CONSTANTS
    HUD = "hud";
    SHADER = "SHADER";
    COLOR = "color";
    BACKGROUND = "Background";
    SCROLLBAR = "Scrollbar";
    TOPBAR = "TopBar";
    HEAD = "LUI_Head";
    HEAD2 = "LUI_Head2";
    //  CONSTANTS

    if(!isDefined(self.menu["ScrollbarLastPos"]["Main"]))
    {
        self.menu["ScrollbarLastPos"]["Main"] = 100;
        self.menu["Cursor"]["Main"] = 0;
    }

    //  HUDS
    self.menu["hud"]["Background"] = createRectangle("TOPRIGHT", "TOPRIGHT", self.menu["X"] - 10, self.menu["Y"] + 100, 200, 1, self.menu[COLOR]["Background"], 0, 0, "white");
    self.menu[HUD]["Scrollbar"] = createRectangle("TOPRIGHT", "TOPRIGHT", self.menu["X"] - 10, (isDefined(self.menu["Cursor"][self getCurrentMenu()]) ? self.menu["ScrollbarLastPos"][self getCurrentMenu()] : self.menu["Y"] + 100), 200, 20, (isDefined(self.hudcolor["Scrollbar"])) ? (self.hudcolor["Scrollbar"]) : (self.menu[COLOR]["Scrollbar"]), 1, 0, "white");
    self.menu[HUD]["BottomBar"] = createRectangle("TOPRIGHT", "TOPRIGHT", self.menu["X"] - 10, self.menu["Y"] + 120, 200, 20, (isDefined(self.hudcolor["BottomBar"])) ? self.hudcolor["BottomBar"] : self.menu[COLOR]["BottomBar"], 1, 0, "white");
    self.menu[HUD]["TopBar"] = createRectangle("TOPRIGHT", "TOPRIGHT", self.menu["X"] - 10, self.menu["Y"] + 80, 200, 20, (isDefined(self.hudcolor["TopBar"])) ? self.hudcolor["TopBar"] : self.menu[COLOR]["TopBar"], 1, 0, "white");
    
    //  Text
    self.menu[HUD]["MenuTitle"] = createText("bigfixed", 1.3, 9, level.menuName, "CENTER", "TOPRIGHT", self.menu["X"] - 110, self.menu["Y"] + 60, 0, (1, 1, 1));
    // self.menu[HUD]["Index"] = createText("objective", 1.3, 9, "", "RIGHT", "TOPRIGHT", self.menu["X"] - 15, self.menu["Y"] + 90, 0, (1, 1, 1));
    self.menu[HUD]["Index"] = createText("objective", 1.3, 9, "", "RIGHT", "TOPRIGHT", self.menu["X"] - 15, self.menu["Y"] + 130, 0, (1, 1, 1));
    self.menu[HUD]["Root"] = createText("objective", 1.4, 9, "", "CENTER", "TOPRIGHT", self.menu["X"] - 110, self.menu["Y"] + 90, 0, (1, 1, 1));
    // self.menu[HUD]["Root"] = createText("objective", 1.4, 9, "", "LEFT", "TOPRIGHT", self.menu["X"] - 205, self.menu["Y"] + 90, 0, (1, 1, 1));
    self.menu[HUD]["BottomText"] = createText("objective", 1.1, 9, "", "LEFT", "TOPRIGHT", self.menu["X"] - 205, self.menu["Y"] + 130, 0, (1, 1, 1));

    // LUI's
    self.menu[HUD][HEAD] = LUI_createRectangle( undefined, self.menu["X"] + self.LUIx[HEAD], self.menu["Y"] + 65, self.LUIWidth[HEAD], self.LUIHeight[HEAD], (isDefined(self.hudcolor[HEAD])) ? self.hudcolor[HEAD] : self.menu[COLOR][HEAD], self.shader[HEAD], 0, 0, 180);
    self.menu[HUD][HEAD2] = LUI_createRectangle( undefined, self.menu["X"] + self.LUIx[HEAD2], self.menu["Y"] + 65, self.LUIWidth[HEAD2], self.LUIHeight[HEAD2], (isDefined(self.hudcolor[HEAD2]) ? self.hudcolor[HEAD2] : self.menu[COLOR][HEAD2]), self.shader[HEAD2], 0, 1);
    self.menu[HUD]["LUI_Shad"] = LUI_createRectangle( undefined, self.menu["X"] + 975, self.menu["Y"] + 73, 45, 45, (isDefined(self.hudcolor["LUI_Shad"])) ? self.hudcolor["LUI_Shad"] : self.menu[COLOR]["LUI_Shad"], self.shader["LUI_Shad"], 0, 1);
    self.menu[HUD]["LUI_Shad2"] = LUI_createRectangle( undefined, self.menu["X"] + 1215, self.menu["Y"] + 73, 45, 45, (isDefined(self.hudcolor["LUI_Shad2"])) ? self.hudcolor["LUI_Shad2"] : self.menu[COLOR]["LUI_Shad2"], self.shader["LUI_Shad2"], 0, 1);
}

DrawText()
{
    //  CONSTANTS
    HUD = "hud";
    //  CONSTANTS

    if(!isDefined(self.menu[HUD]["Options"]))
        self.menu[HUD]["Options"] = [];
    
    options = self.menu["items"][self getCurrentMenu()].name;

    if(!isDefined(self.menu["ScrollbarLastPos"][self getCurrentMenu()]))
    {
        if(isDefined(options) || options.size)
        {
            OptAmount = (options.size > self.menu["MaxOpts"]) ? self.menu["MaxOpts"] : options.size;
            for(i = 0; i < OptAmount; i ++)
            {
                option = self.menu["items"][self getCurrentMenu()].name[i];
                if(isDefined(self.menu["items"][self getCurrentMenu()].name[i]))
                {
                    self.menu[HUD]["Options"][i] = createText(self.menu["OptFont"], self.menu["OptFontSize"], 9, option, "TOPLEFT", "TOPRIGHT", self.menu["X"] - 205, self.menu["Y"] + 102 + (i * 20), 0, (1, 1, 1));
                    self.menu[HUD]["Options"][i] fadeOverTime(self.menu["ScrollDelay"]);
                    self.menu[HUD]["Options"][i].alpha = 0.5;

                    self SetBools("NoScroll", i);
                    self SetSliders("NoScroll", i);
                    self SetMenuIndicator("NoScroll", i);
                    wait 0.05;  //  Frame
                }
                self.menu[HUD]["Options"][self getCursor()] fadeOverTime(self.menu["ScrollDelay"]);
                self.menu[HUD]["Options"][self getCursor()].alpha = 1;
            }
        }
    }
    else
    {
        self RebuildTextOptions();
    }
}

RebuildTextOptions()
{
    //  CONSTANTS
    HUD = "hud";
    //  CONSTANTS
    self.middle = Floor(self.menu["MaxOpts"] / 2);
    
    if(!isDefined(self.menu["items"][self getCurrentMenu()].name[self getCursor() - int(self.middle)]) || self.menu["items"][self getCurrentMenu()].name.size <= self getMaxCursor())
    {
        //  NO SCROLL NEEDED
        for(i = 0; i < self getMaxCursor(); i++)
        {
            option = self.menu["items"][self getCurrentMenu()].name[i];

            self.menu[HUD]["Options"][i] = createText(self.menu["OptFont"], self.menu["OptFontSize"], 9, option, "TOPLEFT", "TOPRIGHT", self.menu["X"] - 205, self.menu["Y"] + 102 + (i * 20), 0, (1, 1, 1));
            self.menu[HUD]["Options"][i] fadeOverTime(self.menu["ScrollDelay"]);
            self.menu[HUD]["Options"][i].alpha = 0.5;

            self.menu[HUD]["Options"][self getCursor()] fadeOverTime(self.menu["ScrollDelay"]);
            self.menu[HUD]["Options"][self getCursor()].alpha = 1;

            self SetBools("NoScroll", i);
            self SetSliders("NoScroll", i);
            self SetMenuIndicator("NoScroll", i);
            wait 0.05;  //  Frame
        }
        // self.menu[HUD]["Options"][self getCursor()] fadeOverTime(self.menu["ScrollDelay"]);
        // self.menu[HUD]["Options"][self getCursor()].alpha = 1;
    }
    else
    {
        if(isDefined(self.menu["items"][self getCurrentMenu()].name[self getCursor() + (self getMaxCursor() - int(self.middle))]))
        {
            //  IF SCROLL DOWN NEEDED
            optNum = 0;
            for( i = self getCursor() - int(self.middle); i < self getCursor() + (self getMaxCursor() - int(self.middle)); i++ )
            {
                option = self.menu["items"][self getCurrentMenu()].name[i];

                if(!isDefined(self.menu["items"][self getCurrentMenu()].name[i]))
                    self.menu[HUD]["Options"][optNum] setText("");
                else
                {
                    self.menu[HUD]["Options"][optNum] = createText(self.menu["OptFont"], self.menu["OptFontSize"], 9, option, "TOPLEFT", "TOPRIGHT", self.menu["X"] - 205, self.menu["Y"] + 102 + (optNum * 20), 0, (1, 1, 1));
                    self.menu[HUD]["Options"][optNum] fadeOverTime(self.menu["ScrollDelay"]);
                    self.menu[HUD]["Options"][optNum].alpha = 0.5;

                    self SetBools("InfntScrollDown", i, optNum);
                    self SetSliders("InfntScrollDown", i, optNum);
                    self SetMenuIndicator("InfntScrollDown", i, optNum);
                    wait 0.05;  //  Frame
                }

                if( self.menu[HUD]["Options"][int(self.middle)].alpha != 1 )
                {
                    self.menu[HUD]["Options"][int(self.middle)] fadeOverTime(self.menu["ScrollDelay"]);
                    self.menu[HUD]["Options"][int(self.middle)].alpha = 1;
                }
                optNum++;
            }
            // if( self.menu[HUD]["Options"][int(self.middle)].alpha != 1 )
            // {
            //     self.menu[HUD]["Options"][int(self.middle)] fadeOverTime(self.menu["ScrollDelay"]);
            //     self.menu[HUD]["Options"][int(self.middle)].alpha = 1;
            // }
        }
        else
        {
            //  IF SCROLL UP NEEDED
            options = self.menu["items"][self getCurrentMenu()].name;
            for( i = 0; i < self getMaxCursor(); i++ )
            {
                option = self.menu["items"][self getCurrentMenu()].name[self.menu["items"][self getCurrentMenu()].name.size + (i - self getMaxCursor())];
                optNum = (self.menu["items"][self getCurrentMenu()].name.size + (i - self getMaxCursor()));
                
                self.menu[HUD]["Options"][i] = createText(self.menu["OptFont"], self.menu["OptFontSize"], 9, option, "TOPLEFT", "TOPRIGHT", self.menu["X"] - 205, self.menu["Y"] + 102 + (i * 20), 0, (1, 1, 1));
                self.menu[HUD]["Options"][i] fadeOverTime(self.menu["ScrollDelay"]);
                self.menu[HUD]["Options"][i].alpha = 0.5;

                self.menu[HUD]["Options"][(self getCursor() - options.size) + self getMaxCursor()] fadeOverTime(self.menu["ScrollDelay"]);
                self.menu[HUD]["Options"][(self getCursor() - options.size) + self getMaxCursor()].alpha = 1;

                self SetBools("ScrollUp", optNum, i);
                self SetSliders("ScrollUp", optNum, i);
                self SetMenuIndicator("ScrollUp", optNum, i);
                wait 0.05;  //  Frame
            }
            // self.menu[HUD]["Options"][(self getCursor() - options.size) + self getMaxCursor()] fadeOverTime(self.menu["ScrollDelay"]);
            // self.menu[HUD]["Options"][(self getCursor() - options.size) + self getMaxCursor()].alpha = 1;
        }
    }
}

SetMenuIndicator(case, i, tempIndex = undefined)
{
    //  CONSTANTS
    HUD = "hud";
    //  CONSTANTS
    menufunc = self.menu["items"][self getCurrentMenu()].func[i];
    
    if(menufunc != ::newMenu)
        return;

    switch(case)
    {
        case "NoScroll":
            self.menu[HUD]["MenuIndicator"][i] = self createText(self.menu["OptFont"], self.menu["OptFontSize"], 9, "->", "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][i].x + 190, self.menu[HUD]["Options"][i].y + 8, 0, (1, 1, 1));

            self.menu[HUD]["MenuIndicator"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);
            if(self.menu[HUD]["MenuIndicator"][self getCursor()].alpha != 1)
                self.menu[HUD]["MenuIndicator"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
            break;

        case "InfntScrollDown":
            self.menu[HUD]["MenuIndicator"][tempIndex] = self createText(self.menu["OptFont"], self.menu["OptFontSize"], 9, "->", "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, 0, (1, 1, 1));

            if(tempIndex != int(self.middle))  //  Bool pos != int(self.middle) in infinite scrolling
                self.menu[HUD]["MenuIndicator"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
            else    //  Bool pos == int(self.middle)
                self.menu[HUD]["MenuIndicator"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
            break;

        case "ScrollUp":
            options = self.menu["items"][self getCurrentMenu()].name;
            cursPos = ((self getCursor() - options.size) + self getMaxCursor());    //  Current cursor pos related to max options displayed
    
            self.menu[HUD]["MenuIndicator"][tempIndex] = self createText(self.menu["OptFont"], self.menu["OptFontSize"], 9, "->", "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, 0, (1, 1, 1));
            
            if(tempIndex != cursPos)    //  Actual pos of scrollbar != cursor pos.
                self.menu[HUD]["MenuIndicator"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
            else                        //  Actual pos of scrollbar == cursor pos
                self.menu[HUD]["MenuIndicator"][tempIndex] thread hudFade(1, self.menu["ScrollDelay"]);
            break;
    }
}

SetBools(case, i, tempIndex = undefined)
{
    //  CONSTANTS
    HUD = "hud";
    ON = "[^2ON^7]";
    OFF = "[^1OFF^7]";
    COLOR = "color";
    //  CONSTANTS
    
    if(!isDefined(self.menu["items"][self getCurrentMenu()].bool[i]))
        return;

    switch(case)
    {
        //  NO SCROLL NEEDED
        case "NoScroll":
            if(self.menu["BoolStyle"] == "Checks")
            {
                color = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? self.boolColor["BoolOpt"] : (0, 0, 0);
        
                self.menu[HUD]["BoolBack"][i] = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][i].x + 185, self.menu[HUD]["Options"][i].y + 8, 10, 10, self.boolColor["BoolBack"], 2, 0, self.menu["BoolIcon"]);
                self.menu[HUD]["BoolOpt"][i]  = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][i].x + 185, self.menu[HUD]["Options"][i].y + 8, 8, 8, color, 3, 0, self.menu["BoolIcon"]);

                self.menu[HUD]["BoolBack"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);
                self.menu[HUD]["BoolOpt"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);

                if(self.menu[HUD]["BoolBack"][self getCursor()].alpha != 1 && self.menu[HUD]["BoolOpt"][self getCursor()].alpha != 1)
                {
                    self.menu[HUD]["BoolBack"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
                    self.menu[HUD]["BoolOpt"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
                }
            }
            else if(self.menu["BoolStyle"] == "Text")
            {
                string = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? ON : OFF;
                
                self.menu[HUD]["BoolText"][i] = self createText(self.menu["BoolFont"], self.menu["BoolFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][i].x + 190, self.menu[HUD]["Options"][i].y + 8, 0, (1, 1, 1));

                self.menu[HUD]["BoolText"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);

                if(self.menu[HUD]["BoolText"][self getCursor()].alpha != 1)
                {
                    self.menu[HUD]["BoolText"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
                }
            }
            break;
        
        //  IF SCROLL DOWN NEEDED
        case "InfntScrollDown":
            if(self.menu["BoolStyle"] == "Checks")
            {
                color = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? self.boolColor["BoolOpt"] : (0, 0, 0);
        
                self.menu[HUD]["BoolBack"][tempIndex] = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 185, self.menu[HUD]["Options"][tempIndex].y + 8, 10, 10, self.boolColor["BoolBack"], 2, 0, self.menu["BoolIcon"]);
                self.menu[HUD]["BoolOpt"][tempIndex]  = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 185, self.menu[HUD]["Options"][tempIndex].y + 8, 8, 8, color, 3, 0, self.menu["BoolIcon"]);

                if(tempIndex != int(self.middle))  //  Bool pos != int(self.middle) in infinite scrolling
                {
                    self.menu[HUD]["BoolBack"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                    self.menu[HUD]["BoolOpt"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                }
                else    //  Bool pos == int(self.middle)
                {
                    self.menu[HUD]["BoolBack"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
                    self.menu[HUD]["BoolOpt"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
                }
            }
            else if(self.menu["BoolStyle"] == "Text")
            {
                string = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? ON : OFF;
                
                self.menu[HUD]["BoolText"][tempIndex] = self createText(self.menu["BoolFont"], self.menu["BoolFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, 0, (1, 1, 1));

                self.menu[HUD]["BoolText"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);

                if(tempIndex != int(self.middle))  //  Bool pos != int(self.middle) in infinite scrolling
                    self.menu[HUD]["BoolText"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                else    //  Bool pos == int(self.middle)
                    self.menu[HUD]["BoolText"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
            }
            break;

        //  IF SCROLL UP NEEDED
        case "ScrollUp":
            if(self.menu["BoolStyle"] == "Checks")
            {
                color = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? self.boolColor["BoolOpt"] : (0, 0, 0);
                options = self.menu["items"][self getCurrentMenu()].name;
                cursPos = ((self getCursor() - options.size) + self getMaxCursor());    //  Current cursor pos related to max options displayed
        
                self.menu[HUD]["BoolBack"][tempIndex] = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 185, self.menu[HUD]["Options"][tempIndex].y + 8, 10, 10, self.boolColor["BoolBack"], 2, 0, self.menu["BoolIcon"]);
                self.menu[HUD]["BoolOpt"][tempIndex]  = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 185, self.menu[HUD]["Options"][tempIndex].y + 8, 8, 8, color, 3, 0, self.menu["BoolIcon"]);
                
                if(tempIndex != cursPos)    //  Actual pos of scrollbar != cursor pos.
                {
                    self.menu[HUD]["BoolBack"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                    self.menu[HUD]["BoolOpt"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                }
                else                        //  Actual pos of scrollbar == cursor pos
                {
                    self.menu[HUD]["BoolBack"][tempIndex] thread hudFade(1, self.menu["ScrollDelay"]);
                    self.menu[HUD]["BoolOpt"][tempIndex] thread hudFade(1, self.menu["ScrollDelay"]);
                }
            }
            else if(self.menu["BoolStyle"] == "Text")
            {
                string = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? ON : OFF;
                options = self.menu["items"][self getCurrentMenu()].name;
                cursPos = ((self getCursor() - options.size) + self getMaxCursor());    //  Current cursor pos related to max options displayed

                self.menu[HUD]["BoolText"][tempIndex] = self createText(self.menu["BoolFont"], self.menu["BoolFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, 0, (1, 1, 1));
                
                if(tempIndex != cursPos)    //  Actual pos of scrollbar != cursor pos.
                    self.menu[HUD]["BoolText"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                else                        //  Actual pos of scrollbar == cursor pos
                    self.menu[HUD]["BoolText"][tempIndex] thread hudFade(1, self.menu["ScrollDelay"]);
            }
            break;
    }
}

SetSliders(case, i, tempIndex = undefined)
{
    //  CONSTANTS
    HUD = "hud";
    //  CONSTANTS
    
    if(!isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]) && !isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
        return;
    
    switch(case)
    {
        //  NO SCROLL NEEDED
        case "NoScroll":
            if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]))
            {
                string = "< [" + self.menu_SValue[self getCurrentMenu()][i] +  "/" + self.menu["items"][self getCurrentMenu()].intslidermax[i] + "] >";

                self.menu[HUD]["ValSlider"][i] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][i].x + 190, self.menu[HUD]["Options"][i].y + 8, 0, (1, 1, 1));

                self.menu[HUD]["ValSlider"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);

                if(self.menu[HUD]["ValSlider"][self getCursor()].alpha != 1)
                    self.menu[HUD]["ValSlider"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
            }

            if(isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
            {
                // max = (self.menu_Strings[self getCurrentMenu()][i].size);
                string = "< " + self.menu_Strings[self getCurrentMenu()][i][self.menu_SValue[self getCurrentMenu()][i]] + " >";
                
                self.menu[HUD]["OptSlider"][i] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][i].x + 190, self.menu[HUD]["Options"][i].y + 8, 0, (1, 1, 1));

                self.menu[HUD]["OptSlider"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);

                if(self.menu[HUD]["OptSlider"][self getCursor()].alpha != 1)
                    self.menu[HUD]["OptSlider"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
            }
            break;
        
        //  IF SCROLL DOWN NEEDED
        case "InfntScrollDown":
            if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]))
            {
                string = "< [" + self.menu_SValue[self getCurrentMenu()][i] +  "/" + self.menu["items"][self getCurrentMenu()].intslidermax[i] + "] >";
                
                self.menu[HUD]["ValSlider"][tempIndex] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, 0, (1, 1, 1));

                if(tempIndex != int(self.middle))  //  Bool pos != int(self.middle) in infinite scrolling
                {
                    self.menu[HUD]["ValSlider"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                }
                else    //  Bool pos == int(self.middle)
                {
                    self.menu[HUD]["ValSlider"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
                }
            }
            
            if(isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
            {
                // max = (self.menu_Strings[self getCurrentMenu()][i].size);
                string = "< " + self.menu_Strings[self getCurrentMenu()][i][self.menu_SValue[self getCurrentMenu()][i]] + " >";
                
                self.menu[HUD]["OptSlider"][tempIndex] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, 0, (1, 1, 1));

                if(tempIndex != int(self.middle))  //  Bool pos != int(self.middle) in infinite scrolling
                {
                    self.menu[HUD]["OptSlider"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                }
                else    //  Bool pos == int(self.middle)
                {
                    self.menu[HUD]["OptSlider"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
                }
            }
            break;

        //  IF SCROLL UP NEEDED
        case "ScrollUp":
            if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]))
            {
                options = self.menu["items"][self getCurrentMenu()].name;
                cursPos = ((self getCursor() - options.size) + self getMaxCursor());    //  Current cursor pos related to max options displayed

                string = "< [" + self.menu_SValue[self getCurrentMenu()][i] +  "/" + self.menu["items"][self getCurrentMenu()].intslidermax[i] + "] >";
        
                self.menu[HUD]["ValSlider"][tempIndex] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, 0, (1, 1, 1));
                
                if(tempIndex != cursPos)    //  Actual pos of scrollbar != cursor pos.
                {
                    self.menu[HUD]["ValSlider"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                }
                else                        //  Actual pos of scrollbar == cursor pos
                {
                    self.menu[HUD]["ValSlider"][tempIndex] thread hudFade(1, self.menu["ScrollDelay"]);
                }
            }

            if(isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
            {
                options = self.menu["items"][self getCurrentMenu()].name;
                cursPos = ((self getCursor() - options.size) + self getMaxCursor());    //  Current cursor pos related to max options displayed

                // max = (self.menu_Strings[self getCurrentMenu()][i].size);
                string = "< " + self.menu_Strings[self getCurrentMenu()][i][self.menu_SValue[self getCurrentMenu()][i]] + " >";
        
                self.menu[HUD]["OptSlider"][tempIndex] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, 0, (1, 1, 1));
                
                if(tempIndex != cursPos)    //  Actual pos of scrollbar != cursor pos.
                {
                    self.menu[HUD]["OptSlider"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                }
                else                        //  Actual pos of scrollbar == cursor pos
                {
                    self.menu[HUD]["OptSlider"][tempIndex] thread hudFade(1, self.menu["ScrollDelay"]);
                }
            }
            break;
    }
}

SetMenuText()
{
    self RunMenu(); //  Refresh Bools, Opts, Sliders
    self refreshTitle(self getCurrentMenu());
    
    index = ((self getCursor() == 0) ? 1 : self getCursor());
    menuSize = self.menu["items"][self getCurrentMenu()].name.size;

    self.menu["hud"]["Index"] setText(index + " / " + menuSize);
}

refreshTitle(menu)
{
    player = (isDefined(self.selected_player) ? self.selected_player : self);
    menuPlayerName = ((player != self) ? " ^3>" + CleanName(player getName()) + "<^7" : undefined);
    string = self.menu["items"][menu].title;
    status = self getStatus(player);

    if(player != self)
    {
        self.menu["hud"]["Root"].fontscale = 1.2;
        if(!isSubStr(player.name, string))
            string += menuPlayerName;    
    }
    else
        if(self.menu["hud"]["Root"].fontscale != 1.4)
            self.menu["hud"]["Root"].fontscale = 1.4;

    self.menu["hud"]["Root"] setText(string);
    if(player != self || status != self.menu["hud"]["BottomText"].text)
    {
        if(player != self && self.menu["hud"]["BottomText"].text)
        {
            self notify("statusChanged");
            self.bottomTextSet = undefined;
        }
        self thread DoBottomText(player, status);
    }
}

ScrollingSystem(dir)
{
    cursor = self getCursor();

    if(dir == "down")
        cursor ++;
    else if(dir == "up")
        cursor --;
    
    self setCursor(self.menu["CurrentMenu"], cursor);
}

DoBottomFade()  //  Just for opening menu
{
    self.menu["hud"]["Index"] thread hudFade(1, self.menu["ScrollDelay"]);
    self.menu["hud"]["BottomText"] thread hudFade(1, self.menu["ScrollDelay"]);
}

DoBottomText(player, text)
{ 
    if(isDefined(self.bottomTextSet))
        return;
    
    self endon("statusChanged");
    self endon("menuClosed");

    
    if(player == self)
    {
        self.bottomTextSet = true;
        for(;;)
        {
            self.menu["hud"]["BottomText"] setText(text);
            self.menu["hud"]["BottomText"] hudFade(1, 1);
            wait 3;
            self.menu["hud"]["BottomText"] hudFade(0, 1);
            self.menu["hud"]["BottomText"] setText("Created by XY Constant <3");
            self.menu["hud"]["BottomText"] hudFade(1, 1);
            wait 3;
            self.menu["hud"]["BottomText"] hudFade(0, 1);
        }
    }
    else
    {
        if(self.menu["hud"]["BottomText"].text != text)
            self.menu["hud"]["BottomText"] setText(text);
    }
}
