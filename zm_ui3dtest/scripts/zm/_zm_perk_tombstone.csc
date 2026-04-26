#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perk_tombstone.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "client_fx", TOMBSTONE_LIGHTING_FX );

#namespace zm_perk_tombstone;

REGISTER_SYSTEM_EX( "zm_perk_tombstone", &__init__,&__main__, undefined )

// TOMBSTONE
	
function __init__()
{
	enable_tombstone_perk_for_level();
}
function __main__() {}

function enable_tombstone_perk_for_level()
{
	// register custom functions for hud/lua
	zm_perks::register_perk_clientfields( PERK_TOMBSTONE, &tombstone_client_field_func, &tombstone_code_callback_func );
	zm_perks::register_perk_effects( PERK_TOMBSTONE, TOMBSTONE_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( PERK_TOMBSTONE, &init_tombstone );
}

function init_tombstone()
{
	if( IS_TRUE(level.enable_magic) )
	{
		level._effect[TOMBSTONE_MACHINE_LIGHT_FX] = TOMBSTONE_LIGHTING_FX;
	}	
}

function tombstone_client_field_func()
{
	clientfield::register( "clientuimodel", PERK_CLIENTFIELD_TOMBSTONE, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT ); 
}

function tombstone_code_callback_func()
{
}
