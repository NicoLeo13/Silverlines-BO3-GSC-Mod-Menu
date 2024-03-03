ChangeHUDColor(hud, color, hudname)
{
    if(isDefined(self.RainbowActive[hudname]) || isDefined(self.LightRainbowActive[hudname]) || isDefined(self.DarkRainbowActive[hudname]))
    {
        self.LightRainbowActive[hudname] = undefined;
        self.DarkRainbowActive[hudname] = undefined;
        self.RainbowActive[hudname] = undefined;
        // self thread setCursor(self getCurrentMenu(), self getCursor());
    }

    self notifyStopHudFades(hud, hudname);
    self.RainbowType[hudname] = undefined;
    self.hudopen[hudname] = undefined;
    
    if(color == "Random")
        divided_color = dividecolor(RandomInt(255), RandomInt(255), RandomInt(255));
    else
        divided_color = dividecolor(color[0], color[1], color[2]);
    
    if(isLUI(hud))
    {
        self thread LuiColorFade(hud, divided_color, 1);
        self.hudcolor[hudname] = divided_color;        
    }
    else
    {
        hud thread fadeToColor(divided_color, 1);
        self.hudcolor[hudname] = divided_color;
    }
    self.LightRainbowActive[hudname] = undefined;
    self.DarkRainbowActive[hudname] = undefined;
    self.RainbowActive[hudname] = undefined;
}

RandomColor(divide)
{
    color = ((randomInt(255)), (randomInt(255)), (randomInt(255)));
    if(isDefined(divide))
        color = dividecolor(color[0], color[1], color[2]);
    return color;
}

DoBackgroundSize()
{
    // self.menu[HUD]["Background"] = createRectangle("TOPRIGHT", "TOPRIGHT", -10, 100, 200, 140, self.menu[COLOR]["Background"], 0, 0, "white");
    HUD = "hud";
    menuSize = self.menu["items"][self getCurrentMenu()].name.size;

    if(menuSize != self.menu["LastMenuSize"][self getCurrentMenu()] && isDefined(self.menu["LastMenuSize"][self getCurrentMenu()]))
    {
        self.menu["ScrollbarLastPos"][self getCurrentMenu()] = 100;
        self.menu["Cursor"][self getCurrentMenu()] = 0;
        self iPrintLnBold("Size ^5Changed");
    }
    
    if(menuSize > self getMaxCursor())
    {
        height = 20 * self getMaxCursor();
        bottomY = 100 + (20 * self getMaxCursor());
        bottomTextY = 110 + (20 * self getMaxCursor());
        // self iPrintLnBold("Height: " + height);
        self.menu[HUD]["Scrollbar"] thread hudMoveY(self.menu["ScrollbarLastPos"][self getCurrentMenu()], self.menu["ScrollDelay"]);
        self.menu[HUD]["Background"] thread hudScaleOverTime(self.menu["ScrollDelay"], 200, height);
        if(self.menu[HUD]["BottomBar"].y != bottomY)
        {
            self.menu[HUD]["BottomBar"] thread hudMoveY(bottomY, self.menu["ScrollDelay"]);
            self.menu[HUD]["BottomText"] thread hudMoveY(bottomTextY, self.menu["ScrollDelay"]);
            self.menu[HUD]["Index"] thread hudMoveY(bottomTextY, self.menu["ScrollDelay"]);
        }
    }
    else
    {
        height = 20 * menuSize;
        bottomY = 100 + (20 * menuSize);
        bottomTextY = 110 + (20 * menuSize);
        // self iPrintLnBold("Height: " + height);
        self.menu[HUD]["Scrollbar"] thread hudMoveY(self.menu["ScrollbarLastPos"][self getCurrentMenu()], self.menu["ScrollDelay"]);
        self.menu[HUD]["Background"] thread hudScaleOverTime(self.menu["ScrollDelay"], 200, height);
        if(self.menu[HUD]["BottomBar"].y != bottomY)
        {
            self.menu[HUD]["BottomBar"] thread hudMoveY(bottomY, self.menu["ScrollDelay"]);
            self.menu[HUD]["BottomText"] thread hudMoveY(bottomTextY, self.menu["ScrollDelay"]);
            self.menu[HUD]["Index"] thread hudMoveY(bottomTextY, self.menu["ScrollDelay"]);
        }
    }
    self.menu["LastMenuSize"][self getCurrentMenu()] = menuSize;
}

// DoBarPos()
// {
//     HUD = "hud";
//     menuSize = self.menu["items"][self getCurrentMenu()].name.size;
    
//     if(menuSize > self getMaxCursor())
//     {
//         bottomY = 100 + (20 * self getMaxCursor());
//         bottomTextY = 110 + (20 * self getMaxCursor());
//         if(self.menu[HUD]["BottomBar"].y != bottomY)
//         {
//             self.menu[HUD]["BottomBar"] thread hudMoveY(bottomY, self.menu["ScrollDelay"]);
//             self.menu[HUD]["BottomText"] thread hudMoveY(bottomTextY, self.menu["ScrollDelay"]);
//             self.menu[HUD]["Index"] thread hudMoveY(bottomTextY, self.menu["ScrollDelay"]);
//         }
//     }
//     else
//     {
//         bottomY = 100 + (20 * menuSize);
//         bottomTextY = 110 + (20 * menuSize);
//         if(self.menu[HUD]["BottomBar"].y != bottomY)
//         {
//             self.menu[HUD]["BottomBar"] thread hudMoveY(bottomY, self.menu["ScrollDelay"]);
//             self.menu[HUD]["BottomText"] thread hudMoveY(bottomTextY, self.menu["ScrollDelay"]);
//             self.menu[HUD]["Index"] thread hudMoveY(bottomTextY, self.menu["ScrollDelay"]);
//         }
//     }

// }

DoClickAnim()
{
    HUD = "hud";
    scrollCursor = self getScrollCursor();

    menu = self getCurrentMenu();
    cursor = self getCursor();
    intslider = self.menu["items"][menu].intslider[cursor];
    stringslider = self.menu["items"][menu].slider[cursor];

    if(isDefined(intslider))
    {
        prevPos = self.menu[HUD]["ValSlider"][scrollCursor].x;
        self.menu[HUD]["ValSlider"][scrollCursor] hudMoveX(prevPos - 5, self.menu["ScrollDelay"]);
        self.menu[HUD]["ValSlider"][scrollCursor] hudMoveX(prevPos, self.menu["ScrollDelay"]);
        wait 0.01;
        return;
    }

    if(isDefined(stringslider))
    {
        prevPos = self.menu[HUD]["OptSlider"][scrollCursor].x;
        self.menu[HUD]["OptSlider"][scrollCursor] hudMoveX(prevPos - 5, self.menu["ScrollDelay"]);
        self.menu[HUD]["OptSlider"][scrollCursor] hudMoveX(prevPos, self.menu["ScrollDelay"]);
        wait 0.01;
        return;
    }
    
    if(isDefined(intslider) || !isDefined(stringslider))
    {
        prevScale = self.menu[HUD]["Options"][scrollCursor].fontscale;
        self.menu[HUD]["Options"][scrollCursor] hudFontScaleOverTime(prevScale + 0.3, self.menu["ScrollDelay"]);
        self.menu[HUD]["Options"][scrollCursor] hudFontScaleOverTime(prevScale, self.menu["ScrollDelay"]);
    }
}

DoFadeAnim(case)
{
    // huds = ["Background", "Scrollbar", "TopBar", "BottomBar", "MenuTitle", "Index", "Root", "BottomText", "LUI_Head", "LUI_Head2", "LUI_Shad", "LUI_Shad2"];
    huds = ["Background", "Scrollbar", "TopBar", "BottomBar", "MenuTitle", "Root", "LUI_Head", "LUI_Head2", "LUI_Shad", "LUI_Shad2"];
    HUD = "hud";
    
    switch(case)
    {
        case "Open":
            for(i = 0; i < huds.size; i++)
            {
                if(isLUI(self.menu["hud"][huds[i]]))
                    self thread LuiFade(self.menu["hud"][huds[i]], self.hudalpha[huds[i]], self.menu["ScrollDelay"]);
                else
                    self.menu["hud"][huds[i]] thread hudFade(self.hudalpha[huds[i]], self.menu["ScrollDelay"]);
            }
            break;

        case "Close":
            for(i = 0; i < huds.size; i++)
            {
                if(isLUI(self.menu["hud"][huds[i]]))
                {
                    self thread CloseLUIMenuAfterFade(self.menu["hud"][huds[i]], 0, self.menu["ScrollDelay"]);
                }
                else
                    self.menu["hud"][huds[i]] thread hudFade(0, self.menu["ScrollDelay"]);
            }
            break;
    }
    self.bottomTextSet = undefined;
}

DoHudColors(action)
{
    HUD = "hud";
    if(action == "Open")
    {
        self thread RainbowONCheck();
    }
    else if(action == "Close")
    {
        for(i = 0; i <= level.huds.size; i++)
        {
            hud = self.menu["hud"][level.huds[i]]; 
            hudname = level.huds[i]; 
            if(isLUI(hud))  //  LUI
            {
                self notifyStopHudFades(hud, hudname);
                self.hudopen[hudname] = undefined;  //  LUI
            }
            else
            {
                self notifyStopHudFades(hud, hudname);
                self.hudopen[hudname] = undefined;
            }
        }
    }
}

DoBoolTextFade(i, string, prevAlpha)
{
    HUD = "hud";
    
    self.menu[HUD]["BoolText"][i] hudMoveX(100, (self.menu["ScrollDelay"]));
    self.menu[HUD]["BoolText"][i].alpha = 0;
    self.menu[HUD]["BoolText"][i].x = self.menu[HUD]["Options"][i].x + 190;
    self.menu[HUD]["BoolText"][i] thread SetTextString(string);
    self.menu[HUD]["BoolText"][i] thread hudFade(prevAlpha, self.menu["ScrollDelay"]);
}

SetRainbowFades(hud, RainbowType, hudname)
{
    switch(RainbowType)
    {
        case "Rainbow":
            if(!isDefined(self.hudcolor[hudname]))
                self thread RainbowEffect(hud, self.fadeDelay[hudname], hudname);
        break;

        case "LightRainbow":
            if(!isDefined(self.hudcolor[hudname]))
                self thread LightRainbowEffect(hud, self.fadeDelay[hudname], hudname);
        break;

        case "DarkRainbow":
            if(!isDefined(self.hudcolor[hudname]))
                self thread DarkRainbowEffect(hud, self.fadeDelay[hudname], hudname);
        break;

        case "Random Normal Fade":
            if(!isDefined(self.hudcolor[hudname]))
                self thread RandomFade(hud, self.fadeDelay[hudname], hudname);
        break;

        case "Random Light Fade":
            if(!isDefined(self.hudcolor[hudname]))
                self thread RandomLightFade(hud, self.fadeDelay[hudname], hudname);
        break;
        case "Random Dark Fade":
            if(!isDefined(self.hudcolor[hudname]))
                self thread RandomDarkFade(hud, self.fadeDelay[hudname], hudname);
        break;

        default:
            return self iPrintLnBold("No effect Set");
        break;
    }
}

RainbowONCheck()
{
    HUD = "hud";
    for(i = 0; i < level.huds.size; i++)
    {
        if(!isDefined(self.fadeDelay[level.huds[i]]) && !isDefined(self.fadeCheckCalled[level.huds[i]]))
        {
            self.fadeDelay[level.huds[i]] = 4;
            self.fadeCheckCalled[level.huds[i]] = true;
        }
        
        if(isDefined(self.RainbowType[level.huds[i]]) && !isDefined(self.luiopen[level.huds[i]]) && !isDefined(self.hudcolor[level.huds[i]]))
            self thread SetRainbowFades(self.menu[HUD][level.huds[i]], self.RainbowType[level.huds[i]], level.huds[i]);
    }
}

