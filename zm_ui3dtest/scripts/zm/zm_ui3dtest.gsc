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
#using scripts\zm\_zm_perk_tombstone;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;
#using scripts\zm\_zm_powerup_tombstone;

#using scripts\zm\_zm_weap_jetgun;
#using scripts\zm\_zm_weap_freezegun;
#using scripts\zm\_zm_weap_elemental_grenades;

//Traps
#using scripts\zm\_zm_trap_electric;

// Sickle
#using scripts\zm\_zm_melee_weapon;

//Betties
#using scripts\zm\_zm_weap_bo1bouncingbetty;

#using scripts\zm\zm_usermap;

#using scripts\zm\_zm_weap_tazer;

// Sphynx's Craftables
#using scripts\Sphynx\craftables\_zm_craft_power;
#using scripts\Sphynx\craftables\_zm_craft_pap;
#using scripts\Sphynx\craftables\_zm_craft_zombie_shield;

#precache( "fx", "dlc1/castle/fx_castle_electric_cherry_down" );
#precache( "fx", "electric/fx_elec_apt_utility_room_os" );

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	level.dog_rounds_allowed = false;

	zm_usermap::main();

	// Stielhandgranate
	zm_utility::register_lethal_grenade_for_level( "frag_grenade_potato_masher" );
	level.zombie_lethal_grenade_player_init = GetWeapon( "frag_grenade_potato_masher" );
	
	//Elemental Nades
	zm_utility::register_lethal_grenade_for_level( "tesla_nade" );
	zm_utility::register_lethal_grenade_for_level( "thunder_nade" );
	zm_utility::register_lethal_grenade_for_level( "ice_nade" );

	// Sickle
	zm_melee_weapon::init( "sickle_knife", "sickle_flourish", "knife_ballistic_sickle", "knife_ballistic_sickle_upgraded", 3000, "sickle_upgrade", "Hold ^3[{+activate}]^7 for Sickle [Cost: 3000]", "sickle", undefined );

	// Arnie Fix
	zm_utility::register_tactical_grenade_for_level( "octobomb" );

	level.perk_purchase_limit = 4;
	level.player_starting_points = 500000;
	level.start_weapon = (getWeapon("freezegun"));


	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	// Max Ammo
    callback::on_spawned( &watch_max_ammo );
	
	//power on
	level flag::set("power_on");
	level clientfield::set("zombie_power_on", 0);

	thread free_perk_vending_machine_ee();
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

function watch_max_ammo()
{
    self endon("bled_out");
    self endon("spawned_player");
    self endon("disconnect");
    for(;;)
    {
        self waittill("zmb_max_ammo");
        foreach(weapon in self GetWeaponsList(1))
        {
            if(isdefined(weapon.clipsize) && weapon.clipsize > 0)
            {
                self SetWeaponAmmoClip(weapon, weapon.clipsize);
            }
        }
    }
}

function free_perk_vending_machine_ee() {
	level endon("end_game");
	level flag::wait_till("initial_blackscreen_passed");

	level flag::wait_till("power_on");

	vending_trigger = GetEnt( "vending_easter_egg_trigger", "targetname" );
	vending_model = GetEnt( "vending_easter_egg_model", "targetname" );
	perk_spawn_location = struct::get( "vending_easter_egg_struct", "targetname" );
	button_fx = GetEntArray( "vending_easter_egg_button_fx", "targetname" );
	base_fx = GetEnt( "vending_easter_egg_base_fx", "targetname" );

	for (;;) {
		vending_trigger waittill("trigger", player);

		IPrintLn("Triggered");
		if( player IsMeleeing() && player zm_utility::get_player_melee_weapon() == GetWeapon("bowie_knife") ) {
			vending_model vibrate((0,-100,0), 0.3, 0.4, 3);
			vending_model playsound("zmb_perks_power_on");

			PlayFXOnTag( "dlc1/castle/fx_castle_electric_cherry_down", base_fx, "tag_origin" );

			foreach( struct in button_fx ) {
				PlayFXOnTag( "electric/fx_elec_apt_utility_room_os", struct, "tag_origin" );
			}

			wait 3.25;

			level thread zm_powerups::specific_powerup_drop( "free_perk", perk_spawn_location.origin );
			IPrintLn("Spawning perk");
			break;
		} else {
			IPrintLn("failed");
		}
	}

	wait 10;

	foreach( struct in button_fx ) {
		struct Delete();
	}
	base_fx Delete();
	vending_trigger Delete();
	perk_spawn_location struct::delete();
}