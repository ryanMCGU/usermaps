#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_electric_cherry;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

#using scripts\zm\zm_flamethrower;

#using scripts\zm\perks\_zm_perk_phdflopper;

#using scripts\zm\_zm_t4_hud;

#using scripts\zm\zm_perk_poster_challenge;

#using scripts\zm\zm_secret_door;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	level.dog_rounds_allowed = false;
	zm_usermap::main();

	level thread zm_waw_vox();
	callback::on_connect(&zm_waw_vox_reloads);

	// Stielhandgranate
	zm_utility::register_lethal_grenade_for_level( "frag_grenade_potato_masher" );
	level.zombie_lethal_grenade_player_init = GetWeapon( "frag_grenade_potato_masher" );

	//Change Last Stand Weapon
	level.default_laststandpistol = getWeapon("t5_m1911");
	level.default_solo_laststandpistol = getWeapon("t5_m1911_rdw_up");

	//Monitor Power
	level thread MonitorPower();
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Change Starting Weapon
	level.start_weapon = (getWeapon("t5_m1911"));

 	level.perk_purchase_limit = 4;
	
	level.player_starting_points = 500;

	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;
	level.zombie_powerup_weapon[ "minigun" ] = GetWeapon( "t5_minigun" );
	zm_flamethrower::init();
}

function usermap_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );

	zm_zonemgr::add_adjacent_zone("start_zone", "topfloor_north", "start_zone_topfloor_north");
	
	zm_zonemgr::add_adjacent_zone("topfloor_north", "stairs_north", "topfloor_north_stairs_north");
	zm_zonemgr::add_adjacent_zone("topfloor_north", "firstfloor_east", "topfloor_north_firstfloor_east");
	
	zm_zonemgr::add_adjacent_zone("stairs_north", "start_zone", "stairs_north_start_zone");
	zm_zonemgr::add_adjacent_zone("stairs_north", "topfloor_north", "stairs_north_topfloor_north");
	zm_zonemgr::add_adjacent_zone("stairs_north", "secondfloor_west", "stairs_north_secondfloor_west");
	zm_zonemgr::add_adjacent_zone("stairs_north", "secondfloor_east", "stairs_north_secondfloor_east");

	zm_zonemgr::add_adjacent_zone("firstfloor_east", "secondfloor_west", "firstfloor_east_secondfloor_west");
	zm_zonemgr::add_adjacent_zone("firstfloor_east", "topfloor_north", "firstfloor_east_topfloor_north");
	zm_zonemgr::add_adjacent_zone("firstfloor_east", "tunnel", "enter_tunnel");
	zm_zonemgr::add_adjacent_zone("firstfloor_east", "trenchout", "firstfloor_east_trenchout");
	
	zm_zonemgr::add_adjacent_zone("secondfloor_west", "firstfloor_east", "secondfloor_west_firstfloor_east");
	zm_zonemgr::add_adjacent_zone("secondfloor_west", "stairs_north", "secondfloor_west_stairs_north");

	zm_zonemgr::add_adjacent_zone("secondfloor_east", "stairs_north", "secondfloor_east_stairs_north");
	zm_zonemgr::add_adjacent_zone("secondfloor_east", "topfloor_north", "secondfloor_east_topfloor_north");
	zm_zonemgr::add_adjacent_zone("secondfloor_east", "power", "secondfloor_east_power");

	zm_zonemgr::add_adjacent_zone("tunnel", "pap", "enter_pap");

	zm_zonemgr::add_adjacent_zone("power", "secondfloor_east", "power_secondfloor_east");
	zm_zonemgr::add_adjacent_zone("power", "trenchout", "power_trenchout");

	zm_zonemgr::add_adjacent_zone("trenchout", "power", "trenchout_power");
	zm_zonemgr::add_adjacent_zone("trenchout", "firstfloor_east", "trenchout_firstfloor_east");
	zm_zonemgr::add_adjacent_zone("trenchout", "trenchin", "enter_trenchin");

	zm_zonemgr::add_adjacent_zone("trenchin", "trenchout", "enter_trenchout");
	


	zm_zonemgr::add_adjacent_zone("topfloor_north", "topfloor_north2", "start_topfloor_north2");	
	zm_zonemgr::add_zone_flags("start_zone_topfloor_north","start_topfloor_north2");	

	zm_zonemgr::add_adjacent_zone("stairs_north", "stairs_north2", "start_stairs_north2");
	zm_zonemgr::add_zone_flags("topfloor_north_stairs_north","start_stairs_north2");
	zm_zonemgr::add_zone_flags("secondfloor_west_stairs_north","start_stairs_north2");
	zm_zonemgr::add_zone_flags("secondfloor_east_stairs_north","start_stairs_north2");

	zm_zonemgr::add_adjacent_zone("firstfloor_east", "firstfloor_east2", "start_firstfloor_east2");
	zm_zonemgr::add_zone_flags("topfloor_north_firstfloor_east", "start_firstfloor_east2");
	zm_zonemgr::add_zone_flags("secondfloor_west_firstfloor_east", "start_firstfloor_east2");
	zm_zonemgr::add_zone_flags("trenchout_firstfloor_east", "start_firstfloor_east2");

	zm_zonemgr::add_adjacent_zone("secondfloor_west", "secondfloor_west2", "start_secondfloor_west2");
	zm_zonemgr::add_zone_flags("stairs_north_secondfloor_west", "start_secondfloor_west2");
	zm_zonemgr::add_zone_flags("firstfloor_east_secondfloor_west", "start_secondfloor_west2");
	
	zm_zonemgr::add_adjacent_zone("power", "power2", "start_power2");
	zm_zonemgr::add_zone_flags("secondfloor_east_power", "start_power2");
	zm_zonemgr::add_zone_flags("trenchout_power", "start_power2");

	zm_zonemgr::add_adjacent_zone("trenchout", "trenchout2", "start_trenchout_others");
	zm_zonemgr::add_adjacent_zone("trenchout", "trenchout3", "start_trenchout_others");
	zm_zonemgr::add_adjacent_zone("trenchout", "trenchout4", "start_trenchout_others");
	zm_zonemgr::add_adjacent_zone("trenchout", "trenchout5", "start_trenchout_others");
	zm_zonemgr::add_adjacent_zone("trenchout", "trenchout6", "start_trenchout_others");
	zm_zonemgr::add_zone_flags("firstfloor_east_trenchout", "start_trenchout_others");
	zm_zonemgr::add_zone_flags("power_trenchout", "start_trenchout_others");

	zm_zonemgr::add_adjacent_zone("trenchin", "trenchin2", "start_trenchin_others");
	zm_zonemgr::add_adjacent_zone("trenchin", "trenchin3", "start_trenchin_others");
	zm_zonemgr::add_zone_flags("enter_trenchin", "start_trenchin_others");

}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}


function MonitorPower()
{
 level flag::wait_till("initial_blackscreen_passed");
 level util::set_lighting_state(0);

 level flag::wait_till("power_on");
 level util::set_lighting_state(1);
}

function zm_waw_vox()
{
	zm_audio::loadPlayerVoiceCategories("gamedata/audio/zm/zm_waw_vox.csv");
}

function zm_waw_vox_reloads()
{
    self endon("disconnect");

    for(;;)
    {
        if(self IsReloading())
        {
            self thread zm_audio::create_and_play_dialog("general","reload");

            while(self IsReloading())
            {
                WAIT_SERVER_FRAME;    
            }
        }

        WAIT_SERVER_FRAME;
    }
}


