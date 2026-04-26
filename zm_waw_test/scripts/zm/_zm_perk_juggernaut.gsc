#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_util;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_zm_perk_juggernaut.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "material", "specialty_juggernaut_zombies" );
#precache( "string", "ZOMBIE_PERK_JUGGERNAUT" );
#precache( "fx", "zombie/fx_perk_juggernaut_zmb" );

#namespace zm_perk_juggernaut;


REGISTER_SYSTEM( "zm_perk_juggernaut", &__init__, undefined )

// JUGGERNAUT

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	enable_juggernaut_perk_for_level();
}

function enable_juggernaut_perk_for_level()
{	
	// register juggernaut perk for level
	zm_perks::register_perk_basic_info( PERK_JUGGERNOG, "juggernog", JUGGERNAUT_PERK_COST, "Hold ^3[{+activate}]^7 for Juggernog 2.0 [Cost: &&1] \n ^8Increases the player health regeneration and can survive an extra hit", GetWeapon( JUGGERNAUT_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( PERK_JUGGERNOG, &juggernaut_precache );
	zm_perks::register_perk_clientfields( PERK_JUGGERNOG, &juggernaut_register_clientfield, &juggernaut_set_clientfield );
	zm_perks::register_perk_machine( PERK_JUGGERNOG, &juggernaut_perk_machine_setup, &init_juggernaut );
	zm_perks::register_perk_threads( PERK_JUGGERNOG, &give_juggernaut_perk, &take_juggernaut_perk );
	zm_perks::register_perk_host_migration_params( PERK_JUGGERNOG, JUGGERNAUT_RADIANT_MACHINE_NAME, JUGGERNAUT_MACHINE_LIGHT_FX );
}	
	
function init_juggernaut()
{	
	// tweakable variables
	zombie_utility::set_zombie_var( "zombie_perk_juggernaut_health",	100 );
	zombie_utility::set_zombie_var( "zombie_perk_juggernaut_health_upgrade",	150 );		
}

function juggernaut_precache()
{
	if( IsDefined(level.juggernaut_precache_override_func) )
	{
		[[ level.juggernaut_precache_override_func ]]();
		return;
	}
	
	level._effect[JUGGERNAUT_MACHINE_LIGHT_FX] = "zombie/fx_perk_juggernaut_zmb";
	
	level.machine_assets[PERK_JUGGERNOG] = SpawnStruct();
	level.machine_assets[PERK_JUGGERNOG].weapon = GetWeapon( JUGGERNAUT_PERK_BOTTLE_WEAPON );
	level.machine_assets[PERK_JUGGERNOG].off_model = JUGGERNAUT_MACHINE_DISABLED_MODEL;
	level.machine_assets[PERK_JUGGERNOG].on_model = JUGGERNAUT_MACHINE_ACTIVE_MODEL;
}

function juggernaut_register_clientfield()
{
	clientfield::register( "clientuimodel", PERK_CLIENTFIELD_JUGGERNAUT, VERSION_SHIP, 2, "int" );
}

function juggernaut_set_clientfield( state )
{
	self clientfield::set_player_uimodel( PERK_CLIENTFIELD_JUGGERNAUT, state );
}

function juggernaut_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_jugganog_jingle";
	use_trigger.script_string = "jugg_perk";
	use_trigger.script_label = "mus_perks_jugganog_sting";
	use_trigger.longJingleWait = true;
	use_trigger.target = "vending_jugg";
	perk_machine.script_string = "jugg_perk";
	perk_machine.targetname = "vending_jugg";
	if( IsDefined( bump_trigger ) )
	{
		bump_trigger.script_string = "jugg_perk";
	}
}

function give_juggernaut_perk(b_pause, str_perk, str_result)
{
	// Increment player max health if its the jugg perk
	//self zm_perks::perk_set_max_health_if_jugg( PERK_JUGGERNOG, true, false );

	// SELF == PLAYER

	self endon ("disconnect");
	self endon ("lost_" + PERK_JUGGERNOG);	
	
	self notify (PERK_JUGGERNOG + "_start");	
	IPrintLnBold("Jugg Gave");
	self.maxhealth = VERRUCKT_PLAYER_MAX_HEALTH;
	self.health = self.maxhealth;

	self thread verruckt_jug_health_regen();
}

function take_juggernaut_perk( b_pause, str_perk, str_result )
{
	// Increment player max health if its the jugg perk
	//self zm_perks::perk_set_max_health_if_jugg( "health_reboot", true, true );

	// SELF == PLAYER

	self notify ("perk_lost", str_perk);
	self notify ("lost_" + PERK_JUGGERNOG);
	self notify (PERK_JUGGERNOG + "_stop");
	
	IPrintLnBold("Jugg Lost");
	self.maxhealth = level.zombie_vars ["player_base_health"];
}

// ======================================================================================================
// Verruckt Juggernog
// ======================================================================================================

function verruckt_jug_health_regen()
{
	// SELF == PLAYER
	
	self endon (PERK_JUGGERNOG + "_stop");
	
	if (!IsPlayer(self))
		return;

	for (;;)
	{	
		IPrintLnBold("HP = ", self.maxHealth, " Current HP = ", self.health);
		self waittill ("damage", damage, attacker, dir, point, mod, model, tag, part, weapon, flags, inflictor, chargeLevel);
		IPrintLnBold("HP = ", self.maxHealth, " Current HP = ", self.health);
		while (self.health < self.maxhealth)
		{
			if ((self.maxhealth - self.health) > VERRUCKT_PLAYER_HEALTH_REGEN)
				self.health = self.health + VERRUCKT_PLAYER_HEALTH_REGEN;
	
			else
				self.health = self.maxhealth;
				
			IPrintLnBold("HP = ", self.maxHealth, " Current HP = ", self.health);
			wait (VERRUCKT_PLAYER_REGEN_CYCLE_TIME);
		}
		
		self notify ("clear_red_flashing_overlay");
	}
}

// ======================================================================================================
// Verruckt Juggernog
// ======================================================================================================

/* function enable_verruckt_jug_for_level()
{	
	zm_perks::register_perk_basic_info( 				VERRUCKT_JUG_PERK, VERRUCKT_JUG_ALIAS, VERRUCKT_JUG_PERK_COST, "Hold ^3[{+activate}]^7 for " + VERRUCKT_JUG_NAME + " [Cost: &&1] \n" + VERRUCKT_JUG_DESC, GetWeapon (VERRUCKT_JUG_BOTTLE_WEAPON));
	zm_perks::register_perk_precache_func( 				VERRUCKT_JUG_PERK, &verruckt_jug_precache);
	zm_perks::register_perk_clientfields( 				VERRUCKT_JUG_PERK, &verruckt_jug_register_clientfield, &verruckt_jug_set_clientfield);
	zm_perks::register_perk_machine( 					VERRUCKT_JUG_PERK, &verruckt_jug_machine_setup);
	zm_perks::register_perk_threads( 					VERRUCKT_JUG_PERK, &verruckt_jug_give_perk, &verruckt_jug_take_perk);
	zm_perks::register_perk_host_migration_params( 		VERRUCKT_JUG_PERK, VERRUCKT_JUG_RADIANT_MACHINE_NAME, VERRUCKT_JUG_PERK);
	//zm_perks::register_perk_machine_power_override( 	VERRUCKT_JUG_PERK, &verruckt_jug_host_migration_func);
}

function verruckt_jug_precache()
{
	level._effect [VERRUCKT_JUG_PERK]					= VERRUCKT_JUG_MACHINE_LIGHT_FX;
	
	level.machine_assets [VERRUCKT_JUG_PERK] 			= spawnStruct();
	level.machine_assets [VERRUCKT_JUG_PERK].weapon 	= GetWeapon (VERRUCKT_JUG_BOTTLE_WEAPON);
	level.machine_assets [VERRUCKT_JUG_PERK].off_model 	= VERRUCKT_JUG_MACHINE_DISABLED_MODEL;
	level.machine_assets [VERRUCKT_JUG_PERK].on_model 	= VERRUCKT_JUG_MACHINE_ACTIVE_MODEL;	
}

function verruckt_jug_register_clientfield() 
{
	clientfield::register ("clientuimodel", VERRUCKT_JUG_CLIENTFIELD, VERSION_SHIP, 1, "int");
}

function verruckt_jug_set_clientfield (state) 
{
	self clientfield::set_player_uimodel (VERRUCKT_JUG_CLIENTFIELD, state);
}

function verruckt_jug_machine_setup (use_trigger, perk_machine, bump_trigger, collision)
{
	use_trigger.script_sound 							= VERRUCKT_JUG_JINGLE;
	use_trigger.script_string 							= VERRUCKT_JUG_SCRIPT_STRING;
	use_trigger.script_label 							= VERRUCKT_JUG_STING;
	use_trigger.target 									= VERRUCKT_JUG_RADIANT_MACHINE_NAME;
	perk_machine.script_string 							= VERRUCKT_JUG_SCRIPT_STRING;
	perk_machine.targetname 							= VERRUCKT_JUG_RADIANT_MACHINE_NAME;
	if (isDefined (bump_trigger))
		bump_trigger.script_string 						= VERRUCKT_JUG_SCRIPT_STRING;
}

function verruckt_jug_give_perk (b_pause, str_perk, str_result)
{
	// SELF == PLAYER

	self endon ("disconnect");
	self endon ("lost_" + VERRUCKT_JUG_ALIAS);	
	
	self notify (VERRUCKT_JUG_PERK + "_start");	
	
	if (VERRUCKT_JUG_USE_SECONDARY_PERKS == 1)
		for (i = 0; i < VERRUCKT_JUG_SECONDARY_PERKS.size; i++)
			self SetPerk (VERRUCKT_JUG_SECONDARY_PERKS[i]);

	self.maxhealth = VERRUCKT_PLAYER_MAX_HEALTH;
	self.health = self.maxhealth;
	
	self.west_perk_purchase [self.west_perk_purchase.size] = VERRUCKT_JUG_PERK;
	self notify ("west_perk_purchased");
}

function verruckt_jug_take_perk (b_pause, str_perk, str_result)
{
	// SELF == PLAYER

	self notify ("perk_lost", str_perk);
	self notify ("lost_" + VERRUCKT_JUG_ALIAS);
	self notify (VERRUCKT_JUG_PERK + "_stop");
	
	if (VERRUCKT_JUG_USE_SECONDARY_PERKS == 1)
		for (i = 0; i < VERRUCKT_JUG_SECONDARY_PERKS.size; i++)
			self UnsetPerk (VERRUCKT_JUG_SECONDARY_PERKS[i]);
	
	self.maxhealth = level.zombie_vars ["player_base_health"];
}

function verruckt_jug_host_migration_func()
{
	a_verruckt_jug_machines = GetEntArray (VERRUCKT_JUG_RADIANT_MACHINE_NAME, "targetname");
	
	foreach (perk_machine in a_verruckt_jug_machines)
	{
		if (isDefined (perk_machine.model) && perk_machine.model == VERRUCKT_JUG_MACHINE_ACTIVE_MODEL)
		{
			perk_machine zm_perks::perk_fx (undefined, 1);
			perk_machine thread zm_perks::perk_fx (VERRUCKT_JUG_ALIAS);
		}
	}
} */