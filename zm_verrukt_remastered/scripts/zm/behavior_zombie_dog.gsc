#using scripts\shared\ai\archetype_mocomps_utility;
#using scripts\shared\ai\archetype_utility;
#using scripts\shared\ai\archetype_zombie_dog_interface;
#using scripts\shared\ai\systems\ai_interface;
#using scripts\shared\ai\systems\animation_state_machine_notetracks;
#using scripts\shared\ai\systems\animation_state_machine_utility;
#using scripts\shared\ai\systems\behavior_tree_utility;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\zombie;
#using scripts\shared\ai_shared;
#using scripts\shared\math_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\util_shared;

#using scripts\zm\_zm_utility;

#insert scripts\shared\shared.gsh;

#namespace zombiedogbehavior;

function autoexec registerbehaviorscriptfunctions()
{
	spawner::add_archetype_spawn_function( "zombie_dog", &archetypezombiedogblackboardinit );
	behaviortreenetworkutility::registerbehaviortreescriptapi( "zombieDogTargetService", &zombiedogtargetservice );
	behaviortreenetworkutility::registerbehaviortreescriptapi( "zombieDogShouldMelee", &zombiedogshouldmelee );
	behaviortreenetworkutility::registerbehaviortreescriptapi( "zombieDogShouldWalk", &zombiedogshouldwalk );
	behaviortreenetworkutility::registerbehaviortreescriptapi( "zombieDogShouldRun", &zombiedogshouldrun );
	behaviortreenetworkutility::registerbehaviortreeaction( "zombieDogMeleeAction", &zombiedogmeleeaction, undefined, &zombiedogmeleeactionterminate );
	animationstatenetwork::registernotetrackhandlerfunction( "dog_melee", &zombiebehavior::zombienotetrackmeleefire );
	zombiedoginterface::registerzombiedoginterfaceattributes();
}

function archetypezombiedogblackboardinit()
{
	blackboard::createblackboardforentity( self );
	ai::createinterfaceforentity( self );
	self aiutility::registerutilityblackboardattributes();
	blackboard::registerblackboardattribute( self, "_low_gravity", "normal", undefined );
	blackboard::registerblackboardattribute( self, "_should_run", "walk", &bb_getshouldrunstatus );
	blackboard::registerblackboardattribute( self, "_should_howl", "dont_howl", &bb_getshouldhowlstatus );
	self.___archetypeonanimscriptedcallback = &archetypezombiedogonanimscriptedcallback;
	self.kill_on_wine_coccon = 1;
}

function private archetypezombiedogonanimscriptedcallback( entity )
{
	entity.__blackboard = undefined;
	entity archetypezombiedogblackboardinit();
}

function bb_getshouldrunstatus()
{
	if( isdefined( self.hasseenfavoriteenemy )
		&& self.hasseenfavoriteenemy
		|| ( ai::hasaiattribute( self, "sprint" )
			&& ai::getaiattribute( self, "sprint" ) ) ) {
		return "run";
	}
	return "walk";
}

function bb_getshouldhowlstatus()
{
	if( self ai::has_behavior_attribute( "howl_chance" )
		&& ( isdefined( self.hasseenfavoriteenemy )
			&& self.hasseenfavoriteenemy ) ) {
		if( !isdefined( self.shouldhowl ) ) {
			chance = self ai::get_behavior_attribute( "howl_chance" );
			self.shouldhowl = RandomFloat(1) <= chance;
		}
		if( self.shouldhowl ) {
			return "howl";
		}
	}
	return "dont_howl";
}

function getyaw( org )
{
	angles = VectortoAngles( org - self.origin );
	return angles[1];
}

function absyawtoenemy()
{
	yaw = self.angles[1] - getyaw( self.enemy.origin );
	yaw = AngleClamp180( yaw );
	yaw = ( yaw < 0 ? -1 * yaw : yaw );
	return yaw;
}

function need_to_run()
{
	return true;
	run_dist_squared = self ai::get_behavior_attribute( "min_run_dist" ) * self ai::get_behavior_attribute( "min_run_dist" );
	run_yaw = 20;
	run_pitch = 30;
	run_height = 64;
	if( self.health < self.maxhealth ) return true;
	if( !isdefined( self.enemy ) || !IsAlive( self.enemy ) ) return false;
	if( !self CanSee( self.enemy ) ) return false;
	dist = DistanceSquared( self.origin, self.enemy.origin );
	if( dist > run_dist_squared ) return false;
	height = self.origin[2] - self.enemy.origin[2];
	if( Abs( height ) > run_height ) return false;
	yaw = self absyawtoenemy();
	if( yaw > run_yaw ) return false;
	pitch = AngleClamp180( VectortoAngles( self.origin - self.enemy.origin )[0] );
	if( Abs( pitch ) > run_pitch ) return false;
	return true;
}

function private is_target_valid( dog, target )
{
	if( !isdefined( target ) ) {
		return false;
	}
	if( !IsAlive( target ) ) {
		return false;
	}
	if( IsPlayer( target ) && target.sessionstate == "spectator" ) {
		return false;
	}
	if( IsPlayer( target ) && target.sessionstate == "intermission" ) {
		return false;
	}
	if( isdefined( self.intermission ) && self.intermission ) {
		return false;
	}
	if( isdefined( target.ignoreme ) && target.ignoreme ) {
		return false;
	}
	if( target IsNoTarget() ) {
		return false;
	}
	if( dog.team == target.team ) {
		return false;
	}
	if( IsPlayer( target ) && isdefined( level.is_player_valid_override ) ) {
		return [[level.is_player_valid_override]]( target );
	}
	return true;
}

function private get_favorite_enemy( dog )
{
	dog_targets = [];
	if( SessionModeIsZombiesGame() ) {
		if( self.team == "allies" ) {
			dog_targets = GetAITeamArray( level.zombie_team );
		} else {
			dog_targets = GetPlayers();
		}
	} else {
		dog_targets = ArrayCombine( GetPlayers(), GetAIArray(), 0, 0 );
	}
	least_hunted = dog_targets[0];
	closest_target_dist_squared = undefined;
	for( i=0; i<dog_targets.size; i++ ) {
		if( !isdefined( dog_targets[i].hunted_by ) ) {
			dog_targets[i].hunted_by = 0;
		}
		if( !is_target_valid( dog, dog_targets[i] ) ) {
			continue;
		}
		if( !is_target_valid( dog, least_hunted ) ) {
			least_hunted = dog_targets[i];
		}
		dist_squared = DistanceSquared( dog.origin, dog_targets[i].origin );
		if( dog_targets[i].hunted_by <= least_hunted.hunted_by
			&& ( !isdefined( closest_target_dist_squared )
				|| dist_squared < closest_target_dist_squared ) ) {
			least_hunted = dog_targets[i];
			closest_target_dist_squared = dist_squared;
		}
	}
	if( !is_target_valid( dog, least_hunted ) ) {
		return undefined;
	}
	least_hunted.hunted_by = least_hunted.hunted_by + 1;
	return least_hunted;
}

function get_last_valid_position()
{
	if( IsPlayer( self ) ) {
		return self.last_valid_position;
	}
	return self.origin;
}

function get_locomotion_target( behaviortreeentity )
{
	last_valid_position = behaviortreeentity.favoriteenemy get_last_valid_position();
	if( !isdefined( last_valid_position ) ) return undefined;
	locomotion_target = last_valid_position;
	if( ai::has_behavior_attribute( "spacing_value" ) ) {
		spacing_near_dist = ai::get_behavior_attribute( "spacing_near_dist" );
		spacing_far_dist = ai::get_behavior_attribute( "spacing_far_dist" );
		spacing_horz_dist = ai::get_behavior_attribute( "spacing_horz_dist" );
		spacing_value = ai::get_behavior_attribute( "spacing_value" );
		to_enemy = behaviortreeentity.favoriteenemy.origin - behaviortreeentity.origin;
		perp = VectorNormalize( ( to_enemy[1] * -1, to_enemy[0], 0) );
		offset = ( perp * spacing_horz_dist ) * spacing_value;
		spacing_dist = math::clamp( Length( to_enemy ), spacing_near_dist, spacing_far_dist );
		lerp_amount = math::clamp( ( spacing_dist - spacing_near_dist ) / ( spacing_far_dist - spacing_near_dist ), 0, 1 );
		desired_point = last_valid_position + ( offset * lerp_amount );
		desired_point = GetClosestPointOnNavMesh( desired_point, spacing_horz_dist * 1.2, 16 );
		if( isdefined( desired_point ) ) {
			locomotion_target = desired_point;
		}
	}
	return locomotion_target;
}

function zombiedogtargetservice( behaviortreeentity )
{
	if( IS_TRUE( level.intermission ) ) {
		behaviortreeentity ClearPath();
		return;
	}
	if( behaviortreeentity.team == "allies" ) {
		if( !isdefined( behaviortreeentity.favoriteenemy )
			|| !is_target_valid( behaviortreeentity, behaviortreeentity.favoriteenemy ) ) {
			behaviortreeentity.favoriteenemy = findzombieenemy();
			if( !isdefined( behaviortreeentity.favoriteenemy ) ) {
				behaviortreeentity.hasseenfavoriteenemy = 0;
				behaviortreeentity SetGoal( behaviortreeentity.origin );
			}
			return;
		}
	}
	if( behaviortreeentity.ignoreall
		|| behaviortreeentity.pacifist 
		|| ( isdefined( behaviortreeentity.favoriteenemy )
			&& !is_target_valid( behaviortreeentity, behaviortreeentity.favoriteenemy ) ) )  {
		if( isdefined( behaviortreeentity.favoriteenemy )
			&& isdefined( behaviortreeentity.favoriteenemy.hunted_by )
			&& behaviortreeentity.favoriteenemy.hunted_by > 0 )  {
			behaviortreeentity.favoriteenemy.hunted_by--;
		}
		behaviortreeentity.favoriteenemy = undefined;
		behaviortreeentity.hasseenfavoriteenemy = 0;
		if( !behaviortreeentity.ignoreall ) {
			behaviortreeentity SetGoal( behaviortreeentity.origin );
		}
		return;
	}
	if( isdefined( behaviortreeentity.ignoreme )
		&& behaviortreeentity.ignoreme ) {
		return;
	}
	if( !is_target_valid( behaviortreeentity, behaviortreeentity.favoriteenemy ) ) {
		behaviortreeentity.favoriteenemy = get_favorite_enemy( behaviortreeentity );
	}
	if( !( isdefined( behaviortreeentity.hasseenfavoriteenemy )
		&& behaviortreeentity.hasseenfavoriteenemy ) ) {
		if( isdefined( behaviortreeentity.favoriteenemy )
			&& behaviortreeentity need_to_run() ) {
			behaviortreeentity.hasseenfavoriteenemy = 1;
		}
	}
	if( isdefined( behaviortreeentity.favoriteenemy ) ) {
		if( isdefined( level.enemy_location_override_func ) ) {
			goalpos = [[level.enemy_location_override_func]]( behaviortreeentity, behaviortreeentity.favoriteenemy );
			if( isdefined( goalpos ) ) {
				behaviortreeentity SetGoal( goalpos );
				return;
			}
		}
		locomotion_target = get_locomotion_target( behaviortreeentity );
		if( isdefined( locomotion_target ) ) {
			repathdist = ( behaviortreeentity.team == "allies" ? 96 : 16 );
			if( !isdefined( behaviortreeentity.lasttargetposition )
				|| DistanceSquared( behaviortreeentity.lasttargetposition, locomotion_target ) > SQR( repathdist )
				|| !behaviortreeentity HasPath() ) {			
				behaviortreeentity UsePosition( locomotion_target );
				behaviortreeentity.lasttargetposition = locomotion_target;
			}
		}
	}
}


function findzombieenemy()
{
	zombies = GetAISpeciesArray( level.zombie_team, "all" );
	zombie_enemy = undefined;
	closest_dist = undefined;
	foreach( zombie in zombies ) {
		if( IsAlive( zombie )
			&& ( isdefined( zombie.completed_emerging_into_playable_area )
				&& zombie.completed_emerging_into_playable_area )
			&& !zm_utility::is_magic_bullet_shield_enabled( zombie )
			&& ( zombie.archetype == "zombie"
				|| zombie.archetype == "zombie_dog"
				|| ( isdefined( zombie.canbetargetedbyturnedzombies )
					&& zombie.canbetargetedbyturnedzombies ) ) ) {
			dist = DistanceSquared( self.origin, zombie.origin );
			if( !isdefined( closest_dist ) || dist < closest_dist ) {
				closest_dist = dist;
				zombie_enemy = zombie;
			}
		}
	}
	return zombie_enemy;
}

function zombiedogshouldmelee( behaviortreeentity )
{
	if( behaviortreeentity.ignoreall
		|| !is_target_valid( behaviortreeentity, behaviortreeentity.favoriteenemy ) ) {
		return false;
	}
	if( !( isdefined( level.intermission ) && level.intermission ) ) {
		meleedist = 72;
		if( DistanceSquared( behaviortreeentity.origin, behaviortreeentity.favoriteenemy.origin ) < SQR( meleedist )
			&& behaviortreeentity CanSee( behaviortreeentity.favoriteenemy ) ) {
			dog_eye = behaviortreeentity.origin + vectorscale( (0, 0, 1), 40 );
			enemy_eye = behaviortreeentity.favoriteenemy GetEye();
			clip_mask = 1 | 8;
			trace = PhysicsTrace( dog_eye, enemy_eye, ( 0, 0, 0 ), ( 0, 0, 0 ), self, clip_mask );
			can_melee = trace["fraction"] == 1 || ( isdefined( trace["entity"] ) && trace["entity"] == behaviortreeentity.favoriteenemy );
			if( isdefined( can_melee ) && can_melee ) return true;
		}
	}
	return false;
}

function zombiedogshouldwalk( behaviortreeentity )
{
	return bb_getshouldrunstatus() == "walk";
}

function zombiedogshouldrun( behaviortreeentity )
{
	return bb_getshouldrunstatus() == "run";
}

function use_low_attack()
{
	if( !isdefined( self.enemy )
		|| !IsPlayer( self.enemy ) ) {
		return false;
	}
	height_diff = self.enemy.origin[2] - self.origin[2];
	low_enough = 30;
	if( height_diff < low_enough
		&& self.enemy GetStance() == "prone" ) {
		return true;
	}
	melee_origin = ( self.origin[0], self.origin[1], self.origin[2] + 65 );
	enemy_origin = ( self.enemy.origin[0], self.enemy.origin[1], self.enemy.origin[2] + 32 );
	if( !BulletTracePassed( melee_origin, enemy_origin, 0, self ) ) {
		return true;
	}
	return false;
}

function zombiedogmeleeaction( behaviortreeentity, asmstatename )
{
	behaviortreeentity ClearPath();
	context = "high";
	if( behaviortreeentity use_low_attack() ) {
		context = "low";
	}
	blackboard::setblackboardattribute( behaviortreeentity, "_context", context );
	animationstatenetworkutility::requeststate( behaviortreeentity, asmstatename );
	return 5;
}

function zombiedogmeleeactionterminate( behaviortreeentity, asmstatename )
{
	blackboard::setblackboardattribute( behaviortreeentity, "_context", undefined );
	return 4;
}

function zombiedoggravity( entity, attribute, oldvalue, value )
{
	blackboard::setblackboardattribute( entity, "_low_gravity", value );
}