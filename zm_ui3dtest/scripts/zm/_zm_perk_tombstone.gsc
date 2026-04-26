#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\callbacks_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_pack_a_punch_util;	
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_net;

#using scripts\zm\gametypes\_globallogic_score;

#insert scripts\zm\_zm_perk_tombstone.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "material", TOMBSTONE_SHADER );
#precache( "string", TOMBSTONE_PERK_INFO_STRING );
#precache( "fx", TOMBSTONE_LIGHTING_FX );
#precache( "fx", TOMBSTONE_FAKE_FX );

#namespace zm_perk_tombstone;

REGISTER_SYSTEM_EX( "zm_perk_tombstone", &__init__,&__main__, undefined )

// TOMBSTONE

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	enable_tombstone_perk_for_level();
	callback::on_spawned(&register_player_stats);
	callback::on_laststand( &on_laststand );
}

function __main__() {
	thread enable_tombstone_solo();
	thread update_if_more_players();

	level.get_player_perk_purchase_limit = &get_player_perk_purchase_limit;
}

function get_player_perk_purchase_limit()
{
    if( isdefined( self.player_perk_purchase_limit ) )
        return self.player_perk_purchase_limit;
    return level.perk_purchase_limit;
}

function enable_tombstone_perk_for_level()
{	
	// register tombstone perk for level
	zm_perks::register_perk_basic_info( PERK_TOMBSTONE, "tombstone", TOMBSTONE_PERK_COST, TOMBSTONE_PERK_INFO_STRING, GetWeapon( TOMBSTONE_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( PERK_TOMBSTONE, &tombstone_precache );
	zm_perks::register_perk_clientfields( PERK_TOMBSTONE, &tombstone_register_clientfield, &tombstone_set_clientfield );
	zm_perks::register_perk_machine( PERK_TOMBSTONE, &tombstone_perk_machine_setup );
	zm_perks::register_perk_threads( PERK_TOMBSTONE, &give_tomb_perk, &take_tomb_perk );
	zm_perks::register_perk_host_migration_params( PERK_TOMBSTONE, TOMBSTONE_RADIANT_MACHINE_NAME, TOMBSTONE_MACHINE_LIGHT_FX );
}

function tombstone_precache()
{
	if( IsDefined(level.tombstone_precache_override_func) )
	{
		[[ level.tombstone_precache_override_func ]]();
		return;
	}
	
	level._effect[TOMBSTONE_MACHINE_LIGHT_FX] = TOMBSTONE_LIGHTING_FX;
	
	level.machine_assets[PERK_TOMBSTONE] = SpawnStruct();
	level.machine_assets[PERK_TOMBSTONE].weapon = GetWeapon( TOMBSTONE_PERK_BOTTLE_WEAPON );
	level.machine_assets[PERK_TOMBSTONE].off_model = TOMBSTONE_MACHINE_DISABLED_MODEL;
	level.machine_assets[PERK_TOMBSTONE].on_model = TOMBSTONE_MACHINE_ACTIVE_MODEL;
}

function tombstone_register_clientfield()
{
	clientfield::register( "clientuimodel", PERK_CLIENTFIELD_TOMBSTONE, VERSION_SHIP, 2, "int" );
}

function tombstone_set_clientfield( state )
{
	self clientfield::set_player_uimodel( PERK_CLIENTFIELD_TOMBSTONE, state );
}

function tombstone_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = TOMBSTONE_MUS_JINGLE;
	use_trigger.script_string = TOMBSTONE_PERK_STRING;
	use_trigger.script_label = TOMBSTONE_MUS_STING;
	use_trigger.target = TOMBSTONE_RADIANT_MACHINE_NAME;
	perk_machine.script_string = TOMBSTONE_PERK_STRING;
	perk_machine.targetname = TOMBSTONE_RADIANT_MACHINE_NAME;
	if( IsDefined( bump_trigger ) )
	{
		bump_trigger.script_string = TOMBSTONE_PERK_STRING;
	}
}

function register_player_stats()
{
	self globallogic_score::initPersStat(PERK_TOMBSTONE + "_drank", false );
}

function enable_tombstone_solo() {
	level endon("end_game");

	level flag::wait_till( "start_zombie_round_logic" );

	check_for_solo();
}

function check_for_solo() {
	level.solo_tombstone = false;
	if (zm_perks::use_solo_revive()) {
		level.solo_tombstone = true;
	}
}

function update_if_more_players() {
	level endon("end_game");

	level flag::wait_till( "start_zombie_round_logic" );

	for (;;) {
		level waittill( "notify_check_quickrevive_for_hotjoin" );

		check_for_solo();

		wait 0.5;

		players = GetPlayers();
		foreach(player in players) {
			if (player HasPerk(PERK_TOMBSTONE)) {
				player handle_tombstone();
			}
		}
	}
}

function on_laststand() {
	level endon("end_game");
	self endon("disconnect");
	self endon("bled_out");
	self endon("death");

 	if ( self HasPerk( PERK_TOMBSTONE ) )
 	{
		////IPrintLnBold("Dropping tombstone on laststand (DELETE THIS LATER)");
		//level thread zm_powerups::specific_powerup_drop( "tombstone_power_up", self.origin, undefined, undefined, undefined, self, true);

		self thread return_retained_perks();
	}
}

function return_retained_perks() {
	level endon("end_game");
	self endon("disconnect");
	self endon("bled_out");
	self endon("death");

	//IPrintLnBold("waiting for revive");
	self waittill("player_revived", reviver);

	//IPrintLnBold("revived!!!");

	if ( isdefined(self._tombstone_perks_to_keep) ) {
		keys = getarraykeys( self._tombstone_perks_to_keep );
		foreach( perk in keys ) {
			if ( IS_TRUE(self._tombstone_perks_to_keep[perk]) ) {
				self zm_perks::give_perk( perk, false );
				//IPrintLnBold("Returning: " + perk);
				if (perk == PERK_ADDITIONAL_PRIMARY_WEAPON) {
					return_additionalprimaryweapon(self.weapon_taken_by_losing_specialty_additionalprimaryweapon);
				}
			}
		}
	}
	
	//IPrintLnBold("Clearing perk array");
	self.tombstone_dropped = undefined;
	self.tombstone_func = undefined;
	self._tombstone_perks_to_keep = undefined;
	self._tombstone_power_up_perks = undefined;
	self._tombstone_perk_count = undefined;
}

//From Mule Kick
function return_additionalprimaryweapon( w_returning )
{
	if ( isdefined( self.weapons_taken_by_losing_specialty_additionalprimaryweapon[w_returning] ) )
	{
		self zm_weapons::weapondata_give( self.weapons_taken_by_losing_specialty_additionalprimaryweapon[w_returning] );
	}
	else
	{
		self zm_weapons::give_build_kit_weapon( w_returning );
	}
}

function give_tomb_perk() {
	//IPrintLnBold("TOMBSTONE: OBTAINED");

	self notify(PERK_TOMBSTONE + "_start");

	self handle_tombstone();

	if (IS_TRUE(level.solo_tombstone)) {
		if (!isdefined(self.player_perk_purchase_limit)) {
			self.player_perk_purchase_limit = level.perk_purchase_limit;
		}

		self.player_perk_purchase_limit++;
	}
	
}

function take_tomb_perk( b_pause, str_perk, str_result ) {
	//IPrintLnBold("TOMBSTONE: LOST");

	self notify(PERK_TOMBSTONE + "_stop");

	if (IS_TRUE(level.solo_tombstone)) {
		self.player_perk_purchase_limit--;
	}
}

function handle_tombstone() {
	//IPrintLnBold("Starting Tombstone Solo Logic");
	self thread manage_perk_retain_list();

	if (!IS_TRUE(level.solo_tombstone)) {
		//IPrintLnBold("Starting Tombstone Co-Op Logic");
		self thread co_op_drop_tombstone();
	}
}

function co_op_drop_tombstone() {
	level endon("end_game");
	self endon("disconnect");
	level endon( "notify_check_quickrevive_for_hotjoin" );
	self endon("tombstone_returned_perks");
	self endon("tombstone_powerup_perks_returned");
	self endon("player_revived");

	//IPrintLnBold("Waiting for bleed out");
	self waittill("bled_out");
	//IPrintLnBold("bled out");

	location = self.origin;

	self._tombstone_perks_to_keep = undefined;
	self.tombstone_dropped = true;
	self.tombstone_func = &tombstone_power_up_logic;

	//IPrintLnBold("Dropping fake tombstone");
	self thread spawn_fake_tombstone(location);
	
}

function spawn_fake_tombstone(location) {
	struct = level.zombie_powerups["tombstone_power_up"];

	powerup = Spawn( "script_model", location + (0,0,40));
	powerup PlaySound("zmb_spawn_powerup");
	powerup SetModel( struct.model_name );

	fx = PlayFXOnTag(TOMBSTONE_FAKE_FX, powerup, "tag_origin");
	
	powerup thread fake_powerup_wobble();
	powerup PlayLoopSound("zmb_spawn_powerup_loop");
	
	result = level util::waittill_any_ex( "end_game", self, "disconnect", "spawned_player" );

	powerup notify( "fake_powerup_deleted" );

	if (isdefined(fx)) {
		fx Delete();
	}
	if (isdefined(powerup)) {
		powerup StopLoopSound();
		powerup Delete();
	}
	if( result == "spawned_player" )
    {
        level thread zm_powerups::specific_powerup_drop( "tombstone_power_up", location, undefined, undefined, undefined, self );
    }
}

function fake_powerup_wobble()
{
	self endon( "fake_powerup_deleted" );
	self endon( "death" );

	while ( isdefined( self ) )
	{
		waittime = randomfloatrange( 2.5, 5 );
		yaw = RandomInt( 360 );
		if( yaw > 300 )
		{
			yaw = 300;
		}
		else if( yaw < 60 )
		{
			yaw = 60;
		}
		yaw = self.angles[1] + yaw;
		new_angles = (-60 + randomint( 120 ), yaw, -45 + randomint( 90 ));
		self rotateto( new_angles, waittime, waittime * 0.5, waittime * 0.5 );
		if ( isdefined( self.worldgundw ) )
		{
			self.worldgundw rotateto( new_angles, waittime, waittime * 0.5, waittime * 0.5 );
		}
		wait randomfloat( waittime - 0.1 );
	}
}

function manage_perk_retain_list() // self == player
{
	level endon("end_game");
	self endon("disconnect");
	level endon( "notify_check_quickrevive_for_hotjoin" );
	self endon(PERK_TOMBSTONE + "_stop");

	if(!isdefined(self._tombstone_perks_to_keep)) {
    	self._tombstone_perks_to_keep = [];
  	}
	if(!isdefined(self._tombstone_power_up_perks)) {
    	self._tombstone_power_up_perks = [];
  	}
	if(!isdefined(self._tombstone_perk_count)) {
		self._tombstone_perk_count = 0;
	}

	for (;;) {
		a_str_perks = zm_perks::get_perk_array();

    	foreach( str_perk in a_str_perks ) {
        	if( str_perk != PERK_TOMBSTONE && (!IS_TRUE(self._tombstone_perks_to_keep[str_perk])) 
				&& !(str_perk == PERK_QUICK_REVIVE && IS_TRUE(level.solo_tombstone)) && self._tombstone_perk_count < 3) {
				//IPrintLnBold("Obtained: " + str_perk);
				self._tombstone_perks_to_keep[str_perk] = true;
				self._tombstone_perk_count++;
			}

			if (str_perk != PERK_TOMBSTONE) {
				self._tombstone_power_up_perks[str_perk] = true;
			}
    	}

		wait 1;
	}
}

function tombstone_power_up_logic() {
	level endon("end_game");
	self endon("disconnect");

	//IPrintLnBold("Starting power up logic");
	return_power_up_perks();

	////IPrintLnBold("waiting for tombstone_powerup_perks_returned");
	//self waittill("tombstone_powerup_perks_returned");
	////IPrintLnBold("recieved tombstone_powerup_perks_returned");

	return_power_up_weapons( self );

	self.tombstone_dropped = undefined;
	self.tombstone_func = undefined;
	self._tombstone_perks_to_keep = undefined;
	self._tombstone_power_up_perks = undefined;
	self._tombstone_perk_count = undefined;
	
	//IPrintLnBold("Ending power up logic");
}

function return_power_up_perks() {
	if ( isdefined(self._tombstone_power_up_perks) ) {
		//IPrintLnBold("Starting return power up perks");
		keys = getarraykeys( self._tombstone_power_up_perks );
		foreach( perk in keys ) {
			if ( IS_TRUE(self._tombstone_power_up_perks[perk]) ) {
				self zm_perks::give_perk( perk, false );
				//IPrintLnBold("Returning powerup perks: " + perk);

				if (perk == PERK_ADDITIONAL_PRIMARY_WEAPON) {
					return_additionalprimaryweapon(self.weapon_taken_by_losing_specialty_additionalprimaryweapon);
				}
			}
		}
	}
	else {
		//IPrintLnBold("_tombstone_power_up_perks not defined");
	}

	self notify("tombstone_powerup_perks_returned");
}

//bgb - Arms Grace logic
function return_power_up_weapons( player ) {
	orig_weapon = player getcurrentweapon();
    weapon_limit = zm_utility::get_player_weapon_limit( player );
    current_weapons_count = 0;
    weapon_switched = 0;
    pap_triggers = zm_pap_util::get_triggers();
    ray_gun_weapon = getweapon( "ray_gun" );
    has_ray_gun = 0;
    player giveweapon( level.weaponbasemelee );
    
    if ( isdefined( player.laststandprimaryweapons ) )
    {
        primary_is_ray_gun = 0;
        
        foreach ( weapon in player.laststandprimaryweapons )
        {
            if ( weapon.isprimary )
            {
                if ( ray_gun_weapon == zm_weapons::get_base_weapon( weapon ) )
                {
                    primary_is_ray_gun = 1;
                    break;
                }
            }
        }
        
        foreach ( weapon in player.laststandprimaryweapons )
        {
            if ( weapon == orig_weapon )
            {
                continue;
            }
            
            if ( weapon.isprimary )
            {
                primary = undefined;
                w_base = zm_weapons::get_base_weapon( weapon );
                
                if ( !zm_weapons::limited_weapon_below_quota( w_base, player, pap_triggers ) && weapon != level.start_weapon )
                {
                    if ( !has_ray_gun )
                    {
                        if ( !primary_is_ray_gun && !player zm_weapons::has_weapon_or_upgrade( ray_gun_weapon ) )
                        {
                            primary = ray_gun_weapon;
                            has_ray_gun = 1;
                        }
                    }
                }
                else
                {
                    primary = weapon;
                }
                
                if ( isdefined( primary ) )
                {
                    player zm_weapons::weapon_give( primary, 0, 0, 1, !weapon_switched );
					//IPrintLnBold("Returning powerup weapon: " + primary.name);
                    current_weapons_count++;
                    weapon_switched = 1;
                }
            }
            
            if ( weapon_limit <= current_weapons_count )
            {
                break;
            }
        }
    }
}