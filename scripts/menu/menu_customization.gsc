LoadMenuVars() //Presets
{
    //  CONSTANTS
    HEAD = "LUI_Head";
    HEAD2 = "LUI_Head2";
    //  Misc
    self.menu["Instructions"] = true;
    //  Offsets
    self.menu["X"] = 0;
    self.menu["Y"] = 0;
    //  Opts
    self.menu["DefMaxOpts"] = 7;    //  Static predefined Max Opts
    self.menu["MaxOpts"] = self.menu["DefMaxOpts"];
    self.menu["ScrollDelay"] = .15;
    //  Bools
    self.menu["BoolStyle"] = "Checks";    //  "Checks" or "Text"
    self.menu["BoolIcon"] = "white";      //  Name of the Shader
    self.menu["BoolIconName"] = "Box";    //  "Box;Arrow;Inst Kill;Dob Points;Fire Sale;Nuke;Mask;Scavenger;Other"
    self.menu["BoolFont"] = "default";
    self.menu["BoolFontSize"] = 1.1;
    //  Colors
    self thread LoadMenuDefColors();
    //  Rainbow Fades
    self.RainbowType[HEAD2] = "Random Normal Fade";
    //  Opt Font Style
    self.menu["OptFont"] = "escom";
    self.menu["OptFontSize"] = 1.3;
    //  Sliders Font Style
    self.menu["SlidFont"] = "default";
    self.menu["SlidFontSize"] = 1.1;
    //  Shader
    self.menu["ShaderRotation"] = true;
    self thread LoadMenuDefShaders();
    //  Alphas
    self.hudalpha["Background"] = 0.6; self.hudalpha["Scrollbar"] = 0.6; self.hudalpha["TopBar"] = 0.8; self.hudalpha["BottomBar"] = 0.8; self.hudalpha["MenuTitle"] = 1; self.hudalpha["Index"] = 1; self.hudalpha["Root"] = 1; self.hudalpha["BottomText"] = 1; self.hudalpha["LUI_Head"] = 0.8; self.hudalpha["LUI_Head2"] = 0.8; self.hudalpha["LUI_Shad"] = 1; self.hudalpha["LUI_Shad2"] = 1;
    //LUI Headers Defines   //  Useful for Set Vision Func
    self.LUIx[HEAD] = 965; self.LUIWidth[HEAD] = 300; self.LUIHeight[HEAD] = 55;
    self.LUIx[HEAD2] = 965; self.LUIWidth[HEAD2] = 300; self.LUIHeight[HEAD2] = 55;
}

LoadMenuDefColors()
{
    COLOR = "color";
    //  Main Huds Colors
    self.menu[COLOR]["Scrollbar"] = (0, 0.5, 0.5);
    self.menu[COLOR]["Background"] = (0, 0, 0);
    self.menu[COLOR]["TopBar"] = (0, 0, 0);
    self.menu[COLOR]["BottomBar"] = (0, 0, 0);
    self.menu[COLOR]["LUI_Head"] = (0, 0.5, 0.5);
    self.menu[COLOR]["LUI_Head2"] = (1, 0.5, 0.31);
    self.menu[COLOR]["LUI_Shad"] = (1, 1, 1);
    self.menu[COLOR]["LUI_Shad2"] = (1, 1, 1);
    //  Bools Colors
    self.boolColor["BoolBack"] = (0.25, 0.25, 0.25);
    self.boolColor["BoolOpt"] = (0, 1, 0.1);
    // Fonts Color
    self.menu[COLOR]["Options"] = (1, 1, 1);
    self.menu[COLOR]["Root"] = (1, 1, 1);
    self.menu[COLOR]["BottomText"] = (1, 1, 1);
    self.menu[COLOR]["FontBoolColor"] = (0, 1, 0.1);
}

LoadMenuDefShaders()
{
    SHADER = "shader";
    //  Shader
    self.shader["LUI_Head"] = "gradient_fadein";
    self.shader["LUI_Head2"] = "gradient_fadein";
    self.shader["LUI_Shad"] = "acog_23";
    self.shader["LUI_Shad2"] = "acog_23";
    self.hudalpha["LUI_Head"] = 0.8;
    self.hudalpha["LUI_Head2"] = 0.8;
}

SetDefaultPreset()
{
    self.menu["X"] = 0;
    self.menu["Y"] = 0;
    self LoadMenuDefColors();
    self LoadMenuDefShaders();
    for(i = 0; i < level.huds.size; i++)
    {
        hud = self.menu["hud"][level.huds[i]];
        if(isLUI(hud))
        {
            self thread LuiFade(hud, self.hudalpha[level.huds[i]], 0.5);
            self thread LuiColorFade(hud, self.menu["color"][level.huds[i]], 0.5);
            self SetLuiMenuData(hud, "material", self.shader[level.huds[i]]);

        }
        else
            hud thread fadeToColor(self.menu["color"][level.huds[i]], 0.5);
        
        self notifyStopHudFades(hud, level.huds[i]);
        self.hudopen[level.huds[i]] = undefined;
        self.hudcolor[level.huds[i]] = undefined;
        self.RainbowType[level.huds[i]] = undefined;
        self.RainbowActive[level.huds[i]] = undefined;
        self.LightRainbowActive[level.huds[i]] = undefined;
        self.DarkRainbowActive[level.huds[i]] = undefined;
    }
    self.menu["hud"]["MenuTitle"] thread hudFade(1, 0.5);

    if(self.menu["MaxOpts"] != self.menu["DefMaxOpts"])
        self SetMenuMaxOpts(self.menu["DefMaxOpts"]);

    self iPrintLnBold("Default Preset Applied");
}

TypeWriterFXText(text, hud)
{
    self endon("StopTypeWriter");
    // level.TextWrite = isDefined(level.TextWrite) ? undefined : true;
    if(!isDefined(text) || !isDefined(hud))
        return;
    
    hud setText(text);

    while(true)
    {
        if(isDefined(hud))
        {
            level.colorR = RandomIntRange(160, 255); // Rango para el componente rojo (valores más altos)
            level.colorG = RandomIntRange(160, 255); // Rango para el componente verde (valores más altos)
            level.colorB = RandomIntRange(160, 255); // Rango para el componente azul (valores más altos)
            hud.color = divideColor(level.colorR, level.colorG, level.colorB);

            level.brightness = (level.colorR + level.colorG + level.colorB) / 3;

            while(level.brightness < 160)
            {
                level.colorR = RandomIntRange(160, 255); // Rango para el componente rojo (valores más altos)
                level.colorG = RandomIntRange(160, 255); // Rango para el componente verde (valores más altos)
                level.colorB = RandomIntRange(160, 255); // Rango para el componente azul (valores más altos)
                hud.color = divideColor(level.colorR, level.colorG, level.colorB);
                
                level.brightness = (level.colorR + level.colorG + level.colorB) / 3;
                wait 0.01;
            } 
            hud SetTypeWriterFX(25, 2000, 500);
        }
        wait 3;
    }
}

//  Level RGBFade
LevelRGBFade(target_color, time)
{
    start_color = level.RGBFadeColor; // Establece el color inicial en negro
    startTime = getTime(); // Obtiene el tiempo actual en milisegundos
    
    while (true)
    {
        currentTime = getTime(); // Obtiene el tiempo actual en milisegundos
        elapsed = (currentTime - startTime) / 1000.0; // Calcula el tiempo transcurrido en segundos

        if ((color == target_color))
            break; // Sale del bucle si cumple condicion

        t = elapsed / time; // Calcula el factor de interpolación
        color = LerpVector(start_color, target_color, t); // Interpolación lineal del color

        level.RGBFadeColor = color; // Establece el nuevo color
        wait 0.01;
    }
    level.RGBFadeColor = target_color;
}

RGBFade(time)
{
    level endon("NukeInbound");
    level endon("disconnect");
    while (true)
    {
        level LevelRGBFade((1, 0, 0), time); // Rojo
        level LevelRGBFade((1, 1, 0), time); // Amarillo
        level LevelRGBFade((0, 1, 0), time); // Verde
        level LevelRGBFade((0, 1, 1), time); // Cian
        level LevelRGBFade((0, 0, 1), time); // Azul
        level LevelRGBFade((1, 0, 1), time); // Magenta

        wait 0.01;
    }
}

// HUD RGBFade
RainbowEffect(hud, time, hudname)
{
    if(isDefined(self.RainbowType[hudname]) && isDefined(self.hudopen[hudname]))
    {
        if(self.RainbowType[hudname] == "Rainbow")
        {
            if(isLUI(hud))
                self notify("StopRainbow" + hud);
            else
                self notify("StopRainbow" + hudname);
            self.RainbowActive[hudname] = undefined;
            self.RainbowType[hudname] = undefined;
            self.hudopen[hudname] = undefined;
            return;
        }
        else
        {
            self iPrintLnBold("^1Error^7: Rainbow Already Active for this HUD");
            if(self.RainbowType[hudname] == "Random Dark Fade" || self.RainbowType[hudname] == "Random Light Fade" || self.RainbowType[hudname] == "Random Normal Fade")
                self iPrintLnBold("^5" + self.RainbowType[hudname] + "^7 Active. Turn it off first");
            else
                self iPrintLnBold("Deactivate the other effect first");
            return;
        }
    }
    
    if(isLUI(hud))
    {
        self endon("StopRainbow" + hud);
        self.RainbowType[hudname] = "Rainbow";
        self.RainbowActive[hudname] = true;
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        while (true)
        {
            self LuiColorFade(hud, (1, 0, 0), time, hudname);    // Rojo
            self LuiColorFade(hud, (1, 1, 0), time, hudname);    // Amarillo
            self LuiColorFade(hud, (0, 1, 0), time, hudname);    // Verde
            self LuiColorFade(hud, (0, 1, 1), time, hudname);    // Cian
            self LuiColorFade(hud, (0, 0, 1), time, hudname);    // Azul
            self LuiColorFade(hud, (1, 0, 1), time, hudname);    // Magenta
            wait 0.01;
        }
    }
    else
    {
        self endon("StopRainbow" + hudname);
        self.RainbowType[hudname] = "Rainbow";
        self.RainbowActive[hudname] = true;
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        // hud fadeToColor((0.8, 0, 0), 0.5);
        while (true)
        {
            hud fadeToColor((1, 0, 0), time, hudname); // Rojo
            hud fadeToColor((1, 1, 0), time, hudname); // Amarillo
            hud fadeToColor((0, 1, 0), time, hudname); // Verde
            hud fadeToColor((0, 1, 1), time, hudname); // Cian
            hud fadeToColor((0, 0, 1), time, hudname); // Azul
            hud fadeToColor((1, 0, 1), time, hudname); // Magenta
            wait 0.01;
        }
    }
}

LightRainbowEffect(hud, time, hudname)
{
    if(isDefined(self.RainbowType[hudname]) && isDefined(self.hudopen[hudname]))
    {
        if(self.RainbowType[hudname] == "LightRainbow")
        {
            if(isLUI(hud))
                self notify("StopLightRainbow" + hud);
            else
                self notify("StopLightRainbow" + hudname);
            self.LightRainbowActive[hudname] = undefined;
            self.RainbowType[hudname] = undefined;
            self.hudopen[hudname] = undefined;
            return;
        }
        else
        {
            self iPrintLnBold("^1Error^7: Rainbow Already Active for this HUD");
            if(self.RainbowType[hudname] == "Random Dark Fade" || self.RainbowType[hudname] == "Random Light Fade" || self.RainbowType[hudname] == "Random Normal Fade")
                self iPrintLnBold("^5" + self.RainbowType[hudname] + "^7 Active. Turn it off first");
            else
                self iPrintLnBold("Deactivate the other effect first");
            return;
        }
    }

    if(isLUI(hud))
    {
        self endon("StopLightRainbow" + hud);
        self.RainbowType[hudname] = "LightRainbow";
        self.LightRainbowActive[hudname] = true;
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        while (true)
        {
            self LuiColorFade(hud, (1, 0.7, 0.7), time, hudname);    // Rojo
            self LuiColorFade(hud, (1, 1, 0.7), time, hudname);    // Amarillo
            self LuiColorFade(hud, (0.7, 1, 0.7), time, hudname);    // Verde
            self LuiColorFade(hud, (0.7, 1, 1), time, hudname);    // Cian
            self LuiColorFade(hud, (0.7, 0.7, 1), time, hudname);    // Azul
            self LuiColorFade(hud, (1, 0.7, 1), time, hudname);    // Magenta
            wait 0.01;
        }
    }
    else
    {
        self endon("StopLightRainbow" + hudname);
        self.RainbowType[hudname] = "LightRainbow";
        self.LightRainbowActive[hudname] = true;
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        // hud fadeToColor((0.7, 0.6, 0.6), 0.5);
        while (true)
        {
            hud fadeToColor((1, 0.7, 0.7), time, hudname); // Rojo Pastel
            hud fadeToColor((1, 1, 0.7), time, hudname);   // Amarillo Pastel
            hud fadeToColor((0.7, 1, 0.7), time, hudname); // Verde Pastel
            hud fadeToColor((0.7, 1, 1), time, hudname);   // Cian Pastel
            hud fadeToColor((0.7, 0.7, 1), time, hudname); // Azul Pastel
            hud fadeToColor((1, 0.7, 1), time, hudname);   // Magenta Pastel
            wait 0.01;
        }
    }
}

DarkRainbowEffect(hud, time, hudname)
{
    if(isDefined(self.RainbowType[hudname]) && isDefined(self.hudopen[hudname]))
    {
        if(self.RainbowType[hudname] == "DarkRainbow")
        {
            if(isLUI(hud))
                self notify("StopDarkRainbow" + hud);
            else
                self notify("StopDarkRainbow" + hudname);
            self.DarkRainbowActive[hudname] = undefined;
            self.RainbowType[hudname] = undefined;
            self.hudopen[hudname] = undefined;
            return;
        }
        else
        {
            self iPrintLnBold("^1Error^7: Rainbow Already Active for this HUD");
            if(self.RainbowType[hudname] == "Random Dark Fade" || self.RainbowType[hudname] == "Random Light Fade" || self.RainbowType[hudname] == "Random Normal Fade")
                self iPrintLnBold("^5" + self.RainbowType[hudname] + "^7 Active. Turn it off first");
            else
                self iPrintLnBold("Deactivate the other effect first");
            return;
        }
    }

    if(isLUI(hud))
    {
        self endon("StopDarkRainbow" + hud);
        self.RainbowType[hudname] = "DarkRainbow";
        self.DarkRainbowActive[hudname] = true;
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        while (true)
        {
            self LuiColorFade(hud, (0.5, 0.1, 0.1), time, hudname);    // Rojo
            self LuiColorFade(hud, (0.5, 0.5, 0.1), time, hudname);    // Amarillo
            self LuiColorFade(hud, (0.1, 0.5, 0.1), time, hudname);    // Verde
            self LuiColorFade(hud, (0.1, 0.5, 0.5), time, hudname);    // Cian
            self LuiColorFade(hud, (0.1, 0.1, 0.5), time, hudname);    // Azul
            self LuiColorFade(hud, (0.5, 0.1, 0.5), time, hudname);    // Magenta
            wait 0.01;
        }
    }
    else
    {
        self endon("StopDarkRainbow" + hudname);
        self.RainbowType[hudname] = "DarkRainbow";
        self.DarkRainbowActive[hudname] = true;
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        // hud fadeToColor((0.3, 0.1, 0.1), 0.3);
        while (true)
        {
            hud fadeToColor((0.5, 0.1, 0.1), time, hudname); // Rojo Oscuro
            hud fadeToColor((0.5, 0.5, 0.1), time, hudname); // Amarillo Oscuro
            hud fadeToColor((0.1, 0.5, 0.1), time, hudname); // Verde Oscuro
            hud fadeToColor((0.1, 0.5, 0.5), time, hudname); // Cian Oscuro
            hud fadeToColor((0.1, 0.1, 0.5), time, hudname); // Azul Oscuro
            hud fadeToColor((0.5, 0.1, 0.5), time, hudname); // Magenta Oscuro
            wait 0.01;
        }
    }
}

RandomFade(hud, time, hudname)     //  LUI Needs to be created before this is called!
{
    if(isDefined(self.RainbowType[hudname]) && isDefined(self.hudopen[hudname]))
    {
        if(self.RainbowType[hudname] == "Random Normal Fade")
        {
            if(isLUI(hud))
            {
                self notify("StopRandomFade" + hud);
            }
            else
                self notify("StopRandomFade" + hudname);
            self notify("StopRandomFade" + hud);
            self.RainbowType[hudname] = undefined;
            self.hudopen[hudname] = undefined;
            return;
        }
        else
        {
            self iPrintLnBold("^1Error^7: Rainbow Already Active for this HUD");
            if(self.RainbowType[hudname] == "Random Dark Fade" || self.RainbowType[hudname] == "Random Light Fade" || self.RainbowType[hudname] == "Random Normal Fade")
                self iPrintLnBold("^5" + self.RainbowType[hudname] + "^7 Active. Turn it off first");
            else
                self iPrintLnBold("Deactivate the other effect first");
            return;
        }
    }

    if(isLUI(hud))
    {
        self endon("StopRandomFade" + hud);
        self.RainbowType[hudname] = "Random Normal Fade";
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        defTime = time;
        while (true)
        {
            if(!isDefined(defTime))
            {
                time = randomIntRange(4, 10);
            }
            red = randomFloatRange(0, 1);        // Componente rojo oscuro aleatorio
            green = randomFloatRange(0, 1);      // Componente verde oscuro aleatorio
            blue = randomFloatRange(0, 1);       // Componente azul oscuro aleatorio
            color = (Float(red), Float(green), Float(blue));
            self LuiColorFade(hud, color, time, hudname);
            wait 0.01;
        }
    }
    else
    {
        self endon("StopRandomFade" + hudname);
        self.RainbowType[hudname] = "Random Normal Fade";
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        defTime = time;
        while (true)
        {
            if(!isDefined(defTime))
            {
                time = randomIntRange(4, 10);
            }
            red = randomFloatRange(0, 1);        // Componente rojo oscuro aleatorio
            green = randomFloatRange(0, 1);      // Componente verde oscuro aleatorio
            blue = randomFloatRange(0, 1);       // Componente azul oscuro aleatorio
            color = (Float(red), Float(green), Float(blue));
            hud fadeToColor(color, time, hudname);
            wait 0.01;
        }
    }
}

RandomLightFade(hud, time, hudname)     //  LUI Needs to be created before this is called!
{
    if(isDefined(self.RainbowType[hudname]) && isDefined(self.hudopen[hudname]))
    {
        if(self.RainbowType[hudname] == "Random Light Fade")
        {
            if(isLUI(hud))
                self notify("StopRandomLightFade" + hud);
            else
                self notify("StopRandomLightFade" + hudname);
            self.RainbowType[hudname] = undefined;
            self.hudopen[hudname] = undefined;
            return;
        }
        else
        {
            self iPrintLnBold("^1Error^7: Rainbow Already Active for this HUD");
            if(self.RainbowType[hudname] == "Random Dark Fade" || self.RainbowType[hudname] == "Random Light Fade" || self.RainbowType[hudname] == "Random Normal Fade")
                self iPrintLnBold("^5" + self.RainbowType[hudname] + "^7 Active. Turn it off first");
            else
                self iPrintLnBold("Deactivate the other effect first");
            return;
        }
    }

    if(isLUI(hud))
    {
        self endon("StopRandomLightFade" + hud);
        self.RainbowType[hudname] = "Random Light Fade";
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        defTime = time;
        while (true)
        {
            if(!isDefined(defTime))
            {
                time = randomIntRange(4, 10);
            }
            red = randomFloatRange(0.7, 1);        // Componente rojo oscuro aleatorio
            green = randomFloatRange(0.7, 1);      // Componente verde oscuro aleatorio
            blue = randomFloatRange(0.7, 1);       // Componente azul oscuro aleatorio
            color = (Float(red), Float(green), Float(blue));
            self LuiColorFade(hud, color, time, hudname);
            wait 0.01;
        }
    }
    else
    {
        self endon("StopRandomLightFade" + hudname);
        self.RainbowType[hudname] = "Random Light Fade";
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        defTime = time;
        while (true)
        {
            if(!isDefined(defTime))
            {
                time = randomIntRange(4, 10);
            }
            red = randomFloatRange(0.7, 1);        // Componente rojo oscuro aleatorio
            green = randomFloatRange(0.7, 1);      // Componente verde oscuro aleatorio
            blue = randomFloatRange(0.7, 1);       // Componente azul oscuro aleatorio
            color = (Float(red), Float(green), Float(blue));
            hud fadeToColor(color, time, hudname);
            wait 0.01;
        }
    }
}

RandomDarkFade(hud, time, hudname)     //  LUI Needs to be created before this is called!
{
    if(isDefined(self.RainbowType[hudname]) && isDefined(self.hudopen[hudname]))
    {
        if(self.RainbowType[hudname] == "Random Dark Fade")
        {
            if(isLUI(hud))
                self notify("StopRandomDarkFade" + hud);
            else
                self notify("StopRandomDarkFade" + hudname);
            self.RainbowType[hudname] = undefined;
            self.hudopen[hudname] = undefined;
            return;
        }
        else
        {
            self iPrintLnBold("^1Error^7: Rainbow Already Active for this HUD");
            if(self.RainbowType[hudname] == "Random Dark Fade" || self.RainbowType[hudname] == "Random Light Fade" || self.RainbowType[hudname] == "Random Normal Fade")
                self iPrintLnBold("^5" + self.RainbowType[hudname] + "^7 Active. Turn it off first");
            else
                self iPrintLnBold("Deactivate the other effect first");
            return;
        }
    }

    if(isLUI(hud))
    {
        self endon("StopRandomDarkFade" + hud);
        self.RainbowType[hudname] = "Random Dark Fade";
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        defTime = time;
        while (true)
        {
            if(!isDefined(defTime))
            {
                time = randomIntRange(4, 10);
            }
            red = randomFloatRange(0.1, 0.4);        // Componente rojo oscuro aleatorio
            green = randomFloatRange(0.1, 0.4);      // Componente verde oscuro aleatorio
            blue = randomFloatRange(0.1, 0.4);       // Componente azul oscuro aleatorio
            color = (Float(red), Float(green), Float(blue));
            self LuiColorFade(hud, color, time, hudname);
            wait 0.01;
        }
    }
    else
    {
        self endon("StopRandomDarkFade" + hudname);
        self.RainbowType[hudname] = "Random Dark Fade";
        self.hudcolor[hudname] = undefined;
        self.hudopen[hudname] = true;

        defTime = time;
        // hud fadeToColor((0.3, 0.2, 0.2), 0.3);
        while (true)
        {
            if(!isDefined(defTime))
            {
                time = randomIntRange(4, 10);
            }
            red = randomFloatRange(0.1, 0.4);        // Componente rojo oscuro aleatorio
            green = randomFloatRange(0.1, 0.4);      // Componente verde oscuro aleatorio
            blue = randomFloatRange(0.1, 0.4);       // Componente azul oscuro aleatorio
            color = (Float(red), Float(green), Float(blue));
            hud fadeToColor(color, time, hudname); // Rojo Oscuro
            wait 0.01;
        }
    }
}

DoRandomRainbow(case, hud, time, hudname)
{
    switch(case)
    {
        case "Normal":
            self thread RandomFade(hud, time, hudname);
        break;

        case "Light":
            self thread RandomLightFade(hud, time, hudname);
        break;
        
        case "Dark":
            self thread RandomDarkFade(hud, time, hudname);
        break;

        default:
            return self iPrintLnBold("Undefined");
        break;
    }
}

SetMenuMaxOpts(value)
{
    if(value != self.menu["MaxOpts"])
        self.menu["MaxOpts"] = value;
    else
        return self iPrintLnBold("Value is already applied");

    huds = ["BoolBack", "BoolOpt", "BoolText", "ValSlider", "OptSlider", "MenuIndicator", "Options"];
    for(a = 0; a < huds.size; a++)
    {
        self destroyAll(self.menu["hud"][huds[a]]);
        self.menu["hud"][huds[a]] = [];
    }

    self thread SetMenuText();
    self thread DoBackgroundSize();
    self thread DrawText();

    self iPrintLnBold("Max options: ^5" + value);

}

SetCustomShader(shader, none)
{
    if(isDefined(none))
    {
        self.defaultlui_alpha = 0;
        self SetLUIMenuData(self.menu["hud"]["LUI_Shad"], "alpha", int(self.defaultlui_alpha));
        self SetLUIMenuData(self.menu["hud"]["LUI_Shad2"], "alpha", int(self.defaultlui_alpha));
        self SetLUIMenuData(self.menu["hud"]["lui_test"], "alpha", int(self.defaultlui_alpha));
        self.menu["hud"]["rect_test"] DestroyHud();
    }
    else
    {
        if(self.defaultlui_alpha == 0)
        {
            self.defaultlui_alpha = 1;
            self SetLUIMenuData(self.menu["hud"]["LUI_Shad"], "alpha", int(self.defaultlui_alpha));
            self SetLUIMenuData(self.menu["hud"]["LUI_Shad2"], "alpha", int(self.defaultlui_alpha));
            if(!isDefined(self.menu["hud"]["lui_test"]))
            {
                self.menu["hud"]["lui_test"] = LUI_createRectangle( 1, 500, 49, 250, 100, (1, 1, 1), shader, 1, 0);
            }
            self SetLUIMenuData(self.menu["hud"]["lui_test"], "alpha", int(self.defaultlui_alpha));
        }
        self SetLUIMenuData(self.menu["hud"]["LUI_Shad"], "material", shader);
        self SetLUIMenuData(self.menu["hud"]["LUI_Shad2"], "material", shader);
        if(!isDefined(self.menu["hud"]["lui_test"]))
        {
            self.menu["hud"]["lui_test"] = LUI_createRectangle( 1, 500, 49, 250, 100, (1, 1, 1), shader, 1, 0);
        }
        self SetLUIMenuData(self.menu["hud"]["lui_test"], "material", shader);

        self.menu["hud"]["rect_test"] DestroyHud();
        self.menu["hud"]["rect_test"] = createRectangle("CENTER", "CENTER", 200, 170, 50, 50, (1, 1, 1), 0, 1, shader);
        self.shader["LUI_Shad"] = shader;
        self.shader["LUI_Shad2"] = shader;
    }
    wait 0.15;     
}

DoShaderRotation()
{
    self.menu["ShaderRotation"] = isDefined(self.menu["ShaderRotation"]) ? undefined : true;

    self thread SetShaderRotationAnim(self.menu["hud"]["LUI_Shad"]);
    self thread SetShaderRotationAnim(self.menu["hud"]["LUI_Shad2"]);
}

SetShaderRotationAnim(hud, close)
{
    self endon("disconnect");
    self endon("StopShaderRotation" + hud);
    
    if(!isDefined(self.menu["ShaderRotation"]) || isDefined(close))
    {
        self SetLUIMenuData(hud, "zRot", 0);
        self notify("StopShaderRotation" + hud);
    }

    while(isDefined(self.menu["ShaderRotation"]))
    {
        self SetLUIMenuData(hud, "zRot", 0);
        self LuiRotateOverTime(hud, 90, 2);
        self LuiRotateOverTime(hud, 180, 2);
        self LuiRotateOverTime(hud, 270, 2);
        self LuiRotateOverTime(hud, 360, 2);
        // wait 0.001;
    }
}

SetHeaderVision()
{
    self.header_vision = isDefined(self.header_vision) ? undefined : true;
    SHADER = "shader";
    HEAD = "LUI_Head";
    HEAD2 = "LUI_Head2";
    COLOR = "color";
    
    if(isDefined(self.header_vision))
    {
        self notify("StopLUIDarkRainbow" + self.menu["hud"][HEAD2]);
        self notify("StopLUIRainbow" + self.menu["hud"][HEAD2]);

        self SetLuiMenuData(self.menu["hud"][HEAD], "alpha", 0);
        self.hudalpha[HEAD] = 0;
        self SetLuiMenuData(self.menu["hud"][HEAD2], "material", "generic_filter_candy_yellow");
        self.shader[HEAD2] = "generic_filter_candy_yellow";
        // self SetLuiMenuData(self.menu["hud"][HEAD2], "x", 965);
        // self.LUIx[HEAD2] = 965;
        // self SetLuiMenuData(self.menu["hud"][HEAD2], "width", 300);
        // self.LUIWidth[HEAD2] = 300;
        self thread ChangeHUDColor(self.menu["hud"][HEAD2], (1, 1, 1), HEAD2);
    }
    else
    {
        self SetLuiMenuData(self.menu["hud"][HEAD], "alpha", 0.8);
        self.hudalpha[HEAD] = 0.8;
        self SetLuiMenuData(self.menu["hud"][HEAD2], "material", "gradient_fadein");
        self.shader[HEAD2] = "gradient_fadein";
        // self SetLuiMenuData(self.menu["hud"][HEAD2], "x", 970);
        // self.LUIx[HEAD2] = 965;
        // self SetLuiMenuData(self.menu["hud"][HEAD2], "width", 295);
        // self.LUIWidth[HEAD2] = 300;
        self thread LuiColorFade(self.menu["hud"][HEAD2], self.menu[COLOR]["LUI_Head2"], 1, HEAD2);
        self iPrintLnBold(color);
    }
}

SetBoolIconStyle(type)
{
    if(self.menu["BoolStyle"] != "Checks")
        return self iPrintLnBold("Activate Checks style first");
    
    if(type == "Box")
        self.menu["BoolIcon"] = "white";
    else if(type == "Arrow")
        self.menu["BoolIcon"] = "objpoint_default";
    else if(type == "Inst Kill")
        self.menu["BoolIcon"] = "specialty_instakill_zombies";
    else if(type == "Dob Points")
        self.menu["BoolIcon"] = "specialty_doublepoints_zombies";
    else if(type == "Fire Sale")
        self.menu["BoolIcon"] = "specialty_firesale_zombies";
    else if(type == "Mask")
        self.menu["BoolIcon"] = "damage_feedback_tac";
    else if(type == "Scavenger")
        self.menu["BoolIcon"] = "hud_scavenger_pickup";
    else if(type == "Armor")
        self.menu["BoolIcon"] = "damage_feedback_armor";
    else if(type == "Other")
        self.menu["BoolIcon"] = "t7_hud_prompt_press_64";
    else
        return self iPrintLnBold("Undefined");
    
    self ScrollingSystem();
}

SetBoolStyle(type)
{
    if(type == self.menu["BoolStyle"])
        return self iPrintLnBold("Style already applied");
    
    if(type == "Text")
        self.menu["BoolStyle"] = "Text";
    else if(type == "Checks")
        self.menu["BoolStyle"] = "Checks";
    else
        return self iPrintLnBold("Undefined");
    
    self ScrollingSystem();
}

SetBoolColors(color, type)
{
    if(type == "Outline")
        tempBool = "BoolBack";
    else if(type == "Inside")
        tempBool = "BoolOpt";
    else
        return self iPrintLnBold("Undefined");

    if(self.menu["BoolStyle"] != "Checks")
        return self iPrintLnBold("^1Error: ^7Set Checks Style First");
    
    for(i = 0; i < level.colorNames.size; i++)
    {
        if(color == level.colorNames[i] && color != "Random Color" && self.boolColor[tempBool] != level.colors[i])
        {
            tempColor = dividecolor(level.colors[i][0], level.colors[i][1], level.colors[i][2]);
            self.boolColor[tempBool] = tempColor;
            self ScrollingSystem();
        }
        else if(color == level.colorNames[i] && color == "Random Color")
        {
            randColor = self RandomColor(true);
            self.boolColor[tempBool] = randColor;
            self ScrollingSystem();
        }
        else if(color == level.colorNames[i] && self.boolColor[tempBool] == level.colors[i] && color != "Random Color")
            self iPrintLnBold("Color is already applied");
    }
}

SetFadeDelay(value, hudname)
{
    self.fadeDelay[hudname] = value;
    self iPrintLnBold("Value will take effect next time you set a Fade Style");
}

SetBackgroundOpacity(value)
{
    self.menu["hud"]["Background"] thread hudFade(value, 0.5);
    self.hudalpha["Background"] = value;
}

SetTitleOpacity(value)
{
    self.menu["hud"]["MenuTitle"] thread hudFade(value, 0.5);
    self.hudalpha["MenuTitle"] = value;
}

SetHeaderOpacity(value)
{
    self thread LuiFade(self.menu["hud"]["LUI_Head"], value, 0.5);
    self thread LuiFade(self.menu["hud"]["LUI_Head2"], value, 0.5);
    self.hudalpha["LUI_Head"] = value;
    self.hudalpha["LUI_Head2"] = value;
}

// SetMenuBlur(value)
// {
//     self SetBlur(isDefined(self.menu["MenuBlur"]) ? self.menu["MenuBlurValue"] : 0, 0.1);
// }