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
#using scripts\zm\_zm_perks;
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

//JetGun
#using scripts\zm\_zm_weap_jetgun;

//T6 HUD
#using scripts\zm\_zm_t6_deathanim;
#using scripts\zm\_zm_t6_hud;

#using scripts\zm\zm_usermap;

#using scripts\zm\zm_giant_cleanup_mgr;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	level._no_vending_machine_auto_collision = true;
	level.dog_rounds_allowed = false;

	zm_usermap::main();

	zm_perks::spare_change();
	
	level._zombie_custom_add_weapons =&custom_add_weapons;

	level.no_target_override = &no_target_override;
	
	//level variables 
	zombie_utility::set_zombie_var( "player_base_health", 90, false);
	level.pack_a_punch_camo_index = 0;
	level.perk_purchase_limit = 4;
	//level.player_starting_points = 500000;
	level.start_weapon = (getWeapon("t6_m1911"));
	level.default_solo_laststandpistol = getWeapon("t5_m1911_revive_rdw_up");
	level.zombie_powerup_weapon[ "minigun" ] = GetWeapon( "t5_minigun" );

	// Stielhandgranate
	zm_utility::register_lethal_grenade_for_level( "frag_grenade_potato_masher" );
	level.zombie_lethal_grenade_player_init = GetWeapon( "frag_grenade_potato_masher" );

	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	callback::on_connect( &disable_sliding );

	//Quick Revive Clip
	thread soloQuickReviveTrigger();

	//Monitor Power
	level thread MonitorPower();
}

function soloQuickReviveTrigger()
{
	level endon("end_game");
	
	level flag::wait_till("initial_blackscreen_passed");

	i = 0;
	foreach ( players in GetPlayers() ) {
		i++;
	}

	//IPrintLnBold("players: ", i);

	if (i > 1) {
		exploder::kill_exploder("quick_revive_lgts");
	}
	else if (i == 1){
		exploder::exploder("quick_revive_lgts");
	}

    level flag::wait_till("solo_revive");

    wait(4);

    qrSoloClips = GetEntArray("quickReviveSoloClip","targetname");

    foreach(clip in qrSoloClips)
    {
        clip Hide();
        clip ConnectPaths();    
    }

	exploder::kill_exploder("quick_revive_lgts");
	//level util::set_lighting_state(2);
}

function MonitorPower()
{
	level endon("end_game");

 level flag::wait_till("initial_blackscreen_passed");
 level util::set_lighting_state(0);
 exploder::stop_exploder("pap_lght");

 level flag::wait_till("power_on");
 level util::set_lighting_state(1);
 exploder::exploder("quick_revive_lgts");
 exploder::exploder("pap_lght");
}

// --------------------------------
//	NO TARGET OVERRIDE
// --------------------------------
function validate_and_set_no_target_position( position )
{
	if( IsDefined( position ) )
	{
		goal_point = GetClosestPointOnNavMesh( position.origin, 100 );
		if( IsDefined( goal_point ) )
		{
			self SetGoal( goal_point );
			self.has_exit_point = 1;
			return true;
		}
	}
	
	return false;
}

function no_target_override( zombie )
{
	if( isdefined( zombie.has_exit_point ) )
	{
		return;
	}
	
	players = level.players;
	
	dist_zombie = 0;
	dist_player = 0;
	dest = 0;

	if ( isdefined( level.zm_loc_types[ "dog_location" ] ) )
	{
		locs = array::randomize( level.zm_loc_types[ "dog_location" ] );
		
		for ( i = 0; i < locs.size; i++ )
		{
			found_point = false;
			foreach( player in players )
			{
				if( player laststand::player_is_in_laststand() )
				{
					continue;
				}
				
				away = VectorNormalize( self.origin - player.origin );
				endPos = self.origin + VectorScale( away, 600 );
				dist_zombie = DistanceSquared( locs[i].origin, endPos );
				dist_player = DistanceSquared( locs[i].origin, player.origin );
		
				if ( dist_zombie < dist_player )
				{
					dest = i;
					found_point= true;
				}
				else
				{
					found_point = false;
				}
			}
			if( found_point )
			{
				if( zombie validate_and_set_no_target_position( locs[i] ) )
				{
					return;
				}
			}
		}
	}
	
	
	escape_position = zombie giant_cleanup::get_escape_position_in_current_zone();
			
	if( zombie validate_and_set_no_target_position( escape_position ) )
	{
		return;
	}
	
	escape_position = zombie giant_cleanup::get_escape_position();
	
	if( zombie validate_and_set_no_target_position( escape_position ) )
	{
		return;
	}
	
	zombie.has_exit_point = 1;
	
	zombie SetGoal( zombie.origin );
}

// --------------------------------

function disable_sliding() {
	self endon( "disconnect" );

	level flag::wait_till("initial_blackscreen_passed");

	self AllowSlide( false );
}

function usermap_test_zone_init()
{
	zm_zonemgr::add_adjacent_zone("start_zone", "box_room", "start_box_room_door");

	zm_zonemgr::add_adjacent_zone("start_zone", "stairs_room", "start_stairs_room_door");

	zm_zonemgr::add_adjacent_zone("stairs_room", "above_box_room", "stairs_room_above_box_room_door");

	zm_zonemgr::add_adjacent_zone("box_room", "above_box_room", "box_room_stairs");

	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

