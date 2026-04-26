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
#using scripts\shared\spawner_shared;

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
#using scripts\zm\gametypes\_globallogic;
#using scripts\zm\gametypes\_globallogic_score;

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

//T6 HUD
#using scripts\zm\_zm_t6_deathanim;

#using scripts\zm\zm_usermap;

#using scripts\zm\_zm_t4_hud;

#using scripts\zm\_zm_weap_freezegun;
#using scripts\zm\_zm_weap_thundergun;
#using scripts\zm\_zm_weap_tesla;

#using scripts\zm\perks\_zm_perk_phdflopper;
#using scripts\zm\dive;
#using scripts\zm\pap_move;
#using scripts\zm\free_perk_ee;
#using scripts\zm\_zm_weap_bo1bouncingbetty;
#using scripts\zm\zm_flamethrower;
#using scripts\zm\behavior_zombie_dog;

#using scripts\zm\zm_giant_cleanup_mgr;

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

//Stop Lag - check again
#precache( "triggerstring", "ZOMBIE_NEED_POWER" );
#precache( "triggerstring", "ZOMBIE_ELECTRIC_SWITCH");
#precache( "triggerstring", "ZOMBIE_ELECTRIC_SWITCH_OFF");
 
#precache( "triggerstring", "ZOMBIE_PERK_QUICKREVIVE 500" );
#precache( "triggerstring", "ZOMBIE_PERK_QUICKREVIVE 1500" );
#precache( "triggerstring", "ZOMBIE_PERK_FASTRELOAD 3000" );
#precache( "triggerstring", "ZOMBIE_PERK_DOUBLETAP 2000" );
#precache( "triggerstring", "ZOMBIE_PERK_JUGGERNAUT 2500" );
#precache( "triggerstring", "ZOMBIE_PERK_MARATHON 2000" );
#precache( "triggerstring", "ZOMBIE_PERK_DEADSHOT 1500" );
#precache( "triggerstring", "ZOMBIE_PERK_WIDOWSWINE 4000" );
#precache( "triggerstring", "ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON 4000" );
 
#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH 5000" );
#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH 1000" );
#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH_AAT 2500" );
#precache( "triggerstring", "ZOMBIE_PERK_PACKAPUNCH_AAT 500" );
 
#precache( "triggerstring", "ZOMBIE_RANDOM_WEAPON_COST 950" );
#precache( "triggerstring", "ZOMBIE_RANDOM_WEAPON_COST 10" );
 
#precache( "triggerstring", "ZOMBIE_UNDEFINED" );


//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	level._no_vending_machine_auto_collision = true;

	zm_usermap::main();
	_zm_weap_tesla::init();
	zm_flamethrower::init();

	zm_perks::spare_change();

	//FX
	precache_fx();


	level thread zm_waw_vox();
	callback::on_connect(&zm_waw_vox_reloads);
	

	level._zombie_custom_add_weapons =&custom_add_weapons;

	//Level variables
	//zombie_utility::set_zombie_var( "player_base_health", 90, false); 2 hit down
	level.pack_a_punch_camo_index = 0;
	//level.player_starting_points = 5000000;
	level.perk_purchase_limit = 5;
	level.zombie_powerup_weapon[ "minigun" ] = GetWeapon( "t5_minigun" );
	//level.start_weapon = (getWeapon("t5_m1911"));
	level.default_laststandpistol = getWeapon("t5_m1911");
	level.default_solo_laststandpistol = getWeapon("t5_m1911_revive_rdw_up");

	// Stielhandgranate
	zm_utility::register_lethal_grenade_for_level( "frag_grenade_potato_masher" );
	level.zombie_lethal_grenade_player_init = GetWeapon( "frag_grenade_potato_masher" );

	//Quick Revive Clip
	thread soloQuickReviveTrigger();

	//Monitor Power
	level thread MonitorPower();

	level thread PowerOn_Music();

	thread playAllAmbient();

	level.no_target_override = &no_target_override;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	callback::on_connect( &player_doghits );

	level.last_projectile_impact = 0;
	zm::register_actor_damage_callback( &detect_projectile_damage );

	level._actor_damage_callbacks = level.actor_damage_callbacks;
	level.actor_damage_callbacks = [];
	level.actor_damage_callbacks[ 0 ] = &actor_damage_callback_override;

	level thread start_challenge();

	level.giveCustomLoadout = &give_start_weapons;

	//level thread zm_utility::zombie_goto_round( 60 );

	ee_sounds();
	thread playFountainEESong();

	// Register a global spawn callback for all "axis" team AI (typically zombies).
	// This ensures that every time a zombie spawns, our custom speed logic is triggered.
	spawner::add_archetype_spawn_function( "zombie", &on_spawn_zombie_speed_override );
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

function check_actor_damage_callbacks( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, sHitLoc, psOffsetTime, boneIndex, surfaceType )
{
    if ( !isDefined( level._actor_damage_callbacks ) )
        return damage;
    
    for ( i = 0; i < level._actor_damage_callbacks.size; i++ )
    {
        newDamage = self [ [ level._actor_damage_callbacks[ i ] ] ]( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, sHitLoc, psOffsetTime, boneIndex, surfaceType );
        if ( -1 != newDamage )
            return newDamage;
        
    }

    return damage;
}

function actor_damage_callback_override( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type )
{
	n_damage = self check_actor_damage_callbacks( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type );
	
	if ( isDefined( level.ptr_dead_shot_damage_buff ) )
		n_damage = [ [ level.ptr_dead_shot_damage_buff ] ]( str_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type );
	
	return n_damage;
}

function usermap_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );

	zm_zonemgr::add_adjacent_zone("start_zone", "other_start_zone", "spawn_powered_door");

	zm_zonemgr::enable_zone("other_start_zone");

	zm_zonemgr::add_adjacent_zone("start_zone", "mule_room", "spawn_and_mule_door");

	zm_zonemgr::add_adjacent_zone("mule_room", "above_mule_room", "mule_stairs");

	zm_zonemgr::add_adjacent_zone("above_mule_room", "speed_room", "a_mule_speed_door");

	zm_zonemgr::add_adjacent_zone("speed_room", "kitchen", "speed_kitchen_door");

	zm_zonemgr::add_adjacent_zone("kitchen", "power", "kitchen_power_door");

	zm_zonemgr::add_adjacent_zone("other_start_zone", "double_room", "jugg_double_debris");

	zm_zonemgr::add_adjacent_zone("double_room", "bathroom", "double_room_bathroom_door");

	zm_zonemgr::add_adjacent_zone("bathroom", "power", "bathroom_power_door");

	zm_zonemgr::add_adjacent_zone("power", "under", "power_under_door");

	zm_zonemgr::add_adjacent_zone("under", "yard", "under_yard_door");
	
	zm_zonemgr::add_adjacent_zone("yard", "pap", "yard_pap_door");

	zm_zonemgr::add_adjacent_zone("pap", "pap_out", "pap_out_trigger");

	zm_zonemgr::enable_zone("pap_out");
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function give_start_weapons( takeAllWeapons, alreadySpawned )
{
    self GiveWeapon( level.weaponBaseMelee );
    self thread give_start_weapon();
}

function give_start_weapon()
{
	level endon("end_game");
	
	self waittill("spawned_player");

	wait 0.05;
	
    switch( self.characterIndex ) {
        case 0: // Dempsey
            self zm_weapons::weapon_give( GetWeapon( "t5_m1911" ) );
            break;
        case 1: // Nikolai (cannot die)
            self zm_weapons::weapon_give( GetWeapon( "t5_makarov" ) );
            break;
        case 2: // Richtofen
            self zm_weapons::weapon_give( GetWeapon( "s2_luger" ) );
            break;
        case 3: // Takeo
            self zm_weapons::weapon_give( GetWeapon( "t4_nambu" ) );
            break;
    }
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

function playAllAmbient() {
	level endon("end_game");
	level flag::wait_till("initial_blackscreen_passed");

	wait 30;

	level thread playRandomScream();
	level thread playRandomCry();
	level thread playRandomTwo("distant", "distant_1", "distant_2");
	level thread playRandomTwo("ambinsane", "asylum_amb", "insane");
}

function playLostNumbers() {
	level endon("end_game");
	models = GetEntArray("lost_numbers","targetname");
	for (;;) {
		foreach(model in models) {
			playsoundatposition("lost_numbers_start", model.origin);
			wait 2;
			playsoundatposition("lost_numbers", model.origin);
		}

		wait 60;
	}
}

function playRandomTwo(modelName, sound_1, sound_2) {
	level endon("end_game");
	for( ;; ) {
		rand_nums = [];
		rand_nums[0] = 1;
		rand_nums[1] = 2;

		rand_nums = array::randomize( rand_nums );

		if (rand_nums[0] == 1){
			playAmbOnModel(modelName, sound_1);
		}
		else {
			playAmbOnModel(modelName, sound_2);
		}

		wait 180;
	}
}

function playRandomCry() {
	level endon("end_game");
	for( ;; ) {
		rand_nums = [];
		rand_nums[0] = 1;
		rand_nums[1] = 2;
		rand_nums[2] = 3;

		rand_nums = array::randomize( rand_nums );

		if (rand_nums[0] == 1){
			playAmbOnModel("babysob", "baby");
		}
		else if (rand_nums[0] == 2) {
			playAmbOnModel("babysob", "sob_1");
		}
		else {
			playAmbOnModel("babysob", "sob_2");
		}

		wait 40;
	}
}

function playRandomScream() {
	level endon("end_game");
	for( ;; ) {
		rand_nums = [];
		rand_nums[0] = 1;
		rand_nums[1] = 2;
		rand_nums[2] = 3;
		rand_nums[3] = 4;
		rand_nums[4] = 5;
		rand_nums = array::randomize( rand_nums );

		if (rand_nums[0] == 1){
			playAmbOnModel("scream", "scream_1");
		}
		else if (rand_nums[0] == 2) {
			playAmbOnModel("scream", "scream_2");
		}
		else if (rand_nums[0] == 3) {
			playAmbOnModel("scream", "scream_3");
		}
		else if (rand_nums[0] == 4) {
			playAmbOnModel("scream", "scream_4");
		}
		else {
			playAmbOnModel("scream", "scream_5");
		}

		wait 65;
	}
}

function playAmbOnModel(modelName, sound) {
	models = GetEntArray(modelName,"targetname");

	foreach(model in models) {
		playsoundatposition(sound, model.origin);
	}
}

function PowerOn_Music() {
	level endon("end_game");
	level flag::wait_till("power_on");
	//IPrintLnBold("Power On");

	power = GetEntArray("power_pipe","targetname");
	gen_pro = GetEntArray("generator_probe", "targetname");

    foreach(trig in power)
    {
		//IPrintLnBold("Starting music sequence");
        PlaySoundAtPosition("power_start_elec", trig.origin);
		wait 5;
		trig PlaySound("power_music");

		foreach(ent in gen_pro) {
			//IPrintLnBold("Starting loop sequence");
			ent PlayLoopSound("power_elec");
		}
    }

	wait 20;
	level thread playLostNumbers();
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

function ee_sounds() {
	chair_triggers = GetEntArray("dentist", "targetname");
	toilet_trigger = GetEntArray("toilet", "targetname");
	radio_trigger = GetEntArray("radio", "targetname");

	foreach ( trigger1 in chair_triggers) {
		trigger1 thread doDentistEE();
	}

	foreach ( trigger2 in toilet_trigger) {
		trigger2 thread doToiletEE();
	}

	foreach ( trigger3 in radio_trigger) {
		trigger3 thread doRadioEE();
	}
}

function doRadioEE() {
	level endon("end_game");
	level endon("end_ee_radio");

	self SetCursorHint( "HINT_NOICON" );
	self SetHintString("");

	level flag::wait_till("initial_blackscreen_passed");

	self waittill( "trigger", player );

	self PlaySound("bb_vs_nuke");

	wait 17.9;

	level thread zm_powerups::specific_powerup_drop( "nuke", player.origin );

	self Delete();

	level notify("end_ee_radio");
}

function doDentistEE() {
	level endon("end_game");

	self UseTriggerRequireLookAt();
    self SetCursorHint( "HINT_NOICON" );
	self SetHintString("");

	level flag::wait_till("initial_blackscreen_passed");

	for (;;) {
		self waittill( "trigger", player );

		self PlaySound("chair");

		level waittill( "start_of_round" );
	}
}

function doToiletEE() {
	level endon("end_game");

	self UseTriggerRequireLookAt();
    self SetCursorHint( "HINT_NOICON" );
	self SetHintString("");

	level flag::wait_till("initial_blackscreen_passed");

	level.flushed = 0;

	for (;;) {
		self waittill( "trigger", player );

		self PlaySound("toilet");
		
		level.flushed++;

		wait 5;

		if (level.flushed == 3) {
			self PlaySound("lullaby");

			level.flushed = 0;

			level waittill( "start_of_round" );
		}
	}
}

function start_challenge() {
	level endon("end_game");

	for( ;; ) {
		level flag::wait_till( "dog_round" );
		//IPrintLnBold("Challenge Started");
		level thread accuracy_check();
		level thread check_health_passed();
		level waittill( "dog_round_ending" );
	}
}

function detect_projectile_damage( inflictor, attacker, damage, flags, means_of_death, weapon, point, dir, hit_loc, offset_time, bone_index, surface_type )
{
    if( isdefined( self )
        && IS_EQUAL( self.team, level.zombie_team )
        && isdefined( attacker )
        && IsPlayer( attacker ) ) {
        if( IsInArray( array( "ray_gun", "ray_gun_upgraded" ), weapon.name ) ) {
            if( GetTime() > level.last_projectile_impact ) {
                //IPrintLnBold( "Zombie within range! Decrementing var. " + weapon.name);
                attacker.pers["misses"] = attacker.hitsbeforefire;
            }
		
            level.last_projectile_impact = GetTime();
        }
		else if( IsInArray( array( "t5_m72", "t5_m72_up", "t5_m1911_rdw_up","t5_rpg", "t5_rpg_up", 
									"t5_m202", "t5_m202_up", "t5_m16a1_launcher", "t5_m1911_ldw_up", 
									"t5_strela3", "t5_strela3_up", "t5_ak74u_launcher", "t5_fal_launcher" ), weapon.name ) ) {
            if( GetTime() > level.last_projectile_impact ) {
                //IPrintLnBold( "Zombie within range! Decrementing var. " + weapon.name);
				attacker.pers["misses"]--;
            }
		
            level.last_projectile_impact = GetTime();
        }
		else if( IsInArray( array( "t5_china_lake", "t5_china_lake_up", "t4_ray_gun","t4_ray_gun_up" ), weapon.name ) ) {
            if( (GetTime() > level.last_projectile_impact) ) {
				if (isdefined(attacker.china_ex)) {
					if (attacker.china_ex) {
						//IPrintLnBold( "Zombie within range! Decrementing var. " + weapon.name);
						attacker.pers["misses"] = attacker.hitsbeforefire;
						attacker.china_ex = false;
					}

				}
                
            }

            level.last_projectile_impact = GetTime();
        }
    }
    return -1;
}

function player_doghits()
{
    self endon( "disconnect" );
    for(;;) {
        level flag::wait_till( "dog_round" );
        self.shots_fired = 0;
        self.dog_hits = 0;
		self.china_ex = true;
		self.nambu_fired = false;

        while( level flag::get( "dog_round" ) ) { 
			self.hitsbeforefire = self.pers["misses"];
            self waittill( "weapon_fired" , weapon);
			if (weapon.name == "not_t5_china_lake" || weapon.name == "not_t5_china_lake_up" || weapon.name == "t5_m72"
				 || weapon.name == "t5_m72_up" || weapon.name == "t5_m202" || weapon.name == "t5_m202_up" 
				 || weapon.name == "t5_rpg" || weapon.name == "t5_rpg_up" || weapon.name == "t5_m16a1_launcher"
				 || weapon.name == "t5_strela3" || weapon.name == "t5_strela3_up" || weapon.name == "t5_ak74u_launcher" 
				 || weapon.name == "t5_fal_launcher") {

				self.pers["misses"]++;
				//IPrintLnBold( "Incrementing var." );
			}
			if (weapon.name == "t5_china_lake" || weapon.name == "t5_china_lake_up" || weapon.name == "t4_ray_gun" || weapon.name == "t4_ray_gun_up") {
				self waittill( "projectile_impact" );
				wait 1;
			}
			// || weapon.name == "t5_m1911_ldw_up" || weapon.name == "t5_m1911_rdw_up"
			if (weapon.name == "t4_nambu_up") {
				level waittill( "nambu_hit" );
				wait 1;
				self.nambu_fired = false;
			}
			
			self.china_ex = true;
            self.shots_fired++;
			//IPrintLnBold("Shots Fired: ", self.shots_fired, " Hits made: ", self globallogic_score::getPersStat( "hits" ));
        }
    }
}

function accuracy_check() {
	level endon( "intermission" );
	level endon( "end_of_round" );
	level endon( "restart_round" );

	wait 5;
	//IPrintLnBold("Accuracy Challenge Started");

	players = getplayers();
    level.accuracy_check_passed = true;

    for ( i = 0; i < players.size; i++ )
    {
		players[i].total_misses_start_dog_round = players[i] globallogic_score::getPersStat( "misses" );
		//IPrintLnBold("before: ",players[i] globallogic_score::getPersStat( "misses" ));
    }

    level waittill( "last_ai_down", e_last );
	wait 0.5;
    players = getplayers();

    for ( i = 0; i < players.size; i++ )
    {

		total_misses_end_dog_round = players[i] globallogic_score::getPersStat( "misses" ) - players[i].total_misses_start_dog_round;
		//IPrintLnBold("after: ",players[i] globallogic_score::getPersStat( "misses" ));

		if ( total_misses_end_dog_round != 0) {
			level.accuracy_check_passed = false;
			//IPrintLnBold("Accuracy Challenge Failed");
			break;
		}
    }

	if (level.health_passed && level.accuracy_check_passed) {
		//IPrintLnBold("Challenge Passed");
		level thread drop_reward(e_last);
	}
	else {
		//IPrintLnBold("Challenge Failed");
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

	//IPrintLnBold("Health Challenge Started");
	level.health_passed = true;
	level.stop_dog_challenge = true;
	level thread check_last();

	while (level.health_passed && level.stop_dog_challenge) {
		level thread check_player_health();
		wait 0.5;
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
				//IPrintLnBold("Health Challenge FAILED");
            }
        } else {
            if (player.health != 100) {
                level.health_passed = false;
				//IPrintLnBold("Health Challenge FAILED");
            }
        }
    }
}

/*function apply_noncollision() {
	self endon( "death" );

	while (1) {
        self PushActors( false );
        wait(0.25);
	}
}*/

// This function is automatically called on zombie spawn via the line above.
// It applies a speed override to make the zombie sprint by default.
function on_spawn_zombie_speed_override()
{
	self endon( "death" );

	// Apply non-collide
	//self thread apply_noncollision();

    // Apply sprint behavior to this AI (self)

	random_int = RandomIntRange(1, 100);

	if (level.round_number >= 7) {
			self thread zombie_utility::set_zombie_run_cycle( "sprint" );
	}
	else if (level.round_number >= 5 && random_int <= 30) {
		self thread zombie_utility::set_zombie_run_cycle( "sprint" );
	}

    self waittill( "completed_emerging_into_playable_area" );

	if (level.round_number >= 40 && random_int <= 101) {
		self thread zombie_utility::set_zombie_run_cycle( "super_sprint" );
		//IPrintLnBold("Super Sprinter Spawned");
	}

	else if (level.round_number >= 30 && random_int <= 75) {
		self thread zombie_utility::set_zombie_run_cycle( "super_sprint" );
		//IPrintLnBold("Super Sprinter Spawned");
	}
	
	else if (level.round_number >= 25 && random_int <= 50) {
		self thread zombie_utility::set_zombie_run_cycle( "super_sprint" );
		//IPrintLnBold("Super Sprinter Spawned");
	}
	else if (level.round_number >= 20 && random_int <= 35) {
		self thread zombie_utility::set_zombie_run_cycle( "super_sprint" );
		//IPrintLnBold("Super Sprinter Spawned");
	}
	else if (level.round_number >= 15 && random_int <= 25) {
		self thread zombie_utility::set_zombie_run_cycle( "super_sprint" );
		//IPrintLnBold("Super Sprinter Spawned");
	}
	else if (level.round_number >= 8 && random_int <= 15) {
		self thread zombie_utility::set_zombie_run_cycle( "super_sprint" );
		//IPrintLnBold("Super Sprinter Spawned");
	}
}

function playFountainEESong() {
	level endon("end_game");

	level flag::wait_till("initial_blackscreen_passed");

	trig = GetEnt("music_fountain", "targetname");
	trig SetCursorHint( "HINT_NOICON" );
	trig SetHintString("");

	for (;;) {
		trig waittill( "trigger", player );

		weapon = player getCurrentWeapon();
		if( zm_weapons::is_weapon_upgraded( weapon ) || zm_weapons::is_wonder_weapon( weapon ) ) {
			trig PlaySound("fountain_music");
			
			break;
		}

		wait 0.5;
	}
}