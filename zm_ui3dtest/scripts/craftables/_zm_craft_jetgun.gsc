#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_audio;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\shared\ai\zombie_utility;

#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\craftables\_zm_craft_jetgun.gsh;

#namespace zm_craft_jetgun;

REGISTER_SYSTEM_EX( "zm_craft_jetgun", &__init__, &__main__, undefined )
#precache( "xmodel", "wm_t6_jetgun");
#precache( "xmodel", "wm_t6_jetgun_part_1");
#precache( "xmodel", "wm_t6_jetgun_part_2");
#precache( "xmodel", "wm_t6_jetgun_part_3");
#precache( "xmodel", "wm_t6_jetgun_part_4");

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	init();
}

function init()
{
	level.jetgun_part_0 = zm_craftables::generate_zombie_craftable_piece( 	CRAFTABLE_NAME, "part_0", 32, 64, 0, 	undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_0, CRAFTABLE_IS_SHARED, "build_zs" );
	level.jetgun_part_1 = zm_craftables::generate_zombie_craftable_piece( 	CRAFTABLE_NAME, "part_1", 48, 15, 25, 	undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_1, CRAFTABLE_IS_SHARED, "build_zs" );
	level.jetgun_part_2 = zm_craftables::generate_zombie_craftable_piece( 	CRAFTABLE_NAME, "part_2", 48, 15, 25, 	undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_2, CRAFTABLE_IS_SHARED, "build_zs" );
	level.jetgun_part_3 = zm_craftables::generate_zombie_craftable_piece( 	CRAFTABLE_NAME, "part_3", 48, 15, 25, 	undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_3, CRAFTABLE_IS_SHARED, "build_zs" );
	
	RegisterClientField( "world", CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_0,	VERSION_SHIP, 1, "int", undefined, false );
	RegisterClientField( "world", CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_1,	VERSION_SHIP, 1, "int", undefined, false );
	RegisterClientField( "world", CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_2,	VERSION_SHIP, 1, "int", undefined, false );
	RegisterClientField( "world", CLIENTFIELD_JETGUN_PIECE_CRAFTABLE_PART_3,	VERSION_SHIP, 1, "int", undefined, false );
	
	jetgun 				= SpawnStruct();
	jetgun.name 			= CRAFTABLE_NAME;
	jetgun.weaponname 	= CRAFTABLE_WEAPON;
	jetgun zm_craftables::add_craftable_piece( level.jetgun_part_0 );
	jetgun zm_craftables::add_craftable_piece( level.jetgun_part_1 );
	jetgun zm_craftables::add_craftable_piece( level.jetgun_part_2 );
	jetgun zm_craftables::add_craftable_piece( level.jetgun_part_3 );
	jetgun.onBuyWeapon 	= &on_buy_weapon_jetgun;
	jetgun.triggerThink 	= &jetgun_craftable;
	
	zm_craftables::include_zombie_craftable( jetgun );
	
	zm_craftables::add_zombie_craftable( CRAFTABLE_NAME, CRAFT_READY_STRING, "Part Added", CRAFT_GRABED_STRING, &on_fully_crafted, 0 );
	zm_craftables::add_zombie_craftable_vox_category( CRAFTABLE_NAME, "build_zs" );
	zm_craftables::make_zombie_craftable_open( CRAFTABLE_NAME, CRAFTABLE_MODEL, ( 0, 0, 0 ), ( 0, 0, 0 ) ); // COMMENT THIS OUT IF YOU WANT TO ONLY BUILD IT AT ITS DEDICATED TRIGGER - OTHERWISE PLACE THAT TRIGGER UNDER THE MAP
}

function __main__()
{
}


function jetgun_craftable()
{
	zm_craftables::craftable_trigger_think( CRAFTABLE_NAME + "_craftable_trigger", CRAFTABLE_NAME, CRAFTABLE_WEAPON, CRAFT_GRAB_STRING, DELETE_TRIGGER, ONE_USE_AND_FLY );
}

// self is a WorldPiece
function on_pickup_common( player )
{
	// CallBack When Player Picks Up Craftable Piece
	//----------------------------------------------
	player playSound( "zmb_craftable_pickup" );	

	self pickup_from_mover();
	self.piece_owner = player;
}

// self is a WorldPiece
function on_drop_common( player )
{
	// CallBack When Player Drops Craftable Piece
	//-------------------------------------------
	self drop_on_mover( player );
	self.piece_owner = undefined;
}

function pickup_from_mover()
{	
	//Setup for override	
}

function on_fully_crafted()
{
	players = level.players;
	foreach ( e_player in players )
	{
		if ( zm_utility::is_player_valid( e_player ) )
		{
			// e_player thread zm_craftables::player_show_craftable_parts_ui( "zmInventory.player_crafted_shield", "zmInventory.widget_shield_parts", true );
			// e_player thread show_infotext_for_duration( ZMUI_SHIELD_CRAFTED, ZM_CRAFTABLES_FULLY_CRAFTED_UI_DURATION );
		}
	}
	
	return true;
}

function drop_on_mover( player )
{
	//Setup for override
	if ( isDefined( level.craft_jetgun_drop_override ) )
		[[ level.craft_jetgun_drop_override ]]();
	
}

function on_buy_weapon_jetgun( player ){

	weapon = GetWeapon("t6_jetgun");
    if(self.stub.equipname == "t6_jetgun") {
        if(player HasWeapon(weapon)) {
            return true;
        }

        //zm_utility::include_weapon( weapon, true );
        player zm_weapons::weapon_give(weapon);
        player playsoundtoplayer("zmb_craftable_buy_shield", player);
        return true;
    }

    return false;
}

function drop_pieces_when_boom() {
	self endon( "disconnect" );

	self DoDamage(50, self.origin);

	stub = zm_craftables::find_craftable_stub( "t6_jetgun" );

	if ( isdefined( stub ) )
	{
		craftable = stub.craftableSpawn;
		craftable.crafted = false;
		craftable.stub.crafted = false;
		craftable notify( "uncrafted" );
		level.craftables_crafted[ craftable.craftable_name ] = false;
		level notify( craftable.craftable_name + "_uncrafted" );

		for ( i = 0; i < craftable.a_pieceSpawns.size; i++ )
		{
			craftable.a_pieceSpawns[i].crafted = false;

			if ( isdefined( craftable.a_pieceSpawns[i].tag_name ) )
			{
				craftable.stub.model NotSolid();

				if ( !IS_TRUE( craftable.a_pieceSpawns[i].crafted ) )
				{
					craftable.stub.model HidePart( craftable.a_pieceSpawns[i].tag_name );
				}
				else
				{
					craftable.stub.model show();
					craftable.stub.model ShowPart( craftable.a_pieceSpawns[i].tag_name );
				}
			}
	}

	self zm_craftables::player_drop_piece(level.jetgun_part_0, 0);
	self zm_craftables::player_drop_piece(level.jetgun_part_1, 1);
	self zm_craftables::player_drop_piece(level.jetgun_part_2, 2);
	self zm_craftables::player_drop_piece(level.jetgun_part_3, 3);
}
}