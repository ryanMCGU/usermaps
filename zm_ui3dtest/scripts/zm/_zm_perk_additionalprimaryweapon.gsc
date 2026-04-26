#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

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

#insert scripts\zm\_zm_perk_additionalprimaryweapon.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "material", "specialty_extraprimaryweapon_zombies" );
#precache( "string", "ZOMBIE_PERK_ADDITIONALPRIMARYWEAPON" );
#precache( "string", ADDITIONAL_PRIMARY_WEAPON_PERK_INFO_STRING );
#precache( "fx", ADDITIONAL_PRIMARY_WEAPON_MACHINE_FX_FILE_MACHINE_LIGHT );

#namespace zm_perk_additionalprimaryweapon;

REGISTER_SYSTEM( "zm_perk_additionalprimaryweapon", &__init__, undefined )

// ADDITIONAL PRIMARY WEAPON ( MULE KICK )

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	level.additionalprimaryweapon_limit = 3;

	enable_additional_primary_weapon_perk_for_level();
	
	callback::on_laststand( &on_laststand );
	level.return_additionalprimaryweapon = &return_additionalprimaryweapon;
}

function enable_additional_primary_weapon_perk_for_level()
{	
	// register sleight of hand perk for level
	zm_perks::register_perk_basic_info( PERK_ADDITIONAL_PRIMARY_WEAPON, "additionalprimaryweapon", ADDITIONAL_PRIMARY_WEAPON_PERK_COST, ADDITIONAL_PRIMARY_WEAPON_PERK_INFO_STRING, GetWeapon( ADDITIONAL_PRIMARY_WEAPON_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( PERK_ADDITIONAL_PRIMARY_WEAPON, &additional_primary_weapon_precache );
	zm_perks::register_perk_clientfields( PERK_ADDITIONAL_PRIMARY_WEAPON, &additional_primary_weapon_register_clientfield, &additional_primary_weapon_set_clientfield );
	zm_perks::register_perk_machine( PERK_ADDITIONAL_PRIMARY_WEAPON, &additional_primary_weapon_perk_machine_setup );
	zm_perks::register_perk_threads( PERK_ADDITIONAL_PRIMARY_WEAPON, &give_additional_primary_weapon_perk, &take_additional_primary_weapon_perk );
	zm_perks::register_perk_host_migration_params( PERK_ADDITIONAL_PRIMARY_WEAPON, ADDITIONAL_PRIMARY_WEAPON_RADIANT_MACHINE_NAME, ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX );
}

function additional_primary_weapon_precache()
{
	if( IsDefined(level.additional_primary_weapon_precache_override_func) )
	{
		[[ level.additional_primary_weapon_precache_override_func ]]();
		return;
	}
	
	level._effect[ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX] = ADDITIONAL_PRIMARY_WEAPON_MACHINE_FX_FILE_MACHINE_LIGHT;
	
	level.machine_assets[PERK_ADDITIONAL_PRIMARY_WEAPON] = SpawnStruct();
	level.machine_assets[PERK_ADDITIONAL_PRIMARY_WEAPON].weapon = GetWeapon( ADDITIONAL_PRIMARY_WEAPON_PERK_BOTTLE_WEAPON );
	level.machine_assets[PERK_ADDITIONAL_PRIMARY_WEAPON].off_model = ADDITIONAL_PRIMARY_WEAPON_MACHINE_DISABLED_MODEL;
	level.machine_assets[PERK_ADDITIONAL_PRIMARY_WEAPON].on_model = ADDITIONAL_PRIMARY_WEAPON_MACHINE_ACTIVE_MODEL;
}

function additional_primary_weapon_register_clientfield()
{
	clientfield::register( "clientuimodel", PERK_CLIENTFIELD_ADDITIONAL_PRIMARY_WEAPON, VERSION_SHIP, 2, "int" );
}

function additional_primary_weapon_set_clientfield( state )
{
	self clientfield::set_player_uimodel( PERK_CLIENTFIELD_ADDITIONAL_PRIMARY_WEAPON, state );
}

function additional_primary_weapon_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_mulekick_jingle";
	use_trigger.script_string = "tap_perk";
	use_trigger.script_label = "mus_perks_mulekick_sting";
	use_trigger.target = ADDITIONAL_PRIMARY_WEAPON_RADIANT_MACHINE_NAME;
	perk_machine.script_string = "tap_perk";
	perk_machine.targetname = ADDITIONAL_PRIMARY_WEAPON_RADIANT_MACHINE_NAME;
	if(IsDefined(bump_trigger))
	{
		bump_trigger.script_string = "tap_perk";
	}
}

function give_additional_primary_weapon_perk()
{
	self notify (PERK_ADDITIONAL_PRIMARY_WEAPON + "_start");	

	self thread extra_ammo_logic();
	self extra_nade_logic();
}

function take_additional_primary_weapon_perk( b_pause, str_perk, str_result )
{
	self notify (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");	

	if ( b_pause || str_result == str_perk )
	{
		self take_additionalprimaryweapon();
	}

	if (IsDefined (self.extra_ammo_hud))
		self.extra_ammo_hud Destroy();
	if (IsDefined (self.extra_lethal_hud))
		self.extra_lethal_hud Destroy();
	if (IsDefined (self.extra_tact_hud))
		self.extra_tact_hud Destroy();
}

function take_additionalprimaryweapon()
{
	weapon_to_take = level.weaponNone;

	if ( IS_TRUE( self._retain_perks ) || ( IsDefined( self._retain_perks_array ) && IS_TRUE( self._retain_perks_array[ PERK_ADDITIONAL_PRIMARY_WEAPON ] ) ) )
	{
		return weapon_to_take;
	}

	primary_weapons_that_can_be_taken = [];

	primaryWeapons = self GetWeaponsListPrimaries();
	for ( i = 0; i < primaryWeapons.size; i++ )
	{
		if ( zm_weapons::is_weapon_included( primaryWeapons[i] ) || zm_weapons::is_weapon_upgraded( primaryWeapons[i] ) )
		{
			primary_weapons_that_can_be_taken[primary_weapons_that_can_be_taken.size] = primaryWeapons[i];
		}
	}

	self.weapons_taken_by_losing_specialty_additionalprimaryweapon = [];
	pwtcbt = primary_weapons_that_can_be_taken.size;
	while ( pwtcbt >= 3 )
	{
		weapon_to_take = primary_weapons_that_can_be_taken[pwtcbt - 1];
		self.weapons_taken_by_losing_specialty_additionalprimaryweapon[weapon_to_take] = zm_weapons::get_player_weapondata( self, weapon_to_take );
		pwtcbt--;
		if ( weapon_to_take == self GetCurrentWeapon() )
		{
			self SwitchToWeapon( primary_weapons_that_can_be_taken[0] );
		}
		self TakeWeapon( weapon_to_take );
	}

	return weapon_to_take;
}

function on_laststand()
{
 	if ( self HasPerk( PERK_ADDITIONAL_PRIMARY_WEAPON ) )
 	{
		self.weapon_taken_by_losing_specialty_additionalprimaryweapon = take_additionalprimaryweapon();
 	}	
}

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
// ======================================================================================================
// Extra Grenades
// ======================================================================================================

function extra_nade_logic() {
	//SELF == PLAYER

	self thread extra_lethal_logic();
	self thread extra_tactical_logic();
}

// ======================================================================================================
// Extra Lethals
// ======================================================================================================

function extra_lethal_logic() {
	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");

	self.extra_lethal_watch = [];

	self thread extra_lethal_weapon_purchase_watch();
	self thread extra_lethal_weapon_ammo_purchase_watch();
	self thread extra_lethal_max_ammo_watch();
	self thread extra_lethal_weapon_take_watch();
	self thread extra_lethal_end_round_watch();

	for (;;) {
		weapon = self zm_utility::get_player_lethal_grenade();

		if (((IsDefined (weapon.clipsize) && weapon.clipsize > 0) || (IsDefined (weapon.maxAmmo) && weapon.maxAmmo > 0)))
		{
			if (!IsDefined (self.extra_lethal_watch [weapon.name]))
				if (!IsDefined (weapon.unlimitedAmmo) || !weapon.unlimitedAmmo)
					self.extra_lethal_watch [weapon.name] = extra_lethal_get_stocksize (weapon);
			
			if (IsDefined (self.extra_lethal_watch [weapon.name]))
			{
				if (IsDefined (weapon.maxAmmo) && weapon.maxAmmo > 0)
				{
					stock = self GetWeaponAmmoStock (weapon);
					
					if (stock < weapon.maxAmmo)
					{
						add_to_stock = weapon.maxAmmo - stock;
						
						if (self.extra_lethal_watch [weapon.name] < add_to_stock)
							add_to_stock = self.extra_lethal_watch [weapon.name];
							
						self.extra_lethal_watch [weapon.name] -= add_to_stock;
						self SetWeaponAmmoStock (weapon, stock + add_to_stock);
					}
				}
				
				else if (IsDefined (weapon.clipsize) && weapon.clipsize > 0)
				{
					clip = self GetWeaponAmmoClip (weapon);
					
					if (clip < weapon.clipsize)
					{
						add_to_clip = weapon.clipsize - clip;
						
						if (self.extra_lethal_watch [weapon.name] < add_to_clip)
							add_to_clip = self.extra_lethal_watch [weapon.name];
							
						self.extra_lethal_watch [weapon.name] -= add_to_clip;
						self SetWeaponAmmoClip (weapon, clip + add_to_clip);	
					}
				}
				
				if (self.extra_lethal_watch [weapon.name] > 0)
				{
					if (EXTRA_LETHAL_DRAW_AMMO_STOCK == 1)
					{
						if (!IsDefined (self.extra_lethal_hud))
							self.extra_lethal_hud = reap_create_hud_text (EXTRA_LETHAL_ALIGN_X, EXTRA_LETHAL_ALIGN_Y, EXTRA_LETHAL_ALIGN_X, EXTRA_LETHAL_ALIGN_Y, EXTRA_LETHAL_X, EXTRA_LETHAL_Y, .8, EXTRA_LETHAL_COLOR, "+" + self.extra_lethal_watch [weapon.name], 2);
						
						self.extra_lethal_hud SetText ("+" + self.extra_lethal_watch [weapon.name]);
					}
				}
				
				else
					if (IsDefined (self.extra_lethal_hud))
						self.extra_lethal_hud Destroy();
			}
			
			else
				if (IsDefined (self.extra_lethal_hud))
					self.extra_lethal_hud Destroy();
		}
		
		wait 1;
	}
}

function extra_lethal_get_stocksize (weapon)
{
	if (IsDefined (weapon.clipsize) && weapon.clipsize > 0)
	{
		return EXTRA_LETHAL_MULTIPLIER;
	}
	
	else if (IsDefined (weapon.maxAmmo) && weapon.maxAmmo > 0)
		return weapon.maxAmmo;

	return 0;
}

function extra_lethal_weapon_purchase_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("weapon_give", weapon);
		
		WAIT_SERVER_FRAME;
		
		if (IsDefined (self.extra_ammo_set_stock))
		{
			self.extra_lethal_watch [weapon.name] = self.extra_ammo_set_stock;
			self.extra_ammo_set_stock = undefined;
		}
		
		else if (IsDefined (self.extra_lethal_watch [weapon.name]))
			self.extra_lethal_watch [weapon.name] = undefined;			
	}
}

function extra_lethal_weapon_ammo_purchase_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("weapon_ammo_restocked", weapon);
		
		WAIT_SERVER_FRAME;
		
		if (IsDefined (self.extra_lethal_watch [weapon.name]))
			self.extra_lethal_watch [weapon.name] = undefined;
	}
}

function extra_lethal_max_ammo_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("zmb_max_ammo");
		
		WAIT_SERVER_FRAME;
		
		self.extra_lethal_watch = [];
	}
}

function extra_lethal_weapon_take_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("weapon_take", weapon);
		
		WAIT_SERVER_FRAME;
		
		if (IsDefined (self.extra_lethal_watch [weapon.name]))
			self.extra_lethal_watch [weapon.name] = undefined;
	}
}

function extra_lethal_end_round_watch() {
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		level waittill ("start_of_round");
		
		WAIT_SERVER_FRAME;
		wait 1;
		
		self.extra_lethal_watch = [];
	}
}

// ======================================================================================================
// Extra Tacticals
// ======================================================================================================

function extra_tactical_logic() {
	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");

	self.extra_tactical_watch = [];

	self thread extra_tactical_weapon_purchase_watch();
	self thread extra_tactical_weapon_ammo_purchase_watch();
	self thread extra_tactical_max_ammo_watch();
	self thread extra_tactical_weapon_take_watch();

	for (;;) {
		weapon = self zm_utility::get_player_tactical_grenade();

		if (((IsDefined (weapon.clipsize) && weapon.clipsize > 0) || (IsDefined (weapon.maxAmmo) && weapon.maxAmmo > 0)))
		{
			if (!IsDefined (self.extra_tactical_watch [weapon.name]))
				if (!IsDefined (weapon.unlimitedAmmo) || !weapon.unlimitedAmmo)
					self.extra_tactical_watch [weapon.name] = extra_tactical_get_stocksize (weapon);
			
			if (IsDefined (self.extra_tactical_watch [weapon.name]))
			{
				if (IsDefined (weapon.maxAmmo) && weapon.maxAmmo > 0)
				{
					stock = self GetWeaponAmmoStock (weapon);
					
					if (stock < weapon.maxAmmo)
					{
						add_to_stock = weapon.maxAmmo - stock;
						
						if (self.extra_tactical_watch [weapon.name] < add_to_stock)
							add_to_stock = self.extra_tactical_watch [weapon.name];
							
						self.extra_tactical_watch [weapon.name] -= add_to_stock;
						self SetWeaponAmmoStock (weapon, stock + add_to_stock);
					}
				}
				
				else if (IsDefined (weapon.clipsize) && weapon.clipsize > 0)
				{
					clip = self GetWeaponAmmoClip (weapon);
					
					if (clip < weapon.clipsize)
					{
						add_to_clip = weapon.clipsize - clip;
						
						if (self.extra_tactical_watch [weapon.name] < add_to_clip)
							add_to_clip = self.extra_tactical_watch [weapon.name];
							
						self.extra_tactical_watch [weapon.name] -= add_to_clip;
						self SetWeaponAmmoClip (weapon, clip + add_to_clip);	
					}
				}
				
				if (self.extra_tactical_watch [weapon.name] > 0)
				{
					if (EXTRA_TACT_DRAW_AMMO_STOCK == 1)
					{
						if (!IsDefined (self.extra_tactical_hud))
							self.extra_tactical_hud = reap_create_hud_text (EXTRA_TACT_ALIGN_X, EXTRA_TACT_ALIGN_Y, EXTRA_TACT_ALIGN_X, EXTRA_TACT_ALIGN_Y, EXTRA_TACT_X, EXTRA_TACT_Y, .8, EXTRA_TACT_COLOR, "+" + self.extra_tactical_watch [weapon.name], 2);
						
						self.extra_tactical_hud SetText ("+" + self.extra_tactical_watch [weapon.name]);
					}
				}
				
				else
					if (IsDefined (self.extra_tactical_hud))
						self.extra_tactical_hud Destroy();
			}
			
			else
				if (IsDefined (self.extra_tactical_hud))
					self.extra_tactical_hud Destroy();
		}
		
		wait 1;
	}
}

function extra_tactical_get_stocksize (weapon)
{
	if (IsDefined (weapon.clipsize) && weapon.clipsize > 0)
	{
		return EXTRA_TACT_MULTIPLIER;
	}
	
	else if (IsDefined (weapon.maxAmmo) && weapon.maxAmmo > 0)
		return weapon.maxAmmo;

	return 0;
}

function extra_tactical_weapon_purchase_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("weapon_give", weapon);
		
		WAIT_SERVER_FRAME;
		
		if (IsDefined (self.extra_ammo_set_stock))
		{
			self.extra_tactical_watch [weapon.name] = self.extra_ammo_set_stock;
			self.extra_ammo_set_stock = undefined;
		}
		
		else if (IsDefined (self.extra_tactical_watch [weapon.name]))
			self.extra_tactical_watch [weapon.name] = undefined;			
	}
}

function extra_tactical_weapon_ammo_purchase_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("weapon_ammo_restocked", weapon);
		
		WAIT_SERVER_FRAME;
		
		if (IsDefined (self.extra_tactical_watch [weapon.name]))
			self.extra_tactical_watch [weapon.name] = undefined;
	}
}

function extra_tactical_max_ammo_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("zmb_max_ammo");
		
		WAIT_SERVER_FRAME;
		
		self.extra_tactical_watch = [];
	}
}

function extra_tactical_weapon_take_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("weapon_take", weapon);
		
		WAIT_SERVER_FRAME;
		
		if (IsDefined (self.extra_tactical_watch [weapon.name]))
			self.extra_tactical_watch [weapon.name] = undefined;
	}
}

// ======================================================================================================
// Extra Ammo
// ======================================================================================================

function extra_ammo_logic()
{
	//SELF == PLAYER
	
	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	self.extra_ammo_watch = [];
	
	self thread extra_ammo_weapon_purchase_watch();
	self thread extra_ammo_weapon_ammo_purchase_watch();
	self thread extra_ammo_max_ammo_watch();
	self thread extra_ammo_weapon_take_watch();
	
	for (;;)
	{
		weapon = self GetCurrentWeapon();
		
		if (((IsDefined (weapon.clipsize) && weapon.clipsize > 0) || (IsDefined (weapon.maxAmmo) && weapon.maxAmmo > 0)) &&
			!zm_utility::is_offhand_weapon (weapon))
		{
			if (!IsDefined (self.extra_ammo_watch [weapon.name]))
				if (!IsDefined (weapon.unlimitedAmmo) || !weapon.unlimitedAmmo)
					self.extra_ammo_watch [weapon.name] = extra_ammo_get_stocksize (weapon);
			
			if (IsDefined (self.extra_ammo_watch [weapon.name]))
			{
				if (IsDefined (weapon.maxAmmo) && weapon.maxAmmo > 0)
				{
					stock = self GetWeaponAmmoStock (weapon);
					
					if (stock < weapon.maxAmmo)
					{
						add_to_stock = weapon.maxAmmo - stock;
						
						if (self.extra_ammo_watch [weapon.name] < add_to_stock)
							add_to_stock = self.extra_ammo_watch [weapon.name];
							
						self.extra_ammo_watch [weapon.name] -= add_to_stock;
						self SetWeaponAmmoStock (weapon, stock + add_to_stock);
					}
				}
				
				else if (IsDefined (weapon.clipsize) && weapon.clipsize > 0)
				{
					clip = self GetWeaponAmmoClip (weapon);
					
					if (clip < weapon.clipsize)
					{
						add_to_clip = weapon.clipsize - clip;
						
						if (self.extra_ammo_watch [weapon.name] < add_to_clip)
							add_to_clip = self.extra_ammo_watch [weapon.name];
							
						self.extra_ammo_watch [weapon.name] -= add_to_clip;
						self SetWeaponAmmoClip (weapon, clip + add_to_clip);	
					}
				}
				
				if (self.extra_ammo_watch [weapon.name] > 0)
				{
					if (EXTRA_AMMO_DRAW_AMMO_STOCK == 1)
					{
						if (!IsDefined (self.extra_ammo_hud))
							self.extra_ammo_hud = reap_create_hud_text (EXTRA_AMMO_ALIGN_X, EXTRA_AMMO_ALIGN_Y, EXTRA_AMMO_ALIGN_X, EXTRA_AMMO_ALIGN_Y, EXTRA_AMMO_X, EXTRA_AMMO_Y, .8, EXTRA_AMMO_COLOR, "+" + self.extra_ammo_watch [weapon.name], 2);
						
						self.extra_ammo_hud SetText ("+" + self.extra_ammo_watch [weapon.name]);
					}
				}
				
				else
					if (IsDefined (self.extra_ammo_hud))
						self.extra_ammo_hud Destroy();
			}
			
			else
				if (IsDefined (self.extra_ammo_hud))
					self.extra_ammo_hud Destroy();
		}
		
		wait 1;
	}
}

function extra_ammo_get_stocksize (weapon)
{
	if (zm_utility::is_offhand_weapon (weapon)) {
		return 0;
	}

	if (IsDefined (weapon.clipsize) && weapon.clipsize > 0)
	{
		if ((IsDefined (weapon.dualwieldweapon) && weapon.dualwieldweapon != level.weaponnone) && 
			(IsDefined (weapon.dualwieldweapon.clipsize) && weapon.dualwieldweapon.clipsize > 0))
		{	
			clip_sum = weapon.clipsize + weapon.dualwieldweapon.clipsize;
			
			return clip_sum * EXTRA_AMMO_MULTIPLIER;
		}
	
		return weapon.clipsize * EXTRA_AMMO_MULTIPLIER;
	}
	
	else if (IsDefined (weapon.maxAmmo) && weapon.maxAmmo > 0)
		return weapon.maxAmmo;

	return 0;
}

function extra_ammo_weapon_purchase_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("weapon_give", weapon);
		
		WAIT_SERVER_FRAME;
		
		if (IsDefined (self.extra_ammo_set_stock))
		{
			self.extra_ammo_watch [weapon.name] = self.extra_ammo_set_stock;
			self.extra_ammo_set_stock = undefined;
		}
		
		else if (IsDefined (self.extra_ammo_watch [weapon.name]))
			self.extra_ammo_watch [weapon.name] = undefined;			
	}
}

function extra_ammo_weapon_ammo_purchase_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("weapon_ammo_restocked", weapon);
		
		WAIT_SERVER_FRAME;
		
		if (IsDefined (self.extra_ammo_watch [weapon.name]))
			self.extra_ammo_watch [weapon.name] = undefined;
	}
}

function extra_ammo_max_ammo_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("zmb_max_ammo");
		
		WAIT_SERVER_FRAME;
		
		self.extra_ammo_watch = [];
	}
}

function extra_ammo_weapon_take_watch()
{
	//SELF == PLAYER

	self endon (PERK_ADDITIONAL_PRIMARY_WEAPON + "_stop");
	self endon ("disconnect");
	level endon ("end_game");
	level endon ("game_over");
	
	for (;;)
	{
		self waittill ("weapon_take", weapon);
		
		WAIT_SERVER_FRAME;
		
		if (IsDefined (self.extra_ammo_watch [weapon.name]))
			self.extra_ammo_watch [weapon.name] = undefined;
	}
}

function reap_create_hud_text (aligX, aligY, horzAlin, vertAlin, x, y, alp, color, text, size)
{
	hud = undefined;
	
	if (self == level)
		hud = newHudElem();
		
	else
		hud = NewClientHudElem (self);
		
	hud.alignX = aligX; 
	hud.alignY = aligY;
	hud.horzAlign = horzAlin; 
	hud.vertAlign = vertAlin;
	hud.x = x;
	hud.y = y;
	hud.alpha = alp;
	hud.color = color;
	hud.fontScale = size;
	hud setText (text);
	
	return hud;
}