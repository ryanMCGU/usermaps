#using scripts\codescripts\struct;

#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_mocomp;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie_utility;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\laststand_shared;

#using scripts\zm\_util;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm;
#using scripts\shared\spawner_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\damagefeedback_shared;

#using scripts\zm\gametypes\_globallogic;
#using scripts\zm\gametypes\_globallogic_score;
#using scripts\zm\craftables\_zm_craftables;

#using scripts\shared\ai\systems\gib;

#using scripts\zm\_zm_weap_freezegun;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;

#namespace zm_weap_elemental_grenades;

REGISTER_SYSTEM_EX( "zm_weap_elemental_grenades", &__init__, &__main__, undefined )

function __init__() {
    level.weaponTeslaNade = GetWeapon( "tesla_nade" );
    level.weaponThunderNade = GetWeapon( "thunder_nade" );
    level.weaponIceNade = GetWeapon( "ice_nade" );
}

function __main__() {
    zm::register_actor_damage_callback(&elemental_damage_modifier);
    zm_weapons::register_zombie_weapon_callback( level.weaponTeslaNade, &player_give_weaponTeslaNade );
    zm_weapons::register_zombie_weapon_callback( level.weaponThunderNade, &player_give_weaponThunderNade );
    zm_weapons::register_zombie_weapon_callback( level.weaponIceNade, &player_give_weaponIceNade );
}

// self is a player
function player_give_weaponTeslaNade( str_weapon = "tesla_nade" )
{
	// Must remove the old weapon first
	w_tactical = self zm_utility::get_player_lethal_grenade();
	if ( isdefined( w_tactical ) )
	{
		self TakeWeapon( w_tactical );	
	}

	w_weapon = GetWeapon( str_weapon );
	self GiveWeapon( w_weapon );
	self zm_utility::set_player_lethal_grenade( w_weapon );
}

// self is a player
function player_give_weaponThunderNade( str_weapon = "thunder_nade" )
{
	// Must remove the old weapon first
	w_tactical = self zm_utility::get_player_lethal_grenade();
	if ( isdefined( w_tactical ) )
	{
		self TakeWeapon( w_tactical );	
	}

	w_weapon = GetWeapon( str_weapon );
	self GiveWeapon( w_weapon );
	self zm_utility::set_player_lethal_grenade( w_weapon );
}

// self is a player
function player_give_weaponIceNade( str_weapon = "ice_nade" )
{
	// Must remove the old weapon first
	w_tactical = self zm_utility::get_player_lethal_grenade();
	if ( isdefined( w_tactical ) )
	{
		self TakeWeapon( w_tactical );	
	}

	w_weapon = GetWeapon( str_weapon );
	self GiveWeapon( w_weapon );
	self zm_utility::set_player_lethal_grenade( w_weapon );
}

function elemental_damage_modifier (e_inflictor, e_attacker, n_damage, b_flags, str_means_of_death, w_weapon, v_point, v_dir, str_hit_loc, n_ps_offset_time, n_bone_index, str_surface_type) {
    if(self.health - n_damage <= 0)
	{
		b_death = true;
	}
	else
	{
		b_death = false;
	}
    
    if(!IsPlayer(e_attacker))
	{
		return -1;
	}

    if (w_weapon == level.weaponTeslaNade) {
        str_aat = "zm_aat_dead_wire";
        self thread[[level.aat[str_aat].result_func]](b_death, e_attacker, str_means_of_death, w_weapon);
    }

    if (w_weapon == level.weaponThunderNade) {
        str_aat = "zm_aat_thunder_wall";
        self thread[[level.aat[str_aat].result_func]](b_death, e_attacker, str_means_of_death, w_weapon);
    }

    if (w_weapon == level.weaponIceNade) {
        self thread zm_weap_freezegun::do_freezegun_damage(1, e_attacker, 0);
    }

    return -1;
}