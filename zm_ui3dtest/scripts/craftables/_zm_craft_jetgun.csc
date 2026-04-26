#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_utility;

#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\craftables\_zm_craft_jetgun.gsh;
	
#namespace zm_craft_jetgun;

REGISTER_SYSTEM( "zm_craft_jetgun", &__init__, undefined )

function __init__()
{
	zm_craftables::include_zombie_craftable( CRAFTABLE_NAME );
	zm_craftables::add_zombie_craftable( CRAFTABLE_NAME );
	
	RegisterClientField( "world", CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_0, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, false );
	RegisterClientField( "world", CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_1, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, false );
	RegisterClientField( "world", CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_2, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, false );
	RegisterClientField( "world", CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_3, VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, false );
}

