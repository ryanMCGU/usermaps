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
#using scripts\zm\_zm_spawner;
#using scripts\zm\gametypes\_globallogic;
#using scripts\zm\gametypes\_globallogic_score;

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
#using scripts\zm\jugg_perk_ee;
#using scripts\zm\rampage_inducer;

#using scripts\zm\_zm_weap_freezegun;
#using scripts\zm\_zm_weap_thundergun;
#using scripts\zm\_zm_weap_tesla;

//Traps
#precache( "fx", "dlc0/factory/fx_elec_trap_factory" );
#precache( "fx", "maps/zombie/fx_zombie_light_glow_green" );
#precache( "fx", "maps/zombie/fx_zombie_light_glow_red" );
#precache( "fx", "fx_zombie_light_elec_room_on" );
#precache( "fx", "zombie/fx_elec_player_md_zmb" );
#precache( "fx", "zombie/fx_elec_player_sm_zmb" );
#precache( "fx", "zombie/fx_elec_player_torso_zmb" );
#precache( "fx", "electric/fx_elec_sparks_burst_sm_circuit_os" );
#precache( "fx", "electric/fx_elec_sparks_burst_sm_circuit_os" );
#precache( "fx", "zombie/fx_powerup_on_green_zmb" );
//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	level.dog_rounds_allowed = true;
	zm_usermap::main();

	//FX
	precache_fx();
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	level.perk_purchase_limit = 3;
	level.player_starting_points = 50000;
	level.start_weapon = (getWeapon("freezegun"));
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	level thread zm_utility::zombie_goto_round( 5 );

	//callback::on_connect( &player_doghits );
	//zm_spawner::register_zombie_damage_callback( &track_dog_hit_count );

	level thread start_challenge();
}

function usermap_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );

	zm_zonemgr::add_adjacent_zone("start_zone", "zone_2", "start_to_zone_2");
	zm_zonemgr::add_adjacent_zone("zone_2", "start_zone", "zone_2_to_start");

	zm_zonemgr::add_adjacent_zone("start_zone", "zone_3", "start_to_zone_3");
	zm_zonemgr::add_adjacent_zone("zone_2", "zone_3", "zone_2_to_zone_3");

	zm_zonemgr::add_adjacent_zone("zone_3", "zone_2", "zone_3_to_zone_2");
	zm_zonemgr::add_adjacent_zone("zone_3", "start_zone", "zone_3_to_start");

}	

function custom_add_weapons()
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

function start_challenge() {
	level endon("end_game");

	for( ;; ) {
		level flag::wait_till( "dog_round" );
		IPrintLnBold("Challenge Started");
		level thread accuracy_check();
		level thread check_health_passed();
		level waittill( "dog_round_ending" );
	}
}

/* function player_doghits()
{
    self endon( "disconnect" );
    for(;;) {
        level flag::wait_till( "dog_round" );
        self.shots_fired = 0;
        self.dog_hits = 0;
		level.accuracy_check_passed = false;
        while( level flag::get( "dog_round" ) ) {
            self waittill( "weapon_fired" );
            self.shots_fired++;
        }
        if( self.shots_fired == self.dog_hits ) {
            level.accuracy_check_passed = true;
        }
    }
}

function track_dog_hit_count( inflictor, attacker, damage, damageFlags, damageType, weapon, impactPoint, direction, hitLocation, offsetTime, boneIndex, modelIndex )
{
    if( self.archetype !== "zombie_dog" ) return;
    if( !isdefined( attacker )
        || !IsPlayer( attacker )
        || !IsAlive( attacker ) ) {
        return;
    }
    if( !isdefined( attacker.dog_hits ) ) {
        attacker.dog_hits = 0;
    }
    attacker.dog_hits++;
} */

function accuracy_check() {
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );

	wait 5;
	IPrintLnBold("Accuracy Challenge Started");

	players = getplayers();
    level.accuracy_check_passed = true;

    for ( i = 0; i < players.size; i++ )
    {
        //players[i].total_shots_start_dog_round = players[i] globallogic_score::getPersStat( "total_shots" );
        //players[i].total_hits_start_dog_round = players[i] globallogic_score::getPersStat( "hits" );

		players[i].total_misses_start_dog_round = players[i] globallogic_score::getPersStat( "misses" );
		IPrintLnBold("before: ",players[i] globallogic_score::getPersStat( "misses" ));

		//IPrintLnBold("before: ",players[i] globallogic_score::getPersStat( "total_shots" ) + " " + players[i] globallogic_score::getPersStat( "hits" ));
    }

    level waittill( "last_ai_down", e_last );

    players = getplayers();

    for ( i = 0; i < players.size; i++ )
    {
        //total_shots_end_dog_round = players[i] globallogic_score::getPersStat( "total_shots" ) - players[i].total_shots_start_dog_round;
        //total_hits_end_dog_round = players[i] globallogic_score::getPersStat( "hits" ) - players[i].total_hits_start_dog_round;

		total_misses_end_dog_round = players[i] globallogic_score::getPersStat( "misses" ) - players[i].total_misses_start_dog_round;
		IPrintLnBold("after: ",players[i] globallogic_score::getPersStat( "misses" ));

		//IPrintLnBold("after: ",players[i] globallogic_score::getPersStat( "total_shots" ) + " " + players[i] globallogic_score::getPersStat( "hits" ));
        //if ( total_shots_end_dog_round != total_hits_end_dog_round || total_shots_end_dog_round > total_hits_end_dog_round) {
		if ( total_misses_end_dog_round != 0) {
			level.accuracy_check_passed = false;
			IPrintLnBold("Accuracy Challenge Failed");
			break;
		}
    }

	if (level.health_passed && level.accuracy_check_passed) {
		IPrintLnBold("Challenge Passed");
		level thread drop_reward(e_last);
	}
	else {
		IPrintLnBold("Challenge Failed");
	}
}

function drop_reward(e_last) {
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );

	power_up_origin = level.last_dog_origin;
	if ( isdefined(e_last) )
	{
		power_up_origin = e_last.origin;
	}

	if( isdefined( power_up_origin ) )
	{
		level thread zm_powerups::specific_powerup_drop( "free_perk", power_up_origin );
	}
}

function check_health_passed() {
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );

	IPrintLnBold("Health Challenge Started");
	level.health_passed = true;
	level.stop_dog_challenge = true;
	level thread check_last();

	while (level.health_passed && level.stop_dog_challenge) {
		level thread check_player_health();
		wait 1;
	}
}

function check_last() {
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );

	level waittill( "last_ai_down");
	level.stop_dog_challenge = false;
}

function check_player_health() {
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );
	
    players = GetPlayers();

    foreach (player in players) {
        if (isdefined(player.maxHealth)) {
            if (player.health != player.maxHealth) {
                level.health_passed = false;
				IPrintLnBold("Health Challenge FAILED");
            }
        } else {
            if (player.health != 100) {
                level.health_passed = false;
				IPrintLnBold("Health Challenge FAILED");
            }
        }
    }
}