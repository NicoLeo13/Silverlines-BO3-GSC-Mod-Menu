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

givePlayerWeapon(weapon, player)
{
    if(player hasWeapon2(weapon))
    {
        weapons = player GetWeaponsList(true);

        for(i = 0; i < weapons.size; i++)
            if(zm_weapons::get_base_weapon(weapons[i]) == zm_weapons::get_base_weapon(weapon))
                weapon = weapons[i];

        player TakeWeapon(weapon);

        return;
    }
    
    newWeapon = player zm_weapons::weapon_give(weapon, false, false, true);
    player GiveStartAmmo(newWeapon);

    // if(!IsSubStr(weapon.name, "_knife"))
    //     player SetSpawnWeapon(weapon, true);
}

GivePlayerEquipment(equipment, player)
{
    if(player HasWeapon(equipment))
        player TakeWeapon(equipment);
    else
        player zm_weapons::weapon_give(equipment, false, false, true);
}

hasWeapon2(weapon)
{
    weapons = self GetWeaponsList(true);

    for(i = 0; i < weapons.size; i++)
        if(zm_weapons::get_base_weapon(weapons[i]) == zm_weapons::get_base_weapon(weapon))
            return true;

    return false;
}

PackCurrentWeapon(player)
{
    //PaP or Un-Pap the current weapon
    newWeapon = !zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()) ? zm_weapons::get_upgrade_weapon(player GetCurrentWeapon()) : zm_weapons::get_base_weapon(player GetCurrentWeapon());
    
    player takeWeapon(player GetCurrentWeapon());
    weapon = player zm_weapons::give_build_kit_weapon(newWeapon);
    // player notify(#"weapon_give", weapon);
    player givestartammo(weapon);
    player switchtoweapon(weapon);
}

SetPlayerCamo(camo, player)
{
    if(IsString(camo))
        camo = StringToInt(camo);
    
    weap = player GetCurrentWeapon();
    weapon = player CalcWeaponOptions(camo, 0, 0);
    newWeapon = player GetBuildKitAttachmentCosmeticVariantIndexes(weap, zm_weapons::is_weapon_upgraded(player GetCurrentWeapon()));
    
    player TakeWeapon(weap);
    player GiveWeapon(weap, weapon, newWeapon);
    player SwitchToWeaponImmediate(weap);
}

GiveWeaponAAT(aat, player)
{
    if(!isSubStr(aat, "aat_") || !isSubStr(aat, "zm_"))
    {
        keys = GetArrayKeys(level.aat);

        foreach(key, value in level.aatNames)
        {
            if(aat == value)
            {
                aat = keys[key];  //Uses the key to pass the real aat
                break;
            }
        }
    }
    
    if(player.aat[player aat::get_nonalternate_weapon(player GetCurrentWeapon())] != aat)
        player aat::acquire(player GetCurrentWeapon(), aat);
    else
    {
        player aat::remove(player GetCurrentWeapon());
        player clientfield::set_to_player("aat_current", 0);
    }
}