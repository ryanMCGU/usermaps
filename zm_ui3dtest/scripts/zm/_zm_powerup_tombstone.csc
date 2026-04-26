#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;

#using scripts\zm\_zm_powerups;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_tombstone.gsh;

#namespace zm_powerup_tombstone;

REGISTER_SYSTEM_EX( "zm_powerup_tombstone", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_powerups::include_zombie_powerup( TOMBSTONE_STRING );
	zm_powerups::add_zombie_powerup( TOMBSTONE_STRING );
}

function __main__() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------