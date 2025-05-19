#include scripts\codescripts\struct;

#include scripts\shared\callbacks_shared;
#include scripts\shared\clientfield_shared;
#include scripts\shared\math_shared;
#include scripts\shared\system_shared;
#include scripts\shared\util_shared;
#include scripts\shared\hud_util_shared;
#include scripts\shared\hud_message_shared;
#include scripts\shared\hud_shared;
#include scripts\shared\array_shared;
#include scripts\shared\aat_shared;
#include scripts\shared\rank_shared;
#include scripts\shared\ai\zombie_death;
#include scripts\shared\ai\zombie_utility;
#include scripts\shared\ai\zombie_shared;
#include scripts\shared\ai\systems\gib;
#include scripts\shared\tweakables_shared;
#include scripts\shared\ai\systems\shared;
#include scripts\shared\flag_shared;
#include scripts\shared\scoreevents_shared;
#include scripts\shared\lui_shared;
#include scripts\shared\scene_shared;
#include scripts\shared\vehicle_ai_shared;
#include scripts\shared\vehicle_shared;
#include scripts\shared\exploder_shared;
#include scripts\shared\ai_shared;
#include scripts\shared\doors_shared;
#include scripts\shared\gameskill_shared;
#include scripts\shared\laststand_shared;
#include scripts\shared\spawner_shared;
#include scripts\shared\visionset_mgr_shared;
#include scripts\shared\damagefeedback_shared;
#include scripts\shared\bots\_bot;
#include scripts\shared\bots\bot_buttons;
#include scripts\shared\_burnplayer;
#include scripts\shared\audio_shared;
#include scripts\shared\fx_shared;

// #include scripts\shared\_burnplayer;

#include scripts\zm\gametypes\_globallogic;
// #include scripts\zm\_fx;
#include scripts\zm\_util;
#include scripts\zm\_zm;
#include scripts\zm\_zm_behavior;
#include scripts\zm\_zm_bgb;
#include scripts\zm\_zm_score;
#include scripts\zm\_zm_stats;
#include scripts\zm\_zm_weapons;
#include scripts\zm\_zm_perks;
#include scripts\zm\_zm_equipment;
#include scripts\zm\_zm_utility;
#include scripts\zm\_zm_blockers;
#include scripts\zm\craftables\_zm_craftables;
#include scripts\zm\_zm_powerups;
#include scripts\zm\_zm_audio;
#include scripts\zm\_zm_spawner;
#include scripts\zm\_zm_magicbox;
#include scripts\zm\_zm_unitrigger;
#include scripts\zm\_zm_net;
#include scripts\zm\_zm_laststand;
#include scripts\zm\gametypes\_globallogic_audio;

#include scripts\zm\_zm_lightning_chain;
// #include scripts\zm\_zm_weap_thundergun;
#include scripts\shared\music_shared;

// #include scripts\zm\aats\_zm_aat_blast_furnace;
// #include scripts\zm\_zm_pers_upgrades;
// #include scripts\zm\_zm_pers_upgrades_functions;
// #include scripts\zm\_zm_pers_upgrades_system;

#namespace duplicate_render;

//required
autoexec __init__system__()
{
    system::register("duplicate_render", ::__init__, undefined, undefined);
}

//required
__init__()
{
    callback::on_start_gametype(::init);
	callback::on_connect(::on_player_connect);
	callback::on_spawned(::on_player_spawned);
}

init()
{
    // level.default_laststandpistol = getweapon("ray_gun");
	// level.default_solo_laststandpistol = getweapon("ray_gun");
	// level.super_ee_weapon = getweapon("ray_gun");
    
    level.menuName = "Silverlines";
    level.menuVersion = " Beta 1.1";

    level.menuStatus = ["None", "Verified", "VIP", "Admin", "Co-Host", "Host"];

    level.hud_names = ["Shader Left", "Shader Right", "Header Left", "Header Right", "Scrollbar", "Top Bar", "Bottom Bar"];
    level.huds = ["LUI_Shad", "LUI_Shad2", "LUI_Head", "LUI_Head2", "Scrollbar", "TopBar", "BottomBar"];

    //Music
    for(i = 0; i < 99; i++)
        level.musicNames[tableLookup("gamedata/tables/common/music_player.csv", 0, i, 1)] = tableLookup("gamedata/tables/common/music_player.csv", 0, i, 2);

    level.musicNames = mergeSortByValue(level.musicNames);
    
    //Camos
    level.camosCustom = [15, 16, 17, 64, 66, 68, 75, 76, 77, 78, 79, 81, 83, 84, 85, 86, 87, 88, 89, 119, 120, 121, 122, 123, 124, 125, 126, 133, 134, 135, 136, 137, 138, level.pack_a_punch_camo_index];

    //AATs
    level.aatNames = [];
    aatKeys = GetArrayKeys(level.aat);
    for(i = 0; i < aatKeys.size; i++)
    {
        aat = level.aat[aatKeys[i]];
        if(!isdefined(aat) || !isdefined(aat.name))
            continue;
        array::push(level.aatNames, CleanString(aat.name));
    }

    level thread LoadMenuShaders();
    level thread LoadMenuColorsnFades();

    level.overrideplayerdamage = ::override_player_damage;
}

on_player_connect()
{
}

on_player_spawned()
{
    self endon("disconnect");
    self endon("spawned_player");
	
    level flag::wait_till("initial_blackscreen_passed");

    if(self.hasspawned && isDefined(self.respawnCalled))
        return;
    self.respawnCalled = true;      //  Spawn gets called twice after death & Respawn. This Fixes those multiple calls
    
    self thread DeathMonitor();     //  To Prevent Menu Issues - Also check for double on spawn called

    if(isDefined(self.menu["Instructions"]) && self getVerification() > 0 && isDefined(self.firstSpawnPassed))
        self thread MenuInstructions();
    
    if(isDefined(self.firstSpawnPassed))    //  Double return check for other player Setups
        return;
    
    self thread playerSetup();
}

MainMonitor()
{
    self endon("disconnect");
    self endon("death");
    self endon("MonitorEnd");

    self waittill("player_revived");    //  Waits until you get Revived. The rest of the code will execute once you Revive (Someone Revives you).

    if(self.sessionstate != "spectator" && self.sessionstate != "intermission")
    {
        wait 1; //  To ensure there is time to set the DeathMonitor
        self thread DeathMonitor();
    }
}

DeathMonitor()
{
    for(;;)
    {
        self endon("disconnect");
        self endon("MonitorEnd");
        self endon("player_revived");   //  Ends when you get revived

        self waittill("player_downed"); //  Waits until you get downed. The rest of the code will execute once you Go Down.

        self thread MainMonitor();      //  Recursively calls for DeathMonitor if you get Revived.

        while(true)
        {
            if(self.bleedout_time <= 0)
            {
                if(self isInMenu())
                    self thread CloseMenu();
                break;
            }
            if(self.bleedout_time <= 1 && self.bleedout_time > 0)
            {
                if(self isInMenu())
                    self thread CloseMenu();     
                break;
            }
            wait 0.1;
        }
        
        // level waittill("bleed_out", self.characterindex);
        self.respawnCalled = undefined;

        if(isDefined(self.menu["Instructions"]))
            self DeleteInstructions();
            // self.menu["Instructions"] = true;   //  Because it gets reset when hud deleted

        // self iPrintLnBold("^3Exit");
        self notify("MonitorEnd");
    }
}

playerSetup()
{
    self.firstSpawnPassed = true;
    self thread defineVariables();

    if(self getName() == "X Y Constant")
        self.devMode = true;
    
    if(self isHost())
    {
        level thread LoadCustomArrays();
        self.menu["Verification"] = level.menuStatus[(level.menuStatus.size - 1)];
        wait 3;
        if(!isDefined(self.devMode))
            self WelcomeMessage();
        else
            self iPrintLnBold("Dev Mode Active. Welcome Back ^3" + CleanName(self getName()));

        if(isDefined(self.menu["Instructions"]))
            self thread MenuInstructions();
            
        self SetAccess(true, self);
    }
    else
    {
        self.menu["Verification"] = level.menuStatus[0];
        self SetAccess(undefined, self);
    }
}

defineVariables()
{
    if(isDefined(self.DefinedVariables))
        return;
    self.DefinedVariables = true;
    
    if(!isDefined(self.menu))
        self.menu = [];
    
    if(!isDefined(self.menu["hud"]))
        self.menu["hud"] = [];
    
    if(!isDefined(self.previousMenu))
        self.prevmenu = [];

    if(!isDefined(self.hud_count))
        self.hud_count = 0;
    
    //Menu Design Variables
    self thread LoadMenuVars();
    // self thread LoadConstants();
}

LoadMenuColorsnFades()
{
    // level.colorNames = ["Light Blue", "Raspberry", "Skyblue", "Pink", "Green", "Brown", "Blue", "Red", "Orange", "Purple", "Cyan", "Yellow", "Black", "White", "Random Color"];
    // level.colors = [(0, 110, 255), (135, 38, 87), (135, 206, 250), (255, 110, 255), (0, 255, 0), (101, 67, 33), (0, 0, 255), (255, 0, 0), (255, 128, 0), (100, 0, 255), (0, 255, 255), (255, 255, 0), (0, 0, 0), (255, 255, 255), "Random"];

    level.colorNames = ["Magenta", "Teal", "Emerald Green", "Laurel", "Sky Blue", "Aquamarine", "Lime", "Gold", "Indigo", "Maroon", "Turquoise", "Coral", "Olive", "Sapphire", "Orchid", "Amber", "Gray", "White Smoke", "Black", "Random Color"];
    level.colors = [(255, 0, 255), (0, 128, 128), (0, 135, 51), (110, 131, 110), (131, 200, 234), (12, 154, 103), (0, 255, 0), (255, 215, 0), (75, 0, 130), (128, 0, 0), (64, 224, 208), (255, 127, 80), (128, 128, 0), (15, 82, 186), (218, 112, 214), (255, 191, 0), (128, 128, 128), (245, 245, 245), (0, 0, 0), "Random"];
}

LoadMenuShaders()
{
    level.shaderLists = ["Ranks", "Sights", "Icons", "Huds", "Various"];

    level.shader_Ranks = ["menu_zm_rank_1", "menu_zm_rank_2", "menu_zm_rank_3", "menu_zm_rank_3_ded", "menu_zm_rank_4", "menu_zm_rank_4_ded", "menu_zm_rank_5", "menu_zm_rank_5_ded", "rank_2ndlt_128", "rank_bgen_128", "rank_col_128", "rank_com_128", "rank_cpl_128", "rank_cpt_128", "rank_gen_128", "rank_gysgt_128", "rank_lcpl_128", "rank_lt_128", "rank_ltcol_128", "rank_ltgen_128", "rank_maj_128", "rank_majgen_128", "rank_mgysgt_128", "rank_msgt_128", "rank_pfc_128", "rank_prestige01_128", "rank_prestige02_128", "rank_prestige03_128", "rank_prestige04_128", "rank_prestige05_128", "rank_prestige06_128", "rank_prestige07_128", "rank_prestige08_128", "rank_prestige09_128", "rank_prestige10_128", "rank_prestige11_128", "rank_prestige12_128", "rank_prestige13_128", "rank_prestige14_128", "rank_prestige15_128", "rank_sgt_128", "rank_ssgt_128"];
    level.shader_Sights = ["acog_0", "acog_1", "acog_10", "acog_11", "acog_12", "acog_13", "acog_14", "acog_15", "acog_16", "acog_17", "acog_18", "acog_19", "acog_2", "acog_20", "acog_21", "acog_22", "acog_23", "acog_24", "acog_25", "acog_26", "acog_27", "acog_28", "acog_29", "acog_3", "acog_30", "acog_31", "acog_32", "acog_33", "acog_34", "acog_35", "acog_36", "acog_37", "acog_38", "acog_39", "acog_4", "acog_40", "acog_5", "acog_6", "acog_7", "acog_8", "acog_9", "dualoptic_0", "dualoptic_1", "dualoptic_10", "dualoptic_11", "dualoptic_12", "dualoptic_13", "dualoptic_14", "dualoptic_15", "dualoptic_16", "dualoptic_17", "dualoptic_18", "dualoptic_19", "dualoptic_2", "dualoptic_20", "dualoptic_21", "dualoptic_22", "dualoptic_23", "dualoptic_24", "dualoptic_25", "dualoptic_26", "dualoptic_27", "dualoptic_28", "dualoptic_29", "dualoptic_3", "dualoptic_30", "dualoptic_31", "dualoptic_32", "dualoptic_33", "dualoptic_34", "dualoptic_35", "dualoptic_36", "dualoptic_37", "dualoptic_38", "dualoptic_39", "dualoptic_4", "dualoptic_40", "dualoptic_5", "dualoptic_6", "dualoptic_7", "dualoptic_8", "dualoptic_9", "ir_0", "ir_1", "ir_10", "ir_11", "ir_12", "ir_13", "ir_14", "ir_15", "ir_16", "ir_17", "ir_2", "ir_24", "ir_25", "ir_26", "ir_27", "ir_28", "ir_29", "ir_3", "ir_30", "ir_31", "ir_32", "ir_33", "ir_4", "ir_5", "ir_6", "ir_7", "ir_8", "ir_9", "mtl_weapon_acog_lens_green", "mtl_weapon_acog_lens_orange", "mtl_weapon_acog_lens_red", "mtl_weapon_acog_lens_yellow", "reflex_0", "reflex_1", "reflex_10", "reflex_11", "reflex_12", "reflex_13", "reflex_14", "reflex_15", "reflex_16", "reflex_17", "reflex_18", "reflex_19", "reflex_2", "reflex_20", "reflex_21", "reflex_22", "reflex_23", "reflex_24", "reflex_25", "reflex_26", "reflex_27", "reflex_28", "reflex_29", "reflex_3", "reflex_30", "reflex_31", "reflex_32", "reflex_33", "reflex_34", "reflex_35", "reflex_36", "reflex_37", "reflex_38", "reflex_39", "reflex_4", "reflex_40", "reflex_5", "reflex_6", "reflex_7", "reflex_8", "reflex_9"];
    level.shader_Icons = ["hudItems.perks.juggernaut", "code_warning_bandwidth", "code_warning_bandwidthlimited", "code_warning_collision", "code_warning_file", "code_warning_fps", "code_warning_gamestate", "code_warning_scripterrors", "code_warning_serverfps", "code_warning_snapshotents", "emblem_bg_nocod", "headicon_dead", "headicontalkballoon", "headiconyouinkillcam", "hud_anim_cobra", "hud_anim_littlebird", "hud_chalk_0", "hud_chalk_1", "hud_chalk_2", "hud_chalk_3", "hud_chalk_4", "hud_chalk_5", "hud_dpad_blood", "hud_explosive_arrow_icon", "hud_grenadeicon", "hud_grenadepointer", "hud_grenadethrowback", "hud_grenadethrowback_glow", "hud_horizontal_compass_blackcell", "hud_horizontal_compass_minimap_t7", "hud_icon_stuck_semtex", "hud_lui_arrow_global", "hud_lui_dpad_circle", "hud_obit_crate", "hud_obit_death_crush", "hud_obit_death_falling", "hud_obit_death_grenade_round", "hud_obit_death_suicide", "hud_obit_exploding_barrel", "hud_obit_exploding_car", "hud_obit_hk_drone", "hud_obit_knife", "hud_obit_weapon_butt", "hud_objective_circle_meter", "hud_objective_rcbomb", "hud_offscreenobjectivepointer", "hud_scavenger_pickup", "hud_shoutcasting_notify_a", "hud_shoutcasting_notify_arrow", "hud_shoutcasting_notify_b", "hud_shoutcasting_notify_bomb", "hud_shoutcasting_notify_c", "hud_shoutcasting_notify_flag", "hud_shoutcasting_notify_hq", "hud_shoutcasting_notify_kc", "hud_spectating_change_tab_zm", "hud_spectating_viewing_box_dead_zm", "hud_status_connecting", "hud_status_dead", "killiconheadshot", "lagometer", "light_corona", "livestream_cam", "lui_loader", "lui_loader_32", "luts_t7_default", "map_directional_selector", "map_mortar_selector", "map_mortar_selector_done", "masked_minimap", "menu_livestream_signal", "menu_livestream_tower", "menu_lobby_icon_facebook", "menu_lobby_icon_twitter", "menu_mp_lobby_scrollbar_block", "menu_mp_lobby_scrollbar_main", "menu_mp_party_ease_icon", "menu_mp_popup", "menu_mp_popup_bottom", "menu_mp_popup_stretch", "menu_mp_popup_top", "menu_mp_star_rating", "menu_mp_star_rating_empty", "menu_mp_toomany_backing", "menu_mp_weapon_lvl_star", "menu_number_zero", "menu_registered_symbol", "menu_zm_cac_backing", "menu_zm_gamertag", "menu_zm_popup", "mpflag_spectator", "mtl_t6_attach_bcpu_ui3d_background", "mtl_t6_attach_optic_rangefinder_ui3d_background", "mtl_t6_wpn_briefcase_bomb_progress_background", "mtl_t6_wpn_launch_fhj18_ui3d_background", "mtl_t6_wpn_pda_ui3d_background", "mtl_t6_wpn_tac_insert_screen_background", "mtl_weapon_camo_packapunch_diffuse", "mtl_weapon_camo_packapunch_env", "mtl_weapon_camo_packapunch_specular", "net_new_animation", "nottalkingicon", "objpoint_default", "ping_bar_01", "ping_bar_02", "ping_bar_03", "ping_bar_04", "playlist_arena_champions", "playlist_arena_moshpit", "playlist_arena_popular", "playlist_ball", "playlist_bonus", "playlist_core", "playlist_ctf", "playlist_custom", "playlist_demolition", "playlist_domination", "playlist_escort", "playlist_ffa", "playlist_generic_01", "playlist_generic_02", "playlist_generic_03", "playlist_generic_04", "playlist_generic_05", "playlist_groundwar", "playlist_gungame", "playlist_gungame_promo", "playlist_hardcore", "playlist_headquarters", "playlist_infantry", "playlist_infect", "playlist_kill_confirm", "playlist_koth", "playlist_map", "playlist_mercenary", "playlist_prop_hunt", "playlist_search_destroy", "playlist_sniper_only", "playlist_sticks_and_stones", "playlist_tdm", "playlist_war", "playlist_zsurvival", "remotemissile_target", "seven_segment", "specialty_doublepoints_zombies", "specialty_firesale_zombies", "specialty_instakill_zombies", "spinner_wedge", "statmon_warning_tris", "t7_codcaster_icon_team01", "t7_codcaster_icon_team02", "t7_codcaster_icon_team03", "t7_codcaster_icon_team04", "t7_codcaster_icon_team05", "t7_cp_hud_obj_defend", "t7_cp_hud_obj_destroy", "t7_cp_hud_obj_goto", "t7_cp_hud_obj_interact", "t7_hud_icon_menu_siegebot_kf", "t7_hud_ks_c54i_drop", "t7_hud_ks_drone_amws_drop", "t7_hud_ks_rolling_thunder_drop", "t7_hud_ks_wpn_turret_drop", "t7_hud_minimap_friendly_arrow", "t7_hud_minimap_raps", "t7_hud_prompt_press_64", "t7_hud_zm_aat_bgb", "t7_hud_zm_aat_blastfurnace", "t7_hud_zm_aat_deadwire", "t7_hud_zm_aat_fireworks", "t7_hud_zm_aat_thunderwall", "t7_hud_zm_aat_turned", "t7_hud_zm_powerup_giant_deathmachine", "t7_menu_frontend_contextual_purchase", "t7_menu_unlock_token", "t7_menu_unlock_token_cp", "talkingicon", "uie_t7_hud_zm_distill", "uie_t7_hud_zm_vial_aar_256", "uie_t7_icon_blackmarket_cryptokey", "uie_t7_icon_official_customgame", "voice_off", "voice_off_mute_xboxlive", "voice_off_xboxlive", "voice_on", "voice_on_dim", "voice_on_xboxlive"];
    level.shader_Huds = ["compass_combat_robot_top", "compass_cuav", "compass_hk", "compass_lodestar", "compass_map_color_overlay", "compass_map_color_overlay2", "compass_map_color_underlay", "compass_map_color_underlay2", "compass_map_flicker", "compass_objpoint_helicopter", "compass_qrdrone", "compass_radarline", "compass_supply_drop_black", "compass_supply_drop_green", "compass_supply_drop_red", "compass_supply_drop_white", "compass_talon", "compass_talon_top", "compass_turret_white", "compass_vtol", "compass_waypoint_bomb", "compass_waypoint_capture", "compass_waypoint_capture_a", "compass_waypoint_capture_b", "compass_waypoint_capture_c", "compass_waypoint_captureneutral", "compass_waypoint_captureneutral_a", "compass_waypoint_captureneutral_b", "compass_waypoint_captureneutral_c", "compass_waypoint_contested", "compass_waypoint_defend", "compass_waypoint_defend_a", "compass_waypoint_defend_b", "compass_waypoint_defend_c", "compass_waypoint_defuse", "compass_waypoint_defuse_a", "compass_waypoint_defuse_b", "compass_waypoint_kill", "compass_waypoint_target", "compass_waypoint_target_b", "compass_waypoint_targetneutral", "compassping_blank_mp", "compassping_blankfiring_mp", "compassping_enemy", "compassping_enemy_diamond_bottom", "compassping_enemydirectional", "compassping_enemyfiring", "compassping_enemysatellite", "compassping_enemysatellite_diamond", "compassping_enemysmoke", "compassping_enemyyelling", "compassping_firstplace", "compassping_friendly_mp", "compassping_friendlyfiring_mp", "compassping_friendlysmoke", "compassping_friendlyyelling_mp", "compassping_player", "compassping_player_bracket", "compassping_playerfiring_mp_shoutcast", "compassping_pulse", "compassping_pulse_thin", "compassping_squad_fire_mp", "compassping_squad_mp", "compassping_squadyelling_mp", "hud_horizontal_compass_blackcell", "hud_horizontal_compass_minimap_t7", "t7_hud_waypoint_quad_tank_targeting_icon", "t7_hud_waypoints_bomb_new_mini", "t7_hud_waypoints_capture_new_a_mini", "t7_hud_waypoints_capture_new_b_mini", "t7_hud_waypoints_capture_new_c_mini", "t7_hud_waypoints_capture_new_flag_mini", "t7_hud_waypoints_capture_new_mini", "t7_hud_waypoints_defend_new_a_mini", "t7_hud_waypoints_defend_new_b_mini", "t7_hud_waypoints_defend_new_c_mini", "t7_hud_waypoints_defend_new_flag_mini", "t7_hud_waypoints_defend_new_mini", "t7_hud_waypoints_neutral_koth_mini", "t7_hud_waypoints_neutral_new_a_mini", "t7_hud_waypoints_neutral_new_b_mini", "t7_hud_waypoints_neutral_new_c_mini", "t7_hud_waypoints_neutral_new_mini", "t7_hud_waypoints_uplink_grab_mini", "t7_hud_waypoints_uplink_uplink_mini", "waypoint_circle_arrow", "waypoint_circle_arrow_green", "waypoint_circle_arrow_red", "waypoint_circle_arrow_yellow", "waypoint_contested", "waypoint_dogtags", "waypoint_flag_capture", "waypoint_flag_grab", "waypoint_flag_yellow", "waypoint_recon_artillery_strike", "waypoint_return", "waypoint_revive", "waypoint_revive_zm"];
    // level.shader_Various = ["ammowidget_arrow", "button_left_mouse", "button_middle_mouse", "button_right_mouse", "cac_restricted", "cycle_button_left", "cycle_button_right", "damage_feedback", "damage_feedback_armor", "damage_feedback_flak", "damage_feedback_glow", "damage_feedback_glow_blue", "damage_feedback_glow_orange", "damage_feedback_tac", "damage_feedbacktag", "demo_backing", "demo_button_outline", "demo_forward_fast", "demo_forward_slow", "demo_pause", "demo_play", "demo_step", "demo_stop", "demo_timeline_arrow", "demo_timeline_bookmark", "demo_timeline_faded", "demo_timeline_solid", "depth_clear", "directional_damage_feedback", "gradient_center", "gradient_fadein", "graphline", "hint_mantle", "hint_mantle_glow", "hit_direction_glow", "hit_direction_hexless", "hit_direction_zm", "html_cursor", "hud_icon_stuck_semtex", "hud_lui_arrow_global", "hud_lui_dpad_circle", "hud_obit_crate", "hud_obit_death_crush", "hud_obit_death_falling", "hud_obit_death_grenade_round", "hud_obit_death_suicide", "hud_obit_exploding_barrel", "hud_obit_exploding_car", "hud_obit_hk_drone", "hud_obit_knife", "hud_obit_weapon_butt", "hud_objective_circle_meter", "hud_objective_rcbomb", "hud_offscreenobjectivepointer", "hud_scavenger_pickup", "hud_shoutcasting_notify_a", "hud_shoutcasting_notify_arrow", "hud_shoutcasting_notify_b", "hud_shoutcasting_notify_bomb", "hud_shoutcasting_notify_c", "hud_shoutcasting_notify_flag", "hud_shoutcasting_notify_hq", "hud_shoutcasting_notify_kc", "hud_spectating_change_tab_zm", "hud_spectating_viewing_box_dead_zm", "hud_status_connecting", "lui_bottomshadow", "lui_leftshadow", "lui_rightshadow", "lui_topshadow", "menu_livestream_hollow_circle", "menu_livestream_hollow_fill", "menu_mp_lobby_frame_line", "menu_mp_lobby_scrollbar_block", "menu_mp_lobby_scrollbar_main", "menu_mp_party_ease_icon", "menu_mp_popup", "menu_mp_popup_bottom", "menu_mp_popup_stretch", "menu_mp_popup_top", "menu_mp_star_rating", "menu_mp_star_rating_empty", "menu_mp_star_rating_half", "mouse_anim_d", "mouse_anim_l", "mouse_anim_r", "mouse_anim_u", "mouse_click", "mouse_edit", "mpflag_spectator", "objective_arrow", "objective_line", "offscreen_arrow", "overlay_low_health", "overlay_low_health_splat", "progress_bar_bg", "progress_bar_fg", "progress_bar_fill", "ps3button_circle", "ps3button_dpad_all", "ps3button_dpad_down", "ps3button_dpad_left", "ps3button_dpad_right", "ps3button_dpad_rl", "ps3button_dpad_ud", "ps3button_dpad_up", "ps3button_l1", "ps3button_l2", "ps3button_l3", "ps3button_r1", "ps3button_r2", "ps3button_r3", "ps3button_select", "ps3button_square", "ps3button_start", "ps3button_triangle", "ps3button_x", "ps4_controller_top", "remotemissile_target", "score_bar_bg", "scorebar_zom_1", "spinner_wedge", "statmon_warning_tris", "t7_codcaster_icon_team01", "t7_codcaster_icon_team02", "t7_codcaster_icon_team03", "t7_codcaster_icon_team04", "t7_codcaster_icon_team05", "ui_add", "ui_arrow_left", "ui_arrow_right", "ui_button_ps3_lstick_anim_d", "ui_button_ps3_lstick_anim_l", "ui_button_ps3_lstick_anim_r", "ui_button_ps3_lstick_anim_u", "ui_button_ps3_rstick_anim_d", "ui_button_ps3_rstick_anim_l", "ui_button_ps3_rstick_anim_r", "ui_button_ps3_rstick_anim_u", "ui_button_ps3_stick_animated_32_ldown", "ui_button_ps3_stick_animated_32_rdown", "ui_button_ps3_stick_ls_32", "ui_button_ps3_stick_rs_32", "ui_button_xenon_lstick_anim_d", "ui_button_xenon_lstick_anim_l", "ui_button_xenon_lstick_anim_r", "ui_button_xenon_lstick_anim_u", "ui_button_xenon_rstick_anim_d", "ui_button_xenon_rstick_anim_l", "ui_button_xenon_rstick_anim_r", "ui_button_xenon_rstick_anim_u", "ui_button_xenon_stick_ani_32_ldown", "ui_button_xenon_stick_ani_32_rdown", "ui_cursor", "ui_host", "ui_line", "ui_line_graph", "ui_multiply", "ui_multiplyinverse", "ui_normal", "ui_scrollbar_arrow_left", "ui_scrollbar_arrow_right", "ui_skin_black", "ui_skin_green", "ui_skin_tan", "ui_skin_white", "uie_aar_segment", "uie_bow_launcher_reticle", "uie_clock_add", "uie_clock_multiply", "uie_clock_normal", "uie_comms_radial_distortion", "uie_digital_noise", "uie_ekg", "uie_elliptical_ring", "uie_emp", "uie_expensive_blur", "uie_feather_add", "uie_feather_blend", "uie_feather_edges", "uie_feather_multiply", "uie_flipbook", "uie_flipbook_add", "uie_flipbook_animated", "uie_fractal", "uie_fractal_reveal_grid", "uie_fractal_string_reveal", "uie_gaussian", "uie_gradient", "uie_mosaic", "uie_mosaic_scene", "uie_nineslice_add", "uie_nineslice_normal", "uie_pixel_tear", "uie_rocket_launcher_lockon", "uie_saturation_normal", "uie_scanlines", "uie_scanlines_add", "uie_scene_blur_pass_1", "uie_scene_blur_pass_1_nineslice", "uie_scene_blur_pass_2", "uie_scene_blur_pass_2_highquality", "uie_slice", "uie_smoke", "uie_t7_hud_zm_distill", "uie_t7_hud_zm_vial_aar_256", "uie_t7_icon_blackmarket_cryptokey", "uie_t7_icon_official_customgame", "uie_tile_scroll", "uie_tile_scroll_animated", "uie_tile_scroll_normal", "uie_ui_codpoints_symbol_32x32", "uie_wipe", "uie_wipe_delta", "uie_wipe_delta_normal", "uie_wipe_normal", "wheel_down_mouse", "wheel_up_mouse", "xenon_controller_top", "xenon_stick_move", "xenon_stick_move_look", "xenon_stick_move_turn", "xenon_stick_turn", "xenonbutton_a", "xenonbutton_b", "xenonbutton_back", "xenonbutton_dpad_all", "xenonbutton_dpad_down", "xenonbutton_dpad_left", "xenonbutton_dpad_right", "xenonbutton_dpad_rl", "xenonbutton_dpad_ud", "xenonbutton_dpad_up", "xenonbutton_lb", "xenonbutton_ls", "xenonbutton_lt", "xenonbutton_rb", "xenonbutton_rs", "xenonbutton_rt", "xenonbutton_start", "xenonbutton_x", "xenonbutton_y"];
    
    //  Bidimensional array
    level.cShadersBiArray = [];
    level.cShadersBiArray[0] = level.shader_Ranks;
    level.cShadersBiArray[1] = level.shader_Sights;
    level.cShadersBiArray[2] = level.shader_Icons;
    level.cShadersBiArray[3] = level.shader_Huds;
    level.cShadersBiArray[4] = level.shader_Various;
}

LoadCustomArrays()
{
    foreach(DeathBarrier in GetEntArray("trigger_hurt", "classname"))
        DeathBarrier delete();
    
    level.mapNames = ["zm_zod", "zm_factory", "zm_castle", "zm_island", "zm_stalingrad", "zm_genesis", "zm_prototype", "zm_asylum", "zm_sumpf", "zm_theater", "zm_cosmodrome", "zm_temple", "zm_moon", "zm_tomb"];
    
    level.MenuCharacterNames = ["Dempsey", "Nikolai", "Richtofen", "Takeo", "Shadows of Evil Beast", "Floyd Campbell", "Jack Vincent", "Jessica Rose", "Nero Blackstone"];
    
    level.MapSpawnPoints = ArrayCombine(struct::get_array("player_respawn_point_arena", "targetname"), struct::get_array("player_respawn_point", "targetname"), 0, 1);
    
    level.MenuEffects = [];
    effects = GetArrayKeys(level._effect);

    for(a = 0; a < effects.size; a++)
    {
        if(!isDefined(effects[a]))
            continue;

        if(isInArray(level.MenuEffects, effects[a]))
            continue;
        
        level.MenuEffects[a] = SpawnStruct();

        level.MenuEffects[a].name = effects[a];
        level.MenuEffects[a].displayName = CleanString(effects[a]);
    }
    
    level.CustomPerks = [];
    perks = GetArrayKeys(level._custom_perks);

    for(a = 0; a < perks.size; a++)
        array::add(level.CustomPerks, perks[a], 0);
    
    level.CustomBGB = [];
    bgb = GetArrayKeys(level.bgb);

    for(a = 0; a < bgb.size; a++)
        array::add(level.CustomBGB, bgb[a], 0);
    // level array::alphabetize(level.CustomBGB);
    level.CustomBGB = mergeSortByValue(level.CustomBGB);

    level.PhdFlopperGrenade = getweapon("frag_grenade_slaughter_slide");
}

WelcomeMessage()
{
    if(isDefined(self.welcomeDisplaying))
        return;

    self.welcomeDisplaying = true;

    welcome = [];
    welcome[welcome.size] = self LUI_createRectangle( 0, 450, 50, 1, 1, (0, 0, 0), "white", 0, 0);
    welcome[welcome.size] = self LUI_createRectangle( 0, 450, 50, 1, 1, (0.2, 0.2, 0.2), "white", 0, 0);
    welcome[welcome.size] = self LUI_createRectangle( 0, 460, 57, 60, 60, (1, 1, 1), "acog_11", 0, 0);
    self thread RandomFade(welcome[0], 2, "welcome");

    // createText(font, fontSize, sort, text, align, relative, x, y, alpha, color)
    welcome_text = [];
    string = "Hello " + CleanName(self getName()) + " :)";
    string += "\nWelcome to Silverlines!";
    welcome_text[welcome_text.size] = createText("objective", 1.7, 0, string, "TOPCENTER", "TOPCENTER", 30, 40, 0, (1, 1, 1));

    //  BLACK BOX
    self thread LuiFade(welcome[1], 0.8, 0.5);
    self LuiScaleOverTime(welcome[1], 5, 80, 0.5);
    self LuiWidthOverTime(welcome[1], 80, 0.5);
    //  ICON
    self thread LuiFade(welcome[2], 0.8, 0.5);
    //  TEXT CONTAINER
    self thread LuiFade(welcome[0], 0.8, 0.5);
    self LuiScaleOverTime(welcome[0], 80, 80, 0.1);
    self LuiWidthOverTime(welcome[0], 400, 0.5);

    //  TEXT
    welcome_text[0] hudFade(1, 0.5);
    wait 3;
    welcome_text[0] hudFade(0, 0.5);
    string = "Developed by XY Constant <3";
    string += "\nEnjoy the menu!";
    welcome_text[0] setText(string);
    welcome_text[0] hudFade(1, 0.5);
    wait 3;
    welcome_text[0] hudFade(0, 0.5);

    // HUDS AND TEXT DESTROY
    welcome_text[0] thread hudFadenDestroy(0, 0.5);
    self thread RandomFade(welcome[0], 2, "welcome");
    self LuiWidthOverTime(welcome[0], 80, 0.5);
    for(i = 0; i < welcome.size; i++)
        self thread CloseLUIMenuAfterFade(welcome[i], 0, ((i == 0) ? 0.3 : 1));
    
    welcome = undefined;
    welcome_text = undefined;
    wait 2;
    self.welcomeDisplaying = undefined;
}
