#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
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

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

#using scripts\zm\_zm_weap_freezegun;

#using scripts\zm\perks\_zm_perk_phdflopper;

//Trap
#precache( "client_fx", "dlc0/factory/fx_elec_trap_factory" );
#precache( "client_fx", "maps/zombie/fx_zombie_light_glow_green" );
#precache( "client_fx", "maps/zombie/fx_zombie_light_glow_red" );
#precache( "client_fx", "fx_zombie_light_elec_room_on" );
#precache( "client_fx", "zombie/fx_elec_player_md_zmb" );
#precache( "client_fx", "zombie/fx_elec_player_sm_zmb" );
#precache( "client_fx", "zombie/fx_elec_player_torso_zmb" );
#precache( "client_fx", "electric/fx_elec_sparks_burst_sm_circuit_os" );
#precache( "client_fx", "electric/fx_elec_sparks_burst_sm_circuit_os" );
#precache( "client_fx", "zombie/fx_powerup_on_green_zmb" );

function main()
{
	zm_usermap::main();

	//FX
	precache_fx();

	include_weapons();
	
	util::waitforclient( 0 );
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function precache_fx()
{
	level._effect["zapper"]				= "dlc0/factory/fx_elec_trap_factory";
	level._effect["zapper_light_ready"]		= "maps/zombie/fx_zombie_light_glow_green";
	level._effect["zapper_light_notready"]		= "maps/zombie/fx_zombie_light_glow_red";
	level._effect["elec_room_on"]			= "fx_zombie_light_elec_room_on";
	level._effect["elec_md"]			= "zombie/fx_elec_player_md_zmb";
	level._effect["elec_sm"]			= "zombie/fx_elec_player_sm_zmb";
	level._effect["elec_torso"]			= "zombie/fx_elec_player_torso_zmb";
}