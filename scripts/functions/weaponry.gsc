TakeCurrentWeapon(player)
{
    weapon = player GetCurrentWeapon();

    if(weapon == level.weaponbasemelee || IsSubStr(weapon.name, "_knife"))
        return;
    
    player TakeWeapon(weapon);
}

TakeAllWeapons(player)
{
    foreach(weapon in player GetWeaponsList(1))
    {
        if(weapon == level.weaponbasemelee || IsSubStr(weapon.name, "_knife"))
            continue;
        
        player TakeWeapon(weapon);
    }
}


