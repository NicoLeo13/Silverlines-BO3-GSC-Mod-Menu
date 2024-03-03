ToggleExoSuits()
{
    level.MenuExoSuits = isDefined(level.MenuExoSuits) ? undefined : true;

    if(isDefined(level.MenuExoSuits))
    {
        setdvar("doublejump_enabled", 1);
        setdvar("playerEnergy_enabled", 1);
        setdvar("playerEnergy_maxReserve_zm", 200);
    }
    else
    {
        setdvar("doublejump_enabled", 0);
        setdvar("playerEnergy_enabled", 0);
        setdvar("playerEnergy_maxReserve_zm", 0);
    }

    foreach(player in level.players)
        if(!isDefined(player.ExoSuit))
            player AllowDoubleJump(0);
}

ServerChangeMap(map)
{
    if(!MapExists(map))
        return self iPrintlnBold("Map Doesn't Exist");
    
    if(level.script == map)
        return;
    
    Map(map);
}
