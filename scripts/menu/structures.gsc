MenuArrays(menu)
{
    if(!isDefined(self.menu["items"]))
        self.menu["items"] = [];
    
    if(!isDefined(self.menu["items"][menu]))
        self.menu["items"][menu] = SpawnStruct();
    
    if(!isDefined(self.prevmenu))
        self.prevmenu = [];
    
    if(!isDefined(self.menu["Cursor"]))
        self.menu["Cursor"][menu] = 0;
    
    self.menu["items"][menu].name = [];
    self.menu["items"][menu].name2 = [];
    self.menu["items"][menu].func = [];
    self.menu["items"][menu].arg1 = [];
    self.menu["items"][menu].arg2 = [];
    self.menu["items"][menu].arg3 = [];
    self.menu["items"][menu].arg4 = [];
    self.menu["items"][menu].arg5 = [];
    self.menu["items"][menu].bool = [];
    self.menu["items"][menu].slider = [];
    self.menu["items"][menu].intslider = [];
    self.menu["items"][menu].intslidermin = [];
    self.menu["items"][menu].intsliderstart = [];
    self.menu["items"][menu].intslidermax = [];
    
    if(!isDefined(self.menu_Bool))
        self.menu_Bool = [];
    
    if(!isDefined(self.menu_Bool[menu]))
        self.menu_Bool[menu] = [];
    
    if(!isDefined(self.menu_Strings))
        self.menu_Strings = [];
    
    if(!isDefined(self.menu_Strings[menu]))
        self.menu_Strings[menu] = [];
    
    if(!isDefined(self.menu_SValue))
        self.menu_SValue = [];
    
    if(!isDefined(self.menu_SValue[menu]))
        self.menu_SValue[menu] = [];
}

newMenu(menu)
{
    // if( access >= self.access )
    //     return self IPrintLn( "Access level denined." );
    if(self getCurrentMenu() == "Players Menu" && isDefined(menu))
    {
        player = level.players[self getCursor()];
        if(player IsHost() && !self IsHost())
            return self iPrintlnBold("^1Error: ^7Can't Touch Host :)");
    }
    
    if(!isDefined(menu))
    {
        menu = self.prevmenu[ self.prevmenu.size - 1 ];
        self.prevmenu[ self.prevmenu.size - 1 ] = undefined;
    }
    else
    {
        self.prevmenu[ self.prevmenu.size ] = self getCurrentMenu();
        self MenuArrays(self.prevmenu[ self.prevmenu.size - 1 ]);
    }
        
    self.menu["CurrentMenu"] = menu;

    huds = ["Options", "BoolBack", "BoolOpt", "BoolText", "ValSlider", "OptSlider", "MenuIndicator"];
    for(a = 0; a < huds.size; a++)
    {
        self destroyAll(self.menu["hud"][huds[a]]);
        self.menu["hud"][huds[a]] = [];
    }

    if(!isDefined(self.menu["ScrollbarLastPos"][self getCurrentMenu()]))
    {
        self.menu["hud"]["Scrollbar"] hudMoveY(100, self.menu["ScrollDelay"]);
        self.menu["ScrollbarLastPos"][self getCurrentMenu()] = self.menu["hud"]["Scrollbar"].y;
        self.menu["Cursor"][self getCurrentMenu()] = 0;
    }

    // self thread refreshTitle(self.menu["CurrentMenu"]);
    self thread SetMenuText();
    self thread DoBackgroundSize();
    self DrawText();
    // self ScrollingSystem();
}

addMenu(Menu, title)
{
    self MenuArrays(Menu);

    if(isDefined(title))
        self.menu["items"][Menu].title = title;
    
    if(!isDefined(self.temp))
        self.temp = [];
    
    self.temp["memory"] = Menu;
}

addOpt(name, fnc, arg1, arg2, arg3, arg4)
{
    menu = self.temp["memory"];
    size = self.menu["items"][menu].name.size;
    
    self.menu["items"][menu].name[size] = MakeLocalizedString(name);
    self.menu["items"][menu].func[size] = fnc;
    self.menu["items"][menu].arg1[size] = arg1;
    self.menu["items"][menu].arg2[size] = arg2;
    self.menu["items"][menu].arg3[size] = arg3;
    self.menu["items"][menu].arg4[size] = arg4;
}

addOptBool(bool, name, fnc, arg1, arg2, arg3, arg4)
{
    menu = self.temp["memory"];
    size = self.menu["items"][menu].name.size;
    
    self.menu["items"][menu].name[size] = MakeLocalizedString(name);
    self.menu["items"][menu].func[size] = fnc;
    self.menu["items"][menu].arg1[size] = arg1;
    self.menu["items"][menu].arg2[size] = arg2;
    self.menu["items"][menu].arg3[size] = arg3;
    self.menu["items"][menu].arg4[size] = arg4;
    self.menu["items"][menu].bool[size] = true;
    
    self.menu_Bool[menu][size] = (isDefined(bool) && bool) ? true : undefined;
}

addOptIntSlider(name, fnc, min, start, max, increment, arg1, arg2, arg3, arg4)
{
    menu = self.temp["memory"];
    size = self.menu["items"][menu].name.size;
    
    self.menu["items"][menu].name[size] = MakeLocalizedString(name);
    self.menu["items"][menu].func[size] = fnc;
    self.menu["items"][menu].arg1[size] = arg1;
    self.menu["items"][menu].arg2[size] = arg2;
    self.menu["items"][menu].arg3[size] = arg3;
    self.menu["items"][menu].arg4[size] = arg4;
    self.menu["items"][menu].intslidermin[size] = min;
    self.menu["items"][menu].intsliderstart[size] = start;
    self.menu["items"][menu].intslidermax[size] = max;
    self.menu["items"][menu].intincrement[size] = (isDefined(increment) && increment) ? increment : 1;
    self.menu["items"][menu].intslider[size] = true;
    
    if(!isDefined(self.menu_SValue[menu][size]))
        self.menu_SValue[menu][size] = start;
}

addOptSlider(name, fnc, values, start, arg1, arg2, arg3, arg4, arg5)
{
    menu = self.temp["memory"];
    size = self.menu["items"][menu].name.size;
    
    // if(IsArray(values))
    // {
    //     self.menu_Strings[menu][size] = ArrayStrClean(values);
    //     if(!IsArray(self.menu_Strings[menu]))
    //         self.menu_Strings[menu] = array(values);
    //     // self.menu_Strings[menu] = ArrayStrClean(self.menu_Strings[menu]);
    // }
    // else
    //     self.menu_Strings[menu][size] = StrTok(values, ";");
    self.menu_Strings[menu][size] = StrTok(values, ";");

    self.menu["items"][menu].name[size] = MakeLocalizedString(name);
    self.menu["items"][menu].func[size] = fnc;
    self.menu["items"][menu].start[size] = start;       //  Must be passed as a String. ie: "Check", "0", etc. Not INT values
    self.menu["items"][menu].arg1[size] = arg1;
    self.menu["items"][menu].arg2[size] = arg2;
    self.menu["items"][menu].arg3[size] = arg3;
    self.menu["items"][menu].arg4[size] = arg4;
    self.menu["items"][menu].arg5[size] = arg5;
    self.menu["items"][menu].slider[size] = true;
    
    if(isDefined(start))
    {
        menuSize = self.menu["items"][self getCurrentMenu()].name.size;
        for(i = 0; i < menuSize; i++)
            if(name == self.menu["items"][self getCurrentMenu()].name[i])
                for(a = 0; a < (self.menu_Strings[self getCurrentMenu()][i].size); a++)
                    if(self.menu_Strings[self getCurrentMenu()][i][a] == start)
                        start = a;

        if(isString(start))
            start = 0;  //  If start has not been assigned to an index(int), it becomes 0 to prevent errors
    }

    if(!isDefined(self.menu_SValue[menu][size]))
        self.menu_SValue[menu][size] = ((isDefined(self.menu["items"][menu].start[size])) ? start : 0);
}

SetIntSlider(dir)
{
    menu = self getCurrentMenu();
    curs = self getCursor();

    val = self.menu["items"][menu].intincrement[curs];
    max = self.menu["items"][menu].intslidermax[curs];
    min = self.menu["items"][menu].intslidermin[curs];

    if((self.menu_SValue[menu][curs] < max) && (self.menu_SValue[menu][curs] + val) > max || (self.menu_SValue[menu][curs] > min) && (self.menu_SValue[menu][curs] - val) < min)
        self.menu_SValue[menu][curs] = ((self.menu_SValue[menu][curs] < max) && (self.menu_SValue[menu][curs] + val) > max) ? max : min;
    else
        self.menu_SValue[menu][curs] += (dir > 0) ? val : (val * -1);
    
    if((self.menu_SValue[menu][curs] > max) || (self.menu_SValue[menu][curs] < min))
        self.menu_SValue[menu][curs] = (self.menu_SValue[menu][curs] > max) ? min : max;

    if(isDefined(self.menu["hud"]["ValSlider"][curs]))
    {
        string = "< [" + self.menu_SValue[self getCurrentMenu()][curs] +  "/" + self.menu["items"][self getCurrentMenu()].intslidermax[curs] + "] >";
        self.menu["hud"]["ValSlider"][curs] setText(string);
    }
    else
    {
        self RefreshMenu(); //Resize Option Backgrounds & Refresh Sliders
    }
}

SetStringSlider(dir)
{
    menu = self getCurrentMenu();
    curs = self getCursor();
    max = (self.menu_Strings[menu][curs].size - 1);
    
    self.menu_SValue[menu][curs] += (dir > 0) ? 1 : -1;
    
    if((self.menu_SValue[menu][curs] > max) || (self.menu_SValue[menu][curs] < 0))
        self.menu_SValue[menu][curs] = (self.menu_SValue[menu][curs] > max) ? 0 : max;
    // current_option = self.menu_Strings[menu][curs][self.menu_SValue[menu][curs]];
    string = "< " + self.menu_Strings[self getCurrentMenu()][self getCursor()][self.menu_SValue[self getCurrentMenu()][self getCursor()]] + " >";

    if(isDefined(self.menu["hud"]["OptSlider"][curs]))
        self.menu["hud"]["OptSlider"][curs] setText(string);
    else
    {
        self RefreshMenu(); //Resize Option Backgrounds & Refresh Sliders
    }
}

ExecFunc(func, arg1, arg2, arg3, arg4, arg5, arg6)
{
    if(!isDefined(func))
        return;
    
    if(isDefined(arg6))
        return self thread [[ func ]](arg1, arg2, arg3, arg4, arg5, arg6);
    
    if(isDefined(arg5))
        return self thread [[ func ]](arg1, arg2, arg3, arg4, arg5);
    
    if(isDefined(arg4))
        return self thread [[ func ]](arg1, arg2, arg3, arg4);
    
    if(isDefined(arg3))
        return self thread [[ func ]](arg1, arg2, arg3);
    
    if(isDefined(arg2))
        return self thread [[ func ]](arg1, arg2);
    
    if(isDefined(arg1))
        return self thread [[ func ]](arg1);

    return self thread [[ func ]]();
}
