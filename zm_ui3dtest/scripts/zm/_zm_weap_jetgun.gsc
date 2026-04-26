#using scripts\codescripts\struct;

#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie_utility;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\laststand_shared;

#using scripts\zm\_util;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_magicbox;
#using scripts\shared\spawner_shared;
#using scripts\shared\flag_shared;

#using scripts\zm\gametypes\_globallogic;
#using scripts\zm\gametypes\_globallogic_score;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\shared\ai\systems\gib;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;

#namespace zm_weap_jetgun;

#define TRAIL_FX_STR "destruct/fx_vdest_siegebot_sm_dmg_panel_fire_mp"

#precache( "xmodel", "wm_t6_jetgun");
#precache( "xmodel", "wm_jetgun_part_1");
#precache( "xmodel", "wm_jetgun_part_2");
#precache( "xmodel", "wm_jetgun_part_3");
#precache( "xmodel", "wm_jetgun_part_4");
#precache( "fx", "destruct/fx_vdest_siegebot_sm_dmg_panel_fire_mp" );

/*
	To-do

	Jetgun slowing fall and pulling forward
	Fix animations for firing spinning turbine and the RPM dial to move (maybe do the ammo bar too idk)

	-> Maybe do UI3D or a Shader to get dials to work properly
*/

REGISTER_SYSTEM_EX( "zm_weap_jetgun", &__init__, &__main__, undefined )

function __init__() {
    level.weaponZMjetgun = GetWeapon( "t6_jetgun" );
	level.jetguh_whole = "wm_t6_jetgun";
	level.jetgun_part_1 = "wm_jetgun_part_1";
	level.jetgun_part_2 = "wm_jetgun_part_2";
	level.jetgun_part_3 = "wm_jetgun_part_3";
	level.jetgun_part_4 = "wm_jetgun_part_4";
	level.jetgun_parts_obtained = 0;
	level.partsOnStage = 0;
}

function __main__() {
    callback::on_connect( &wait_for_jetgun_fire );
    zm_spawner::register_zombie_death_event_callback( &jetgun_death );

	level.part_1 = GetEnt("craft_jetgun_zm_part_0","targetname");
	level.part_1 thread apply_pickup_trigger(0);
	level.part_1.name = "part1";
	level.part1Spawn = level.part_1.origin;
	level.part1Angle = level.part_1.angles;

	level.part_2 = GetEnt("craft_jetgun_zm_part_1","targetname");
	level.part_2 thread apply_pickup_trigger(0);
	level.part_2.name = "part2";
	level.part2Spawn = level.part_2.origin;
	level.part2Angle = level.part_2.angles;

	level.part_3 = GetEnt("craft_jetgun_zm_part_2","targetname");
	level.part_3 thread apply_pickup_trigger(0);
	level.part_3.name = "part3";
	level.part3Spawn = level.part_3.origin;
	level.part3Angle = level.part_3.angles;

	level.part_4 = GetEnt("craft_jetgun_zm_part_3","targetname");
	level.part_4 thread apply_pickup_trigger(0);
	level.part_4.name = "part4";
	level.part4Spawn = level.part_4.origin;
	level.part4Angle = level.part_4.angles;

	crafting_table = GetEnt("craft_jetgun_zm_craftable_trigger","targetname");
	crafting_table thread crafting_trigger();

	pick_up_trigger = GetEnt("jetgun_pickup_trigger", "targetname");
	pick_up_trigger Hide();

	thread respawn_all_parts();
}

function do_players_have_jetgun() {
	foreach(player in level.players) {
			if (player HasWeapon(level.weaponZMjetgun)) {
				return true;
			}
	}
	return false;
}

function respawn_all_parts() {
	level endon("end_game");

	level flag::wait_till("initial_blackscreen_passed");

	for(;;) {
		IPrintLnBold("Starting respawn watch...");
		level waittill( "end_of_round" );
		

		if (!do_players_have_jetgun() & level.jetgun_parts_obtained == 0 & level.partsOnStage == 0) {
			IPrintLnBold("success respawn, PartsHeld: " + level.jetgun_parts_obtained + ", PartsStage: " + level.partsOnStage + ", HasWeapon: " + do_players_have_jetgun());
			respawn_part1(0);
			respawn_part2(0);
			respawn_part3(0);
			respawn_part4(0);
		}
		else {
			IPrintLnBold("Failed respawn, PartsHeld: " + level.jetgun_parts_obtained + ", PartsStage: " + level.partsOnStage + ", HasWeapon: " + do_players_have_jetgun());
		}
	}
}

function crafting_trigger() {
	level endon("end_game");

	self UseTriggerRequireLookAt();
    self SetCursorHint( "HINT_NOICON" );
	self SetHintString("Additional Parts required...");

	for (;;) {
		self waittill( "trigger", player );

		if (level.jetgun_parts_obtained >= 4) {
			self SetHintString( "Hold ^3[{+activate}]^7 to add parts." );

			if ( !isdefined( self.useTime ) )
		{
		self.useTime = int( 3 * 1000 );
		}

	self.craft_time = self.useTime;
	self.craft_start_time = getTime();
	craft_time = self.craft_time;
	craft_start_time = self.craft_start_time;

	if ( craft_time > 0 ) {
		player zm_utility::disable_player_move_states( true );

		self thread zm_craftables::craftable_play_craft_fx(player);

		player zm_utility::increment_is_drinking();
		orgweapon = player GetCurrentWeapon();
		build_weapon = GetWeapon( "zombie_builder" );
		player GiveWeapon( build_weapon );
		player SwitchToWeapon( build_weapon );

		player thread zm_craftables::player_progress_bar( craft_start_time, craft_time );

		player.craftsound = spawn( "script_origin", player.origin );
		player.craftsound PlayLoopSound( "zmb_craftable_loop" );

		while ( isdefined( self ) && player player_continue_crafting( self ) && getTime() - self.craft_start_time < self.craft_time )
		{
			WAIT_SERVER_FRAME;
		}

		player zm_weapons::switch_back_primary_weapon( orgweapon );
		player TakeWeapon( build_weapon );

		if ( IS_TRUE( player.is_drinking ) )
		{
			player zm_utility::decrement_is_drinking();
		}
		if (isdefined(player.craftsound)) {
			player.craftsound Delete();
		}
		player zm_utility::enable_player_move_states();
	}
	if ( isdefined( self ) &&
	        player player_continue_crafting( self ) &&
	        ( self.craft_time <= 0 || getTime() - self.craft_start_time >= self.craft_time ) ) {
		self notify( "craft_succeed" );
		

		self Hide();
		self SetHintString("Additional Parts required...");

		weapon_struct = struct::get("jetgun_crafting_model", "targetname");
		weapon_model = util::spawn_model("tag_origin", weapon_struct.origin, weapon_struct.angles);
		weapon_model SetModel(level.jetguh_whole);
		player PlaySound("zmb_craftable_complete");

		pick_up_trigger = GetEnt("jetgun_pickup_trigger", "targetname");
		pick_up_trigger thread jetgun_crafting_pick_up(self, weapon_model);

		self waittill("jetgun_picked_up_from_crafting");
		pick_up_trigger notify("kill_jetgun_picked_up_from_crafting");
		self Show();
	}
	else {
		//make sure the audio sounds go away
		if ( isdefined( player.craftsound ) )
		{
			player.craftsound delete();
			player.craftsound = undefined;
		}

		self notify( "craft_failed" );
		player notify( "craftable_progress_end" );
	}
		}
		else {
			self SetHintString("Additional Parts required...");
		}
	}
}

// self is trigger
function jetgun_crafting_pick_up(parent_trig, weapon_model) {
	self endon("death");
	self endon("kill_jetgun_picked_up_from_crafting");

	self UseTriggerRequireLookAt();
    self SetCursorHint( "HINT_NOICON" );
	self SetHintString( "Hold ^3[{+activate}]^7 to pick up Thrustodyne Aeronautics Model 23." );

	self Show();
	for (;;) {
		self waittill( "trigger", player );

		if (player zm_magicbox::can_buy_weapon() && !(player HasWeapon(level.weaponZMjetgun))) {
			player zm_weapons::weapon_give(level.weaponZMjetgun);

            self Hide();
            weapon_model Delete();
			level.jetgun_parts_obtained = 0;
			player.jetgun_to_blow = 0;
            break;
        }
	}

	parent_trig notify("jetgun_picked_up_from_crafting");
}

//
//	self is a player
function player_continue_crafting( craftableSpawn ) {
	if ( self laststand::player_is_in_laststand() || self zm_utility::in_revive_trigger() )
	{
		return false;
	}

	if ( isdefined( self.screecher ) )
	{
		return false;
	}

	if ( !self UseButtonPressed() )
	{
		return false;
	}

	
	if ( !isdefined( craftableSpawn ) || !craftableSpawn IsTouching( self ) ) //self IsTouching(trigger))
	{
		return false;
	}
	

	return true;
}

function wait_for_jetgun_fire() {
	self endon( "disconnect" );

	self.jetgun_to_blow = 0;

	self thread jetgun_death_rattle();

	for(;;) {
		self waittill( "weapon_fired", weapon );
		if( weapon == level.weaponZMjetgun ) { 
			self thread jetgun_fire(weapon);

			cliponly = IS_TRUE( weapon.isClipOnly );
    		n_ammo = ( cliponly ? self GetWeaponAmmoClip( weapon ) : self GetWeaponAmmoStock( weapon ) );
			if (isdefined(n_ammo) && n_ammo == 0) {
				IPrintLnBold("Piece to blow++");
				self.jetgun_to_blow++;
			}
			if (isdefined(self.jetgun_to_blow) && self.jetgun_to_blow == 4) {
				self jetgun_explode(weapon);
			}
		}
	}
}

function do_power_up_magnet_pull(weapon) {
	self endon( "disconnect" );

	if (weapon == level.weaponZMjetgun) {
		while (self AttackButtonPressed() && ( IS_TRUE( weapon.isClipOnly ) ? self GetWeaponAmmoClip( weapon ) : self GetWeaponAmmoStock( weapon ) ) != 0) {
			if (self.start_magnet_pull == 0) {
				IPrintLnBold("starting magnet pull");
				self thread powerup_magnet();
				self.start_magnet_pull = 1;
			}
			wait 0.1;
		}

		IPrintLnBold("notifying magnet_stop");
		self.start_magnet_pull = 0;
		self notify("magnet_stop");
		foreach (powerup in level.active_powerups)
        {
            if (isDefined (powerup) && IS_TRUE(powerup.b_magnet_threaded))
            {   
                powerup.b_magnet_threaded = false;
                powerup notify("movedone");
            }
        }
	}
}

//Also starts the power up magnet pull
function jetgun_death_rattle() {
	self endon( "disconnect" );

	self.rattled_fire = 0;
	self.start_magnet_pull = 0;

	for(;;) {
		self waittill( "weapon_fired", weapon );

		if (weapon == level.weaponZMjetgun && self.start_magnet_pull == 0) {
			self thread do_power_up_magnet_pull(weapon);
		}

		if (self.jetgun_to_blow == 3 && weapon == level.weaponZMjetgun) {
			while (self AttackButtonPressed() && ( IS_TRUE( weapon.isClipOnly ) ? self GetWeaponAmmoClip( weapon ) : self GetWeaponAmmoStock( weapon ) ) != 0) {
				if (self.rattled_fire == 0) {
					self PlaySound("wpn_t6_jetgun_rattle_start_npc");
					self.rattled_fire++;
					wait 0.1;
				}
				else if (self.rattled_fire == 1) {
					sound_fx = Spawn("script_origin", self.origin);
					sound_fx PlayLoopSound("wpn_t6_jetgun_rattle_loop_npc");
					self.rattled_fire = 2;
				}

				wait 0.1;
			}

			wait 0.1;
			if (isdefined(sound_fx)) {
				sound_fx Delete();
			}
			self PlaySound("wpn_t6_jetgun_rattle_stop_npc");
			wait 0.2;
			self.rattled_fire = 0;
		}
	}
	
}

function jetgun_explode(weapon) {
	self.jetgun_to_blow = 0;
	self TakeWeapon(weapon);
	self thread drop_pieces_when_boom();
	IPrintLnBold("Piece should be boomed!!!");
}

function play_explode_sound() {
	level endon("end_game");
	
	sound_fx = Spawn("script_origin", self.origin);
	sound_fx PlaySound("jet_gun_explo");
	wait 0.5;
	if (isdefined(sound_fx)) {
		sound_fx Delete();
	}
}

function play_quake() {
	level endon("end_game");

	quake = Earthquake(2, .4, self.origin, 512);
	wait 0.5;
	if (isdefined(quake)) {
		quake Delete();
	}
}

function jetgun_fire(weapon) {
    view_pos = self GetWeaponMuzzlePoint();
    outer_range = 150;
    zombies = array::get_all_closest( view_pos, GetAITeamArray( level.zombie_team ), undefined, undefined, outer_range * 1.1 );
    if( !isdefined( zombies ) ) return;

    for( i=0; i<zombies.size; i++ ) {
        z = zombies[i];
        if( !isdefined( z ) || !IsAlive( z ) ) continue;
        z thread damage_zombie(self, weapon);
    }
}

function damage_zombie(player, weapon) {
    self endon( "death" );

    if( !isdefined( self ) || !IsAlive( self ) ) return;
	DEFAULT( self.jetgun_damage, 0 );
	DEFAULT( self.marked_for_jetgun_death, false );
	is_dog = ( self.archetype === "zombie_dog" );
    self.jetgun_damage = Int((self.maxhealth / 8) + 1);
	if( self.jetgun_damage >= self.health || self.health <= 0 ) {
		self.marked_for_jetgun_death = true;
	}

    instakill = player zm_powerups::is_insta_kill_active();
    damage = ( instakill || is_dog || self.marked_for_jetgun_death ? self.health + 666 : self.jetgun_damage );
    self DoDamage( damage, player.origin, player, undefined, "none", "MOD_RIFLE_BULLET", 0, weapon );
	
	self thread play_grind_damage_sound();
}

function play_grind_damage_sound() {
	level endon("end_game");

	sound_fx = Spawn("script_origin", self.origin);
	sound_fx PlaySound("wpn_t6_jetgun_grind");
	wait 0.3;
	sound_fx Delete();
}

function jetgun_death( e_attacker )
{
	if( self.damageweapon === level.weaponZMjetgun ) {
        GibServerUtils::Annihilate(self);
		if( self.archetype !== "zombie" && self.archetype !== "zombie_dog" ) return;
	}
}

function drop_pieces_when_boom() {
	self endon( "disconnect" );

	self DoDamage(50, self.origin);
	self thread play_explode_sound();
	self thread play_quake();

	level.part_1 = util::spawn_model( "tag_origin", self.origin + ( 0, 0, 42 ) , self.angles );
	level.part_1 SetModel(level.jetgun_part_1);
	level.part_1.name = "part1";

	level.part_2 = util::spawn_model( "tag_origin", self.origin + ( 0, 0, 42 ) , self.angles );
	level.part_2 SetModel(level.jetgun_part_2);
	level.part_2.name = "part2";

	level.part_3 = util::spawn_model( "tag_origin", self.origin + ( 0, 0, 42 ) , self.angles );
	level.part_3 SetModel(level.jetgun_part_3);
	level.part_3.name = "part3";

	level.part_4 = util::spawn_model( "tag_origin", self.origin + ( 0, 0, 42 ) , self.angles );
	level.part_4 SetModel(level.jetgun_part_4);
	level.part_4.name = "part4";

	//here to prevent double respawn b/c of a bug
	level.partsOnStage++;
	level.partsOnStage++;
	level.partsOnStage++;
	level.partsOnStage++;

	//part flying out logic
	level.part_1 thread stud_drop_logic( 4 );
	level.part_2 thread stud_drop_logic( 5.5 );
	level.part_3 thread stud_drop_logic( 6.5 );
	level.part_4 thread stud_drop_logic( 6 );

	//part respawn logic
	level.part_1 thread timed_respawn();
	level.part_2 thread timed_respawn();
	level.part_3 thread timed_respawn();
	level.part_4 thread timed_respawn();
}

function timed_respawn() {
	self endon( "death" );
	IPrintLnBold("starting timer respawn");

	wait (120);
	self respawn_this_part();
}

function respawn_part1(respawn) {
	IPrintLnBold("respawning part1");
	level.part_1 = util::spawn_model( "tag_origin", level.part1Spawn , level.part1Angle );
	level.part_1 SetModel(level.jetgun_part_1);
	level.part_1.name = "part1";

	level.part_1 thread apply_pickup_trigger(respawn);
}

function respawn_part2(respawn) {
	IPrintLnBold("respawning part2");
	level.part_2 = util::spawn_model( "tag_origin", level.part2Spawn , level.part2Angle );
	level.part_2 SetModel(level.jetgun_part_2);
	level.part_2.name = "part2";

	level.part_2 thread apply_pickup_trigger(respawn);
}

function respawn_part3(respawn) {
	IPrintLnBold("respawning part3");
	level.part_3 = util::spawn_model( "tag_origin", level.part3Spawn , level.part3Angle );
	level.part_3 SetModel(level.jetgun_part_3);
	level.part_3.name = "part3";

	level.part_3 thread apply_pickup_trigger(respawn);
}

function respawn_part4(respawn) {
	IPrintLnBold("respawning part4");
	level.part_4 = util::spawn_model( "tag_origin", level.part4Spawn , level.part4Angle );
	level.part_4 SetModel(level.jetgun_part_4);
	level.part_4.name = "part4";

	level.part_4 thread apply_pickup_trigger(respawn);
}

function respawn_this_part() {
	if (isdefined(self.name) && self.name == "part1") {
		respawn_part1(1);
	}

	else if (isdefined(self.name) && self.name == "part2") {
		respawn_part2(1);
	}

	else if (isdefined(self.name) && self.name == "part3") {
		respawn_part3(1);
	}

	else if (isdefined(self.name) && self.name == "part4") {
		respawn_part4(1);
	}

	if (isdefined(self.trig)) {
		self.trig Delete();
	}

	self Delete();
}


function stud_drop_logic( weight )
{
	self endon( "death" );

	// math
    x = RandomFloat( 2 );
    y = RandomFloat( 2 );

    if( math::cointoss() )
        x *= -1;
    if( math::cointoss() )
        y *= -1;

	self thread set_part_on_fire();

    // launch the stud and wait until the moving is done
    self PhysicsLaunch( self.origin, ( AnglesToForward( self.angles ) + ( x, y, 0.5 ) ) * weight );
    self util::waitTillNotMoving();
	IPrintLnBold("Pieces on ground.");

    self thread apply_pickup_trigger(1);
}

function set_part_on_fire() {
	level endon("end_game");
	
	// play fx on the stud launching out
	trail_fx = Spawn("script_model",self.origin);
	trail_fx SetModel("tag_origin");

	trail_fx EnableLinkTo();
	trail_fx LinkTo(self);
	
    PlayFXOnTag( TRAIL_FX_STR, trail_fx, "tag_origin" );

	self waittill( "death" );
	if (isdefined(trail_fx)) {
		trail_fx Delete();
	}
}

function apply_pickup_trigger(is_respawn) {
	self endon( "death" );

	if (!is_respawn) {
		level.partsOnStage++;
	}
	// create a small trigger and wait till a player touches it
    self.trig = spawn( "trigger_radius_use", self.origin, 0, 50, 50 );
    self.trig SetHintString( "Hold ^3[{+activate}]^7 to pick up part." );
    self.trig TriggerIgnoreTeam();
    self.trig SetVisibleToPlayer( self );
    self.trig SetTeamForTrigger( "allies" );
    self.trig UseTriggerRequireLookAt();
    self.trig SetCursorHint( "HINT_NOICON" );
    self.trig EnableLinkTo();
    self.trig LinkTo( self );
    self.trig waittill("trigger", player);
	player PlaySound("zmb_craftable_pickup"); 
    self.trig Delete();
	level.jetgun_parts_obtained++;

	if (level.jetgun_parts_obtained >= 4) {
		crafting_table = GetEnt("craft_jetgun_zm_craftable_trigger","targetname");
		crafting_table SetHintString( "Hold ^3[{+activate}]^7 to add parts." );
	}

	level.partsOnStage--;
    // delete the stud
    WAIT_SERVER_FRAME;
    self Delete();
}


//Westchiefs magnet script
function powerup_magnet()
{
	self endon ("magnet_stop");
	
    for(;;)
    {
        WAIT_SERVER_FRAME;

        foreach (powerup in level.active_powerups)
        {
            if (isDefined (powerup) && !IS_TRUE(powerup.b_magnet_threaded))
            {   
                powerup.closest_player = undefined;
                powerup.b_magnet_threaded = true;
                powerup thread _powerup_check_valid_players(self);
                powerup thread _powerup_watch_magnet(self);
            }
        }
    }
}

function _powerup_watch_magnet(the_player)
{
    self endon ("death");
    self endon ("hacked");
    self endon ("powerup_grabbed");
    self endon ("powerup_timedout");
	the_player endon ("magnet_stop");

	MAGNET_RANGE = 720;
	MAGNET_PULL_SPEED_FAR = 10;
	MAGNET_STOP_DISTANCE = 0;

    while (isDefined (self))
    {
        WAIT_SERVER_FRAME;

        self notify ("movedone");
		
		self MoveTo (self.origin, .05);

        if (!isDefined (self.closest_player))
			continue;
        
        else 
			n_dist = Distance (self.origin, (self.closest_player.origin));		
		
		if ((n_dist > ((MAGNET_RANGE / 8) * 7)) && (n_dist < MAGNET_RANGE))
			self MoveTo(self.closest_player.origin + (0, 0, 30), MAGNET_PULL_SPEED_FAR);
					
		else if ((n_dist > ((MAGNET_RANGE / 4) * 3)) && (n_dist < (((MAGNET_RANGE / 8) * 7) + 1)))
			self MoveTo(self.closest_player.origin + (0, 0, 30), (MAGNET_PULL_SPEED_FAR * .75));
			
		else if ((n_dist > ((MAGNET_RANGE / 8) * 5)) && (n_dist < (((MAGNET_RANGE / 4) * 3) + 1)))
			self MoveTo(self.closest_player.origin + (0, 0, 30), (MAGNET_PULL_SPEED_FAR * .5));
		
		else if ((n_dist > ((MAGNET_RANGE / 4) * 2)) && (n_dist < (((MAGNET_RANGE / 8) * 5) + 1)))
			self MoveTo(self.closest_player.origin + (0, 0, 30), (MAGNET_PULL_SPEED_FAR * .25));
			
		else if ((n_dist > ((MAGNET_RANGE / 8) * 3)) && (n_dist < (((MAGNET_RANGE / 4) * 2) + 1)))
			self MoveTo(self.closest_player.origin + (0, 0, 30), (MAGNET_PULL_SPEED_FAR * .1875));
		
		else if ((n_dist > ((MAGNET_RANGE / 4) * 1)) && (n_dist < (((MAGNET_RANGE / 8) * 3) + 1)))
			self MoveTo(self.closest_player.origin + (0, 0, 30), (MAGNET_PULL_SPEED_FAR * .125));
			
		else if ((n_dist > ((MAGNET_RANGE / 8) * 1)) && (n_dist < (((MAGNET_RANGE / 4) * 1) + 1)))
			self MoveTo(self.closest_player.origin + (0, 0, 30), (MAGNET_PULL_SPEED_FAR * .0625));
			
		if (n_dist < MAGNET_STOP_DISTANCE)
			self MoveTo (self.origin, .05);
    }
}

function _powerup_check_valid_players(the_player)
{
    self endon ("death");
    self endon ("hacked");
    self endon ("powerup_grabbed");
    self endon ("powerup_timedout");
	the_player endon ("magnet_stop");

	MAGNET_RANGE = 720;

    if (isDefined (self.powerup_player))
    {
        self thread _powerup_check_valid_player_solo(the_player);
        return;
    }

    while (isDefined (self))
    {
        WAIT_SERVER_FRAME;

        a_valids = [];
        foreach (player in level.players)
        {
            WAIT_SERVER_FRAME;

            if (zm_utility::is_player_valid(player, false, true) && player HasWeapon(level.weaponZMjetgun))
				a_valids[a_valids.size] = player;
        }

        if (a_valids.size < 1)
        {
            self.closest_player = undefined;
            continue;
        }

        else 
			self.closest_player = ArrayGetClosest (self.origin, a_valids, MAGNET_RANGE);
    }
}

function _powerup_check_valid_player_solo(the_player)
{
    self endon ("death");
    self endon ("hacked");
    self endon ("powerup_grabbed");
    self endon ("powerup_timedout");
	the_player endon ("magnet_stop");
    
    while (isDefined (self))
    {
        WAIT_SERVER_FRAME;

        if( zm_utility::is_player_valid (self.powerup_player, false, true) &&
										self.powerup_player HasWeapon(level.weaponZMjetgun) &&
										 self.closest_player != self.powerup_player) 
			self.closest_player = self.powerup_player;
        
        else 
			self.closest_player = undefined;
    }
}