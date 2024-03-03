createText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
{
    textElem = self hud::CreateFontString(font, fontSize);

    textElem.hideWhenInMenu = true;
    textElem.archived = false;
    if( self.hud_count >= 19 ) 
        textElem.archived = true;
    textElem.foreground = true;
    textElem.player = self;

    textElem.sort = sort;
    textElem.alpha = alpha;
    textElem.color = color;

    textElem hud::SetPoint(align, relative, x, y);

    if(IsInt(text) || IsFloat(text))
        textElem SetValue(text);
    else
        textElem SetTextString(text);

    self.hud_count++;

    return textElem;
}

LUI_createText(text, align, x, y, width, color, alpha)
{    
    textElem = self OpenLUIMenu("HudElementText");

    //4 - LEFT | 1 - RIGHT | 2 - CENTER
    self SetLUIMenuData(textElem, "text", text);
    self SetLUIMenuData(textElem, "alignment", align);
    self SetLUIMenuData(textElem, "x", x);
    self SetLUIMenuData(textElem, "y", y);
    self SetLUIMenuData(textElem, "width", width);
    self SetLuiMenuData(textElem, "alpha", alpha );
    
    self SetLUIMenuData(textElem, "red", color[0]);
    self SetLUIMenuData(textElem, "green", color[1]);
    self SetLUIMenuData(textElem, "blue", color[2]);

    return textElem;
}

createServerText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
{
    textElem = hud::CreateServerFontString(font, fontSize);

    textElem.hideWhenInMenu = true;
    textElem.archived = true;
    textElem.foreground = true;

    textElem.sort = sort;
    textElem.alpha = alpha;
    textElem.color = color;

    textElem hud::SetPoint(align, relative, x, y);
    
    if(IsInt(text) || IsFloat(text))
        textElem SetValue(text);
    else
        textElem SetTextString(text);
    
    return textElem;
}

createRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
{
    uiElement = NewClientHudElem(self);
    uiElement.elemType = "bar";
    uiElement.children = [];
    
    uiElement.hideWhenInMenu = true;
    uiElement.archived = false;
    if( self.hud_count >= 19 ) 
        uiElement.archived = true;
    uiElement.foreground = true;
    uiElement.hidden = false;
    uiElement.player = self;

    uiElement.align = align;
    uiElement.relative = relative;
    uiElement.xOffset = 0;
    uiElement.yOffset = 0;
    uiElement.sort = sort;
    uiElement.color = color;
    uiElement.alpha = alpha;
    
    uiElement SetShaderValues(shader, width, height);
    uiElement hud::SetParent(level.uiParent);
    uiElement hud::SetPoint(align, relative, x, y);

    self.hud_count++;
    
    return uiElement;
}

LUI_createRectangle( alignment, x, y, width, height, rgb, shader, alpha, sort, rotation)
{
    boxElem = self OpenLUIMenu( "HudElementImage" );
    //4 - LEFT | 1 - RIGHT | 2 - CENTER
    self SetLuiMenuData( boxElem, "alignment", alignment );
    self SetLuiMenuData( boxElem, "x", x );
    self SetLuiMenuData( boxElem, "y", y );
    self SetLuiMenuData( boxElem, "width", width );
    self SetLuiMenuData( boxElem, "height", height );
    self SetLuiMenuData( boxElem, "alpha", alpha );
    self SetLuiMenuData( boxElem, "material", shader );
    self SetLuiMenuData( boxElem, "sort", sort );
    self SetLuiMenuData( boxElem, "zRot", rotation );

    self SetLUIMenuData( boxElem, "red", rgb[0] );
    self SetLUIMenuData( boxElem, "green", rgb[1] );
    self SetLUIMenuData( boxElem, "blue", rgb[2] );
    return boxElem;
}

createServerRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
{
    uiElement = NewHudElem();
    uiElement.elemType = "bar";
    uiElement.children = [];
    
    uiElement.hideWhenInMenu = false;
    uiElement.archived = true;
    uiElement.foreground = true;
    uiElement.hidden = false;

    uiElement.align = align;
    uiElement.relative = relative;
    uiElement.xOffset = 0;
    uiElement.yOffset = 0;
    uiElement.sort = sort;
    uiElement.color = color;
    uiElement.alpha = alpha;
    
    uiElement SetShaderValues(shader, width, height);
    uiElement hud::SetParent(level.uiParent);
    uiElement hud::SetPoint(align, relative, x, y);
    
    return uiElement;
}

DestroyHud()
{
    if(!isDefined(self))
        return;
    
    self destroy();

    if(isDefined(self.player))
        self.player.hud_count--;
}

SetTextString(text)
{
    if(!isDefined(self) || !isDefined(text))
        return;
    
    self.text = text;
    self SetText(text);
}

SetShaderValues(shader, width, height)
{
    if(!isDefined(shader))
    {
        if(!isDefined(self.shader))
            return;
        
        shader = self.shader;
    }
    
    if(!isDefined(width))
    {
        if(!isDefined(self.width))
            return;
        
        width = self.width;
    }
    
    if(!isDefined(height))
    {
        if(!isDefined(self.height))
            return;
        
        height = self.height;
    }
    
    self.shader = shader;
    self.width = width;
    self.height = height;

    self SetShader(shader, width, height);
}

//  Fade Options
fadeToColor(color, time, hudname)
{
    self fadeOverTime(time);
    self.color = color;
    if(isDefined(hudname))
        self.menu["color"][hudname] = color;
    self iPrintLnBold(self.menu["color"][hudname]);
    wait time;
}

hudFade(alpha, time)
{
    self FadeOverTime(time);
    self.alpha = alpha;
    wait time;
}

hudMoveY(y, time)
{
    self MoveOverTime(time);
    self.y = y;
    wait time;
}

hudMoveX(x, time)
{
    self MoveOverTime(time);
    self.x = x;
    wait time;
}

hudMoveXY(x, y, time)
{
    self MoveOverTime(time);
    self.x = x;
    self.y = y;
    wait time;
}

hudScaleOverTime(time, width, height)
{
    self ScaleOverTime(time, width, height);

    self.width = width;
    self.height = height;
    wait time;
}

hudFontScaleOverTime(fontSize, time)
{
    self ChangeFontScaleOverTime(time);

    self.fontscale = fontSize;
    wait time;
}

hudScalenDestroy(time, width, height, destroy)
{
	self ScaleOverTime(time, width, height);
	self.width = width;
	self.height = height;
	wait(time);
	if(isdefined(destroy))
	{
		wait(destroy);
		self DestroyHud();
	}
}

hudFadenDestroy(alpha, time)
{
    self hudFade(alpha, time);
    self DestroyHud();
}

divideColor(c1, c2, c3)
{
    return ((c1 / 255), (c2 / 255), (c3 / 255));
}

printHudColor(hud)
{
    if(isLUI(hud))
    {
        color = self.hudcolor[hud];
        self iPrintLnBold("RGB: " + (color[0] * 255) + ", " + (color[1] * 255) + ", " + (color[2] * 255));
    }
    else
    {
        color = self.hudcolor[hud];
        self iPrintLnBold("RGB: " + (color[0] * 255) + ", " + (color[1] * 255) + ", " + (color[2] * 255));
    }
}

//  LUI Fade Options
CloseLUIMenuAfterFade(menu, alpha, time)
{
    self thread LuiFade(menu, alpha, time);
    while(true)
    {
        if(self GetLUIMenuData(menu, "alpha") == 0)
        {
            self CloseLUIMenu(menu);
            break;
        }
        wait 0.01;
    }
}

LuiFade(menu, target_alpha, time)
{
    start_alpha = self GetLUIMenuData(menu, "alpha");
    startTime = getTime(); // Gets the current time in milliseconds

    while (true)
    {
        if (self GetLUIMenuData(menu, "alpha") == target_alpha)
            break; // Exits the loop if the total time has been reached

        currentTime = getTime(); // Gets the current time in milliseconds
        elapsed = (currentTime - startTime) / 1000.0; // Calculate the elapsed time in seconds

        t = elapsed / time; // Calculate the interpolation factor

        alpha = LerpFloat(start_alpha, target_alpha, t); // Alpha linear interpolation

        self setluimenudata(menu, "alpha", alpha);
        wait 0.01;
    }
    self setluimenudata(menu, "alpha", target_alpha); // Ensures that the alpha is set to the final value
}

LuiColorFade(menu, target_color, time, hudname)
{
    start_red = self GetLUIMenuData(menu, "red");
    start_green = self GetLUIMenuData(menu, "green");
    start_blue = self GetLUIMenuData(menu, "blue");
    start_color = (start_red, start_green, start_blue);
    startTime = getTime(); // Gets the current time in milliseconds

    while (true)
    {
        if (color == target_color || elapsed >= time)
            break; // Exits the loop if the total time has been reached

        currentTime = getTime(); // Gets the current time in milliseconds
        elapsed = (currentTime - startTime) / 1000.0; // Calculate the elapsed time in seconds

        t = elapsed / time; // Calculate the interpolation factor
        color = LerpVector(start_color, target_color, t); // linear color interpolation

        self lui::set_color(menu, color);
        wait 0.01;
    }
    if(isDefined(hudname))
        self.menu["color"][hudname] = color;
}

LuiScaleOverTime(menu, target_width, target_height, time)
{
    start_height = self GetLUIMenuData(menu, "height");
    start_width = self GetLUIMenuData(menu, "width");
    startTime = getTime(); // Gets the current time in milliseconds

    while (true)
    {
        currentTime = getTime(); // Gets the current time in milliseconds
        elapsed = (currentTime - startTime) / 1000.0; // Calculate the elapsed time in seconds

        if(self GetLUIMenuData(menu, "height") == target_height && self GetLUIMenuData(menu, "width") == target_width)
            break; // Exits the loop if condition is met

        t = elapsed / time; // Calculate the interpolation factor

        height = int(LerpFloat(start_height, target_height, t)); // Height linear interpolation
        width = int(LerpFloat(start_width, target_width, t)); // Width linear interpolation

        self setluimenudata(menu, "height", height);
        self setluimenudata(menu, "width", width);
        wait 0.05;
    }
    self setluimenudata(menu, "height", target_height); // Ensures that the height is set to the final value
    self setluimenudata(menu, "width", target_width); // Ensures that the width is set to the final value
}

LuiWidthOverTime(menu, target_width, time)
{
    start_width = self GetLUIMenuData(menu, "width");
    startTime = getTime(); // Gets the current time in milliseconds

    while (true)
    {
        currentTime = getTime(); // Gets the current time in milliseconds
        elapsed = (currentTime - startTime) / 1000.0; // Calculate the elapsed time in seconds

        if(self GetLUIMenuData(menu, "width") == target_width)
            break; // Exits the loop if condition is met

        t = elapsed / time; // Calculate the interpolation factor

        width = int(LerpFloat(start_width, target_width, t)); // Width linear interpolation

        self setluimenudata(menu, "width", width);
        wait 0.05;
    }
    self setluimenudata(menu, "width", target_width); // Ensures that the width is set to the final value
}

LuiHeightOverTime(menu, target_height, time)
{
    start_height = self GetLUIMenuData(menu, "height");
    startTime = getTime(); // Gets the current time in milliseconds

    while (true)
    {
        currentTime = getTime(); // Gets the current time in milliseconds
        elapsed = (currentTime - startTime) / 1000.0; // Calculate the elapsed time in seconds

        if(self GetLUIMenuData(menu, "height") == target_height)
            break; // Exits the loop if condition is met

        t = elapsed / time; // Calculate the interpolation factor

        height = int(LerpFloat(start_height, target_height, t)); // Height linear interpolation

        self setluimenudata(menu, "height", height);
        wait 0.05;
    }
    self setluimenudata(menu, "height", target_height); // Ensures that the height is set to the final value
}

LuiMoveOverTime(menu, target_x, target_y, time)
{
    start_x = self GetLUIMenuData(menu, "x");
    start_y = self GetLUIMenuData(menu, "y");
    startTime = getTime(); // Gets the current time in milliseconds

    while (true)
    {
        currentTime = getTime(); // Gets the current time in milliseconds
        elapsed = (currentTime - startTime) / 1000.0; // Calculate the elapsed time in seconds

        if((self GetLUIMenuData(menu, "x") == target_x) && (self GetLUIMenuData(menu, "y") == target_y))
            break; // Exits the loop if condition is met

        t = elapsed / time; // Calculate the interpolation factor

        x = int(LerpFloat(start_x, target_x, t)); // Linear interpolation of the X coordinate
        y = int(LerpFloat(start_y, target_y, t)); // Linear interpolation of the Y coordinate

        self setluimenudata(menu, "x", x);
        self setluimenudata(menu, "y", y);
        wait 0.01;
    }
    self setluimenudata(menu, "x", target_x); // Ensures that the X coordinate is set to the final value
    self setluimenudata(menu, "y", target_y); // Ensures that the Y coordinate is set to the final value
}

LuiRotateOverTime(menu, target_rot, time)
{
    start_rotation = self GetLUIMenuData(menu, "zRot");
    startTime = getTime(); // Gets the current time in milliseconds

    while (true)
    {
        currentTime = getTime(); // Gets the current time in milliseconds
        elapsed = (currentTime - startTime) / 1000.0; // Calculate the elapsed time in seconds

        if ((self GetLUIMenuData(menu, "zRot") == target_rot))
            break; // Exits the loop if condition is met

        t = elapsed / time; // Calculate the interpolation factor

        rotation = int(LerpFloat(start_rotation, target_rot, t)); // Angle of rotation linear interpolation

        self setluimenudata(menu, "zRot", rotation);
        wait 0.01;
    }
    // self setluimenudata(menu, "zRot", target_rot); // Asegura que la coordenada x se establezca en el valor final
}
