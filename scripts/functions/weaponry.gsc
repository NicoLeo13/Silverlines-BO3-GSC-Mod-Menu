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
    // TAKE WEAPON IF PLAYER HAS IT
    if(player hasWeapon2(weapon))
    {
        weapons = player GetWeaponsList(true);

        for(i = 0; i < weapons.size; i++)
            if(zm_weapons::get_base_weapon(weapons[i]) == zm_weapons::get_base_weapon(weapon))
                weapon = weapons[i];

        // If weapon is Melee
        if(zm_utility::is_melee_weapon(weapon))
        {
            // If is ballistic knife, handle it differently
            if(weapon.isballisticknife)
            {
                player takeweapon(weapon);
                return;
            }
            player takeweapon(weapon);
            player.current_melee_weapon = level.weaponbasemelee;
            player giveweapon(level.weaponbasemelee);
        }
        // Hero weapon
        else if(zm_utility::is_hero_weapon(weapon))
        {
            old_hero = player zm_utility::get_player_hero_weapon();
			if(old_hero != level.weaponnone)
                player TakeHeroWeapon(player, old_hero);
        }
        // Origin Staffs Upgraded
        else if(IsSubStr(weapon.name, "staff") && isSubStr(weapon.name, "upgraded"))
            player TakeStaffUpgraded(player, weapon);
        // Every other weapon
        else
            player TakeWeapon(weapon);
        
        return;
    }

    // GIVE WEAPON IF PLAYER DOESN'T HAVE IT
    //Melee weapons are handled differently
    if(zm_utility::is_melee_weapon(weapon))
    {
        // If player doesn't have this melee weapon, give it
        if(!weapon.isballisticknife)
        {
            current_melee_weapon = player zm_utility::get_player_melee_weapon();
            if(current_melee_weapon != level.weaponnone && current_melee_weapon != weapon)
            {
                player takeweapon(current_melee_weapon);
                player zm_utility::set_player_melee_weapon(weapon);
                player zm_weapons::weapon_give(weapon, false, false, false);
            }
        }
    }
    // Hero weapon give
    else if(zm_utility::is_hero_weapon(weapon))
    {
        old_hero = player zm_utility::get_player_hero_weapon();
        if(old_hero != level.weaponnone)
            player TakeHeroWeapon(player, old_hero);
        
        newWeapon = player zm_weapons::weapon_give(weapon, false, false, false);
        player zm_utility::set_player_hero_weapon(weapon);
        player thread [[level._hero_weapons[weapon].power_full_fn]](weapon);
        player gadgetpowerset(0, 100);
    }
    // Origin Staffs Upgraded
    else if(IsSubStr(weapon.name, "staff") && isSubStr(weapon.name, "upgraded"))
        player GiveStaffUpgraded(player, weapon);
    // Every other weapon
    else
    {
        newWeapon = player zm_weapons::weapon_give(weapon, false, false, true);
        player GiveStartAmmo(newWeapon);
    }

    // if(!IsSubStr(weapon.name, "_knife"))
    //     player SetSpawnWeapon(weapon, true);
    return;

}

TakeHeroWeapon(player, weapon)
{
    player thread [[level._hero_weapons[weapon].take_fn]](weapon);
    player zm_weapons::weapon_take(weapon);
    player zm_utility::set_player_hero_weapon(level.weaponnone);
    player gadgetpowerset(0, 0);
    // wait 0.1;
}

GiveStaffUpgraded(player, staff)
{
    player notify("watch_staff_usage");
        
    player setActionSlot(3, "weapon", level.var_2b2f83e5);
    player giveWeapon(level.var_2b2f83e5);
    player setActionSlot(3, "weapon", GetWeapon("staff_revive"));
    player clientfield::set_player_uimodel("hudItems.showDpadLeft_Staff", 1);
    
    player thread DpadAmmoCountWatch(level.var_2b2f83e5);
    
    player zm_weapons::weapon_give(staff, 0, 0, 1);
}

DpadAmmoCountWatch(weapon)
{
    self notify("hash_38af9e8e");
    self endon("hash_38af9e8e");
    self endon("hash_75edd128");
    self endon("disconnect");
    while(true)
    {
        ammo = self getAmmoCount(weapon);
        self clientfield::set_player_uimodel("hudItems.dpadLeftAmmo", ammo);
        wait(0.05);
    }
}

TakeStaffUpgraded(player, staff)
{
    player setActionSlot(3, "", 0);
    player takeWeapon(level.var_2b2f83e5);
    player setActionSlot(3, "", 0);
    player clientfield::set_player_uimodel("hudItems.showDpadLeft_Staff", 0);
    
    player zm_weapons::weapon_take(staff);
}

GivePlayerEquipment(equipment, player)
{
    // TAKE EQUIPMENT IF PLAYER HAS IT
    if(player HasWeapon(equipment))
    {
        // Placeable Mine
        if(zm_utility::is_placeable_mine(equipment) && !IsSubStr(equipment.name, "diesel"))
        {
            old_mine = player zm_utility::get_player_placeable_mine();
            if(old_mine != level.weaponnone)
                player TakeMine(player, old_mine);
        }
        // Riot Shield
        else if(equipment.isriotshield)
            player TakeRiotShield(player);
        // Maxis Drone //TODO: Review
        else if(IsSubStr(equipment.name, "drone") || IsSubStr(equipment.name, "diesel"))
            player TakeDrone(player);
        else
            player TakeWeapon(equipment);
        
        return;
    }
    
    // GIVE EQUIPMENT IF PLAYER DOESN'T HAVE IT
    // Placeable Mine give
    if(zm_utility::is_placeable_mine(equipment) && !IsSubStr(equipment.name, "diesel"))
    {
        // Take the drone if player has it and is changing to a new mine
        if(isDefined(player.hasMaxisQuadrotor) || player HasWeapon(getweapon("equip_dieseldrone")))
            player TakeDrone(player);
        
        old_mine = player zm_utility::get_player_placeable_mine();
        if(old_mine != level.weaponnone)
            player TakeMine(player, old_mine);
        
        player zm_weapons::weapon_give(equipment, false, false, false);
        player zm_utility::set_player_placeable_mine(equipment);
    }
    // Riot Shield give
    else if(equipment.isriotshield)
    {
        player zm_equipment::give(equipment);
        if(isdefined(player.player_shield_reset_health))
        {
            player [[player.player_shield_reset_health]]();
        }
    }
    // Maxis Drone //TODO: Review
    else if(IsSubStr(equipment.name, "drone") || IsSubStr(equipment.name, "diesel"))
    {
        player GiveDrone(player);
    }
    else
        player zm_weapons::weapon_give(equipment, false, false, false);
}

TakeMine(player, weapon)
{
    player zm_weapons::weapon_take(weapon);
    player zm_utility::set_player_placeable_mine(level.weaponnone);
    player setactionslot(4, "");
    if(isdefined(player.last_placeable_mine_uimodel))
        player clientfield::set_player_uimodel(player.last_placeable_mine_uimodel, 0);
    player clientfield::set_player_uimodel("hudItems.showDpadRight", 0);
}

TakeRiotShield(player)
{
    if(!player.hasriotshield)
        return;

    if(isdefined(player.weaponriotshield))
	{
		player zm_equipment::take(player.weaponriotshield);
	}
	// else
	// {
	// 	player zm_equipment::take(level.weaponriotshield);
	// }
	player.hasriotshield = 0;
	player.hasriotshieldequipped = 0;
    player setactionslot(2, "", 0);
    player clientfield::set_player_uimodel("hudItems.showDpadDown", 0);
}

TakeDrone(player)
{
    if(isDefined(player.hasMaxisQuadrotor))
    {
        player notify("drone_should_destroy");
    }
    drone = getweapon("equip_dieseldrone");
    player zm_weapons::weapon_take(drone);
    player zm_utility::set_player_placeable_mine(level.weaponnone);
    player setactionslot(4, "");
    player clientfield::set_player_uimodel("hudItems.showDpadRight_Drone", 0);
    player clientfield::set_player_uimodel("hudItems.showDpadRight", 0);
}

GiveDrone(player)
{
    // Check if player has the drone and is cooling down or is already in the air. Take it
    if(isDefined(player.hasMaxisQuadrotor) && (player HasWeapon(getweapon("equip_dieseldrone")) && !isDefined(player.hasMaxisQuadrotor)))
    {
        player notify("drone_should_destroy");
        player TakeDrone(player);
        return;
    }
    
    old_mine = player zm_utility::get_player_placeable_mine();
    if(old_mine != level.weaponnone)
    {
        player TakeMine(player, old_mine);
    }

    drone = getweapon("equip_dieseldrone");
    player zm_weapons::weapon_give(drone);
    player setweaponammoclip(drone, 1);
    player clientfield::set_player_uimodel("hudItems.showDpadRight", 0);
    player setactionslot(4, "weapon", drone);
    player clientfield::set_player_uimodel("hudItems.showDpadRight_Drone", 1);
    player notify("equip_dieseldrone_zm_given");
    player thread MaxisDroneWatcher(player);
    player zm_equipment::show_hint_text("Maxis Drone ready, press [{+actionslot 4}] to use.");
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

SetLevelPapCamo(camo)
{
    if(IsString(camo) && camo != "Default")
    {
        camo = StringToInt(camo);
        level.pack_a_punch_camo_index = camo;
    }
    else
        level.pack_a_punch_camo_index = level.mapDefaultCamoIndex;

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

MysteryBoxPap()
{
    level.mysteryBoxPap = isDefined(level.mysteryBoxPap) ? undefined : true;

    if(isdefined(level.mysteryBoxPap) && level.mysteryBoxPap) 
    {
        weapons = GetArrayKeys(level.zombie_weapons);
        foreach(weapon in weapons)
        {
            if(isDefined(weapon) && isDefined(level.zombie_weapons[weapon].is_in_box) && level.zombie_weapons[weapon].is_in_box)
            {
                upgradedWeap = level.zombie_weapons[weapon].upgrade;         
                level.customWeaponsInBox[level.customWeaponsInBox.size] = upgradedWeap;
            }
        }
        level.CustomRandomWeaponWeights = ::PutWeaponsInBox;
    }
    else
    {
        level.customWeaponsInBox = [];
        level.CustomRandomWeaponWeights = level.mysteryBoxOriginalWeights;
    }
    
}

PutWeaponsInBox()
{
    return array::randomize(level.customWeaponsInBox);
}

CanPutWeaponInBox(weapon)
{
	if(!zm_weapons::get_is_in_box(weapon))
		return 0;
}

SetMenuUpgradedWeapons(player)
{
    player.weaponsVariant = isDefined(player.weaponsVariant) ? undefined : true;

    // if(isdefined(player.weaponsVariant) && player.weaponsVariant)
    //     player.menuWeapons = ArrayCopy(level.zombie_weapons_upgraded);
    // else
    //     player.menuWeapons = ArrayCopy(level.zombie_weapons);
}