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
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_tombstone;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
#using scripts\zm\_zm_powerup_tombstone;

#using scripts\zm\_zm_weap_freezegun;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

//#using scripts\zm\_zm_weap_tazer;

// Sphynx's Craftables
#using scripts\Sphynx\craftables\_zm_craft_power;
#using scripts\Sphynx\craftables\_zm_craft_pap;
#using scripts\Sphynx\craftables\_zm_craft_zombie_shield;

function main()
{
	// P-06
	LuiLoad( "ui.uieditor.widgets.Reticles.ChargeShot.ChargeShot_reticle" );
	// R70 Ajax
	LuiLoad( "ui.uieditor.widgets.Reticles.Infinite.lmgInfiniteReticle" );
	// LV8 Basilisk
	LuiLoad( "ui.uieditor.widgets.Reticles.PulseRifle.PulseRifleReticle_NumbersScreen" );
	zm_usermap::main();

	include_weapons();
	
	util::waitforclient( 0 );
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}
