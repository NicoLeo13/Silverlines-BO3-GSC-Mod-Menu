setCursor(menu = "none", value = 0)
{
    //  Constants
    HUD = "hud";
    SCROLLBAR = "Scrollbar";
    //  Constants
    
    options = self.menu["items"][self getCurrentMenu()].name;
    max = options.size - 1;

    if(value < 0)
        value = max;

    if(value > max)
        value = 0;
    
    self.menu["Cursor"][menu] = value;
    index = ((self getCursor() == 0) ? 1 : self getCursor() + 1);
    self.middle = Floor(self.menu["MaxOpts"] / 2);
    // self iPrintLnBold("Cursor pos: ^5" + self.menu["Cursor"][menu]);

    if(!isDefined(self.menu["items"][self getCurrentMenu()].name[self getCursor() - int(self.middle)]) || self.menu["items"][self getCurrentMenu()].name.size <= self getMaxCursor())
    {
        //  NO SCROLL NEEDED
        self.menu[HUD]["Index"] setText(index + " / " + options.size);
        self DeleteBoolsnSlides();
        for(i = 0; i < self getMaxCursor(); i++)
        {
            if(isDefined(self.menu["items"][self getCurrentMenu()].name[i]))    //  Test
                self.menu[HUD]["Options"][i] setText(self.menu["items"][self getCurrentMenu()].name[i]);
            else
                self.menu[HUD]["Options"][i] setText("");

            
            self SetScrollBools("NoScroll", i);
            self SetScrollSliders("NoScroll", i);
            self SetScrollMenuIndicator("NoScroll", i);
        }

        if(self.menu[HUD][SCROLLBAR].y != 100 + (20 * self getCursor()))
        {
            self.menu[HUD][SCROLLBAR] moveOverTime(self.menu["ScrollDelay"]);
            self.menu[HUD][SCROLLBAR].y = 100 + (20 * self getCursor());
        }
 
       for( a = 0; a < self getMaxCursor(); a ++ )
        {
            if( a != self getCursor() )
            {
                self.menu[HUD]["Options"][a] fadeOverTime(self.menu["ScrollDelay"]);
                self.menu[HUD]["Options"][a].alpha = 0.5;
            }
            self.menu[HUD]["Options"][self getCursor()] fadeOverTime(self.menu["ScrollDelay"]);
            self.menu[HUD]["Options"][self getCursor()].alpha = 1;

            self CheckBoolsnSlidesFade("NoScroll", a);
            self CheckMenuIndFade("NoScroll", a);
        }
        // self.menu[HUD]["Options"][self getCursor()] fadeOverTime(self.menu["ScrollDelay"]);
        // self.menu[HUD]["Options"][self getCursor()].alpha = 1;
    }
    else
    {
        if(isDefined(self.menu["items"][self getCurrentMenu()].name[self getCursor() + (self getMaxCursor() - int(self.middle))]))
        {
            //  IF SCROLL DOWN NEEDED
            self.menu[HUD]["Index"] setText(index + " / " + options.size);
            // self iPrintLnBold("^2inf scroll");
            self DeleteBoolsnSlides();
            optNum = 0;
            for( i = self getCursor() - int(self.middle); i < self getCursor() + (self getMaxCursor() - int(self.middle)); i++ )
            {
                if(!isDefined(self.menu["items"][self getCurrentMenu()].name[i]))
                    self.menu[HUD]["Options"][optNum] setText("");
                else
                    self.menu[HUD]["Options"][optNum] setText(self.menu["items"][self getCurrentMenu()].name[i]);

                self SetScrollBools("InfntScrollDown", i, optNum);
                self SetScrollSliders("InfntScrollDown", i, optNum);
                self SetScrollMenuIndicator("InfntScrollDown", i, optNum);
                self CheckBoolsnSlidesFade("InfntScrollDown", i, optNum);
                self CheckMenuIndFade("InfntScrollDown", i, optNum);
                optNum++;
            }
            if(self.menu[HUD][SCROLLBAR].y != 100 + (20 * int(self.middle)))
            {
                self.menu[HUD][SCROLLBAR] moveOverTime(self.menu["ScrollDelay"]);
                self.menu[HUD][SCROLLBAR].y = 100 + (20 * int(self.middle));
            }

            for( a = 0; a < self getMaxCursor(); a ++ )
            {
                if( self.menu[HUD]["Options"][int(self.middle)].alpha != 1 || a == int(self.middle))
                {
                    self.menu[HUD]["Options"][int(self.middle)] fadeOverTime(self.menu["ScrollDelay"]);
                    self.menu[HUD]["Options"][int(self.middle)].alpha = 1;
                }
                else
                {
                    self.menu[HUD]["Options"][a] fadeOverTime(self.menu["ScrollDelay"]);
                    self.menu[HUD]["Options"][a].alpha = 0.5;
                }
            }
            self.menu[HUD]["Options"][int(self.middle)] fadeOverTime(self.menu["ScrollDelay"]);
            self.menu[HUD]["Options"][int(self.middle)].alpha = 1;
        }
        else
        {
            //  IF SCROLL UP NEEDED
            self.menu[HUD]["Index"] setText(index + " / " + options.size);
            // self iPrintLnBold("^5else");
            self DeleteBoolsnSlides();

            for( i = 0; i < self getMaxCursor(); i++ )
            {
                optNum = options.size + (i - self getMaxCursor());
                
                self.menu[HUD]["Options"][i] setText(self.menu["items"][self getCurrentMenu()].name[self.menu["items"][self getCurrentMenu()].name.size + (i - self getMaxCursor())]);
                self SetScrollBools("ScrollUp", optNum, i);
                self SetScrollSliders("ScrollUp", optNum, i);
                self SetScrollMenuIndicator("ScrollUp", optNum, i);
            }

            if(self.menu[HUD][SCROLLBAR].y != 100 + (20 * ((self getCursor() - options.size) + self getMaxCursor())))
            {
                self.menu[HUD][SCROLLBAR] moveOverTime(self.menu["ScrollDelay"]);
                self.menu[HUD][SCROLLBAR].y = 100 + (20 * ((self getCursor() - options.size) + self getMaxCursor()));
            }
            
            for( a = 0; a < self getMaxCursor(); a ++ )
            {
                optNum = options.size + (a - self getMaxCursor());
                
                if( a != ((self getCursor() - options.size) + self getMaxCursor()) )
                {
                    self.menu[HUD]["Options"][a] fadeOverTime(self.menu["ScrollDelay"]);
                    self.menu[HUD]["Options"][a].alpha = 0.5;
                }
                self.menu[HUD]["Options"][(self getCursor() - options.size) + self getMaxCursor()] fadeOverTime(self.menu["ScrollDelay"]);
                self.menu[HUD]["Options"][(self getCursor() - options.size) + self getMaxCursor()].alpha = 1;
                self CheckBoolsnSlidesFade("ScrollUp", optNum, a);
                self CheckMenuIndFade("ScrollUp", optNum, a);
            }
            // self.menu[HUD]["Options"][(self getCursor() - options.size) + self getMaxCursor()] fadeOverTime(self.menu["ScrollDelay"]);
            // self.menu[HUD]["Options"][(self getCursor() - options.size) + self getMaxCursor()].alpha = 1;
        }
    }
    self.menu["ScrollbarLastPos"][self getCurrentMenu()] = self.menu[HUD][SCROLLBAR].y;
}

SetScrollMenuIndicator(case, i, tempIndex = undefined)
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
            if(!isDefined(self.menuIndicatorAlpha[self getCurrentMenu()]))
                self.menuIndicatorAlpha[self getCurrentMenu()] = [];
            previousAlpha = (isDefined(self.menuIndicatorAlpha[self getCurrentMenu()][i])) ? self.menuIndicatorAlpha[self getCurrentMenu()][i] : 0.5;  //  So it can be handled by 

            self.menu[HUD]["MenuIndicator"][i] = self createText(self.menu["OptFont"], self.menu["OptFontSize"], 9, "->", "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][i].x + 190, self.menu[HUD]["Options"][i].y + 8, previousAlpha, (1, 1, 1));
            break;

        case "InfntScrollDown":
            previousAlpha = (isDefined(self.menuIndicatorAlpha[self getCurrentMenu()][tempIndex])) ? self.menuIndicatorAlpha[self getCurrentMenu()][tempIndex] : 0.5;  //  So it can be handled by 
            
            self.menu[HUD]["MenuIndicator"][tempIndex] = self createText(self.menu["OptFont"], self.menu["OptFontSize"], 9, "->", "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, previousAlpha, (1, 1, 1));
            break;

        case "ScrollUp":
            options = self.menu["items"][self getCurrentMenu()].name;
            cursPos = ((self getCursor() - options.size) + self getMaxCursor());    //  Current cursor pos related to max options displayed
            previousAlpha = (isDefined(self.menuIndicatorAlpha[self getCurrentMenu()][tempIndex])) ? self.menuIndicatorAlpha[self getCurrentMenu()][tempIndex] : 0.5;  //  So it can be handled by 

            self.menu[HUD]["MenuIndicator"][tempIndex] = self createText(self.menu["OptFont"], self.menu["OptFontSize"], 9, "->", "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, previousAlpha, (1, 1, 1));
            break;
    }
}

CheckMenuIndFade(case, i, tempIndex = undefined)
{
    menufunc = self.menu["items"][self getCurrentMenu()].func[i];
    if(menufunc != ::newMenu)
        return;
    
    //  CONSTANTS
    HUD = "hud";
    //  CONSTANTS
    switch(case)
    {
        //  NO SCROLL NEEDED
        case "NoScroll":
                self.menu[HUD]["MenuIndicator"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);

                if(self.menu[HUD]["MenuIndicator"][self getCursor()].alpha != 1)   //  Scrollbar opt alpha != 1
                {
                    self.menu[HUD]["MenuIndicator"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
                }
                self.menuIndicatorAlpha[self getCurrentMenu()][i] = self.menu[HUD]["MenuIndicator"][i].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
            break;

        //  SCROLL DOWN NEEDED
        case "InfntScrollDown":
                if(tempIndex != int(self.middle))  //  Bool pos int(!= self.middle) in infinite scrolling
                    self.menu[HUD]["MenuIndicator"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                else    //  Bool pos int(== self.middle)
                    self.menu[HUD]["MenuIndicator"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
                
                self.menuIndicatorAlpha[self getCurrentMenu()][tempIndex] = self.menu[HUD]["MenuIndicator"][tempIndex].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
            break;

        //  SCROLL UP NEEDED
        case "ScrollUp":
            options = self.menu["items"][self getCurrentMenu()].name;
            cursPos = ((self getCursor() - options.size) + self getMaxCursor());    //  Current cursor pos related to max options displayed

            if(tempIndex != cursPos)    //  Actual pos of scrollbar != cursor pos.
                self.menu[HUD]["MenuIndicator"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
            else                        //  Actual pos of scrollbar == cursor pos
                self.menu[HUD]["MenuIndicator"][tempIndex] thread hudFade(1, self.menu["ScrollDelay"]);
            self.menuIndicatorAlpha[self getCurrentMenu()][tempIndex] = self.menu[HUD]["MenuIndicator"][tempIndex].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
            break;

        default:
            return;
    }
}

SetScrollBools(case, i, tempIndex = undefined)
{
    if(!isDefined(self.menu["items"][self getCurrentMenu()].bool[i]))
        return;
    
    //  CONSTANTS
    HUD = "hud";
    ON = "[^2ON^7]";
    OFF = "[^1OFF^7]";
    //  CONSTANTS

    switch(case)
    {
        //  NO SCROLL NEEDED
        case "NoScroll":
            if(!isDefined(self.boolPreviousAlpha[self getCurrentMenu()]))
                self.boolPreviousAlpha[self getCurrentMenu()] = [];

            previousAlpha = (isDefined(self.boolPreviousAlpha[self getCurrentMenu()][i])) ? self.boolPreviousAlpha[self getCurrentMenu()][i] : 0.5;  //  So it can be handled by CheckBoolsnSlidesFade.
            if(isDefined(self.menu["items"][self getCurrentMenu()].bool[i]))
            {
                if(self.menu["BoolStyle"] == "Checks")
                {
                    color = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? self.boolColor["BoolOpt"] : (0, 0, 0);
                    
                    self.menu[HUD]["BoolBack"][i] = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][i].x + 185, self.menu[HUD]["Options"][i].y + 8, 10, 10, self.boolColor["BoolBack"], 2, previousAlpha, self.menu["BoolIcon"]);
                    self.menu[HUD]["BoolOpt"][i]  = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][i].x + 185, self.menu[HUD]["Options"][i].y + 8, 8, 8, color, 3, previousAlpha, self.menu["BoolIcon"]);
                }
                else if(self.menu["BoolStyle"] == "Text")
                {
                    string = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? ON : OFF;

                    self.menu[HUD]["BoolText"][i] = self createText(self.menu["BoolFont"], self.menu["BoolFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][i].x + 190, self.menu[HUD]["Options"][i].y + 8, previousAlpha, (1, 1, 1));
                }
            }
            break;

        //  SCROLL DOWN NEEDED
        case "InfntScrollDown":
            previousAlpha = (isDefined(self.boolPreviousAlpha[self getCurrentMenu()][tempIndex])) ? self.boolPreviousAlpha[self getCurrentMenu()][tempIndex] : 0.5;  //  So it can be handled by CheckBoolsnSlidesFade.
            if(isDefined(self.menu["items"][self getCurrentMenu()].bool[i]))
            {
                if(self.menu["BoolStyle"] == "Checks")
                {
                    color = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? self.boolColor["BoolOpt"] : (0, 0, 0);
                    
                    self.menu[HUD]["BoolBack"][tempIndex] = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 185, self.menu[HUD]["Options"][tempIndex].y + 8, 10, 10, self.boolColor["BoolBack"], 2, previousAlpha, self.menu["BoolIcon"]);
                    self.menu[HUD]["BoolOpt"][tempIndex]  = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 185, self.menu[HUD]["Options"][tempIndex].y + 8, 8, 8, color, 3, previousAlpha, self.menu["BoolIcon"]);
                }
                else if(self.menu["BoolStyle"] == "Text")
                {
                    string = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? ON : OFF;

                    self.menu[HUD]["BoolText"][tempIndex] = self createText(self.menu["BoolFont"], self.menu["BoolFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, previousAlpha, (1, 1, 1));
                }
            }
            break;

        //  SCROLL UP NEEDED
        case "ScrollUp":
            previousAlpha = (isDefined(self.boolPreviousAlpha[self getCurrentMenu()][tempIndex])) ? self.boolPreviousAlpha[self getCurrentMenu()][tempIndex] : 0.5;  //  So it can be handled by CheckBoolsnSlidesFade.
            if(isDefined(self.menu["items"][self getCurrentMenu()].bool[i]))
            {
                if(self.menu["BoolStyle"] == "Checks")
                {
                    color = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? self.boolColor["BoolOpt"] : (0, 0, 0);

                    self.menu[HUD]["BoolBack"][tempIndex] = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 185, self.menu[HUD]["Options"][tempIndex].y + 8, 10, 10, self.boolColor["BoolBack"], 2, previousAlpha, self.menu["BoolIcon"]);
                    self.menu[HUD]["BoolOpt"][tempIndex]  = self createRectangle("CENTER", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 185, self.menu[HUD]["Options"][tempIndex].y + 8, 8, 8, color, 3, previousAlpha, self.menu["BoolIcon"]);
                }
                else if(self.menu["BoolStyle"] == "Text")
                {
                    string = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? ON : OFF;

                    self.menu[HUD]["BoolText"][tempIndex] = self createText(self.menu["BoolFont"], self.menu["BoolFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu[HUD]["Options"][tempIndex].x + 190, self.menu[HUD]["Options"][tempIndex].y + 8, previousAlpha, (1, 1, 1));
                }
            }
            break;

        default:
            return;
    }
}

SetScrollSliders(case, i, tempIndex = undefined)
{
    if(!isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]) && !isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
        return;
    
    switch(case)
    {
        //  NO SCROLL NEEDED
        case "NoScroll":
            if(!isDefined(self.sliderPreviousAlpha[self getCurrentMenu()]))
                self.sliderPreviousAlpha[self getCurrentMenu()] = [];

            previousAlpha = (isDefined(self.sliderPreviousAlpha[self getCurrentMenu()][i])) ? self.sliderPreviousAlpha[self getCurrentMenu()][i] : 0.5;  //  So it can be handled by CheckBoolsnSlidesFade.
            
            if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]))
            {
                intString = "< [" + self.menu_SValue[self getCurrentMenu()][i] +  "/" + self.menu["items"][self getCurrentMenu()].intslidermax[i] + "] >";

                self.menu["hud"]["ValSlider"][i] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, intString, "RIGHT", "TOPRIGHT", self.menu["hud"]["Options"][i].x + 190, self.menu["hud"]["Options"][i].y + 8, previousAlpha, (1, 1, 1));
            }

            if(isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
            {
                // max = (self.menu_Strings[self getCurrentMenu()][self getCursor()].size - 1);
                string = "< " + self.menu_Strings[self getCurrentMenu()][i][self.menu_SValue[self getCurrentMenu()][i]] + " >";

                self.menu["hud"]["OptSlider"][i] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu["hud"]["Options"][i].x + 190, self.menu["hud"]["Options"][i].y + 8, previousAlpha, (1, 1, 1));
            }            
            break;

        //  SCROLL DOWN NEEDED
        case "InfntScrollDown":
            previousAlpha = (isDefined(self.sliderPreviousAlpha[self getCurrentMenu()][tempIndex])) ? self.sliderPreviousAlpha[self getCurrentMenu()][tempIndex] : 0.5;  //  So it can be handled by CheckBoolsnSlidesFade.

            if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]))
            {
                intString = "< [" + self.menu_SValue[self getCurrentMenu()][i] +  "/" + self.menu["items"][self getCurrentMenu()].intslidermax[i] + "] >";
                
                self.menu["hud"]["ValSlider"][tempIndex] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, intString, "RIGHT", "TOPRIGHT", self.menu["hud"]["Options"][tempIndex].x + 190, self.menu["hud"]["Options"][tempIndex].y + 8, previousAlpha, (1, 1, 1));
            }

            if(isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
            {
                string = "< " + self.menu_Strings[self getCurrentMenu()][i][self.menu_SValue[self getCurrentMenu()][i]] + " >";
                
                self.menu["hud"]["OptSlider"][tempIndex] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu["hud"]["Options"][tempIndex].x + 190, self.menu["hud"]["Options"][tempIndex].y + 8, previousAlpha, (1, 1, 1));
            }            
            break;

        //  SCROLL UP NEEDED
        case "ScrollUp":
            previousAlpha = (isDefined(self.sliderPreviousAlpha[self getCurrentMenu()][tempIndex])) ? self.sliderPreviousAlpha[self getCurrentMenu()][tempIndex] : 0.5;  //  So it can be handled by CheckBoolsnSlidesFade.

            if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]))
            {
                intString = "< [" + self.menu_SValue[self getCurrentMenu()][i] +  "/" + self.menu["items"][self getCurrentMenu()].intslidermax[i] + "] >";

                self.menu["hud"]["ValSlider"][tempIndex] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, intString, "RIGHT", "TOPRIGHT", self.menu["hud"]["Options"][tempIndex].x + 190, self.menu["hud"]["Options"][tempIndex].y + 8, previousAlpha, (1, 1, 1));
            }

            if(isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
            {
                string = "< " + self.menu_Strings[self getCurrentMenu()][i][self.menu_SValue[self getCurrentMenu()][i]] + " >";

                self.menu["hud"]["OptSlider"][tempIndex] = self createText(self.menu["SlidFont"], self.menu["SlidFontSize"], 9, string, "RIGHT", "TOPRIGHT", self.menu["hud"]["Options"][tempIndex].x + 190, self.menu["hud"]["Options"][tempIndex].y + 8, previousAlpha, (1, 1, 1));
            }
            break;

        default:
            return;
    }
}

CheckBoolsnSlidesFade(case, i, tempIndex = undefined)
{
    if(!isDefined(self.menu["items"][self getCurrentMenu()].bool[i]) && !isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]) && !isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
        return;
    
    //  CONSTANTS
    HUD = "hud";
    ON = "[^2ON^7]";
    OFF = "[^1OFF^7]";
    //  CONSTANTS
    
    switch(case)
    {
        //  NO SCROLL NEEDED
        case "NoScroll":
            //  BOOLS
            if(isDefined(self.menu["items"][self getCurrentMenu()].bool[i]))
            {
                if(self.menu["BoolStyle"] == "Checks")
                {
                    self.menu[HUD]["BoolBack"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);
                    self.menu[HUD]["BoolOpt"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);

                    if(self.menu[HUD]["BoolBack"][self getCursor()].alpha != 1 && self.menu[HUD]["BoolOpt"][self getCursor()].alpha != 1)   //  Scrollbar opt alpha != 1
                    {
                        self.menu[HUD]["BoolBack"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
                        self.menu[HUD]["BoolOpt"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
                    }
                    self.boolPreviousAlpha[self getCurrentMenu()][i] = self.menu[HUD]["BoolBack"][i].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
                }
                else if(self.menu["BoolStyle"] == "Text")
                {
                    self.menu[HUD]["BoolText"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);

                    if(self.menu[HUD]["BoolText"][self getCursor()].alpha != 1)   //  Scrollbar opt alpha != 1
                        self.menu[HUD]["BoolText"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
                    self.boolPreviousAlpha[self getCurrentMenu()][i] = self.menu[HUD]["BoolText"][i].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
                }
            }

            //  INT SLIDERS
            if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]))
            {
                self.menu[HUD]["ValSlider"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);

                if(self.menu[HUD]["ValSlider"][self getCursor()].alpha != 1)   //  Scrollbar opt alpha != 1
                {
                    self.menu[HUD]["ValSlider"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
                }
                self.sliderPreviousAlpha[self getCurrentMenu()][i] = self.menu[HUD]["ValSlider"][i].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
            }

            //  STRING SLIDERS
            if(isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
            {
                self.menu[HUD]["OptSlider"][i] thread hudFade(0.5, self.menu["ScrollDelay"]);

                if(self.menu[HUD]["OptSlider"][self getCursor()].alpha != 1)   //  Scrollbar opt alpha != 1
                {
                    self.menu[HUD]["OptSlider"][self getCursor()] thread hudFade(1, self.menu["ScrollDelay"]);
                }
                self.sliderPreviousAlpha[self getCurrentMenu()][i] = self.menu[HUD]["OptSlider"][i].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
            }
            break;

        //  SCROLL DOWN NEEDED
        case "InfntScrollDown":
            //  BOOLS
            if(isDefined(self.menu["items"][self getCurrentMenu()].bool[i]))
            {
                if(self.menu["BoolStyle"] == "Checks")
                {
                    if(tempIndex != int(self.middle))  //  Bool pos int(!= self.middle) in infinite scrolling
                    {
                        self.menu[HUD]["BoolBack"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                        self.menu[HUD]["BoolOpt"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                    }
                    else    //  Bool pos int(== self.middle)
                    {
                        self.menu[HUD]["BoolBack"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
                        self.menu[HUD]["BoolOpt"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
                    }
                    self.boolPreviousAlpha[self getCurrentMenu()][tempIndex] = self.menu[HUD]["BoolBack"][tempIndex].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
                }
                else if(self.menu["BoolStyle"] == "Text")
                {
                    if(tempIndex != int(self.middle))  //  Bool pos int(!= self.middle) in infinite scrolling
                        self.menu[HUD]["BoolText"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                    else    //  Bool pos int(== self.middle)
                        self.menu[HUD]["BoolText"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
                    self.boolPreviousAlpha[self getCurrentMenu()][tempIndex] = self.menu[HUD]["BoolText"][tempIndex].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
                }
            }

            //  INT SLIDERS
            if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]))
            {
                if(tempIndex != int(self.middle))  //  Bool pos int(!= self.middle) in infinite scrolling
                    self.menu[HUD]["ValSlider"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                else    //  Bool pos int(== self.middle)
                    self.menu[HUD]["ValSlider"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
                
                self.sliderPreviousAlpha[self getCurrentMenu()][tempIndex] = self.menu[HUD]["ValSlider"][tempIndex].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
            }

            //  STRING SLIDERS
            if(isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
            {
                if(tempIndex != int(self.middle))  //  Bool pos int(!= self.middle) in infinite scrolling
                    self.menu[HUD]["OptSlider"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                else    //  Bool pos int(== self.middle)
                    self.menu[HUD]["OptSlider"][int(self.middle)] thread hudFade(1, self.menu["ScrollDelay"]);
                
                self.sliderPreviousAlpha[self getCurrentMenu()][tempIndex] = self.menu[HUD]["OptSlider"][tempIndex].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
            }             
            break;

        //  SCROLL UP NEEDED
        case "ScrollUp":
            //  BOOLS
            options = self.menu["items"][self getCurrentMenu()].name;
            cursPos = ((self getCursor() - options.size) + self getMaxCursor());    //  Current cursor pos related to max options displayed
            if(isDefined(self.menu["items"][self getCurrentMenu()].bool[i]))
            {
                if(self.menu["BoolStyle"] == "Checks")
                {
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
                    self.boolPreviousAlpha[self getCurrentMenu()][tempIndex] = self.menu[HUD]["BoolBack"][tempIndex].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
                }
                else if(self.menu["BoolStyle"] == "Text")
                {
                    if(tempIndex != cursPos)    //  Actual pos of scrollbar != cursor pos.
                        self.menu[HUD]["BoolText"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                    else                        //  Actual pos of scrollbar == cursor pos
                        self.menu[HUD]["BoolText"][tempIndex] thread hudFade(1, self.menu["ScrollDelay"]);
                    self.boolPreviousAlpha[self getCurrentMenu()][tempIndex] = self.menu[HUD]["BoolText"][tempIndex].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
                }
            }

            //  INT SLIDERS
            if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]))
            {
                if(tempIndex != cursPos)    //  Actual pos of scrollbar != cursor pos.
                    self.menu[HUD]["ValSlider"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                else                        //  Actual pos of scrollbar == cursor pos
                    self.menu[HUD]["ValSlider"][tempIndex] thread hudFade(1, self.menu["ScrollDelay"]);
                self.sliderPreviousAlpha[self getCurrentMenu()][tempIndex] = self.menu[HUD]["ValSlider"][tempIndex].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
            }

            //  STRING SLIDERS
            if(isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
            {
                if(tempIndex != cursPos)    //  Actual pos of scrollbar != cursor pos.
                    self.menu[HUD]["OptSlider"][tempIndex] thread hudFade(0.5, self.menu["ScrollDelay"]);
                else                        //  Actual pos of scrollbar == cursor pos
                    self.menu[HUD]["OptSlider"][tempIndex] thread hudFade(1, self.menu["ScrollDelay"]);
                self.sliderPreviousAlpha[self getCurrentMenu()][tempIndex] = self.menu[HUD]["OptSlider"][tempIndex].alpha;  //  So it can be handled by CheckBoolsnSlidesFade.
            }             
            break;

        default:
            return;
    }
}

DeleteBoolsnSlides()
{
    huds = ["BoolBack", "BoolOpt", "BoolText", "ValSlider", "OptSlider", "MenuIndicator"];
    for(a = 0; a < huds.size; a++)
    {
        self destroyAll(self.menu["hud"][huds[a]]);
        self.menu["hud"][huds[a]] = [];
    }
}

RefreshMenu()
{
    self RunMenu();
    //  CONSTANTS
    HUD = "hud";
    ON = "[^2ON^7]";
    OFF = "[^1OFF^7]";
    //  CONSTANTS

    // if(!isDefined(self.menu["items"][self getCurrentMenu()].bool[self getCursor()]) && !isDefined(self.menu["items"][self getCurrentMenu()].intslider[self getCursor()]) && !isDefined(self.menu["items"][self getCurrentMenu()].slider[self getCursor()]))
    //     return;
    if(!isDefined(self.menu["items"][self getCurrentMenu()].name[self getCursor() - int(self.middle)]) || self.menu["items"][self getCurrentMenu()].name.size <= self getMaxCursor())
    {
        for( i = 0; i < self getMaxCursor(); i++ )
        {
            if(isDefined(self.menu["items"][self getCurrentMenu()].bool[i]))
            {
                if(self.menu["BoolStyle"] == "Checks")
                {
                    color = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? self.boolColor["BoolOpt"] : (0, 0, 0);
                    self.menu[HUD]["BoolOpt"][i] thread fadeToColor(color, self.menu["ScrollDelay"]);
                }
                else if(self.menu["BoolStyle"] == "Text")
                {
                    string = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? ON : OFF;
                    if(self.menu[HUD]["BoolText"][i].text != string)
                    {
                        prevAlpha = self.menu[HUD]["BoolText"][i].alpha;
                        self thread DoBoolTextFade(i, string, prevAlpha);
                    }
                }
            }
        }   
    }
    else
    {
        if(isDefined(self.menu["items"][self getCurrentMenu()].name[self getCursor() + (self getMaxCursor() - int(self.middle))]))
        {
            optNum = 0;
            for( i = self getCursor() - int(self.middle); i < self getCursor() + (self getMaxCursor() - int(self.middle)); i++ )
            {
                if(isDefined(self.menu["items"][self getCurrentMenu()].bool[i]))
                {
                    if(self.menu["BoolStyle"] == "Checks")
                    {
                        color = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? self.boolColor["BoolOpt"] : (0, 0, 0);
                        self.menu[HUD]["BoolOpt"][optNum] thread fadeToColor(color, self.menu["ScrollDelay"]);
                    }
                    else if(self.menu["BoolStyle"] == "Text")
                    {
                        string = (isDefined(self.menu_Bool[self getCurrentMenu()][i]) && (self.menu_Bool[self getCurrentMenu()][i])) ? ON : OFF;
                        if(self.menu[HUD]["BoolText"][optNum].text != string)
                        {
                            prevAlpha = self.menu[HUD]["BoolText"][optNum].alpha;
                            self thread DoBoolTextFade(optNum, string, prevAlpha);
                        }
                    }
                }

                if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[i]))
                {
                    string = "< [" + self.menu_SValue[self getCurrentMenu()][i] +  "/" + self.menu["items"][self getCurrentMenu()].intslidermax[i] + "] >";
                    self.menu[HUD]["ValSlider"][optNum] setText(string);
                }

                if(isDefined(self.menu["items"][self getCurrentMenu()].slider[i]))
                {
                    string = "< " + self.menu_Strings[self getCurrentMenu()][i][self.menu_SValue[self getCurrentMenu()][i]] + " >";
                    self.menu[HUD]["OptSlider"][optNum] setText(string);
                }
                optNum ++;
            }
        }
        else
        {
            options = self.menu["items"][self getCurrentMenu()].name;
            for( i = 0; i < self getMaxCursor(); i++ )
            {
                optNum = options.size + (i - self getMaxCursor());
                if(isDefined(self.menu["items"][self getCurrentMenu()].bool[optNum]))
                {
                    if(self.menu["BoolStyle"] == "Checks")
                    {
                        color = (isDefined(self.menu_Bool[self getCurrentMenu()][optNum]) && (self.menu_Bool[self getCurrentMenu()][optNum])) ? self.boolColor["BoolOpt"] : (0, 0, 0);
                        self.menu[HUD]["BoolOpt"][i] thread fadeToColor(color, self.menu["ScrollDelay"]);
                    }
                    else if(self.menu["BoolStyle"] == "Text")
                    {
                        string = (isDefined(self.menu_Bool[self getCurrentMenu()][optNum]) && (self.menu_Bool[self getCurrentMenu()][optNum])) ? ON : OFF;
                        if(self.menu[HUD]["BoolText"][i].text != string)
                        {
                            prevAlpha = self.menu[HUD]["BoolText"][i].alpha;
                            self thread DoBoolTextFade(i, string, prevAlpha);
                        }
                    }
                }

                if(isDefined(self.menu["items"][self getCurrentMenu()].intslider[optNum]))
                {
                    string = "< [" + self.menu_SValue[self getCurrentMenu()][optNum] +  "/" + self.menu["items"][self getCurrentMenu()].intslidermax[optNum] + "] >";
                    self.menu[HUD]["ValSlider"][i] setText(string);
                }

                if(isDefined(self.menu["items"][self getCurrentMenu()].slider[optNum]))
                {
                    string = "< " + self.menu_Strings[self getCurrentMenu()][optNum][self.menu_SValue[self getCurrentMenu()][optNum]] + " >";
                    self.menu[HUD]["OptSlider"][i] setText(string);
                }
            }
        }
    }
}
