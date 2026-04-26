#using scripts\shared\system_shared;
#using scripts\zm\_zm_powerups;
#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_fuse.gsh;

#namespace zm_powerup_fuse;

REGISTER_SYSTEM_EX( "zm_powerup_fuseammo", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_powerups::include_zombie_powerup( FUSE_STRING );
	zm_powerups::add_zombie_powerup( FUSE_STRING );
}

function __main__() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------