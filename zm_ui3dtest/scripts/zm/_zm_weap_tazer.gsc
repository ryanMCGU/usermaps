// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
// #using scripts\zm_common\zm_loadout.gsc;
#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_melee_weapon;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;

#namespace zm_weap_galvaknuckles_t8;

function autoexec __init__system__()
{
	system::register( "galvaknuckles", &__init__, &__main__, undefined );
}

function private __init__()
{
	zm_utility::register_melee_weapon_for_level( "t6_tazer_knuckles" );
	level.w_tazerknuckles = getweapon( "t6_tazer_knuckles");
	callback::on_ai_killed(&on_ai_killed);
}

function private __main__()
{
	prompt = &"ZOMBIE_WEAPONCOSTONLY_CFILL"; 

	// if ( !IS_TRUE( level.weapon_cost_client_filled ))
	// {
	// 	prompt = &"ZOMBIE_WEAPON_TAZER_BUY";
	// }

	zm_melee_weapon::init( "t6_tazer_knuckles",  "t6_tazer_knuckles_flourish", undefined, undefined, 5000, "tazer_upgrade",  prompt, "galva", undefined);

	zm_melee_weapon::set_fallback_weapon( "t6_tazer_knuckles", "zombie_fists_tazer" );
}

function on_ai_killed(s_params)
{
	wait(0.15);
	if(s_params.weapon === level.w_tazerknuckles && isdefined(self) && isactor(self) && isdefined(s_params.eattacker))
	{
		var_5b84ed9a = s_params.eattacker getcentroid();
		var_2640e082 = 15 * (vectornormalize(self getcentroid() - var_5b84ed9a)) + vectorscale((0, 0, 1), 0.1);
		self startragdoll();
		self launchragdoll(var_2640e082);
	}
}

