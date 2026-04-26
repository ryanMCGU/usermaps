#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
//#using scripts\shared\weapons\_bouncingbetty;

#using scripts\zm\_bo1bouncingbetty;

#insert scripts\shared\shared.gsh;

#using scripts\zm\_util;

#namespace bo1_bouncingbetty;

REGISTER_SYSTEM( "bo1_bouncingbetty", &__init__, undefined )

function __init__( localClientNum )
{
	bo1_bouncingbetty::init_shared();
}