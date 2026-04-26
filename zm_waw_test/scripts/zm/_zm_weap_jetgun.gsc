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

#using scripts\zm\_util;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\shared\spawner_shared;
#using scripts\shared\flag_shared;

#using scripts\zm\gametypes\_globallogic;
#using scripts\zm\gametypes\_globallogic_score;

#using scripts\shared\ai\systems\gib;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

//#precache( "fx", "dlc5/temple/fx_ztem_leak_flame_jet_os" );

#namespace zm_weap_jetgun;

REGISTER_SYSTEM_EX( "zm_weap_jetgun", &__init__, &__main__, undefined )

function __init__() {
    level.weaponZMjetgun = GetWeapon( "t6_jetgun" );
	//level._effect[ "jetgun_back_fire" ] = "dlc5/temple/fx_ztem_leak_flame_jet_os";
}

function __main__() {
    callback::on_connect( &wait_for_jetgun_fire );
    zm_spawner::register_zombie_death_event_callback( &jetgun_death );
}

function wait_for_jetgun_fire()
{
	self endon( "disconnect" );

	//self flag::init("jetgun_firing");

	//self thread handleFiringFX();

	for(;;) {
		self waittill( "weapon_fired", weapon );
		if( weapon == level.weaponZMjetgun ) { 
			self thread jetgun_fire(weapon);
		}
	}
}

//Unused: was for fx but got working in APE
function handleFiringFX() {
	self endon( "disconnect" );

	//self thread moveJetFX();
	
	for (;;) {
		if (self AttackButtonPressed()) {
			if (self GetCurrentWeapon() == level.weaponZMjetgun) {
				self flag::set("jetgun_firing");
			}
		}
		else {
			self flag::clear("jetgun_firing");
			//self notify("jetgun_firing_fx");
		}
		
		wait 0.1;
	}
}

//Unused: was for fx but got working in APE
function moveJetFX() {
	self endon( "disconnect" );
	//self endon( "jetgun_firing_fx" );

	//view_pos = self GetWeaponMuzzlePoint();
	//self.muzzle = util::spawn_model("tag_origin", view_pos);
	//self.muzzle EnableLinkTo();
	//self.muzzle LinkTo(self);
	for (;;) {
		doOnce = true;
	
		self flag::wait_till("jetgun_firing");
		while (self flag::get("jetgun_firing")) {
			if (doOnce) {
				//self.muzzle = PlayFXOnTag(level._effect[ "jetgun_back_fire" ], self, "tag_brass", false);
				doOnce = false;
			}

			wait 0.1;
		}
	
		//self.muzzle Delete(); //Cant delete client side fx
		wait 0.1;
	}
}

function jetgun_fire(weapon) {
    view_pos = self GetWeaponMuzzlePoint();
    outer_range = 150;
    zombies = array::get_all_closest( view_pos, GetAITeamArray( level.zombie_team ), undefined, undefined, outer_range * 1.1 );
    if( !isdefined( zombies ) ) return;

    for( i=0; i<zombies.size; i++ ) {
        z = zombies[i];
        if( !isdefined( z ) || !IsAlive( z ) ) continue;
        z thread damage_zombie(self, weapon);
    }
}

function damage_zombie(player, weapon) {
    self endon( "death" );

    if( !isdefined( self ) || !IsAlive( self ) ) return;
	DEFAULT( self.jetgun_damage, 0 );
	DEFAULT( self.marked_for_jetgun_death, false );
	is_dog = ( self.archetype === "zombie_dog" );
    self.jetgun_damage = Int((self.maxhealth / 8) + 1);
	if( self.jetgun_damage >= self.health || self.health <= 0 ) {
		self.marked_for_jetgun_death = true;
	}

    instakill = player zm_powerups::is_insta_kill_active();
    damage = ( instakill || is_dog || self.marked_for_jetgun_death ? self.health + 666 : self.jetgun_damage );
    self DoDamage( damage, player.origin, player, undefined, "none", "MOD_RIFLE_BULLET", 0, weapon );
	
    player zm_score::player_add_points( "thundergun_fling", 10 );
	sound_fx = Spawn("script_origin", self.origin);
	sound_fx PlaySound("wpn_t6_jetgun_grind");
	wait 0.3;
	sound_fx Delete();
}

function jetgun_death( e_attacker )
{
	if( self.damageweapon === level.weaponZMjetgun ) {
        GibServerUtils::Annihilate(self);
		if( self.archetype !== "zombie" && self.archetype !== "zombie_dog" ) return;
	
		e_attacker zm_score::player_add_points( "thundergun_fling", 60 );
	}
}