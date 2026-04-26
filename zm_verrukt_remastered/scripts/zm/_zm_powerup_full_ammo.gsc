#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_death;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_placeable_mine;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_full_ammo.gsh;

#precache( "string", "ZOMBIE_POWERUP_MAX_AMMO" );
#precache( "eventstring", "zombie_notification" );

#namespace zm_powerup_full_ammo;

REGISTER_SYSTEM_EX( "zm_powerup_full_ammo", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	zm_powerups::register_powerup( FULL_AMMO_STRING, &grab_full_ammo );
	zm_powerups::add_zombie_powerup( FULL_AMMO_STRING, FULL_AMMO_MODEL, &"ZOMBIE_POWERUP_MAX_AMMO", ( FULL_AMMO_CAN_ZOMBIES_DROP ? &zm_powerups::func_should_always_drop : &zm_powerups::func_should_never_drop ), !POWERUP_ONLY_AFFECTS_GRABBER, !POWERUP_ANY_TEAM, !POWERUP_ZOMBIE_GRABBABLE );
	zm_powerups::powerup_set_can_pick_up_in_last_stand( FULL_AMMO_STRING, FULL_AMMO_CAN_GRAB_IN_LASTSTAND );
	zm_powerups::powerup_set_statless_powerup( FULL_AMMO_STRING );
	zm_audio::sndAnnouncerVoxAdd( FULL_AMMO_STRING, FULL_AMMO_SOUND_ALIAS_SUFFIX );
}

function __main__() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function grab_full_ammo( e_player )
{	
	level thread full_ammo_powerup( self, e_player );
	
	luiNotifyEvent( &"zombie_notification", 1, &"ZOMBIE_POWERUP_MAX_AMMO" );
}

function full_ammo_powerup( drop_item, e_player )
{
	e_player thread zm_powerups::powerup_vo( FULL_AMMO_STRING );
	
	e_player playSoundToTeam( "zmb_full_ammo", e_player.team );
	
	a_players = getPlayers( e_player.team );
	
	if ( isDefined( level._get_game_module_players ) )
		a_players = [[ level._get_game_module_players ]]( e_player );
	
	level notify( "zmb_max_ammo_level" );
	
	for ( i = 0; i < a_players.size; i++ )
	{
		if ( a_players[ i ] laststand::player_is_in_laststand() )
			continue;
		
		if ( isDefined( level.check_player_is_ready_for_ammo ) )
		{
			if( !IS_TRUE( [[ level.check_player_is_ready_for_ammo ]]( a_players[ i ] ) ) )
				continue;
			
		}	

		a_primary_weapons = a_players[ i ] getWeaponsList( 1 ); 

		a_players[ i ] notify( "zmb_max_ammo" );
		a_players[ i ] notify( "zmb_lost_knife" );
		
		a_players[ i ] zm_placeable_mine::disable_all_prompts_for_player();
		
		for ( x = 0; x < a_primary_weapons.size; x++ )
		{
			if ( level.headshots_only && zm_utility::is_lethal_grenade( a_primary_weapons[ x ] ) )
				continue;
			
			if ( isDefined( level.zombie_include_equipment ) && isDefined( level.zombie_include_equipment[ a_primary_weapons[ x ] ] ) && !IS_TRUE( level.zombie_equipment[ a_primary_weapons[ x ] ].refill_max_ammo ) )
				continue;
			
			if ( isDefined( level.zombie_weapons_no_max_ammo ) && isDefined( level.zombie_weapons_no_max_ammo[ a_primary_weapons[ x ].name ] ) )
				continue;
			
			if ( zm_utility::is_hero_weapon( a_primary_weapons[ x ] ) )
				continue;			

			if ( a_players[ i ] hasWeapon( a_primary_weapons[ x ] ) )
			{
				a_players[ i ] giveMaxAmmo( a_primary_weapons[ x ] );
				if ( IS_TRUE( FULL_AMMO_WILL_REFILL_CLIP ) )
					a_players[ i ] setWeaponAmmoClip( a_primary_weapons[ x ], a_primary_weapons[ x ].clipSize );
				
			}
		}
	}
}