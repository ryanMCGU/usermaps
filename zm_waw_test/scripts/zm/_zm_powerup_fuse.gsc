#using scripts\shared\system_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\perk_doors;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_fuse.gsh;

#precache( "string", "FUSE_OBTAIN" );
#precache( "eventstring", "zombie_notification" );

#namespace zm_powerup_fuse;

REGISTER_SYSTEM_EX( "zm_powerup_fuse", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	level.fuses_obtained = 0;
	zm_powerups::register_powerup( FUSE_STRING, &grab_fuse );
	zm_powerups::add_zombie_powerup( FUSE_STRING, FUSE_MODEL, &"FUSE_OBTAIN", ( FUSE_CAN_ZOMBIES_DROP ? &zm_powerups::func_should_always_drop : &zm_powerups::func_should_never_drop ), !POWERUP_ONLY_AFFECTS_GRABBER, !POWERUP_ANY_TEAM, !POWERUP_ZOMBIE_GRABBABLE );
	zm_powerups::powerup_set_can_pick_up_in_last_stand( FUSE_STRING, FUSE_CAN_GRAB_IN_LASTSTAND );
	zm_powerups::powerup_set_statless_powerup( FUSE_STRING );
	zm_audio::sndAnnouncerVoxAdd( FUSE_STRING, FUSE_SOUND_ALIAS_SUFFIX );
}

function __main__() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function grab_fuse( e_player )
{	
	level.fuses_obtained++;
	perk_doors::updateDoorHintString();
	luiNotifyEvent( &"zombie_notification", 1, &"FUSE_OBTAIN" );
}
