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

//MystifiedTulip's essentials
#using scripts\zm\mystifiedtulips_essentials;

// Sickle
#using scripts\zm\_zm_melee_weapon;

#using scripts\zm\_zm_weap_bo1bouncingbetty;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	zm_usermap::main();

	// Stielhandgranate
	zm_utility::register_lethal_grenade_for_level( "frag_grenade_potato_masher" );
	level.zombie_lethal_grenade_player_init = GetWeapon( "frag_grenade_potato_masher" );

	// Sickle
	zm_melee_weapon::init( "sickle_knife", "sickle_flourish", "knife_ballistic_sickle", "knife_ballistic_sickle_upgraded", 3000, "sickle_upgrade", "Hold ^3[{+activate}]^7 for Sickle [Cost: 3000]", "sickle", undefined );

	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;
}

function usermap_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );

	zm_zonemgr::add_adjacent_zone("top_floor_east_out", "top_floor_east", "topfloor_east_out_topfloor_east");

	zm_zonemgr::enable_zone("top_floor_east_out");

	zm_zonemgr::add_adjacent_zone("top_floor_east", "top_floor_middle", "topfloor_east_topfloor_middle");

	zm_zonemgr::add_adjacent_zone("top_floor_middle", "top_floor_west", "topfloor_middle_topfloor_west");

	zm_zonemgr::add_adjacent_zone("top_floor_west", "top_floor_west_out", "topfloor_west_topfloor_west_out");

	zm_zonemgr::add_adjacent_zone("bottom_floor_west_out", "bottom_floor_west", "bottom_floor_west_out_bottom_floor_west");

	zm_zonemgr::enable_zone("bottom_floor_west_out");

	zm_zonemgr::add_adjacent_zone("bottom_floor_west", "bottom_floor_middle", "bottom_floor_west_bottom_floor_middle");

	zm_zonemgr::add_adjacent_zone("bottom_floor_middle", "bottom_floor_east", "bottom_floor_middle_bottom_floor_east");

	zm_zonemgr::add_adjacent_zone("bottom_floor_east", "bottom_floor_east_out", "bottom_floor_east_bottom_floor_east_out");

	zm_zonemgr::add_adjacent_zone("bottom_floor_east_out", "bottom_floor_easter", "bottom_floor_east_out_bottom_floor_easter");
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}