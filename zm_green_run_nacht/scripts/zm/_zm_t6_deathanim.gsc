#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weapons;

#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

REGISTER_SYSTEM_EX( "_zm_t6_deathanim", &__init__, undefined, undefined )

function __init__()
{
    callback::on_spawned(&setLatestDeath);

	level waittill("end_game");
	
	player = level.latestPlayerDownedForDeathAnim;

	if(isdefined(player))
	{
		wait(0.5);
		player TakeAllWeapons();
		player zm_weapons::weapon_give(GetWeapon("t6_deathanim"),false,false,true,true);
	}
}

function setLatestDeath()
{
	self endon("player_spawned");
	self endon("bled_out");

	level.latestPlayerDownedForDeathAnim = self;

	while(isdefined(self))
	{
		self waittill("entering_last_stand");

		level.latestPlayerDownedForDeathAnim = self;
	}
}