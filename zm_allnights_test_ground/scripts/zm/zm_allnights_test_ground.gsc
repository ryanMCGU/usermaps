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
#using scripts\zm\_zm_perks;

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

//Mine
#using scripts\zm\_zm_fuse_doors;
#using scripts\zm\_zm_perk_fuse;
#using scripts\zm\_zm_locker_rewards;
#using scripts\zm\_zm_fuse_mystery_box;
#using scripts\zm\_zm_powerup_fuse;
#using scripts\zm\_zm_weap_bo1bouncingbetty;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	zm_usermap::main();
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	level.perk_purchase_limit = 4;
	level.player_starting_points = 500000;
	zm_perks::spare_change();
	array::thread_all(GetEntArray("audio_bump_trigger", "targetname"), &zm_perks::thread_bump_trigger);
	level.dog_rounds_allowed = false;

	free_fuse();
	handleFuse("free_pick_up_fuse_trig", "free_pick_up_fuse_model");
}

function handleFuse(fuse_trig, fuse_model) {
    trig = GetEnt(fuse_trig, "targetname");

    trig thread handleFuseTrig(fuse_model);
}

function handleFuseTrig(fuse_model) {
    level endon("end_game");

    self SetCursorHint( "HINT_NOICON" );
	self SetHintString("");

    self waittill( "trigger", player );

    level notify ("global_fuse_obtained");

	self PlaySound("zmb_craftable_pickup"); 

    self Delete();

    fuse = GetEnt(fuse_model, "targetname");
    fuse Delete();
}

function usermap_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function free_fuse() {
	trigs = GetEntArray("free_fuse_trig", "targetname");

    foreach(trig in trigs) {
        trig thread handleFreeFuse();
    }
}

function handleFreeFuse() {
	level endon("end_game");

	self SetCursorHint( "HINT_NOICON" );
	self SetHintString("Hold ^3[{+activate}]^7 for free fuse");

	for (;;) {
		self waittill( "trigger", player );

		level thread zm_powerups::specific_powerup_drop( "fuse", player.origin );
	}
}