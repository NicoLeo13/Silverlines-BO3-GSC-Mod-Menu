test()
{
    self iPrintLnBold("Test");
}

testbool()
{
    self.testbool = isDefined(self.testbool) ? undefined : true;
    
    if(isDefined(self.testbool))
        self iPrintLnBold("Test Bool ^2ON");
    else
        self iPrintLnBold("Test Bool ^1OFF");
}

testIntSlider(value)
{
    self iPrintLnBold("Value is: ^5" + value);
}

testOptSlider(value)
{
    self iPrintLnBold("String is: ^3" + value);
}

testWelcome()
{
    self WelcomeMessage();
}

debugexit()
{
    exitlevel(false);
}

RestartGame()
{
    Map_Restart(false);
}

bool(variable)
{
    return isDefined(variable) && int(variable);
}

isInMenu()
{
    return isDefined(self.menu_open) && self.menu_open;
}

isLUI(hud)
{
    if(self GetLUIMenuData(hud, "material") != undefined || self GetLUIMenuData(hud, "alignment") != undefined)
        return true;
    else
        return false;
}

Is_Alive(player)
{
    return (IsAlive(player) && player.sessionstate != "spectator");
}

isDown()
{
    return isDefined(self.revivetrigger);
}

getCurrentMenu()
{
    return self.menu["CurrentMenu"];
}

getCursor(menu = self.menu["CurrentMenu"])
{
    if(!isDefined(self.menu["Cursor"][menu]))
        self.menu["Cursor"][menu] = 0;
        // self setCursor(menu);

    return self.menu["Cursor"][menu];
}

getScrollCursor(menu = self.menu["CurrentMenu"])
{
    options = self.menu["items"][self getCurrentMenu()].name;
    
    if(!isDefined(self.menu["items"][self getCurrentMenu()].name[self getCursor() - int(self.middle)]) || self.menu["items"][self getCurrentMenu()].name.size <= self getMaxCursor())
        cursor = self getCursor();
    else
        if(isDefined(self.menu["items"][self getCurrentMenu()].name[self getCursor() + (self getMaxCursor() - int(self.middle))]))
            cursor = int(self.middle);
        else
            cursor = ((self getCursor() - options.size) + self getMaxCursor());

    return cursor;
}

getMaxCursor()
{
    return self.menu["MaxOpts"];
}

destroyAll(array)
{
    if(!isDefined(array))
        return;
    
    huds = GetArrayKeys(array);

    for(a = 0; a < huds.size; a++)
        if(IsArray(array[huds[a]]))
        {
            foreach(value in array[huds[a]])
                if(isDefined(value))
                    value DestroyHud();
        }
        else
            if(isDefined(array[huds[a]]))
                array[huds[a]] DestroyHud();
}

destroyAllLui(huds)
{
    foreach(hud in huds)    //  LUIs
    {
        if(isLUI(hud))
            self CloseLUIMenu(hud);
    }
}

notifyStopHudFades(hud, hudname)
{
    if(isLUI(hud))
    {
        self notify("StopRainbow" + hud);
        self notify("StopLightRainbow" + hud);
        self notify("StopDarkRainbow" + hud);
        self notify("StopRandomFade" + hud);
        self notify("StopRandomLightFade" + hud);
        self notify("StopRandomDarkFade" + hud);
    }
    else
    {
        self notify("StopRainbow" + hudname);
        self notify("StopLightRainbow" + hudname);
        self notify("StopDarkRainbow" + hudname);
        self notify("StopRandomFade" + hudname);
        self notify("StopRandomLightFade" + hudname);
        self notify("StopRandomDarkFade" + hudname);
    }
}

CleanString(string)
{
    if(string[0] == ToUpper(string[0]))
        if(IsSubStr(string, " ") && !IsSubStr(string, "_"))
            return string;
    
    string = StrTok(ToLower(string), "_");
    str = "";
    
    for(a = 0; a < string.size; a++)
    {
        //List of strings what will be removed from the final string output
        strings = ["specialty", "zombie", "zm", "t7", "t6", "p7", "zmb", "zod", "ai", "g", "bg", "perk", "player", "weapon", "wpn", "aat", "bgb", "visionset", "equip", "craft", "der", "viewmodel", "mod", "fxanim", "moo", "moon", "zmhd", "fb", "bc", "asc", "vending", "part", "menu", "ui", "uie", "mtl"];
        
        //This will replace any '_' found in the string
        replacement = " ";

        if(!isInArray(strings, string[a]))
        {
            for(b = 0; b < string[a].size; b++)
                if(b != 0)
                    str += string[a][b];
                else
                    str += ToUpper(string[a][b]);
            
            if(a != (string.size - 1))
                str += replacement;
        }
    }
    
    return str;
}

CleanName(name)
{
    if(!isDefined(name) || name == "")
        return;
    
    colors = ["^0", "^1", "^2", "^3", "^4", "^5", "^6", "^7", "^8", "^9", "^H", "^B"];
    string = "";

    for(a = 0; a < name.size; a++)
        if(name[a] == "^" && isInArray(colors, name[a] + name[(a + 1)]))
            a++;
        else
            string += name[a];
    
    return string;
}

getName()
{
    name = self.name;

    if(name[0] != "[")
        return name;

    for(a = (name.size - 1); a >= 0; a--)
        if(name[a] == "]")
            break;

    return GetSubStr(name, (a + 1));
}

GetPlayerFromEntityNumber(number)
{
    foreach(player in level.players)
        if(player GetEntityNumber() == number)
            return player;
}

CleanMenuName(menu)
{
    tokens = StrTok(menu, " ");
    player = GetPlayerFromEntityNumber(Int(tokens[(tokens.size - 1)]));
    
    newmenu = "";
    sepmenu = StrTok(menu, " " + player GetEntityNumber());

    for(a = 0; a < sepmenu.size; a++)
    {
        newmenu += sepmenu[a];

        if(a != (sepmenu.size - 1))
            newmenu += " ";
    }

    return newmenu;
}

array_delete(array)
{   
    foreach(item in array)
    {
        if(IsDefined(item))
            item delete();
    }
}

ReturnPerkName(perk)
{
    perk = ToLower(perk);
    
    switch(perk)
    {
        case "additionalprimaryweapon":
            return "Mule Kick";
        
        case "doubletap2":
            return "Double Tap";
        
        case "deadshot":
            return "Deadshot Daiquiri";
        
        case "armorvest":
            return "Jugger-Nog";
        
        case "quickrevive":
            return "Quick Revive";
        
        case "fastreload":
            return "Speed Cola";
        
        case "staminup":
            return "Stamin-Up";
        
        case "widowswine":
            return "Widow's Wine";
        
        case "electriccherry":
            return "Electric Cherry";
        
        default:
            return "Unknown Perk";
    }
}

ReturnMapName(map)
{
    switch(map)
    {
        case "zm_zod":
            return "Shadows Of Evil";
        
        case "zm_factory":
            return "The Giant";
        
        case "zm_castle":
            return "Der Eisendrache";
        
        case "zm_island":
            return "Zetsubou No Shima";
        
        case "zm_stalingrad":
            return "Gorod Krovi";
        
        case "zm_genesis":
            return "Revelations";
        
        case "zm_prototype":
            return "Nacht Der Untoten";
        
        case "zm_asylum":
            return "Verruckt";
        
        case "zm_sumpf":
            return "Shi No Numa";
        
        case "zm_theater":
            return "Kino Der Toten";
        
        case "zm_cosmodrome":
            return "Ascension";
        
        case "zm_temple":
            return "Shangri-La";

        case "zm_moon":
            return "Moon";
        
        case "zm_tomb":
            return "Origins";
        
        default:
            return "Unknown";
    }
}

ReturnCharacterName(index)
{
    switch(index)
    {
        case 0:
            return "Dempsey";
        
        case 1:
            return "Nikolai";
        
        case 2:
            return "Richtofen";
        
        case 3:
            return "Takeo";
        
        case 4:
            return "Shadows of Evil Beast";
        
        case 5:
            return "Floyd Campbell";
        
        case 6:
            return "Jack Vincent";
        
        case 7:
            return "Jessica Rose";
        
        case 8:
            return "Nero Blackstone";
        
        default:
            return "Unknown";
    }
}

CheckPlayerAccess(player)
{
    self iPrintLnBold("Status for " + CleanName(player getName()) + " is: " + verificationToColor(player.menu["Verification"]));
    playerAccess = ((isDefined(player.access) && player.access) ? "Access ^2Set^7 for: " + CleanName(player getName()) : "Access ^1Denied^7 for: " + CleanName(player getName()));
    self iPrintLnBold(playerAccess);    
}

isPlayerLinked(exclude)
{
    ents = GetEntArray("script_model", "classname");

    for(a = 0; a < ents.size; a++)
    {
        if(isDefined(exclude))
        {
            if(ents[a] != exclude && self isLinkedTo(ents[a]))
                return true;
        }
        else
        {
            if(self isLinkedTo(ents[a]))
                return true;
        }
    }

    return false;
}

SpawnScriptModel(origin, model, angles, time)
{
    if(isDefined(time))
        wait time;

    ent = Spawn("script_model", origin);
    ent SetModel(model);

    if(isDefined(angles))
        ent.angles = angles;

    return ent;
}

DevGUIInfo()
{
    SetDvar("ui_lobbyDebugVis", (GetDvarString("ui_lobbyDebugVis") == "1") ? "0" : "1");
}

TraceBullet()
{
    return BulletTrace(self GetWeaponMuzzlePoint(), self GetWeaponMuzzlePoint() + VectorScale(AnglesToForward(self GetPlayerAngles()), 1000000), 0, self)["position"];
}

CheckEmptyOptions()
{
    options = self.menu["items"][self getCurrentMenu()].name;

    if(!isDefined(options) || !options.size)
        self addOpt("Nothing Here..");

    // self setCursor(self getCurrentMenu(), self getCursor());
    // menuSize = self.menu["items"][self getCurrentMenu()].name.size;
    // self.menu["LastMenuSize"][self getCurrentMenu()] = menuSize;
    // return menuSize;
}

ForceHost()
{
    if(GetDvarInt("migration_forceHost") != 1)
    {
        SetDvar("lobbySearchListenCountries", "0,103,6,5,8,13,16,23,25,32,34,24,37,42,44,50,71,74,76,75,82,84,88,31,90,18,35");
        SetDvar("excellentPing", 3);
        SetDvar("goodPing", 4);
        SetDvar("terriblePing", 5);
        SetDvar("migration_forceHost", 1);
        SetDvar("migration_minclientcount", 12);
        SetDvar("party_connectToOthers", 0);
        SetDvar("party_dedicatedOnly", 0);
        SetDvar("party_dedicatedMergeMinPlayers", 12);
        SetDvar("party_forceMigrateAfterRound", 0);
        SetDvar("party_forceMigrateOnMatchStartRegression", 0);
        SetDvar("party_joinInProgressAllowed", 1);
        SetDvar("allowAllNAT", 1);
        SetDvar("party_keepPartyAliveWhileMatchmaking", 1);
        SetDvar("party_mergingEnabled", 1);
        SetDvar("party_neverJoinRecent", 0);
        SetDvar("party_readyPercentRequired", 0.25);
        SetDvar("partyMigrate_disabled", 0);
    }
    else
    {
        SetDvar("lobbySearchListenCountries", "");
        SetDvar("excellentPing", 30);
        SetDvar("goodPing", 100);
        SetDvar("terriblePing", 500);
        SetDvar("migration_forceHost", 0);
        SetDvar("migration_minclientcount", 2);
        SetDvar("party_connectToOthers", 1);
        SetDvar("party_dedicatedOnly", 0);
        SetDvar("party_dedicatedMergeMinPlayers", 2);
        SetDvar("party_forceMigrateAfterRound", 0);
        SetDvar("party_forceMigrateOnMatchStartRegression", 0);
        SetDvar("party_joinInProgressAllowed", 1);
        SetDvar("allowAllNAT", 1);
        SetDvar("party_keepPartyAliveWhileMatchmaking", 1);
        SetDvar("party_mergingEnabled", 1);
        SetDvar("party_neverJoinRecent", 0);
        SetDvar("partyMigrate_disabled", 0);
    }
}

ArrayToString(array, additionalStrs = undefined)
{
    str = "";

    // Shoudl be passed as a string separated by ";, not an array
    if(isDefined(additionalStrs))
        str += additionalStrs;
    
    for(a = 0; a < array.size; a++)
    {
        str += array[a];
        
        if(a != (array.size - 1))
            str += ";";
    }
    return str;
}

ArrayStrClean(array)
{
    for(a = 0; a < array.size; a++)
    {
        if(array[a] == "free_perk")     //  This is a special case for the free perk Str
            array[a] = "Free Perk";
        else
            array[a] = CleanString(array[a]);
    }

    return array;
}

CleanArrayToString(array)
{
    str = "";
    
    for(a = 0; a < array.size; a++)
    {
        str += CleanString(array[a]);
        
        if(a != (array.size - 1))
            str += ";";
    }
    
    return str;
}

// StringToInt(string)
// {
//     //Receive a string and return the int value. 
//     if(!isDefined(string) || string == "")
//         return 0;

//     intValue = 0;

//     for(i = 0; i < string.size; i++)
//     {
//         char = string[i];

//         //If char is a number, parse it to intValue
//         if(char == "0") digitValue = 0;
//         else if(char == "1") digitValue = 1;
//         else if(char == "2") digitValue = 2;
//         else if(char == "3") digitValue = 3;
//         else if(char == "4") digitValue = 4;
//         else if(char == "5") digitValue = 5;
//         else if(char == "6") digitValue = 6;
//         else if(char == "7") digitValue = 7;
//         else if(char == "8") digitValue = 8;
//         else if(char == "9") digitValue = 9;
//         else
//             continue;

//         intValue = (intValue * 10) + digitValue;    //  Multiply the current intValue by 10 and add the digit value
//     }
    
//     return intValue;
// }

StringToInt(value)
{
    //Receive a string and return the int value.
    if(strisint(value))
	{
		value = int(value);
	}
	else if(strisfloat(value))
	{
		value = float(value);
	}
	return value;
}

mergeSortByValue(array)
{
    if(array.size <= 1)
        return array;

    // Create temporary array for ordering
    pairs = [];
    keys = getArrayKeys(array);
    
    // Save key-value pairs to maintain the association
    for(i = 0; i < keys.size; i++)
    {
        pairs[i] = [];
        pairs[i]["key"] = keys[i];
        pairs[i]["value"] = array[keys[i]];
    }

    // TEMPORARY ARRAY
    pairs = mergeSort(pairs);

    // Rebuiold the original array with sorted values
    result = [];
    for(i = 0; i < pairs.size; i++)
    {
        result[pairs[i]["key"]] = pairs[i]["value"];
    }

    return result;
}

mergeSort(array)
{
    if(array.size <= 1)
        return array;
        
    midpoint = int(array.size / 2);
    left = [];
    right = [];
    
    for(i = 0; i < midpoint; i++)
        left[i] = array[i];
    
    for(i = midpoint; i < array.size; i++)
        right[i - midpoint] = array[i];
    
    left = mergeSort(left);
    right = mergeSort(right);
    
    return merge(left, right);
}

merge(left, right)
{
    result = [];
    i = 0;
    j = 0;
    k = 0;
    
    while(i < left.size && j < right.size)
    {
        // Comparison by value
        if(left[i]["value"] <= right[j]["value"])
        {
            result[k] = left[i];
            i++;
        }
        else
        {
            result[k] = right[j];
            j++;
        }
        k++;
    }
    
    while(i < left.size)
    {
        result[k] = left[i];
        i++;
        k++;
    }
    
    while(j < right.size)
    {
        result[k] = right[j];
        j++;
        k++;
    }
    
    return result;
}