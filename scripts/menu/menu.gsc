SelectPlayer()
{
    foreach(player in level.players)
        if(isDefined(self.selected_player) && player == self.selected_player)
            return player;
    return self;
}

RunMenu()
{
    self endon("disconnect");

    player = self SelectPlayer();
    menu = CleanMenuName(self getCurrentMenu());

    weapons = ["Assault Rifles", "Sub Machine Guns", "Light Machine Guns", "Sniper Rifles", "Shotguns", "Pistols", "Launchers", "Specials", "Knifes"];
    weaponsVar = ["assault", "smg", "lmg", "sniper", "cqb", "pistol", "launcher", "special", "knife"];
    weaponAttachTypes = ["Optic", "Rig", "Mod"]; //gamedata\weapons\common\attachmenttable.csv
    
    switch(menu)
    {
        case "Main":
            self addMenu("Main", "Main Menu");
                if(self getVerification() > 0)  //  Verified
                {
                    self addOpt("Basic Scripts", ::newMenu, "Basic Scripts " + player GetEntityNumber());
                }
                if(self getVerification() > 1)  //  VIP
                {
                    self addOpt("Gameplay", ::newMenu, "Gameplay " + player GetEntityNumber());
                    self addOpt("Powerup Menu", ::newMenu, "Powerup Menu " + player GetEntityNumber());
                    self addOpt("Weapons", ::newMenu, "Weapons " + player GetEntityNumber());
                    self addOpt("Fun Scripts", ::newMenu, "Fun Scripts " + player GetEntityNumber());
                }
                if(self getVerification() > 2)  //  Admin
                {
                    self addOpt("Fx Menu", ::newMenu, "Fx Menu");
                    self addOpt("Players Menu", ::newMenu, "Players Menu");
                }
                if(self getVerification() > 3)  //  Co-Host
                {
                    self addOpt("Server", ::newMenu, "Server Options");
                }
                if(self IsHost())               //  Host
                {
                    self addOpt("Bot Menu", ::newMenu, "Bot Menu");
                    self addOpt("Host Menu", ::newMenu, "Host Menu");
                }
                self addOpt("Menu Customization", ::newMenu, "Menu Customization");
            break;
        
        case "Basic Scripts":
            self addMenu("Basic Scripts " + player GetEntityNumber(), "Basic Scripts");
                self addOptBool(player.godmode, "God Mode", ::Godmode, player);
                self addOptBool(player.DemiGod, "Demi God", ::DemiGod, player);
                self addOptBool(player.NoTarget, "No Target", ::NoTarget, player);
                self addOpt("Perk Menu", ::newMenu, "Perk Menu");
                self addOpt("Custom Perks", ::newMenu, "Custom Perks");
                self addOpt("Gobblegum Menu", ::newMenu, "GobbleGum Menu");
                self addOptSlider("Unlimited Ammo", ::InfiniteAmmo, "Non-Stop;Reload;Disable", "Disable", player);
                self addOptBool(player.permagrenade, "Unlimited Equipment", ::PermaGrenade, player);
                self addOptSlider("Modify Score", ::ModifyScore, "-1000000;-100000;-10000;-1000;-500;-100;0;100;500;1000;10000;100000;1000000;", "0", player);
                self addOptBool(player.Noclip, "No Clip", ::Noclip, player);
                self addOptBool(player.NoclipBind, "Bind No Clip To [{+actionslot 2}]", ::BindNoclip, player);
                self addOptBool(player.UFOMode, "UFO Mode", ::UFOMode, player);
                self addOptBool(player.AutoRevive, "Auto Revive", ::PlayerAutoRevive, player);
                if(self getVerification() > 1)
                    self addOpt("Respawn", ::PlayerRespawn, player);
                self addOpt("Revive", ::PlayerRevive, player);
                self addOpt("Down", ::PlayerDeath, "Down", player);
                self addOpt("Suicide", ::PlayerDeath, "Kill", player);
            break;

        case "Perk Menu":
            self addMenu("Perk Menu", "Perks");
                self addOptBool(player.keepPerks, "Keep Perks On Death", ::Keep_Perks, player);
                if(isDefined(level.CustomPerks) && level.CustomPerks.size)
                {
                    self addOptBool((player.perks_active.size == level.CustomPerks.size), "Give All Perks", ::GiveAllPerks, player);
                    for(a = 0; a < level.CustomPerks.size; a++)
                    {
                        perkname = ReturnPerkName(CleanString(level.CustomPerks[a]));
                        if(perkname == "Unknown Perk")
                            perkname = CleanString(level.CustomPerks[a]);
                        self addOptBool((player HasPerk(level.CustomPerks[a]) || player zm_perks::has_perk_paused(level.CustomPerks[a])), perkname, ::GivePerk, level.CustomPerks[a], player);
                    }
                }
            break;

        case "Custom Perks":
            self addMenu("Custom Perks", "Custom Perks");
                self addOptBool(isDefined(player.PhdFlopper) && player.PhdFlopper == "Flopper", "PhD Flopper", ::PhdFlopper, player, "Flopper");
                self addOptBool(isDefined(player.PhdFlopper) && player.PhdFlopper == "Slider", "PhD Slider", ::PhdFlopper, player, "Slider");
                self addOptBool(isDefined(player.ElectricCherry) && player.ElectricCherry == "v1", "Electric Cherry", ::ElectricCherry, player, "v1");
                // self addOptBool(isDefined(player.ElectricCherry) && player.ElectricCherry == "v2", "Electric Cherry v2", ::ElectricCherry, player, "v2");
                self addOptBool(player.AirFryer, "Air Fryer", ::AirFryer, player);
            break;

        case "GobbleGum Menu":
            self addMenu("GobbleGum Menu", "GobbleGums");
                for(a = 0; a < level.CustomBGB.size; a++)
                    self addOptBool((player.bgb == level.CustomBGB[a]), BGBName(level.CustomBGB[a]), ::GiveGobblegum, level.CustomBGB[a], player);
                    // self addOptBool((player.bgb == level.CustomBGB[a]), level.CustomBGB[a], ::GiveGobblegum, level.CustomBGB[a], player);
            break;

        case "Gameplay":
            self addMenu("Gameplay " + player GetEntityNumber(), "Gameplay");
                self addOptBool(player.ThirdPerson, "Third Person", ::ThirdPerson, player);
                self addOptBool(player.NoExplosiveDamage, "No Explosive Damage", ::ChasquiBoom, player);
                self addOptBool(player.Invisibility, "Invisibility", ::Invisibility, player);
                self addOpt("Modded Spread", ::newMenu, "Modded Spread");
                self addOptIntSlider("Movement Speed", ::SetMovementSpeed, 0, 1, 3, 0.2, player);
                self addOptBool(player.ExoSuit, "Exo Suit", ::ExoSuit, player);
                self addOptBool(player.DoubleJump, "Double Jump", ::DoubleJump, player);
                self addOpt("Edit Vision", ::newMenu, "Edit Vision");
                self addOptSlider("Zombie Charms", ::ZombieChams, "None;Orange;Green;Purple;Blue", "None", player);
                self addOptSlider("Character Model", ::SetCharacterModel, "Dempsey;Nikolai;Richtofen;Takeo;Shadows of Evil Beast;Floyd Campbell;Jack Vincent;Jessica Rose;Nero Blackstone", ReturnCharacterName(player.characterindex), player);
                self addOptBool(player.HideHud, "Hide HUD", ::HideHUD, player);
                self addOptBool(player.SprintnShoot, "Shoot While Sprinting", ::SprintnShoot, player);
                self addOptBool(player.UnlimitedSprint, "Unlimited Sprint", ::UnlimitedSprint, player);
                self addOptBool(player.HealthBar, "Health Bar", ::HealthBar, player);
                self addOptBool(player.ZombieCounter, "Zombie Counter", ::ZombieCounter, player);
            break;

        case "Modded Spread":
            self addMenu("Modded Spread", "Modded Spread");
                self addOptBool(player.NoSpread, "No Spread", ::NoSpread, player);
                self addOptIntSlider("Custom Spread", ::ModdedSpread, 0, 1, 8, 1, player);
        break;

        case "Edit Vision":
            self addMenu("Edit Vision", "Edit Vision");
                self addOptSlider("Normal Visions", ::CommonVision, "Default;LastStand;Death", "Default", player);

                if(!isDefined(player.currentVision))
                    player.currentVision = "None";
                
                foreach( type, array in level.vsmgr )
                {
                    foreach( name, struct in level.vsmgr[ type ].info )
                    {
                        vision = level.vsmgr[ type ].info[ name ];
                        if( vision.state.should_activate_per_player )
                            self addOptBool(player.currentVision == vision.name, CleanString(vision.name), ::SetVision, vision.type, vision.name, player);
                    }
                }
        break;

        case "Powerup Menu":
            self addMenu("Powerup Menu " + player GetEntityNumber(), "Powerups");
                    self addOpt("Spawn Powerup", ::newMenu, "Spawn Powerup");
            break;

        case "Spawn Powerup":
            if(!isDefined(self.PowerUpSpawnLocation))
                self.PowerUpSpawnLocation = "Crosshairs";
            powerups = GetArrayKeys(level.zombie_include_powerups);

            self addMenu("Spawn Powerup", "Spawn Powerup");
                self addOptSlider("Spawn Powerup", ::SpawnPowerUp, powerups, 0);
                self addOpt("Spawn All", ::SpawnPowerUp, "Spawn All");

                // if(isDefined(powerups) && powerups.size)
                // {
                //     for(a = 0; a < powerups.size; a++)
                //     {
                //         if(powerups[a] != "free_perk")
                //             self addOpt(CleanString(powerups[a]), ::SpawnPowerUp, powerups[a]);
                //         else
                //             self addOpt("Free Perk", ::SpawnPowerUp, powerups[a]);
                //     }
                // }
            break;

        case "Menu Customization":
            self addMenu("Menu Customization", "Menu Customization");
                self addOpt("Set Default Preset", ::SetDefaultPreset);
                self addOptIntSlider("Max Opts", ::SetMenuMaxOpts, 3, self.menu["MaxOpts"], 9, 2);
                self addOptBool(self.menu["Instructions"], "Menu Instructions", ::SetMenuInstructions);
                self addOpt("Menu Colors", ::newMenu, "Menu Colors");
                self addOpt("Header", ::newMenu, "Header");
                self addOpt("Opacity", ::newMenu, "Opacity");
                self addOpt("Shaders", ::newMenu, "Shaders");
                self addOpt("Toggle Styles", ::newMenu, "Toggle Styles");
            break;

        case "Menu Colors":
            self addMenu("Menu Colors", "Menu Colors");
                for(i = 0; i <= level.huds.size; i++)
                {
                    self addOpt(level.hud_names[i], ::newMenu, level.hud_names[i]);
                }
            break;

        case "Opacity":
            self addMenu("Opacity", "Opacity");
                self addOptIntSlider("Title Opacity", ::SetTitleOpacity, 0, self.hudalpha["MenuTitle"], 1, 0.1);
                self addOptIntSlider("Header Opacity", ::SetHeaderOpacity, 0, self.hudalpha["LUI_Head"], 1, 0.1);
                self addOptIntSlider("Background Opacity", ::SetBackgroundOpacity, 0, self.hudalpha["Background"], 1, 0.1);
            break;

        case "Header":
            self addMenu("Header", "Header");
                self addOptBool(self.header_vision, "Header Vision", ::SetHeaderVision);
            break;

        case "Shaders":
            self addMenu("Shaders", "Shaders");
                self addOptBool(self.menu["ShaderRotation"], "Shader Spinning", ::DoShaderRotation);
                for(i = 0; i < level.shaderLists.size; i++)
                {
                    self addOpt(level.shaderLists[i], ::newMenu, "Shader List " + level.shaderLists[i]);
                }
            break;

        case "Toggle Styles":
            self addMenu("Toggle Styles", "Toggle Styles");
                self addOptSlider("Toggle Style", ::SetBoolStyle, "Checks;Text", self.menu["BoolStyle"]);
                self addOptSlider("Icon Style", ::SetBoolIconStyle, "Box;Arrow;Inst Kill;Dob Points;Fire Sale;Mask;Scavenger;Armor;Other", self.menu["BoolIconName"]);
                self addOptSlider("Inside Color", ::SetBoolColors, "Magenta;Teal;Laurel;Sky Blue;Aquamarine;Lime;Gold;Indigo;Maroon;Turquoise;Coral;Olive;Sapphire;Orchid;Amber;Gray;White Smoke;Black;Random Color", undefined, "Inside");
                self addOptSlider("Outline Color", ::SetBoolColors, "Magenta;Teal;Laurel;Sky Blue;Aquamarine;Lime;Gold;Indigo;Maroon;Turquoise;Coral;Olive;Sapphire;Orchid;Amber;Gray;White Smoke;Black;Random Color", undefined, "Outline");
                self addOptBool(self.testbool, "Bool Test", ::testbool, self);
                for(i = 0; i < (self.menu_Strings[self getCurrentMenu()].size - 1); i++)
                {
                    self iPrintLnBold(self.menu_Strings[self getCurrentMenu()][i]);
                }
            break;

        case "Weapons":
            self addMenu("Weapons " + player GetEntityNumber(), "Weapons");
                self addOpt("Weapon Options", ::newMenu, "Weapon Options " + player GetEntityNumber());
                self addOpt("Equipment", ::newMenu, "Equipment " + player GetEntityNumber());
                for(i = 0; i < weapons.size; i++)
                    self addOpt(weapons[i], ::newMenu, weapons[i]);
            break;

        case "Fun Scripts":
            self addMenu("Fun Scripts " + player GetEntityNumber(), "Fun Scripts");
                self addOptBool(self.FrogJump, "Frog Jump", ::FrogJump, player);
                self addOptSlider("Clone Player", ::PlayerClone, "Clone;Dead", undefined, player);
            break;
        
        case "Fx Menu":
            self addMenu("Fx Menu", "Fx Menu");
                self addOpt("Delete All FXs", ::CustomFxPlayer, undefined, true);
                // self addOpt("");
                self addOpt("Fx List", ::newMenu, "Fx List");
                // for(a = 0; a < level.MenuEffects.size; a++)
                //     self addOpt(level.MenuEffects[a].name, ::CustomFxPlayer, level.MenuEffects[a].name);
            break;

        case "Fx List":
            self addMenu("Fx List", "Fx List");
                for(a = 0; a < level.MenuEffects.size; a++)
                    self addOpt(level.MenuEffects[a].name, ::CustomFxPlayer, level.MenuEffects[a].name);
            break;

        case "Server Options":
            self addMenu("Server Options", "Server Options");
                if(self IsHost())
                {
                    self addOptBool(level.mysteryBoxPap, "PaP Mystery Box Weapons", ::MysteryBoxPap);
                    self addOptSlider("Set Level PaP Camo", ::SetLevelPapCamo, ArrayToString(level.camosCustom), 0);
                    self addOpt("Music Menu", ::newMenu, "Music Menu");
                    self addOpt("Dvars", ::newMenu, "Dvars");
                    self addOpt("Change Map", ::newMenu, "Change Map");
                }
            break;

        case "Dvars":
            self addMenu("Dvars", "Dvars");
                self addOptBool(level.MenuExoSuits, "Allow Exo Suits", ::ToggleExoSuits);
            break;

        case "Change Map":
            self addMenu("Change Map", "Change Map");
                for(a = 0; a < level.mapNames.size; a++)
                    self addOptBool((level.script == level.mapNames[a]), ReturnMapName(level.mapNames[a]), ::ServerChangeMap, level.mapNames[a]);
            break;
        
        case "Music Menu":
            self addMenu("Music Menu", "Music Menu");
                if(isDefined(level.musicNames))
                    foreach(key, value in level.musicNames)
                        self addOpt(value, ::PlayLobbyMusic, key);
            break;
        
        case "Bot Menu":
            self addMenu("Bot Menu", "Bot Menu");
                self addOpt("Remove Bots", ::RemoveBots);
                self addOptIntSlider("Add Bots", ::AddBots, 1, 1, 3, 1);
                self addOpt("Revive Bots", ::ReviveBots);
                self addOpt( "Give All Bots Random Weapon", ::BotGiveWeapon);
                self addOpt( "PAP All Bots Weapons", ::PapBotWeapons);
                self addOptSlider("Set Bot AAT", ::GiveBotsWeaponAAT, ArrayToString(level.aatNames), 0);
                self addOptBool(level.BotAmmo, "Bot Unlimited Ammo", ::BotUnlimitedAmmo);
                self addOptBool(level.BotRevive, "Bot Revive Players", ::BotRevivePlayers);
                self addOptBool(level.BotAllPerks, "Enable Bot All Perks", ::BotsAllPerks);
                self addOptBool(level.BotGodmode, "Enable Bot Godmode", ::BotGodmode);
                self addOptBool(level.BotFollowHost, "Bot Follow Host", ::BotFollowHost);
                self addOptBool(level.BotHunt, "Bot Hunting", ::BotHunting);
                self addOptBool(level.BotDistributePoints, "Distribute Bot Points", ::BotDistributePoints);
                self addOptBool(level.BotConfigTest, "Bot Config Test", ::CustomBotConfig);
                // self addOpt("Bot Config Test", ::CustomBotConfig);
            break;

        case "Host Menu":
            self addMenu("Host Menu", "Host Menu");
                self addOptBool((GetDvarInt("migration_forceHost") == 1), "Force Host", ::ForceHost);
                self addOpt("Debug Exit", ::debugexit);
                self addOpt("Restart Game", ::RestartGame);
                self addOpt("Nuke Game (End)", ::DoNuke);
                self addOptBool((GetDvarString("ui_lobbyDebugVis") == "1"), "DevGui Info", ::DevGUIInfo);
                self addOpt("Revive", ::PlayerRevive, self);
                self addOpt("Down", ::PlayerDeath, "Down", self);
                self addOpt("Suicide", ::PlayerDeath, "Kill", self);
                self addOpt("Test Stuff", ::newMenu, "Test");
            break;

        case "Test":
            self addMenu("Test", "Test Stuff");
                self addOpt("^3Test", ::test);
                self addOpt("Test Welcome Message", ::testWelcome);
                self addOptBool(self.godmode, "God Mode", ::Godmode, self);
                self addOptBool(self.testbool, "Bool Test", ::testbool, self);
                self addOptIntSlider("Slider Int Test", ::testIntSlider, 1, 1, 5, 1);
                self addOptSlider("Slider String Test", ::testOptSlider, "Uno;Dos;Tres");
                for(i = 0; i < 3; i++)
                {
                    self addOpt("Real Option " + (i + 1));
                }
            break;

        case "Players Menu":
            self addMenu("Players Menu", "Players Menu");
                foreach(player in level.players)
                {
                    self.selected_player = undefined;
                    status = level.menuStatus[player getVerification()];
                    self addOpt("[" + verificationToColor(status) + "^7]" + CleanName(player getName()), ::newMenu, "Player Menu: " + player GetEntityNumber());
                    // self addOpt(level.players[i] + ((IsTestClient(level.players[i])) ? " (Bot)" : ""));
                }
            break;

        case "Verification":
            self addMenu("Verification " + player GetEntityNumber(), "Verification");
                for(a = 0; a < (level.menuStatus.size - 1); a++)
                    self addOptBool((player getVerification() == a), level.menuStatus[a], ::setVerification, a, player, true);
                if(player IsHost() && self IsHost())
                    self addOptBool((player getVerification() == a), level.menuStatus[level.menuStatus.size - 1], ::setVerification, 5, player, true);
            break;

        default:
            nothingToShow = true;
            newmenu = self getCurrentMenu();
            // self iPrintLnBold(newmenu);
            for(i = 0; i <= level.hud_names.size; i++)
            {
                if(level.hud_names[i] == newmenu)
                {
                    nothingToShow = false;
                    HUD = "hud";
                    self addMenu(level.hud_names[i], level.hud_names[i]);
                    self addOptIntSlider("Fade Delay (Secs)", ::SetFadeDelay, 1, self.fadeDelay[level.huds[i]], 10, 1, level.huds[i]);
                    self addOptBool(self.RainbowActive[level.huds[i]], "Rainbow Fade", ::RainbowEffect, self.menu[HUD][level.huds[i]], self.fadeDelay[level.huds[i]], level.huds[i]);
                    self addOptBool(self.DarkRainbowActive[level.huds[i]], "Dark Rainbow Fade", ::DarkRainbowEffect, self.menu[HUD][level.huds[i]], self.fadeDelay[level.huds[i]], level.huds[i]);
                    self addOptBool(self.LightRainbowActive[level.huds[i]], "Light Rainbow Fade", ::LightRainbowEffect, self.menu[HUD][level.huds[i]], self.fadeDelay[level.huds[i]], level.huds[i]);
                    self addOptSlider("Random Color Fade", ::DoRandomRainbow, "Normal;Light;Dark", undefined, self.menu[HUD][level.huds[i]], self.fadeDelay[level.huds[i]], level.huds[i]);
                    for(a = 0; a <= level.colorNames.size; a++)
                    {
                        self addOpt(level.colorNames[a], ::ChangeHUDColor, self.menu[HUD][level.huds[i]], level.colors[a], level.huds[i]);
                    }
                    if(self IsHost())
                        self addOpt("Print HUD Color", ::printHudColor, level.huds[i]);
                }
            }

            if(isSubStr(newmenu, "Shader List "))
            {
                // self iPrintLnBold("Substring found for: ^5" + newmenu);
                nothingToShow = false;
                for(i = 0; i < level.shaderLists.size; i++)
                {
                    if("Shader List " + level.shaderLists[i] == newmenu)
                    {
                        self addMenu(newmenu, level.shaderLists[i]);
                        self addOpt("No Shader", ::SetCustomShader, undefined, true);
                        currArray = level.cShadersBiArray[i];
                        for(a = 0; a < currArray.size; a++)
                        {
                            self addOpt(CleanString(currArray[a]), ::SetCustomShader, currArray[a]);
                            // self addOpt(currArray[a], ::SetCustomShader, currArray[a]);
                        }
                    }
                }
            }

            if(isSubStr(newmenu, "Player Menu: "))
            {
                nothingToShow = false;
                foreach(selPlayer in level.players)
                {
                    if(newmenu == "Player Menu: " + selPlayer GetEntityNumber())
                        RunPlayerMenu(selPlayer, newmenu);
                }
            }

            //Weapon Options
            if(isSubStr(newmenu, "Weapon Options "))
            {
                nothingToShow = false;
                self addMenu(newmenu, "Weapon Options");
                    self addOpt("PaP/Un-PaP Current Weapon", ::PackCurrentWeapon, player);
                    self addOpt("Set Random Camo", ::SetPlayerCamo, array::random(level.camosCustom), player);
                    self addOptSlider("Set AAT", ::GiveWeaponAAT, ArrayToString(level.aatNames), 0, player);
                    self addOptSlider("Set Camo", ::SetPlayerCamo, ArrayToString(level.camosCustom), 0, player);
            }
            
            //Equipment
            if(isSubStr(newmenu, "Equipment "))
            {
                nothingToShow = false;
                self addMenu(newmenu, "Equipment");
                
                equipment = [];
                
                if(isDefined(level.zombie_lethal_grenade_list) && isDefined(level.zombie_tactical_grenade_list))
                    equipment = ArrayCombine(level.zombie_lethal_grenade_list, level.zombie_tactical_grenade_list, 0, 1);
                
                // Add included equipment
                if(isDefined(level.zombie_include_equipment))
                    equipment = ArrayCombine(equipment, GetArrayKeys(level.zombie_include_equipment), 0, 1);

                if(isDefined(level.placeable_mines))
                    equipment = ArrayCombine(equipment, level.placeable_mines, 0, 1);

                if(equipment.size > 0)
                {
                    foreach(weapon in equipment)
                    {
                        // Skip upgraded variants
                        // if(IsSubStr(weapon.name, "_upgraded"))
                            // continue;
                        if(MakeLocalizedString(weapon.displayname) == "" || weapon.name == "none")
                            continue;
                        else if(weapon.name == "claymore")
                            self addOptBool( player HasWeapon(weapon), "Claymore", ::GivePlayerEquipment, weapon, player);
                        else if(isSubStr(weapon.name, "shield") && IsSubStr(weapon.name, "upgraded"))
                            self addOptBool( player HasWeapon(weapon), MakeLocalizedString(weapon.displayname) + " Upgraded", ::GivePlayerEquipment, weapon, player);
                        else if(isSubStr(weapon.name, "widow"))
                            self addOptBool( player HasWeapon(weapon), "Widows Wine Grenade", ::GivePlayerEquipment, weapon, player);
                        else if(isSubStr(weapon.name, "diesel"))
                            self addOptBool( (player HasWeapon(weapon) || isdefined(player.hasMaxisQuadrotor)), weapon.displayname, ::GivePlayerEquipment, weapon, player);
                        else
                            self addOptBool( player HasWeapon(weapon), weapon.displayname, ::GivePlayerEquipment, weapon, player);
                    }
                }
                else
                    self addOpt("No Equipment Found");
            }
            
            //Weapons
            if(IsInArray(weapons, newmenu))
            {
                pistols = ["pistol_standard", "pistol_burst", "pistol_fullauto", "pistol_m1911", "pistol_revolver38", "pistol_c96"];
                specials = [];

                foreach(index, weapon_type in weapons)
                {
                    if(newmenu == weapon_type)
                    {
                        nothingToShow = false;
                        self addMenu(newmenu, weapon_type);
                            foreach(weapon in GetArrayKeys(level.zombie_weapons))
                            {
                                // if(MakeLocalizedString(weapon.displayname) == "" || weapon.isgrenadeweapon || weapon.name == "knife" || IsSubStr(weapon.name, "upgraded") || weapon.name == "none")
                                if(MakeLocalizedString(weapon.displayname) == "" || weapon.isgrenadeweapon || (IsSubStr(weapon.name, "upgraded") && !IsSubStr(weapon.name, "staff")) || weapon.name == "none")
                                    continue;
                                else if(weapon.isequipment || weapon.isriotshield || weapon.isgrenadeweapon || zm_utility::is_placeable_mine(weapon))
                                    continue;
                                
                                // Pistols
                                if(!IsInArray(pistols, weapon.name) && !IsInArray(specials, weapon) && zm_utility::GetWeaponClassZM(weapon) == "weapon_pistol")
                                    specials[specials.size] = weapon;
                                // Every other weapon to their respective category
                                else if(zm_utility::GetWeaponClassZM(weapon) == "weapon_" + weaponsVar[index])
                                        self addOptBool(player hasWeapon2(weapon), weapon.displayname, ::givePlayerWeapon, weapon, player);
                            }
                    }
                }

                if(newmenu == "Specials")
                {
                    foreach(weapon in specials)
                    {
                        nothingToShow = false;
                        if(weapon.isgrenadeweapon || weapon.name == "knife" || weapon.name == "none")
                            continue;
                        
                        string = weapon.name;

                        if(MakeLocalizedString(weapon.displayname) != "")
                            string = weapon.displayname;
                        
                        self addOptBool(player hasWeapon2(weapon), string, ::givePlayerWeapon, weapon, player);
                    }
                    
                    self addOptBool(player hasWeapon2(GetWeapon("minigun")), "Death Machine", ::GivePlayerWeapon, GetWeapon("minigun"), player);
                    self addOptBool(player hasWeapon2(GetWeapon("defaultweapon")), "Default Weapon", ::GivePlayerWeapon, GetWeapon("defaultweapon"), player);
                }
            }

            if(nothingToShow)
            {
                self addMenu(newmenu, "No Options Found");
                    self addOpt("Nothing Here..");
            }
            break;
    }
}

RunPlayerMenu(player, menu)
{
    self.selected_player = player;  //  To be used in RunMenu
    playerMenus = ["Basic Scripts", "Gameplay", "Fun Scripts", "Weapons"];

    self addMenu(menu, CleanName(player getName()));
        if(self getVerification() >= 3)
            self addOpt("Verification", ::newMenu, "Verification" + " " + player GetEntityNumber());

        foreach(submenu in playerMenus)
            self addOpt(submenu, ::newMenu, submenu + " " + player GetEntityNumber());
        if(self IsHost() || self getVerification() >= 3)
        {
            self addOpt("Check Player Access", ::CheckPlayerAccess, player);
            self addOpt("Kick", ::KickPlayer, player);
            self addOpt("Revive", ::PlayerRevive, player);
            self addOpt("Down", ::PlayerDeath, "Down", player);
            self addOpt("Kill", ::PlayerDeath, "Kill", player);
        }
}