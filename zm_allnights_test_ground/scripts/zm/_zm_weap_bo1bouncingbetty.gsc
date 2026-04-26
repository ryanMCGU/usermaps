#using scripts\zm\_zm_score;
#using scripts\shared\callbacks_shared;
#using scripts\codescripts\struct;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_placeable_mine;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\weapons\_weaponobjects;
#using scripts\zm\gametypes\_globallogic_score;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_weap_bo1bouncingbetty;

REGISTER_SYSTEM_EX( "zm_weap_bo1bouncingbetty", &__init__, &__main__, undefined )

function __init__() {
	// If your using this in a mod for a map uncomment this and remove the __main__() stuff
	// weaponobjects::createRetrievableHint( "bo1_bouncingbetty", "Hold ^3[{+activate}]^7 to pick up Betty" );
	// level.placeable_mines[ "bo1_bouncingbetty" ] = GetWeapon( "bo1_bouncingbetty" );
	// ARRAY_ADD( level.placeable_mine_planted_callbacks["bo1_bouncingbetty"], &do_nothing );
}

function do_nothing(nothing) {}

function __main__()
{	
	level.waw_betties = GetWeapon("bo1_bouncingbetty");

	// weaponobjects::createRetrievableHint( "bo1_bouncingbetty", "Hold ^3[{+activate}]^7 to pick up Betty" );
	level.placeable_mines[ "bo1_bouncingbetty" ] = GetWeapon( "bo1_bouncingbetty" );
	ARRAY_ADD( level.placeable_mine_planted_callbacks["bo1_bouncingbetty"], &do_nothing );

	zm_weapons::register_zombie_weapon_callback( level.waw_betties, &player_give_betty);

	callback::on_spawned( &watchBetties );
}

function player_give_betty( str_weapon = "bo1_bouncingbetty" )
{
	level endon( "game_ended" );

	//IPrintLnBold("Betties Purchased");

	self GiveWeapon(level.waw_betties);
	self zm_utility::set_player_placeable_mine( level.waw_betties );
	self SetActionSlot(4, "weapon", level.waw_betties);
	self SetWeaponAmmoStock(level.waw_betties, 2);
	//self SwitchToWeapon( level.waw_betties );

	self thread giveBettyEachRound();
}

function giveBettyEachRound() {
	level endon("end_game");
	
	self endon("disconnect");

	for (;;) {
		level waittill( "start_of_round" );

		self SetWeaponAmmoStock(level.waw_betties, 2);
	}
}


function watchBetties()
{
	self endon( "disconnect" );

	level endon("end_game");

	self globallogic_score::initPersStat( "bo1_bouncingbetty_planted", false );
	self globallogic_score::initPersStat( "bo1_bouncingbetty_pickedup", false );
	
	for( ;; ) {
		self waittill( "grenade_fire", betty, weap );
		
		if( isdefined( weap ) && weap.name == "bo1_bouncingbetty" )
		{
			//IPrintLnBold("Watching Betties");
			betty.owner = self;
			betty thread handlePickupTrigger();
		}
	}
}

function deathWatch(trigger) {
	level endon("end_game");

	self waittill("death");

	trigger Delete();
}

function handlePickupTrigger() {
	level endon("end_game");

	self endon("death");

	self endon("betty_pickup");
	
	trigger = Spawn("trigger_radius_use", self.origin, 0, 32, 32);
	trigger SetCursorHint( "HINT_NOICON" );

	players = GetPlayers();
	foreach (player in players) {
		trigger SetInvisibleToPlayer( player );
	}

	trigger SetVisibleToPlayer( self.owner );
	trigger.owner = self.owner;
	trigger SetHintLowPriority(true);
	trigger TriggerIgnoreTeam();
	trigger SetTeamForTrigger("allies");

	self thread deathWatch(trigger);

	trigger SetHintString( "Hold ^3[{+activate}]^7 to pick up Betty" ); 
	
	trigger enablelinkto();
	trigger linkto( self );

	//IPrintLnBold("Created Pick Up Trigger");

	while (1) {
		trigger waittill( "trigger", player );
		if(player != self.owner)
			continue;
		else if(player == self.owner)
		{
			self.owner.betty_ammo_max = false;
			
			self pickup_betty();
			
			if (!self.owner.betty_ammo_max)
				self notify("betty_pickup");
			
			continue;
		}
		
		wait(0.05);
	}
}

function pickup_betty()
{
	ammo = self.owner GetWeaponAmmoStock( level.waw_betties );
	if (ammo >= 2){
		self.owner.betty_ammo_max = true;
		return;
	}
	else if(ammo < 2)
		new_ammo = self.owner GetWeaponAmmoStock( level.waw_betties ) + 1;
	else
		new_ammo = 2;
	self.owner  GiveWeapon(level.waw_betties);
	self.owner  SetActionSlot(4,"weapon",level.waw_betties);
	self.owner  SetWeaponAmmoClip(level.waw_betties,new_ammo);
	self Delete();
	//IPrintLnBold("Betty Picked Up");
}