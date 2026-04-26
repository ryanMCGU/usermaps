#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

#using scripts\shared\system_shared;
#insert scripts\zm\MystifiedTulips_Essentials.gsh;
//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

#precache( "client_fx", UNDERWATER_FX_1 );
#precache( "client_fx", UNDERWATER_FX_2 );
#precache( "client_fx", RAIN_FX);
#precache( "client_fx", SNOW_FX);

#namespace essentials;

REGISTER_SYSTEM_EX( "mystifiedtulips_essentials", &__init__, &__main__, undefined )

function __main__()
{
	//Rocket Shield
	clientfield::register( "clientuimodel", "zmInventory.widget_shield_parts", VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "clientuimodel", "zmInventory.player_crafted_shield", VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );

	//player drowing sounds
	clientfield::register( "toplayer", "index", VERSION_SHIP, 4, "int", &index, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	//add weapons to box
	clientfield::register( "world", "add_ww_to_box", 1, 1, "int", &add_ww_to_box, 0, 0 );    
    clientfield::register( "world", "remove_ww_from_box", 1, 1, "int", &remove_ww_from_box, 0, 0 );

	level._effect["water_debris"] = UNDERWATER_FX_1;
	level._effect["water_player_bubbles"] = UNDERWATER_FX_2;
	level._effect["player_rain"] = RAIN_FX;
	level._effect["player_snow"] = SNOW_FX;
}
function __init__()
{
	callback::add_callback( #"on_localclient_connect", &onconnect);
	callback::on_spawned( &onspawn );
}
////////////////////////
//  PLAYER CALLBACKS  //
////////////////////////
function onspawn( localClientNum)
{
	self.recover = "nothing";
	self.swim_sound = "nothing";
	self.gulp = "nothing";
	self thread wait_for_swim(localclientnum);
}
function onconnect( localClientNum ) 
{
	//weather
	if(IsInt(WEATHER)){}
	else if(WEATHER == "rain")
	{self thread weather_player( localclientnum , "player_rain");}
	else if(WEATHER == "snow")
	{self thread weather_player( localclientnum , "player_snow");}
	//extracams
	cam_01 = GetEnt( localclientnum, "cam_01", "targetname" ); //Get the origin you placed in the map 
	if(isdefined(cam_01)){cam_01 SetExtraCam( 0, 1280, 720 );} //Activates the camera so it will be displayed on screen 
	cam_02 = GetEnt( localclientnum, "cam_02", "targetname" ); //Get the origin you placed in the map 
	if(isdefined(cam_02)){cam_02 SetExtraCam( 1, 1280, 720 );} //Activates the camera so it will be displayed on screen 
	cam_03 = GetEnt( localclientnum, "cam_03", "targetname" ); //Get the origin you placed in the map 
	if(isdefined(cam_03)){cam_03 SetExtraCam( 2, 1280, 720 );} //Activates the camera so it will be displayed on screen 
	cam_04 = GetEnt( localclientnum, "cam_04", "targetname" ); //Get the origin you placed in the map 
	if(isdefined(cam_04)){cam_04 SetExtraCam( 3, 1280, 720 );} //Activates the camera so it will be displayed on screen 
}
///////////////////////////////////////////
//  ADD WEAPONS TO MYSTERY BOX MID GAME  //
///////////////////////////////////////////
function add_ww_to_box( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
    w_weapon = getWeapon( LIST_OF_WEAPONS_TO_ADD_TO_BOX_LATER[newVal] );
    addZombieBoxWeapon( w_weapon, w_weapon.worldmodel, w_weapon.isDualWield );
}
function remove_ww_from_box( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
    w_weapon = getWeapon( LIST_OF_WEAPONS_TO_ADD_TO_BOX_LATER[newVal] );
    RemoveZombieBoxWeapon( w_weapon );
}
////////////////
//  SWIMMING  //
////////////////
function wait_for_swim(localclientnum)
{
	self endon( "entityshutdown" );
	self endon("death");
	while( true )
	{ 
		self waittill( "water_surface_underwater_begin");
		self thread swimming(localclientnum);
		self thread swim_sound(localclientnum);
		if(DEBUG == true){SubtitlePrint(localclientnum, 5, "^6" + self.name + "^7 begun swimming");}
		health = self.health;
		self waittill( "water_surface_underwater_end" );
		self thread swimming_end(localclientnum);
		if(DEBUG == true){SubtitlePrint(localclientnum, 5, "^6" + self.name + "^7 ended swimming");}
	}	
}
function swim_sound(localclientnum)
{
	self endon( "entityshutdown" );
	self endon( "water_surface_underwater_end" );
	self endon("death");
	self.swim_sound = self playloopsound( UNDERWATER_LOOP_SOUND );
	while(isdefined(self) && HOLD_BREATH_UNDERWATER != true)
	{
		wait(15);
		if(self.index == 1)
		{self.gulp = self PlaySound( localClientNum, "gulp1" );}
		else if(self.index == 2)
		{self.gulp = self PlaySound( localClientNum, "gulp2" );}
		else if(self.index == 3)
		{self.gulp = self PlaySound( localClientNum, "gulp3" );}
		else{self.gulp = self PlaySound( localClientNum, "gulp0" );}
	}
}
//play looped fx while player is underwater
function swimming(localclientnum)
{
	//when player exits underwater the looop stops
	self endon( "water_surface_underwater_end" );
	self endon( "entityshutdown" );
	self endon("death");

	while(isdefined(self))
	{
		if(self IsPlayerSwimmingUnderwater())
		{
			EnableSpeedBlur(localclientnum, UNDERWATER_BLUR_AMOUNT,.5,.75,false);

			while(self IsPlayerSwimmingUnderwater())
			{
				self.firstperson_water_fx = PlayFXOnCamera( localClientNum, level._effect["water_player_bubbles"], (0,0,0), (1,0,0), (0,0,1)  );
				self.firstperson_water_fx = PlayFXOnCamera( localClientNum, level._effect["water_debris"], (0,0,0), (1,0,0), (0,0,1)  );
				wait(2);
			}
		}
		wait(2);
	}
}
//clear fx and fades the blur out
function swimming_end(localclientnum)
{
	self endon( "water_surface_underwater_begin" );
	self endon("death");
	numb = UNDERWATER_BLUR_AMOUNT;

	self stoploopsound( self.swim_sound );
	if(self.index == 1)
	{self.recover = self PlaySound( localClientNum, "breath1" );}
	else if(self.index == 2)
	{self.recover = self PlaySound( localClientNum, "breath2" );}
	else if(self.index == 3)
	{self.recover = self PlaySound( localClientNum, "breath3" );}
	else{self.recover = self PlaySound( localClientNum, "breath0" );}

	EnableSpeedBlur(localclientnum, numb,.4,.75,false);
	wait(5);
	while(numb > 0)
	{
		EnableSpeedBlur(localclientnum, numb,.5,.75,false);
		wait(.5);
		numb = numb - .05;
	}
		DisableSpeedBlur(localclientnum);
}
//gets the character model being used from .gsc to use correct drown sounds
function index( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	if(newVal == 0)
	{self.index = 0;}
	if(newVal == 1)
	{self.index = 1;}
	if(newVal == 2)
	{self.index = 2;}
	if(newVal == 3)
	{self.index = 3;}
}
///////////////
//  WEATHER  //
///////////////
function weather_player( localclientnum, fx)
{
	self.weather_fx = PlayFXOnCamera( localClientNum, level._effect[fx], (0,0,0), (1,0,0), (0,0,1));
}

