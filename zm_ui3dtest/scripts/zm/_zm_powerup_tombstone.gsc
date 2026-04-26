#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;

#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;


#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_tombstone.gsh;

#precache( "string", "TOMBSTONE_OBTAIN" );
#precache( "eventstring", "zombie_notification" );

#namespace zm_powerup_tombstone;

REGISTER_SYSTEM_EX( "zm_powerup_tombstone", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_powerups::register_powerup( TOMBSTONE_STRING, &grab_tombstone );
	zm_powerups::add_zombie_powerup( TOMBSTONE_STRING, TOMBSTONE_MODEL, &"TOMBSTONE_OBTAIN", &zm_powerups::func_should_never_drop, POWERUP_ONLY_AFFECTS_GRABBER, !POWERUP_ANY_TEAM, !POWERUP_ZOMBIE_GRABBABLE );
	zm_powerups::powerup_set_can_pick_up_in_last_stand( TOMBSTONE_STRING, false );
	zm_powerups::powerup_set_prevent_pick_up_if_drinking( TOMBSTONE_STRING, true );
	zm_powerups::powerup_set_statless_powerup( TOMBSTONE_STRING );
	zm_audio::sndAnnouncerVoxAdd( TOMBSTONE_STRING, TOMBSTONE_SOUND_ALIAS_SUFFIX );
	zm_powerups::powerup_set_player_specific( TOMBSTONE_STRING, POWERUP_FOR_SPECIFIC_PLAYER );
}

function __main__() {
	thread when_tombstone_drops();
}

function grab_tombstone( e_player ) {	
	if ( IS_TRUE(e_player.tombstone_dropped) ) {
		e_player thread [[e_player.tombstone_func]]();

		//e_player luiNotifyEvent( &"zombie_notification", 1, &"TOMBSTONE_OBTAIN" );

		e_player.tombstone_dropped = undefined;
		e_player.tombstone_func = undefined;
	}
}

function when_tombstone_drops() {
	level endon("end_game");

	level flag::wait_till( "start_zombie_round_logic" );

	for(;;) {
    	level waittill( "powerup_dropped", powerup );
		if (isdefined(powerup.powerup_name) && powerup.powerup_name == TOMBSTONE_STRING)
    		powerup thread wait_for_timedout();
	}
}

function wait_for_timedout() {
	level endon("end_game");
    self endon( "powerup_grabbed" );
    
	self waittill( "powerup_timedout" );

	if(isdefined(self.powerup_player)) {
		self.powerup_player.tombstone_dropped = undefined;
		self.powerup_player.tombstone_func = undefined;
	}
}