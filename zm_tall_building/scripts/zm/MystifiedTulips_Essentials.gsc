#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#insert scripts\shared\version.gsh;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm;
#insert scripts\shared\shared.gsh;
#using scripts\shared\callbacks_shared;
#using scripts\zm\_zm_utility;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_spawner; 
#using scripts\shared\aat_shared;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_bgb;
#using scripts\shared\_burnplayer;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\exploder_shared;
#using scripts\shared\laststand_shared;
#using scripts\zm\gametypes\_globallogic_spawn;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\lui_shared;
#using scripts\zm\_zm_perks;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\util_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\flag_shared;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\zm_giant_cleanup_mgr;
#using scripts\shared\hud_util_shared;
#insert scripts\zm\mystifiedtulips_essentials.gsh;

//MATERIAL
#precache("material",HUD_OVERLAY);
#precache("material",ZOMBIE_KILL);
#precache("material",ZOMBIE_HITMARKER);
#precache("material",ZOMBIE_HITMARKER_HEADSHOT);
#precache("material",FRIENDLY_FIRE_HITMARKER);
#precache("material",GENERIC_HITMARKER);
//SIDE EASTER EGG FX
#precache( "fx",PERK_BOTTLE_FX);
#precache( "fx",EASTER_EGG_SONG_TRIGGER_FX);
//SOULBOX FX
#precache( "fx", SOULBOX_ENTER_FX );
#precache( "fx", SOULBOX_TRAIL_FX);
#precache( "fx", SOULBOX_IDLE_FX);
//LAVA FX
#precache( "fx", "explosions/fx_vexp_raps_death");
//BEASTMODE FX
#precache( "fx", BEASTMODE_FX);
//ZOMBIE SPAWN FX
#precache( "fx", ZOMBIE_SPAWN_FX);

#namespace essentials;

//*****************************************************************************
// MAIN
//*****************************************************************************

function autoexec main()
{
	//Rocket Shield
	clientfield::register( "clientuimodel", "zmInventory.widget_shield_parts", VERSION_SHIP, 1, "int" );
	clientfield::register( "clientuimodel", "zmInventory.player_crafted_shield", VERSION_SHIP, 1, "int" );

	//for player drowining sounds
	clientfield::register( "toplayer", "index", VERSION_SHIP, 4, "int" );

	//add weapons to box
	clientfield::register( "world", "add_ww_to_box", VERSION_SHIP, 1, "int" );
    clientfield::register( "world", "remove_ww_from_box", VERSION_SHIP, 1, "int" );

	//Arnie Fix 
	zm_utility::register_tactical_grenade_for_level( "octobomb" );	

	//Callbacks
	callback::on_spawned(&onspawned);
	callback::on_connect(&onconnect);
	callback::on_laststand(&onlaststand);
	callback::on_ai_spawned(&on_ai_spawn);
	zm_spawner::register_zombie_death_event_callback( &OnZombieKilled );
	zm::register_player_friendly_fire_callback( &on_friendly_fire_damage );

	//LAVA SETUP
	trig_fire = GetEntArray("lava_trig","targetname");
	if(isdefined(trig_fire)){ zm_spawner::add_custom_zombie_spawn_logic( &get_trig ); zm_spawner::register_zombie_death_event_callback( &watch_for_death);}
	
	//2D SOUND CALL "LEVEL playsound("voice_over"); to play a 2d sound to every player any time.
	LEVEL = Spawn("script_model",(0,0,0));
	LEVEL SetModel("tag_origin");

	//gameover text
	level.custom_game_over_hud_elem = &Ending; 

	//clean up ai too far from the player
	level.enemy_location_override_func = &enemy_location_override;
	level.no_target_override = &no_target_override;

	//######################################################################################################//
	//	  True/False Statements ALL of these can be toggled true/false at any point throughout the match	//
	//######################################################################################################//	
	level.intro_fly_in = INTRO_FLY_IN; //true and camera will do a fly in intro when player spawns
	level.use_light_states = USE_LIGHT_STATES; //true and lightstates are automatically changed for power on/off & dogrounds to toggle change level.use_light_states to true/false
	level.keep_weapons_after_death = KEEP_WEAPONS_AFTER_DEATH; //true and players keep weapons on death & respawn
	level.keep_perks_after_downing = KEEP_PERKS_AFTER_DOWNING;//true and players keep perks after downing/dying //if toggling on mid match will need to do " level notify("keep_perks_after_downing"); " to enable as well as editing the true/false statement
	level.zombie_hitmarkers = ZOMBIE_HITMARKERS;//true and zombies will play hitmarkers when shot
	level.no_end_game_check = DISABLE_GAMEOVER_SCREEN;//true to disable gameover screen when all players die
	level.enable_mysterybox_at_every_location = ENABLE_MYSTERYBOX_AT_EVERY_LOCATION;//true and mystery box will be enabled at every location //IF TOGGLING also add level notify("toggle_mystery_box"); as well as editing the true/false statement
	level.use_powerup_volumes = DISABLE_POWER_UPS_IN_CERTAIN_AREAS; //add targetname | " no_powerups " to zone volumes to disable powerups from spawning in specific areas
	level.can_revive = CAN_PLAYERS_REVIVE;//false and players cannot be revived undefined and they can be revived
	level.enable_magic = ENABLE_MAGIC;//false to disable mystery box
	level.headshots_only = HEADSHOTS_ONLY;//true for headshots only
	level.disable_powerups = DISABLE_POWERUPS;//true and powerups are disabled
	level.friendly_fire = FRIENDLY_FIRE;//true and players can damage other players
	level.zom_missing_head = ZOMBIE_MISSING_HEAD;//true and 10% chance zombies will be missing their heads
	level.zom_missing_legs = ZOMBIE_MISSING_LEGS;//true and 10% chance zombies will be missing their legs
	level.zom_sprinters = ZOMBIE_SPRINTERS;//true and zombies will be sprinters forever
	level.disable_zombie_collision = DISABLE_ZOMBIE_COLLISION;//true and zombies wont collide with other zombies
	level.wongame = false;//set this to true when the main ee has been completed (it will get set to true when buyable ending is bought)
	level.boss_fight = false;//set to true to use the boss fight spawn points " prefab "
	
	//THESE VARIABLES CANNOT BE TOGGLED THROUGHOUT THE MATCH!
	level.random_pandora_box_start = RANDOM_MYSTERY_BOX_START;//true and mysterybox will spawn at a random location
	level.timed_gameplay = TIMED_GAMEPLAY;//true and there will be no time delay / pause between rounds //you can enable timedgameplay at any time with " thread essentials::timed_gameplay(); to enable" BUt YOU CANNOT TOGGLE IT OFF ONCE ON
	level.dog_rounds_allowed = DOG_ROUNDS_ALLOWED;
	level.randomize_perk_machine_location = RANDOMISE_PERK_MACHINES;//if true add script_notify = random_perk_machine to perk prefab then place script_structs in radiant on the script_struct target_name add perk_random_machine_location and perks will spawn randomly on the script_structs

	//######################//
	//	Number Statements	//
	//######################//	
	if(PACKAPUNCH_CAMO == 0){level.pack_a_punch_camo_index = 75;}
	else{level.pack_a_punch_camo_index = PACKAPUNCH_CAMO;}

	if(PACKAPUNCH_CAMO_VARIANTS == 0){level.pack_a_punch_camo_index_number_variants = 5;}
	else{level.pack_a_punch_camo_index_number_variants = PACKAPUNCH_CAMO_VARIANTS;}

	// Run True/False Statements
	level thread check_statements();

	//Dvar
	SetDvar("ui_keepLoadingScreenUntilAllPlayersConnected", 1);
	SetDvar("player_lastStandBleedoutTime",BLEEDOUT_TIME);
	SetDvar( "wallrun_enabled", 1 );
	setdvar("cg_cameraUnderwaterLens",1);

	//define barrier fx
	level._effect["poltergeist"] = "zombie/fx_barrier_buy_zmb";

	//######################//
	//		Zombie Stats	//
	//######################//	
	difficulty = 1;
	column = int(difficulty) + 1;

	// AI
	zombie_utility::set_zombie_var( "zombie_health_increase", 			ZOMBIE_HEALTH_INCREASE,	false,	column );	//	cumulatively add this to the zombies' starting health each round (up to round 10)
	zombie_utility::set_zombie_var( "zombie_health_increase_multiplier",ZOMBIE_HEALTH_MULTIPLIER, 	true,	column );	//	after round 10 multiply the zombies' starting health by this amount
	zombie_utility::set_zombie_var( "zombie_health_start", 				ZOMBIE_START_HEALTH,	false,	column );	//	starting health of a zombie at round 1
	zombie_utility::set_zombie_var( "zombie_spawn_delay", 				ZOMBIE_SPAWN_DELAY,	true,	column );	// Time to wait between spawning zombies.  This is modified based on the round number.
	zombie_utility::set_zombie_var( "zombie_new_runner_interval", 		 10,	false,	column );	//	Interval between changing walkers who are too far away into runners 
	zombie_utility::set_zombie_var( "zombie_move_speed_multiplier", 	  ZOMBIE_MOVE_SPEED_MULTIPLIER,	false,	column );	//	Multiply by the round number to give the base speed value.  0-40 = walk, 41-70 = run, 71+ = sprint
	zombie_utility::set_zombie_var( "zombie_move_speed_multiplier_easy",  ZOMBIE_MOVE_SPEED_MULTIPLIER/2,	false,	column );	//	Multiply by the round number to give the base speed value.  0-40 = walk, 41-70 = run, 71+ = sprint

	zombie_utility::set_zombie_var( "zombie_max_ai", 					ZOMBIE_MAX_AI,		false,	column );	//	Base number of zombies per player (modified by round #)
	zombie_utility::set_zombie_var( "zombie_ai_per_player", 			ZOMBIE_MAX_AI/4,		false,	column );	//	additional zombie modifier for each player in the game
	zombie_utility::set_zombie_var( "below_world_check", 				-1000 );					//	Check height to see if a zombie has fallen through the world.

	// Round	
	zombie_utility::set_zombie_var( "spectators_respawn", 				SPECTATORS_RESPAWN_END_OF_ROUND );		// Respawn in the spectators in between rounds
	zombie_utility::set_zombie_var( "zombie_use_failsafe", 				true );		// Will slowly kill zombies who are stuck
	zombie_utility::set_zombie_var( "zombie_between_round_time", 		BETWEEN_ROUND_WAIT );		// How long to pause after the round ends
	zombie_utility::set_zombie_var( "zombie_intermission_time", 		15 );		// Length of time to show the end of game stats
	zombie_utility::set_zombie_var( "game_start_delay", 				0,		false,	column );	// How much time to give people a break before starting spawning

	// Life and death
	zombie_utility::set_zombie_var( "player_base_health", 				PLAYER_HEALTH );		// Base health of a player

	zombie_utility::set_zombie_var( "penalty_no_revive", 				0.10, 	true,	column );	// Percentage of money you lose if you let a teammate die
	zombie_utility::set_zombie_var( "penalty_died",						0.0, 	true,	column );	// Percentage of money lost if you die
	zombie_utility::set_zombie_var( "penalty_downed", 					0.05, 	true,	column );	// Percentage of money lost if you go down // ww: told to remove downed point loss

	zombie_utility::set_zombie_var( "zombie_score_kill_4player", 		ZOMBIE_KILL_SCORE );		// Individual Points for a zombie kill in a 4 player game
	zombie_utility::set_zombie_var( "zombie_score_kill_3player",		ZOMBIE_KILL_SCORE );		// Individual Points for a zombie kill in a 3 player game
	zombie_utility::set_zombie_var( "zombie_score_kill_2player",		ZOMBIE_KILL_SCORE );		// Individual Points for a zombie kill in a 2 player game
	zombie_utility::set_zombie_var( "zombie_score_kill_1player",		ZOMBIE_KILL_SCORE );		// Individual Points for a zombie kill in a 1 player game

	zombie_utility::set_zombie_var( "zombie_score_damage_normal",		ZOMBIE_SCORE_DAMAGE );		// points gained for a hit with a non-automatic weapon
	zombie_utility::set_zombie_var( "zombie_score_damage_light",		ZOMBIE_SCORE_DAMAGE );		// points gained for a hit with an automatic weapon

	zombie_utility::set_zombie_var( "zombie_score_bonus_melee", 		ZOMBIE_SCORE_MELEE );		// Bonus points for a melee kill
	zombie_utility::set_zombie_var( "zombie_score_bonus_head", 			ZOMBIE_SCORE_HEAD );		// Bonus points for a head shot kill
	zombie_utility::set_zombie_var( "zombie_score_bonus_neck", 			ZOMBIE_SCORE_NECK );		// Bonus points for a neck shot kill
	zombie_utility::set_zombie_var( "zombie_score_bonus_torso", 		ZOMBIE_SCORE_TORSO );		// Bonus points for a torso shot kill
	zombie_utility::set_zombie_var( "zombie_score_bonus_burn", 			ZOMBIE_SCORE_TORSO );		// Bonus points for a burn kill
}
function check_statements()
{
    thread timed_gameplay();
	thread zombie_collision_with_zombies();
	thread toggle_fire_sale();

	boss_structs = GetEntArray("boss_structs_teleport","targetname");
	foreach(ent in boss_structs){ent SetModel("tag_origin");}

	if(SPECIFIC_ZOMBIE_MODELS_PER_RISER_LOC == true){level.fn_custom_zombie_spawner_selection = &getActiveMultiSpawner;}

	struct = struct::get_array("earthquake_struct","targetname");
	foreach(ent in struct){ent thread earthquake();}
    lockdown_trig = GetEntArray("lockdown","targetname");
    foreach(ent in lockdown_trig){ent thread setup_lockdown();}

	level waittill("initial_blackscreen_passed");

	//disable drowning if true
	if(HOLD_BREATH_UNDERWATER == true)
	{
		level.drown_damage = 0;
		level.drown_damage_interval = -1;
		level.drown_damage_after_time = -1;
		level.drown_pre_damage_stage_time = -1;
	}

	level.perk_purchase_limit = PERK_PURCHASE_LIMIT;//the number of perks the player can buy
	level.zombie_powerup_weapon[ "minigun" ] = GetWeapon(( array::randomize(DEATHMACHINE)[0]));

	thread giant_bridge();
	
	thread lightning_strike();

	if(IsInt(INTRO_TEXT)){}
	else if(INTRO_TEXT == "type_writer"){thread typewriter_screen_text(INTRO_TEXT_LINE1,INTRO_TEXT_LINE2,INTRO_TEXT_LINE3);}
	else if(INTRO_TEXT == "print"){thread print_screen_text(INTRO_TEXT_LINE1,INTRO_TEXT_LINE2,INTRO_TEXT_LINE3);}

	if(level.no_end_game_check == true || level.keep_weapons_after_death == true)
	{
		level.default_laststandpistol 		= GetWeapon( "" );//remove so we can accruatly save the players loadout
		level.default_solo_laststandpistol	= GetWeapon( "" );//remove so we can accruatly save the players loadout
	}
	else
	{
		level.default_laststandpistol 		= GetWeapon(( array::randomize(LASTSTAND_WEAPON)[0]));
		level.default_solo_laststandpistol	= GetWeapon(( array::randomize(SOLO_LASTSTAND_WEAPON)[0]));
	}
	players = GetPlayers();
	level.start_weapon = GetWeapon(( array::randomize(START_WEAPON)[0]));
	if(players.size == 1){thread zm::set_default_laststand_pistol(true);}
	else{thread zm::set_default_laststand_pistol(false);}

	if(INITIAL_POWER_ON == true){level flag::set("power_on");}
}
////////////////////////
//  CALLBACKS PLAYER  //
////////////////////////
function onspawned()
{
	self.ambient_sound = false;
	self.laststand = false;
	self.cheat1 = false;
	self.cheat2 = false;
	self.cheat3 = false;
	self.cheat4 = false;
	self.fast_travel = false;
	self.end_game_check = false;
	self.touching_lockdown_trigger = false;
	self.touching_mask_trigger = false;
	self.IS_DRINKING = 0;

	self thread starting_weapon();
	self thread setup_wallrun();
	self thread setup_doublejump();
	self thread setup_falltrigger();
	self thread ambient_sounds();
	self thread on_player_damage();
	self thread fly_in();

	if(self.characterIndex == 0){CodeSetPlayerStateClientField(self, "index",0);}
	if(self.characterIndex == 1){CodeSetPlayerStateClientField(self, "index",1);}
	if(self.characterIndex == 2){CodeSetPlayerStateClientField(self, "index",2);}
	if(self.characterIndex == 3){CodeSetPlayerStateClientField(self, "index",3);}

	stuck_in_water_trigger = GetEntArray("stuck_in_water_trigger","targetname");
	foreach(ent in stuck_in_water_trigger){ent thread stuck_in_water(self);}

	//teleport players to boss arena if boss fight is enabled.
	boss_structs = GetEntArray("boss_structs_teleport","targetname");
	if(isdefined(boss_structs) && level.boss_fight == true)
	{
		i=0;
		free = false;
		while(free == false)
		{
			free = thread check_location_free(boss_structs[i].origin);
			if(free == true)
			{break;}
			else 
			{
				if(DEBUG == true){IPrintLnBold("^1Error^7: Another player was standing in your spawn point!! picking a new location");}
				if(i<boss_structs.size){i++;}
				else{i=0; wait.05;}
			}
		}
		self SetOrigin(boss_structs[i].origin);
		self SetPlayerAngles(boss_structs[i].angles);
	}

	is_developer = array::contains(DEVELOPER_NAMES, self.name);
	if(is_developer == 1)
	{self thread is_developer();}
}
function onconnect()
{
	self.score = STARTING_POINTS;

	self thread keep_perks();
	self thread setServerMovement();
	self thread lava_on_player();
	self thread beast();

	overlay = GetEntArray("hud_overlay", "targetname");
	foreach(ent in overlay){self thread hud_overlay(ent);}
	ladder = GetEntArray("ladder","targetname");
	foreach(ladder in ladder){self thread isladder(ladder);}//if player touches this trig and their on a ladder make player invinsible, ignored by zombies and mantle hint text when at top of ladder
    lockdown_trig = GetEntArray("lockdown","targetname");
    foreach(ent in lockdown_trig){ent thread lockdown_on_player(self);}
	disable_weapons = GetEntArray("disable_weapons","targetname");
	foreach(disable_weapons in disable_weapons){disable_weapons thread disable_weapon(self);}//if player touches this trig hide their weapons and ignored by zombies
	lower_weapons = GetEntArray("lower_weapons","targetname");
	foreach(lower_weapons in lower_weapons){lower_weapons thread lower_weapons(self);}//if player touches this trig lower their weapons and ignored by zombies
	gravity = GetEntArray("gravity_trigger", "targetname");
	foreach(ent in gravity){self thread gravity(ent);}

	special_persons = array::contains(SPECIAL_PERSONS, self.name);
	if(special_persons == 1)
	{
		self.special = true;
		level.special = true;
		if(DEBUG == true){IPrintLnBold("level.special_persons == true");}
	}

}
function onlaststand()
{
	self endon("bled_out");
	self endon("death");
	self endon("disconnect");
	level endon("end_game");

	players = GetPlayers();
	if(level.keep_weapons_after_death == true && players.size > 1 && level.no_end_game_check != true)
	{self thread give_weapons();}

	else if(level.no_end_game_check == true) 
	{self thread no_end_game_check();}

	self StopLocalSound(PLAYER_NEAR_DEATH_SOUND);
	self PlayLocalSound(PLAYER_DOWNED_SOUND);
	self thread play_bleedout_sound();
	self waittill("player_revived");
	self StopSound(BLEEDOUT_LOOP_SOUND);
	self PlayLocalSound(PLAYER_REVIVED_SOUND);
}
function on_friendly_fire_damage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime, boneIndex )
{
	if(level.friendly_fire != true){return;}
	if(IsPlayer(eAttacker) && IsPlayer(self) && self != eAttacker)
	{
		if(self laststand::player_is_in_laststand()){eAttacker thread playHitSound( ZOMBIE_KILL_HEADSHOT_SOUND );}
		else if(sHitLoc == "head" || sHitLoc == "helmet"){eAttacker thread playHitSound ( ZOMBIE_HEADSHOT_SOUND );}
		else{eAttacker thread playHitSound ( GENERIC_HITMARKER_SOUND );}
		eAttacker.hud_damagefeedback setShader( FRIENDLY_FIRE_HITMARKER, 30, 30 );
		eAttacker.hud_damagefeedback.alpha = 1;
		eAttacker.hud_damagefeedback fadeOverTime(1);
		eAttacker.hud_damagefeedback.alpha = 0;

		self DoDamage(iDamage / 20,self.origin);
		PlayFX("blood/fx_blood_trail_zmb", vPoint);
		wait(.1);
		self ShellShock("explosion", 1);
		eAttacker thread zm_equipment::show_hint_text("^3"+ self.name +"^8's Health: ^6"+ self.health +"^8!",.5);
		if(DEBUG == true){IPrintLnBold("^6" + eAttacker.name + "^7 has caused ^1friendly fire^7 to ^3" + self.name);}
	} 
}
function on_player_damage()
{
	self endon("death");
	self endon("bled_out");
	self endon("disconnect");
	while(isdefined(self) && self.sessionstate != "spectator")
	{
        self waittill("damage");
        if (self.health <= 30) 
		{
			self PlayLocalSound(PLAYER_NEAR_DEATH_SOUND);
			while(self.health <= 30 && IsAlive(self) && !self laststand::player_is_in_laststand())
			{
				Earthquake(.15, .1, self.origin, 100);
				wait.1;
			}
		}
    }
}
///////////////////
//  CALLBACKS AI //
///////////////////
function on_ai_spawn()
{
	self endon("death");
	if(level.zom_missing_head == true){rand = RandomInt(10);if(rand == 0){self Detach(self.head);}}
	wait(5);
	if(level.zom_missing_legs == true){rand = RandomInt(10);if(rand == 0){self.missingLegs = true;}}
	if(level.zom_sprinters == true){ self zombie_utility::set_zombie_run_cycle_override_value("super_sprint");}

	trig = GetEntArray( "teleport_ai", "targetname" );
	foreach(ent in trig){ent thread teleport_zombie(self);}
	kill_trig = GetEntArray("kill_ai","targetname");
	foreach(ent in kill_trig){ent thread kill_zombie(self);}

	while(IsAlive(self))
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type, tagName, modelName, partName, weapon, dFlags, inflictor, chargeLevel );
		if(IsPlayer(attacker) && level.zombie_hitmarkers == true && attacker.cheat1 == false && IsAlive(self))
		{
			str_damagemod = self.damagemod;
			w_damage = self.damageweapon;
			w_damage = zm_weapons::get_nonalternate_weapon( w_damage );
			weaponClass = util::getWeaponClass( w_damage );

			if( zm_utility::is_headshot( w_damage, self.damagelocation, str_damagemod))
			{
				attacker.hud_damagefeedback setShader( ZOMBIE_HITMARKER_HEADSHOT, 24, 24 );
				attacker thread playHitSound ( ZOMBIE_HEADSHOT_SOUND );
			}
			else {attacker.hud_damagefeedback setShader( ZOMBIE_HITMARKER, 24, 24 );}
			attacker thread playHitSound ( ZOMBIE_HITMARKER_SOUND );
			attacker.hud_damagefeedback.alpha = 1;
			attacker.hud_damagefeedback fadeOverTime(1);
			attacker.hud_damagefeedback.alpha = 0;
		}
	}
}
function OnZombieKilled(player)
{
	level endon("end_game");

	if(level.zombie_hitmarkers != true || player.cheat1 == true){return;}
	if(IsPlayer(player))
	{
		str_damagemod = self.damagemod;
		w_damage = self.damageweapon;
		w_damage = zm_weapons::get_nonalternate_weapon( w_damage );
		weaponClass = util::getWeaponClass( w_damage );

		if( zm_utility::is_headshot( w_damage, self.damagelocation, str_damagemod))
		{
			player PlayLocalSound( ZOMBIE_KILL_HEADSHOT_SOUND ); 
		}
		player thread playHitSound ( ZOMBIE_HITMARKER_SOUND );
		player.hud_damagefeedback setShader( ZOMBIE_KILL, 24, 24 );
		player.hud_damagefeedback.alpha = 1;
		player.hud_damagefeedback fadeOverTime(1);
		player.hud_damagefeedback.alpha = 0;	
	}
}
///////////////////
//  ON END GAME  //
///////////////////
function autoexec end_game()
{
	level waittill("end_game");
	zm_spawner::deregister_zombie_death_event_callback( &OnZombieKilled );
	soul_box = getentarray("custom_soul_box","targetname");
	if(isdefined(soul_box)){zm_spawner::deregister_zombie_death_event_callback( &WatchMe);}
	trig_fire = GetEntArray("lava_trig","targetname");if(isdefined(trig_fire)){zm_spawner::deregister_zombie_death_event_callback( &watch_for_death);}

	if(level.wongame == true){LEVEL PlaySound(GAMEOVER_WIN);}
	else
	{
		LEVEL PlaySound(GAMEOVER_LOSE); 
		LEVEL PlaySound(PLAYER_DEATH_SOUND);
		foreach(player in GetPlayers())
		{
			player thread end_game_camera_transition(); 
			player ShellShock("explosion", 7);
		}
	}
	foreach(player in GetPlayers()){player StopLocalSound(PLAYER_NEAR_DEATH_SOUND);}
}
function end_game_camera_transition()
{
	if(OUTRO_DEATH_SCENE != true){return;}
	visionset_mgr::activate( "overlay", "zm_bgb_in_plain_sight", self, 2, 1, 2 );
	wait(1);
	if(self.sessionstate != "spectator")
	{
		org = self GetOrigin();
		angles = self GetPlayerAngles();
		self thread move_camera(undefined, 2,(org[0],org[1] + 100,org[2] + 10), (90, angles[1], angles[2]));
		wait(3);
		self lui::screen_fade_out(.5);
		wait(.5);
		self thread end_camera();
	}
}
///////////////////////////
//  GIVE STARTING WEAPON //
///////////////////////////
function starting_weapon()
{
	//take the start_weapon and replace with random or per player weapon
	self TakeAllWeapons();
	self zm_weapons::weapon_give(GetWeapon("knife"), false, true);

	if(USING_PER_PLAYER_START_WEAPON != true){self zm_weapons::weapon_give(GetWeapon(( array::randomize(START_WEAPON)[0])));}
	else 
	{
		//determain the character were playing as
		character = self GetCharacterBodyType();
		//original crew
		if(character == 0)//0-3 dempsey,nikolai,richtofen,takeo 
		{self zm_weapons::weapon_give(GetWeapon(( array::randomize(DEMPSEY)[0])));}
		else if(character == 1)//0-3 dempsey,nikolai,richtofen,takeo 
		{self zm_weapons::weapon_give(GetWeapon(( array::randomize(NIKOLAI)[0])));}
		else if(character == 2)//0-3 dempsey,nikolai,richtofen,takeo 
		{self zm_weapons::weapon_give(GetWeapon(( array::randomize(RICHTOFEN)[0])));}
		else if(character == 3)//0-3 dempsey,nikolai,richtofen,takeo 
		{self zm_weapons::weapon_give(GetWeapon(( array::randomize(TAKEO)[0])));}   
		//soe crew
		else if(character == 5)
		{self zm_weapons::weapon_give(GetWeapon(( array::randomize(FLOYD)[0])));}
		else if(character == 6)//5-8 floyd,jack,jess,nero
		{self zm_weapons::weapon_give(GetWeapon(( array::randomize(JACK)[0])));}
		else if(character == 7)//5-8 floyd,jack,jess,nero
		{self zm_weapons::weapon_give(GetWeapon(( array::randomize(JESSICA)[0])));}
		else if(character == 8)//5-8 floyd,jack,jess,nero
		{self zm_weapons::weapon_give(GetWeapon(( array::randomize(NERO)[0])));}   
		//beast
		else if(character == 4)//4 The Beast
		{self zm_weapons::weapon_give(GetWeapon(( array::randomize(BEAST)[0])));}  
		//if character is someone completly random then give them the default option
		else
		{self zm_weapons::weapon_give(GetWeapon(( array::randomize(START_WEAPON)[0])));}
	}
}
///////////////
//  SOULBOX  //
///////////////
function autoexec init_soulbox()
{
	zm_spawner::register_zombie_death_event_callback( &WatchMe);

    soul_box = getentarray("custom_soul_box","targetname");
	level.soul_box_done = 0;
	level.soul_box_total = soul_box.size;
    foreach(ent in soul_box)
    {ent thread Individual_Soul_Box();}

	//add more above if you add more systems, match the string to all the prefabs kvps base string
}
function Individual_Soul_Box()
{
	self endon("death");
	level endon("end_game");
	
	//if self.script_delete != 1 then the soul box can be reused again by sending the notify again
	while(isdefined(self))
	{
		self.active = 0;

		//make the soul box hidden until ready to use?
		if(isdefined(self.script_startstate) && self.script_startstate == "hide" && self.script_startstate != "")
		{self Hide();}

		//if waittill is defined soulbox wont collect souls until a specific notify is sent
		if(isdefined(self.script_waittill) && self.script_waittill != "")
		{level waittill(self.script_waittill);}

		if(isdefined(self.script_presound) && self.script_presound != "")
		{self PlayLoopSound(self.script_presound);}

		//show soul box if it was hidden
		if(isdefined(self.script_startstate) && self.script_startstate == "hide" && self.script_startstate != "")
		{self Show();}

		if(DEBUG == true){IPrintLnBold("Soul box ^6" + self.script_notify + "^7 active!");}

		self.active = 1;

		if(isdefined(self.script_firefx) && self.script_firefx != "")
		{PlayFXOnTag(self.script_firefx, self, "tag_origin");}

		if(isdefined(self))
		{self.scale = 0;}

		finalscale = 1;

		//while soul box is incomplete
		while(isdefined(self) && self.scale<finalscale)
		{wait(.05);}

		//once soul box is finished
		if(isdefined(self))
		{        
			//send a custom notify that this specific soulbox is complete
			if(isdefined(self.script_notify) && self.script_notify != "")
			{level notify(self.script_notify); if(DEBUG == true){IPrintLnBold("Soulbox done sending notify ^6" + self.script_notify);}}

			//play a sound when completed
			if(isdefined(self.script_sound) && self.script_sound != "")
			{self PlaySound(self.script_sound);}

			self.active = 2;

			level.soul_box_done++;
			if(level.soul_box_done == level.soul_box_total)
			{
				zm_spawner::deregister_zombie_death_event_callback( &WatchMe);
				level notify ("all_souls_complete");
				if(DEBUG == true){IPrintLnBold("^3all soul boxes complete");}
				level.soul_box_total = undefined;
				level.soul_box_done = undefined;
			}

			if(isdefined(self.script_presound) && self.script_presound != "")
			{self StopLoopSound();}

			if(isdefined(self.script_delete) && IsInt(self.script_delete) && self.script_delete == 1)
			{
				self Delete();
				return;
			}
		}
	}
}
function WatchMe(e_attacker)
{
	if(IsPlayer(e_attacker))
	{
		level endon("all_souls_complete");

		// start = self GetTagOrigin( "J_SpineLower" );//different for dog
		if(!isdefined(self))
		{
			return;
		}
		start = self.origin+(0,0,60);
		if(!isdefined(start))
		{
			return;
		}

		soul_box = getentarray("custom_soul_box","targetname");
		keys = GetArrayKeys(soul_box);

		foreach(soul in keys)
		{
			soul_box = ArrayCombine(soul_box, GetEntArray(soul,"targetname"),false,false);
		}
		closest = 300;
		cgs = undefined;
		foreach(gs in soul_box)
		{
			if(Distance(start,gs.origin)<closest && BulletTracePassed( start, gs.origin+(0,0,50), false, self ))
			{
				closest = Distance(start,gs.origin);
				cgs = gs;
			}
		}
		if(!isdefined(cgs) || !isdefined(cgs.origin))
		{
			return;
		}
		cgs thread SendSoul(start,e_attacker);
	}
}
function SendSoul(start,e_attacker)
{
	if(self.active == 0){if(DEBUG == true){IPrintLnBold("soul box is not ready yet");} return;}
	if(self.active == 2){if(DEBUG == true){IPrintLnBold("soul box has finished!");} return;}
	if(isdefined(self.script_string) && self.script_string != "")
	{
		weapon = e_attacker GetCurrentWeapon();
		if(DEBUG == true){IPrintLnBold("^6"+self.script_string + "^7 required. You used ^3"+weapon.name+"^7!");}
		if(self.script_string == weapon.name && IsPlayer(e_attacker)){}
		else{ if(DEBUG == true){IPrintLnBold("^1WRONG WEAPON!!!");} return;}
	}
	if(isdefined(self))
	{end = self.origin;}

	if(!isdefined(start) || !isdefined(end))
	{return;}

	if(isdefined(self.script_soundalias) && self.script_soundalias != "")
	{self PlaySound(self.script_soundalias);}
	else
	{self PlaySound("evt_nuked");}
	
	if(isdefined(self))
	{
			if(isdefined(self.script_float) && self.script_float != 0){}
			else{self.script_float = .043;}
			self.scale+= self.script_float;
	}
	if(!isdefined(level.fx_count))
	{
		level.fx_count = 0;
	}
	if(level.fx_count < 5)
	{
		level.fx_count++;
		fxOrg = util::spawn_model( "tag_origin", start );

		if(isdefined(self.script_trailfx) && self.script_trailfx != "")
		{fx = PlayFXOnTag(self.script_trailfx, fxOrg,"tag_origin");}
		else
		{fx = PlayFxOnTag( SOULBOX_TRAIL_FX, fxOrg, "tag_origin" );}

		time = Distance(start,end)/200;
		fxOrg MoveTo(end+(0,0,50),time);
		wait(time - .05);
		fxOrg moveto(end, .5);
		fxOrg waittill("movedone");
		
		if(isdefined(self.script_soundalias) && self.script_soundalias != "")
		{
			self PlaySound(self.script_soundalias);
		}

		PlayFX(SOULBOX_ENTER_FX,self.origin);
		fxOrg delete();
		level.fx_count--;
	}
	else
	{
		if(isdefined(self.script_soundalias) && self.script_soundalias != "")
		{
			self PlaySound(self.script_soundalias);
		}
		PlayFX(SOULBOX_ENTER_FX,self.origin);
	}
}
//////////////////////
//  BLEEDOUT SOUND  //
//////////////////////
function play_bleedout_sound()
{
	self endon("disconnect");
	self endon("bled_out");
	self endon("player_revived");
	
	while(self laststand::player_is_in_laststand())
	{
		self PlaySoundWithNotify(BLEEDOUT_LOOP_SOUND,"bleedout_sound");
		self waittill("bleedout_sound");
	}
}
/////////////////////////
//  PRINT SCREEN TEXT  //
/////////////////////////
function print_screen_text(line1,line2,line3)
{
	thread creat_simple_intro_hud( line1, 50, 100, 3, 5 ); 
	thread creat_simple_intro_hud( line2, 50, 75, 2, 5 );
	thread creat_simple_intro_hud( line3, 50, 50, 2, 5 );
}

function creat_simple_intro_hud( text, align_x, align_y, font_scale, fade_time )
{
	hud = NewHudElem();
	hud.foreground = true;
	hud.fontScale = font_scale;
	hud.sort = 1;
	hud.hidewheninmenu = false;
	hud.alignX = "left";
	hud.alignY = "bottom";
	hud.horzAlign = "left";
	hud.vertAlign = "bottom";
	hud.x = align_x;
	hud.y = hud.y - align_y;
	hud.alpha = 1;
	hud SetText( text );
	wait( 8 ); 
	hud fadeOverTime( fade_time ); 
	hud.alpha = 0; 
	wait( fade_time ); 
	hud Destroy();  
}
//////////////////////////////
//  TYPE WRITER INTRO TEXT  //
//////////////////////////////
function typewriter_screen_text(line1,line2,line3)
{
    intro_hud = [];
    str_text = Array( line1, line2, line3 );

    for ( i = 0; i < str_text.size; i++ )
    {
        intro_hud[i] = NewHudElem();
        intro_hud[i].x = 20;
        intro_hud[i].y = -250 + ( 20 * i );
        intro_hud[i].fontscale = ( IsSplitScreen() ? 2.75 : 1.75 );
        intro_hud[i].alignx = "LEFT";
        intro_hud[i].aligny = "BOTTOM";
        intro_hud[i].horzalign = "LEFT";
        intro_hud[i].vertalign = "BOTTOM";
        intro_hud[i].color = (1.0, 1.0, 1.0);
        intro_hud[i].alpha = 1;
        intro_hud[i].sort = 0;
        intro_hud[i].foreground = true;
        intro_hud[i].hidewheninmenu = true;
        intro_hud[i].archived = false;
        intro_hud[i].showplayerteamhudelemtospectator = true;
        intro_hud[i] SetText(str_text[i]);
        intro_hud[i] SetTypewriterFX( 100, 10000 - ( 3000 * i ), 3000 );
        wait(3);
    }

    wait(10);
    foreach ( hudelem in intro_hud ) hudelem Destroy();
}
/////////////////////////
//  LIGHTNING STRIKES  //
/////////////////////////
function lightning_strike()
{
	while(LIGHTNING == true)
	{
		LEVEL playsound(LIGHTNING_STRIKE_SOUND);
		exploder::exploder("lightning_strikes");
		if(DEBUG == true){IPrintLnBold("lightning strike");}
		rand = RandomIntRange(LIGHTNING_DELAY_MIN, LIGHTNING_DELAY_MAX);
		wait(rand);
	}
}
////////////////////////
//  MUSIC EASTER EGG  //
////////////////////////
function autoexec easter_egg_song()
{
	level waittill("all_players_connected");
	trig = GetEntArray("easter_egg_song","targetname");
	foreach(trig in trig){trig thread easter_egg_song_touch();}
}
function easter_egg_song_touch()
{
	//get the model
	model = getent(self.target,"targetname");
	model PlayLoopSound(EASTER_EGG_SONG_TRIGGER_LOOP);

	//waittill trigger is triggered
	self waittill("trigger",player);
	model StopLoopSound();
	model PlaySound(EASTER_EGG_SONG_TRIGGER_CONFIRMATION);
	PlayFX(EASTER_EGG_SONG_TRIGGER_FX,model.origin);
	model Delete();
	self Delete();
	trig = GetEntArray("easter_egg_song","targetname");
	if(trig.size == 0){LEVEL PlaySound(EASTER_EGG_SONG);}
}
//////////////////////////////
//  PERK BOTTLE EASTER EGG  //
//////////////////////////////
function autoexec perk_bottle_easter_egg()
{
	level waittill("all_players_connected");
	perk_bottle_easter_egg = GetEntArray("perk_bottle_easter_egg","targetname");
	foreach(ent in perk_bottle_easter_egg){ent thread shoot_perk_bottle_easter_egg();}
}
function shoot_perk_bottle_easter_egg()
{
	model = getent(self.target,"targetname");
	org = model GetOrigin();
	self thread PlayHitMarker();
	self waittill("trigger",player);
	model PlaySound(PERK_BOTTLE_SHOT_SOUND);
	PlayFX(PERK_BOTTLE_FX,(org[0],org[1],org[2] + 6));
	model Delete();
	self Delete();
	perk_bottle_easter_egg = GetEntArray("perk_bottle_easter_egg","targetname");
	if(perk_bottle_easter_egg.size == 0)
	{
		reward = array::randomize(PERK_BOTTLE_REWARD)[0];
		if(IsInt(reward))
		{foreach(player in GetPlayers()){player.score += reward; player PlayLocalSound(PURCHASE_ACCEPT);}}

		else if(reward == "free_perk")
		{foreach(player in GetPlayers()){player zm_perks::give_random_perk();}}
		
		else if(reward == "perkaholic")
		{foreach(player in GetPlayers()){ player bgb::give("zm_bgb_perkaholic"); }}

		else if(reward == "free_perk_and_slot")
		{level.perk_purchase_limit++; foreach(player in GetPlayers()){player zm_perks::give_random_perk();}}

		else if(reward == "weapon_upgrade")
		{foreach(player in GetPlayers()){player thread upgrade_weapon();}}
	}	
}
function upgrade_weapon()
{
    current_weapon = self getcurrentweapon();
    upgraded_weapon = zm_weapons::get_upgrade_weapon( current_weapon, false );

    if ( ( isdefined( level.aat_in_use ) && level.aat_in_use ) )
    {
        self thread aat::acquire( upgraded_weapon );
    }

	weapon_options = self GetBuildKitWeaponOptions( upgraded_weapon, level.pack_a_punch_camo_index); 
	acvi = self GetBuildKitAttachmentCosmeticVariantIndexes( upgraded_weapon, true );

    self TakeWeapon( current_weapon );
	self GiveWeapon( upgraded_weapon, weapon_options, acvi );
    if(self HasPerk("specialty_extraammo"))
        self GiveMaxAmmo( upgraded_weapon );
    else
        self GiveStartAmmo( upgraded_weapon );
        
    self SwitchToWeapon( upgraded_weapon );

    zm_utility::play_sound_at_pos( "zmb_perks_packa_ready", self );
}
////////////////
//  LOCKDOWN  //
////////////////
function setup_lockdown()
{
	targets = GetEntArray(self.target,"targetname");
	
    //hides the lockdown clips
    for(i=0; i < targets.size; i++)
	{
		if(isdefined(targets[i].script_noteworthy))
		{
			if(targets[i].script_noteworthy == "clip"){targets[i] Hide();}
		}
	}
    //hides spawner models
	for(i = 0; i < targets.size; i++)
	{
		if(isdefined(targets[i].script_noteworthy))
		{
			if(targets[i].script_noteworthy == "spawner")
			{
				targets[i] SetModel("tag_origin");
				struct[i] = SpawnStruct();
				struct[i].origin = targets[i].origin;
				struct[i].angles = targets[i].angles;
				struct[i].targetname = targets[i].targetname;
			}
		}
	}

    level flag::init(self.script_waittill);

    //wait for specific lockdown to be activated (should have a unique script_waittill kvp)
    level waittill(self.script_waittill)

    ;//once activated it will waittill player is touching the area and then lock them in
    level flag::set(self.script_waittill);
    self thread watch_flag(self.script_waittill);

    if(DEBUG == true){IPrintLnBold("Lockdown ^6"+self.script_waittill+"^7 is ready!");} 

	//lockdown is active but wait for a player to actually be inside the lockdown room
	self waittill("player_in_lockdown");

	if(DEBUG == true){IPrintLnBold("Lockdown ^6"+self.script_waittill+"^7 is now spawning zombies!");} 

	self thread lockdown_spawn(self.script_waittill);

	level waittill(self.script_waittill);

	if(DEBUG == true){IPrintLnBold("Lockdown ^6"+self.script_waittill+"^7 Complete!");}  

    //delete everything
    for(i=0; i < targets.size; i++)
    {targets[i] Delete();}
    self Delete(); 
}

//play lockdown event on player
function lockdown_on_player(client)
{
	targets = GetEntArray(self.target,"targetname");
	//wait for specific lockdown to be activated (should have a unique script_waittill kvp)
	//if player joins mid game if trigger is active then dont use waittill
	if(!isdefined(self.set_active))
	{self.set_active = false;}
	if(self.set_active == false)
	{
		if(isdefined(self.script_waittill) && self.script_waittill != "")
		{level waittill(self.script_waittill);}
		self.set_active = true;
	}

	wait.25;
	level endon(self.script_waittill);
	while(isdefined(client) && isdefined(self))
	{
		//wait for player to touch one of the triggers and check if lockdown is still active
		while(isdefined(client) && level flag::get(self.script_waittill) && client.touching_lockdown_trigger != true)
		{
			if(client IsTouching(self)){break; client.touching_lockdown_trigger = true;}
			else{for(i=0;i<targets.size;i++){if(targets[i].script_noteworthy == "trigger"){if(client IsTouching(targets[i])){
			client.touching_lockdown_trigger = true; break;}}}}
			wait(.2);
		}

		client.touching_lockdown_trigger = false;
		
		//if flag is still active and player touched a trigger then lock them in the room
		if(level flag::get(self.script_waittill))
		{
			self notify("player_in_lockdown");
			if(DEBUG == true){IPrintLnBold("^6"+client.name+"^7 entered "+self.script_waittill+" ^7lockdown room!");}  
			//shows the lockdown clips to player
			for(i=0; i < targets.size; i++)
			{if(targets[i].script_noteworthy == "clip"){targets[i] SetInvisibleToPlayer(client, false);}}             
		}
		//if player dies hide the lockdown clip so they can re-enter and get locked in again.
		client thread waittill_a_specific_notify();
		client waittill("lockdown_reset_for_player");
		for(i=0; i < targets.size; i++)
		{if(targets[i].script_noteworthy == "clip"){targets[i] SetInvisibleToPlayer(client, true);}} 
	}
}
function waittill_a_specific_notify()
{
	self endon("lockdown_reset_for_player");
	thread waittill_a_specific_notifyb();
	self waittill("respawned_players");
	self notify("lockdown_reset_for_player");
}
function waittill_a_specific_notifyb()
{
	self endon("lockdown_reset_for_player");
	self waittill("death");
	self notify("lockdown_reset_for_player");
}
//spawn zombies around the objective
function lockdown_spawn(flag)
{
	spawner = array::random( level.zombie_spawners );
	targets = GetEntArray(self.target,"targetname");

	//continue spawning from specified spawns until lockdown notify is notified again
	while(level flag::get(flag))
	{
		//check if a player is inside lockdown otherwise disable spawning until true
		self.a_player_is_touching = false;
		players = GetPlayers();
		for(p=0;p<players.size;p++)
		{
			if(players[p] IsTouching(self)){self.a_player_is_touching = true;}
			else{for(i=0;i<targets.size;i++){if(isdefined(targets[i].script_noteworthy)){if(targets[i].script_noteworthy == "trigger"){if(players[p] IsTouching(targets[i])){self.a_player_is_touching = true;}}}}}
		}
		size = 0;
		if(self.a_player_is_touching == true)
		{
			for(i = 0; i < targets.size; i++)
			{
				if(targets[i].script_noteworthy == "spawner")
				{
					if(level.zombie_total < 50)
					{
						struct[i] = SpawnStruct();
						struct[i].origin = targets[i].origin;
						struct[i].angles = targets[i].angles;
						zom[i] = zombie_utility::spawn_zombie(spawner, undefined, struct[i]);
						zom[i].script_string = "find_flesh";
						zom[i] zm_spawner::zombie_spawn_init(undefined);
						wait(.05);
						PlaySoundAtPosition(ZOMBIE_SPAWN, struct[i].origin);
						PlayFX(ZOMBIE_SPAWN_FX,struct[i].origin);
						wait(.2);
					}
				}
				else{size++; if(size == targets.size){if(DEBUG == true){IPrintLnBold("^6"+self.script_waittill+" ^7LOCKDOWN HAS NO ZOMBIE SPAWNS ATTACHED TO IT!");}return;}}
			}
		}
		//the delay between the next wave of additional zombie spawns
		if(isdefined(self.script_int) && self.script_int > 0)
		{wait(self.script_int);}
		else{wait(5); if(DEBUG == true){IPrintLnBold("^1Error^7: ^7lockdown script_int value is either undefined or set to 0");}}
	}
}
function watch_flag(flag)
{
    level waittill(flag);
    level flag::clear(flag);
	if(DEBUG == true){IPrintLnBold("^6"+flag+"^7 flag has ended");}
}
////////////////////////
//  DEVELOPER CHEATS  //
////////////////////////
function is_developer()
{
	self.developer = true;
	level.developer = true;
	setdvar("developer",1);
	SetDvar("sv_cheats", 1);
	setdvar("cheats", 1);
	if(DEBUG == true){IPrintLnBold("Cheats: ^3Enabled^7!");}
	self thread cheats();
}
function cheats()
{
	self.cheat1 = false;
	self.cheat2 = false;
	self.cheat3 = false;
	self.cheat4 = false;
	self thread actionslot1();//fast_restart
	self thread actionslot2();//ai_spawning
	self thread actionslot3();//timescale
	self thread actionslot4();//navmesh + god
}
function actionslot4()
{
	self endon("disconnect");
	level endon("end_game");
	IPrintLn("^5" + self.name + "^7 " + ACTIONSLOT4 + "toggle ^3Navmesh/God Mode/infinite ammo^7!");
	timer = 4;
	while(isdefined(self) && self.sessionstate != "spectator" && isdefined(self.end_game_check) && self.end_game_check != true)
	{
		if(self ActionSlotFourButtonPressed())
		{
			if(self.cheat4 != true){ setdvar("player_sustainAmmo",1); self PlayLocalSound(PICKUP); setdvar("ai_shownavmesh",1); self.cheat4 = true; self thread zm_equipment::show_hint_text("NAVMESH + GODMODE ^3ENABLED^7!",4);
			old_score = self.score;
			self.score = 50000;
			keys = GetArrayKeys( level._custom_perks );
			if(isdefined(keys))
			{
				for ( i = 0; i < keys.size; i++ )
				{
					perk = keys[ i ];
					if ( !self hasPerk( perk ) )
					{
						self zm_perks::give_perk(perk);	
					}	
				}
			}
			foreach(player in GetPlayers()){player EnableInvulnerability();}

		}
			else{setdvar("player_sustainAmmo",0); self PlayLocalSound(PICKUP); setdvar("ai_shownavmesh",0); self.cheat4 = false; self.score = old_score; self thread zm_equipment::show_hint_text("NAVMESH + GODMODE ^1DISABLED^7!",4);
			wait(1); if(self.cheat3 != true){foreach(player in GetPlayers()){player DisableInvulnerability();}}
		}
			wait(.5);
		}
		wait(.05);
		timer = timer - .05;
		if(timer <= 0)
		{ 
			IPrintLn("^5" + self.name + "^7 " + ACTIONSLOT4 + "to toggle ^3Navmesh/God Mode/infinite ammo^7!");
			timer = 10;
		}
	}

	//if player dies stop the cheat
	setdvar("player_sustainAmmo",0); setdvar("ai_shownavmesh",0);
	wait(1); foreach(player in GetPlayers()){player DisableInvulnerability();}
}
function actionslot3()
{
	self endon("disconnect");
	level endon("end_game");
	IPrintLn("^5" + self.name + "^7 " + ACTIONSLOT3 + "toggle ^3Timescale^7!");
	timer = 4;
	while(isdefined(self) && self.sessionstate != "spectator" && isdefined(self.end_game_check) && self.end_game_check != true)
	{
		if(self ActionSlotThreeButtonPressed())
		{
			if(self.cheat3 != true){self PlayLocalSound(PICKUP); setdvar("timescale",10); self.cheat3 = true; self thread zm_equipment::show_hint_text("TIMESCALE ^3ENABLED^7!",4);
			foreach(player in GetPlayers()){player EnableInvulnerability();}
			}
			else
			{
				self PlayLocalSound(PICKUP); setdvar("timescale",1);self.cheat3 = false;self thread zm_equipment::show_hint_text("TIMESCALE ^1DISABLED^7!",4);
				wait(1); if(self.cheat4 != true){foreach(player in GetPlayers()){player DisableInvulnerability();}}
			}
			wait(.5);
		}
		wait(.05);
		timer = timer - .05;
		if(timer <= 0)
		{
			IPrintLn("^5" + self.name + "^7 " + ACTIONSLOT3 + "toggle ^3Timescale^7!");
			timer = 10;
		}
	}

	//end cheat if player bleedsout
	setdvar("timescale",1);
	foreach(player in GetPlayers()){player DisableInvulnerability();}

}
function actionslot2()
{
	self endon("disconnect");
	level endon("end_game");
	IPrintLn("^5" + self.name + "^7 " + ACTIONSLOT2 + "toggle ^3Ai Spawning^7!");
	timer = 4;
	while(isdefined(self) && self.sessionstate != "spectator" && isdefined(self.end_game_check) && self.end_game_check != true)
	{
		if(self ActionSlotTwoButtonPressed())
		{
			if(self.cheat2 != true){self PlayLocalSound(PICKUP); setdvar("ai_disablespawn",1); self.cheat2 = true; self thread zm_equipment::show_hint_text("AI SPAWNING ^1DISABLED^7!",4);}
			else{self PlayLocalSound(PICKUP); setdvar("ai_disablespawn",0); self.cheat2 = false; self thread zm_equipment::show_hint_text("AI SPAWNING ^3ENABLED^7!",4);}
			wait(.5);
		}
		wait(.05);
		timer = timer - .05;
		if(timer <= 0)
		{
			IPrintLn("^5" + self.name + "^7 " + ACTIONSLOT2 + "toggle ^3Ai Spawning^7!");
			timer = 10;
		}
	}
	//end cheat if player dies
	setdvar("ai_disablespawn",0);
}
function actionslot1()
{
	self endon("disconnect");
	level endon("end_game");
	IPrintLn("^5" + self.name + " ^7" + ACTIONSLOT1 + "toggle ^3cinermatic mode^7!");
	timer = 4;
	//no point in cinermatics if its splitscreen
	if(IsSplitScreen() == true){return;}
	while(isdefined(self) && self.sessionstate != "spectator" && isdefined(self.end_game_check) && self.end_game_check != true)
	{
		if(self ActionSlotOneButtonPressed())
		{
			if(self.cheat1 != true)
			{
				self PlayLocalSound(PICKUP);
				self EnableInvulnerability();
				setdvar("developer",0);
				setdvar("ui_enabled",0);
				setdvar("cg_drawCrosshair",0);
				setdvar("cg_disableplayernames",1);
				setdvar("grenade_indicators_enabled",0);
				setdvar("timescale",.4);

				self.cin_mode = NewClientHudElem(self);
				self.cin_mode.alignX = "center";
				self.cin_mode.alignY = "middle";
				self.cin_mode.horzAlign = "user_center";
				self.cin_mode.vertAlign = "user_center";	
				if(self IsSplitScreen())
				{
					self.cin_mode SetShader(HUD_OVERLAY, 960, 240); 
				}
				else
				{
					self.cin_mode SetShader(HUD_OVERLAY, 960, 480); 
				}
				self.cin_mode.alpha = 1;
				self.cheat1 = true;
				//self thread zm_equipment::show_hint_text("Cinermatic Mode ^3Enabled^7!",4);
			}
			else
			{
				self PlayLocalSound(PICKUP); 
				self DisableInvulnerability();
				setdvar("developer",1);
				setdvar("ui_enabled",1);
				setdvar("cg_drawCrosshair",1);
				setdvar("cg_disableplayernames",0);
				setdvar("grenade_indicators_enabled",1);
				setdvar("timescale",1);
				self.cin_mode Destroy();
				self.cheat1 = false;
				//self thread zm_equipment::show_hint_text("Cinermatic Mode ^1Disabled^7!",4);
			}
			wait(.5);
		}
		wait(.05);
		timer = timer - .05;
		if(timer <= 0)
		{
			IPrintLn("^5" + self.name +" ^7" +ACTIONSLOT1 + "toggle ^3cinermatic mode^7!");
			timer = 10;
		}
	}
	//end cheat when player dies
	setdvar("developer",1);
	setdvar("ui_enabled",1);
	setdvar("cg_drawCrosshair",1);
	setdvar("cg_disableplayernames",0);
	setdvar("grenade_indicators_enabled",1);
	setdvar("timescale",1);
}
////////////////
//  MOVEMENT  //  
////////////////
function setServerMovement()
{
	SetDvar("doublejump_enabled", 1);
	SetDvar("juke_enabled", 1);
	SetDvar("playerEnergy_enabled", 1);
	SetDvar("sprintLeap_enabled", 1);
	SetDvar( "wallrun_enabled", 1 );

	self AllowDoubleJump(false);
}

//////////////////////
// ZOMBIE COLLISION //
//////////////////////
function zombie_collision_with_zombies()
{
	level endon("end_game");
	while(1)
    {
		zombies = GetAiSpeciesArray("axis");
		for(k=0;k<zombies.size;k++)
		{
			if(level.disable_powerups == true){zombies[k].no_powerups = 1;}
			if(level.disable_zombie_collision == true){zombies[k] PushActors( false );}
		}
		wait(0.5);
	}
}
////////////////////////
//  TOGGLE FIRE SALE  //
////////////////////////
function toggle_fire_sale()
{
	level waittill ("initial_blackscreen_passed");
	level endon("end_game");
	oldval = 69;
	while(1)
	{
		if(level.enable_mysterybox_at_every_location == true && oldval != level.enable_mysterybox_at_every_location)
		{
			oldval = level.enable_mysterybox_at_every_location;
			level.zombie_vars[ FIRE_SALE_ON ] = 1;
			wait(1);
			if(DEBUG == true){IPrintLnBold("Fire Sale ^3Enabled^7!");}
			thread zm_powerup_fire_sale::toggle_fire_sale_on();//if ya install kingslayerkyles powerup hud you can remove the firesale image from existance
	
			for ( i = 0; i < level.chests.size; i++ )
			{
				level.chests[ i ].zombie_cost = 950;
			}
		}
		if(level.enable_mysterybox_at_every_location == false && oldval != level.enable_mysterybox_at_every_location)
		{
			oldval = level.enable_mysterybox_at_every_location;
			if(DEBUG == true){IPrintLnBold("Fire Sale ^1Disabled^7!");}
			level.zombie_vars[ FIRE_SALE_ON ] = 0;
			level notify("fire_sale_off");
		}
		wait(2);
		level waittill("toggle_mystery_box");
	}
}
/////////////////
//  HITMARKER  //
/////////////////
function playhitmarker()
{
	if(!isdefined(self)){return;}
	if(IsPlayer(self))
	{
		self thread playHitSound ( GENERIC_HITMARKER_SOUND );
		self.hud_damagefeedback setShader( GENERIC_HITMARKER, 24, 48 );
		self.hud_damagefeedback.alpha = 1;
		self.hud_damagefeedback fadeOverTime(1);
		self.hud_damagefeedback.alpha = 0;
	}
	//else self is an entity so play hitmarker on the attacker everytime its shot
	else
	{
		self SetCanDamage(true);
		while(isdefined(self))
		{
			self waittill( "damage", amount, attacker, direction_vec, point, type, tagName, modelName, partName, weapon, dFlags, inflictor, chargeLevel );
			if(IsPlayer(attacker))
			{
				attacker thread playHitSound ( GENERIC_HITMARKER_SOUND );
				attacker.hud_damagefeedback setShader( GENERIC_HITMARKER, 24, 48 );
				attacker.hud_damagefeedback.alpha = 1;
				attacker.hud_damagefeedback fadeOverTime(1);
				attacker.hud_damagefeedback.alpha = 0;
			}
			wait(.05);
		}
	}
}
function playHitSound ( alert )
{
	self endon ("disconnect");
	
	if (self.hitSoundTracker)
	{
		self.hitSoundTracker = false;
		
		self playlocalsound(alert);

		wait (.05);	// waitframe
		self.hitSoundTracker = true;
	}
}

////////////////////
// TIMED GAMEPLAY //
////////////////////
function timed_gameplay()
{
	if(level.timed_gameplay != true){return;}
	level.round_wait_func = &round_wait_override; //this has to happen before zm::round_start() runs!

	wait 0.5; 
	level.zombie_vars["zombie_between_round_time"] = 0; //remove the delay at the end of each round 
	level.zombie_round_start_delay = 0; //remove the delay before zombies start to spawn

	level.ugxm_settings = [];
	if(isDefined(level.tgTimer)) level.tgTimer Destroy();
	level.tgTimer = NewHudElem();

	level.isTimedGameplay = true;

	if(!isDefined(level.ugxm_settings["timed_hud_offset"]))
		level.ugxm_settings["timed_hud_offset"] = 0;

	level.tgTimerTime = SpawnStruct();

	level.tgTimerTime.days = 0;
	level.tgTimerTime.hours = 0;
	level.tgTimerTime.minutes = 0;
	level.tgTimerTime.seconds = 0;
	level.tgTimerTime.toalSec = 0;
	
	level.tgTimer.foreground = false; 
	level.tgTimer.sort = 2; 
	level.tgTimer.hidewheninmenu = false; 

	level.tgTimer.fontScale = 1;
	level.tgTimer.alignX = "left"; 
	level.tgTimer.alignY = "bottom";
	level.tgTimer.horzAlign = "left";  
	level.tgTimer.vertAlign = "bottom";
	level.tgTimer.x = -6000; 
	level.tgTimer.y = - -6005 + level.ugxm_settings["timed_hud_offset"]; 
	
	level.tgTimer.alpha = 0;
	
	level.tgTimer SetTimerUp(0);
	
	level.tgTimer.alpha = 1;
}
function round_wait_override()
{
	level endon("restart_round");
	level endon( "kill_round" );

	wait( 1 );

	while( 1 )
	{
		should_wait = ( level.zombie_total > 0 || level.intermission );	
		if( !should_wait )
		{
			return;
		}			
			
		if( level flag::get( "end_round_wait" ) )
		{
			return;
		}
		wait( 1.0 );
	}
}
//////////////////
//  EARTHQUAKE  //
//////////////////
function earthquake()
{
	level endon("end_game");

	//script_int is divided by 100 because using decimals dont register in script_int so 50 = .5 60 = .6 25 = .25
	if(isdefined(self.script_int) && self.script_int > 0)
	{scale = self.script_int;}
	else{scale = 30;}

	scale = scale / 100;
	if(scale > 1){scale = 1;}
	if(scale <= 0){scale = .1;}

	if(isdefined(self.script_radius) && self.script_radius > 0)
	{radius = self.script_radius;}
	else{radius = 350;}
	
	if(isdefined(self.script_wait) && self.script_wait > 0)
	{duration = self.script_wait;}
	else{duration = 4;}
	
	if(isdefined(self.script_sound))
	{sound = self.script_sound;}
	else{sound = "earthquake";}
	
	sound_model = Spawn("script_model",self.origin);
	sound_model SetModel("tag_origin");

	//if no waittill playloop sound always.
	if(!isdefined(self.script_waittill)){sound_model PlayLoopSound(sound);}

	if(isdefined(self.script_waittill))
	{level flag::init(self.script_waittill);}

	while(isdefined(scale) && isdefined(radius) && isdefined(duration) && isdefined(self))
	{
		if(isdefined(self.script_waittill) && !level flag::get(self.script_waittill)){level waittill(self.script_waittill);}
		//play earthquake
		Earthquake(scale, duration, self.origin, radius);
		//if a waittill is defined play 
		if(isdefined(self.script_waittill)){sound_model PlayLoopSound(sound); wait(duration / 2); sound_model StopLoopSound(duration / 2);} 
		
		// divid by 6 so if earthquake is looping it loops without a noticeable fade out
		else{wait(duration / 6);}
	}
	//stop the loopsound if self is deleted or values are wrong...
	sound_model StopLoopSound(.5);
	
	//cleaned up
	sound_model Delete();
	self Delete();
}
//////////////////////////////////////////
//  KEEP PERKS AFTER LASTSTAND & DEATH  //
//////////////////////////////////////////
function keep_perks()
{
	self endon("disconnect");
	level endon("end_game");
	while(isdefined(self))
	{
		while(level.keep_perks_after_downing == true && level.no_end_game_check == true && isdefined(self))
		{
			perk_list = [];
			keys = GetArrayKeys( level._custom_perks );
			for ( i = 0; i < keys.size; i++ )
			{
				perk = keys[ i ];
				if ( self hasPerk( perk ) )
				{
					perk_list[ perk_list.size ] = perk;
				}	
			}
			wait(1);
			if(self laststand::player_is_in_laststand())
			{
				if(DEBUG == true){IPrintLnBold(self.name +" has gone ^1down^7! ^3Saving^7 their perks.");}
				while(self laststand::player_is_in_laststand())
				{
					wait(.5);	
				}
				while(self.sessionstate == "spectator")
				{
					wait(.5);
				}
				if(level.no_end_game_check == true){wait(3);}
				if(DEBUG == true){IPrintLnBold(self.name +" is back! returning their perks.");}
				players = GetPlayers();
				for ( i = 0; i < perk_list.size; i++ )
				{
					if(perk_list[i] == "specialty_quickrevive" && players.size == 1)
					{
						wait(.05);
						if(DEBUG == true){IPrintLnBold( self.name + " had ^3"+ perk_list[i] + "^7 but we cannot give that back!"[i]);}
					}
					else
					{
						self zm_perks::give_perk(perk_list[i]);	
						if(DEBUG == true){IPrintLnBold( self.name + " had ^3"+ perk_list[i]);}
					}
				}
			}	
		}
		level waittill("keep_perks_after_downing");
	}
}
////////////////////////////////
// ADD WEAPONS TO MYSTERY BOX //
///////////////////////////////
function autoexec to_box()
{
    level waittill("initial_blackscreen_passed");

	if(LIST_OF_WEAPONS_TO_ADD_TO_BOX_LATER.size > 0)
	{
		for(i=0;i<LIST_OF_WEAPONS_TO_ADD_TO_BOX_LATER.size;i++)
		{
			if(isdefined(LIST_OF_WEAPONS_TO_ADD_TO_BOX_LATER[i]) && LIST_OF_WEAPONS_TO_ADD_TO_BOX_LATER[i] != "")
			{
				thread remove_then_add_to_box(LIST_OF_WEAPONS_TO_ADD_TO_BOX_LATER[i], i);
			}
		}
	}
}
function remove_then_add_to_box(weapon, number)
{
	if(!isdefined(weapon)){return;}
    //remove the weapon from the box
    level.zombie_weapons[ getWeapon( weapon ) ].is_in_box = 0;//removes weapon from box
    level clientfield::set( "remove_ww_from_box", number );//removes the model from the box
    
	//send this notify to add the specific weapon to box at any point in the match
    level waittill(weapon);

    if(DEBUG == true){IPrintLnBold("^6"+weapon +"^7 added to MysteryBox");}
    //add weapon to the box
    level clientfield::set( "add_ww_to_box", number );//adds model to the box
    level.zombie_weapons[ getWeapon( weapon ) ].is_in_box = 1;//adds weapon to the box
}
///////////////////////////////////////
//  CLEAN UP AI TOO FAR FROM PLAYER  //
///////////////////////////////////////
function enemy_location_override( zombie, enemy )
{
	AIProfile_BeginEntry( "factory-enemy_location_override" );
	if ( IS_TRUE( zombie.is_trapped ) )
	{
		AIProfile_EndEntry();
		return zombie.origin;
	}
	AIProfile_EndEntry();
	return undefined;
}
function validate_and_set_no_target_position( position )
{
	if( IsDefined( position ) )
	{
		goal_point = GetClosestPointOnNavMesh( position.origin, 100 );
		if( IsDefined( goal_point ) )
		{
			self SetGoal( goal_point );
			self.has_exit_point = 1;
			return true;
		}
	}return false;
}
function no_target_override( zombie )
{
	if( isdefined( zombie.has_exit_point ) )
	{return;}
	
	players = level.players;
	
	dist_zombie = 0;
	dist_player = 0;
	dest = 0;

	if ( isdefined( level.zm_loc_types[ "dog_location" ] ) )
	{
		locs = array::randomize( level.zm_loc_types[ "dog_location" ] );
		
		for ( i = 0; i < locs.size; i++ )
		{
			found_point = false;
			foreach( player in players )
			{
				if( player laststand::player_is_in_laststand() )
				{continue;}
				
				away = VectorNormalize( self.origin - player.origin );
				endPos = self.origin + VectorScale( away, 600 );
				dist_zombie = DistanceSquared( locs[i].origin, endPos );
				dist_player = DistanceSquared( locs[i].origin, player.origin );
		
				if ( dist_zombie < dist_player )
				{dest = i;found_point= true;}
				else
				{found_point = false;}
			}
			if( found_point )
			{
				if( zombie validate_and_set_no_target_position( locs[i] ) )
				{return;}
			}
		}
	}
	escape_position = zombie giant_cleanup::get_escape_position_in_current_zone();	
	if( zombie validate_and_set_no_target_position( escape_position ) )
	{return;}
	escape_position = zombie giant_cleanup::get_escape_position();
	
	if( zombie validate_and_set_no_target_position( escape_position ) )
	{return;}
	zombie.has_exit_point = 1;
	
	zombie SetGoal( zombie.origin );
}
//////////////////////
// THE GIANT BRIDGE //
//////////////////////
function giant_bridge()
{
	wnuen_bridge_clip = getentarray( "wnuen_bridge_clip", "targetname" );
	warehouse_bridge_clip = getentarray( "warehouse_bridge_clip", "targetname" );
	wnuen_bridge = getentarray( "wnuen_bridge", "targetname" );
	if(wnuen_bridge_clip.size == 0){return;}
	
	//Setup callbacks for bridge fxanim
	scene::add_scene_func("p7_fxanim_zm_factory_bridge_lft_bundle", &bridge_disconnect , "init" );
	scene::add_scene_func("p7_fxanim_zm_factory_bridge_lft_bundle", &bridge_connect , "done" );
	scene::add_scene_func("p7_fxanim_zm_factory_bridge_rt_bundle", &bridge_disconnect , "init" );
	scene::add_scene_func("p7_fxanim_zm_factory_bridge_rt_bundle", &bridge_connect , "done" );	

	level flag::init( "bridge_down" );

	// wait for power
	if(!flag::get("power_on"))
	{level waittill( "power_on" );}
	
	level util::clientnotify ("pl1");
	
	level thread scene::play( "p7_fxanim_zm_factory_bridge_lft_bundle" );
	level scene::play( "p7_fxanim_zm_factory_bridge_rt_bundle" );
	
	// wait until the bridges are down.
	level flag::set( "bridge_down" );

    foreach(clip in wnuen_bridge_clip){clip ConnectPaths(); clip delete();}
    foreach(clip in warehouse_bridge_clip){clip ConnectPaths(); clip delete();}
    foreach(clip in wnuen_bridge){clip ConnectPaths();}

	//add new playable zones
	//zm_zonemgr::connect_zones( "wnuen_bridge_zone", "bridge_zone" );
	//zm_zonemgr::connect_zones( "warehouse_top_zone", "bridge_zone" );
}

function bridge_disconnect( a_parts )
{
	foreach( part in a_parts )
	{
		part DisconnectPaths();
	}
}

function bridge_connect( a_parts )
{
	foreach( part in a_parts )
	{
		part ConnectPaths();
	}
}
//////////////////
//  BEAST MODE  //
//////////////////
function beast()
{
	trigger = GetEntArray("beast_mode", "targetname");
	foreach(trig in trigger)
	{
		trig thread become_the_beast(self);
	}
}
function become_the_beast(player)
{
	player endon("disconnect");
	level endon("end_game");
	trigger = GetEntArray("beast_mode", "targetname");
	self UseTriggerRequireLookAt();

	if(isdefined(self.script_hint)){self SetHintString(self.script_hint);}else{self SetHintString("Currently Unavalible.");}

	//if player joins mid game if trigger is active then dont use waittill
	if(!isdefined(self.set_active))
	{self.set_active = false;}
	if(self.set_active == false)
	{
		if(isdefined(self.script_waittill) && self.script_waittill != "")
		{level waittill(self.script_waittill);}
		self.set_active = true;
	}

	while(isdefined(self) && isdefined(player))
	{
		player.beast = 1;
		foreach(trig in trigger)
		{
			trig SetHintStringForPlayer(player, "Hold ^3[{+activate}] ^7to become the beast");
		}		
		self waittill("trigger",client);

		if(player.beast > 0 && client == player)
		{
			org = player GetOrigin();
			angles = player GetPlayerAngles();
			style = player GetCharacterBodyType();
			PlayFX(BEASTMODE_FX, player.origin);
			wait(.05);
			foreach(trig in trigger)
			{
				trig SetHintStringForPlayer(player, "The Curse has awoke");
			}
			walls = GetEntArray("beast_wall", "targetname");
			foreach(wall in walls)
			{
				wall SetInvisibleToPlayer(player, true);
			}
			player FreezeControls(true);
			player thread lui::screen_fade_out(.1); 
			player.ignoreme = true;
			player EnableInvulnerability();
			player.beast = 2;
			player.thirdperson = 1;
			player.touching_beast_trigger = 0;
			player SetPlayerGravity(300);
			wait(.5);
			player thread watch_ads();
			player thread lui::screen_fade_in(.5); 
			player SetCharacterBodyType(4);
			player SetClientThirdPerson(1);
			player FreezeControls(false);

			beast_mode_brief_first_person = getentarray("beast_mode_brief_first_person","targetname");
			foreach(ent in beast_mode_brief_first_person)
			{
				player thread beast_mode_brief_first_person(ent);
			}

			player PlaySound(FAST_TRAVEL_AND_BEAST_MODE_SOUND);
			player thread zm_equipment::show_hint_text("Double Jump is ^3Enabled^7.",10);
			player AllowDoubleJump(true);
			player DisableWeapons();

			timer = BEASTMODE_TIME;
			while(timer > 0)
			{
				if(timer < 6)
				{
					player thread zm_equipment::show_hint_text("Ending in ^3" + timer + "^7.",.98);
				}
				wait(1);
				timer = timer - 1;
			}

			free = false;
			while(free == false)
			{
				free = thread check_location_free(org);
				if(free == true){break;}
				else 
				{
					if(DEBUG == true){IPrintLnBold("^1Error^7: Another player was standing in your spawn point!! picking a new location");}
					else{wait.1;}
				}
			}
			PlayFX(BEASTMODE_FX, player.origin);	
			player SetOrigin(org);
			player SetPlayerAngles(angles);
			player SetStance("stand");
			player SetCharacterBodyType(style);
			player ClearPlayerGravity();
			player SetClientThirdPerson(0);
			player DisableInvulnerability();
			foreach(trig in trigger)
			{
				trig SetHintStringForPlayer(player, "The Curse Sleeps...");
			}	
			foreach(wall in walls)
			{
				wall SetInvisibleToPlayer(player, false);
			}
			player StopSound(FAST_TRAVEL_AND_BEAST_MODE_SOUND);
			player PlaySound(PLAYER_REVIVED_SOUND);
			self notify("used_beast_mode");
			player AllowDoubleJump(false);
			player.beast = 0;
			wait(.15);
			PlayFX(BEASTMODE_FX, player.origin);		
			player SetClientThirdPerson(0);
			visionset_mgr::deactivate( "overlay", "zm_bgb_in_plain_sight", player );
			visionset_mgr::deactivate( "visionset", "zm_bgb_in_plain_sight", player );
			player EnableWeapons();
			wait(3);
			player.touching_beast_trigger = 0;
			player.thirdperson = 0;
			player EnableWeapons();
			player.ignoreme = false;
			level waittill("start_of_round");
			player.beast = 1;	
		}
	}
}
function beast_mode_brief_first_person(trig)
{
	self endon("disconnect");
	self endon("used_beast_mode");

	while(isdefined(self) && self.beast == 2)
	{
		if(self IsTouching(trig))
		{}
		else
		{
			trig waittill("trigger",player);
			if(player != self)
			{continue;}
		}
		if(self.beast == 2)
		{
			self thread lui::screen_fade_in(.2);
			self SetClientThirdPerson(0);
			visionset_mgr::activate( "overlay", "zm_bgb_in_plain_sight", self, 2, 1, 2 );
			visionset_mgr::activate( "visionset", "zm_bgb_in_plain_sight", self, 2 );

			while(self IsTouching(trig) && self.beast == 2)
			{
				self SetClientThirdPerson(0);
				self.thirdperson = 0;
				self.touching_beast_trigger = 1;
				wait(.1);
			}
			self thread lui::screen_fade_in(.2);
			visionset_mgr::deactivate( "overlay", "zm_bgb_in_plain_sight", self );
			visionset_mgr::deactivate( "visionset", "zm_bgb_in_plain_sight", self );
			self SetClientThirdPerson(1);
			self.thirdperson = 1;
			self.touching_beast_trigger = 0;
		}
	}
}
function watch_ads()
{
	self endon("disconnect");
	self endon("used_beast_mode");
	while(isdefined(self) && self.beast == 2)
	{
		while((self AdsButtonPressed() || self IsReloading()) && self.beast == 2)
		{
			self SetClientThirdPerson(0);
			visionset_mgr::activate( "overlay", "zm_bgb_in_plain_sight", self, 2, 1, 2 );
			visionset_mgr::activate( "visionset", "zm_bgb_in_plain_sight", self, 2 );
			self.thirdperson = 0;
			self EnableWeapons();
			wait(.1);
		}
		if(self.beast == 2 && self.thirdperson == 0 && self.touching_beast_trigger != 1)
		{
			visionset_mgr::deactivate( "overlay", "zm_bgb_in_plain_sight", self );
			visionset_mgr::deactivate( "visionset", "zm_bgb_in_plain_sight", self );
			self SetClientThirdPerson(1);
			self.thirdperson = 1;
		}
		self DisableWeapons();
		wait.05;
	}
}
///////////////////////////////
//  INFINITE ZOMBIE SPAWNING //
///////////////////////////////
function autoexec toggle_infinite_spawning()
{
	level endon("end_game");
	level waittill("all_players_connected");
	while(1)
	{
		level waittill(INFINITE_ZOMBIE_SPAWNING_NOTIFY);
		total = level.zombie_total;
		thread do_the_infinite_spawning();
		if(DEBUG == true){IPrintLnBold("infinite spawning ^3True");}

		level waittill(INFINITE_ZOMBIE_SPAWNING_NOTIFY);
		level.zombie_total = total;
		if(DEBUG == true){IPrintLnBold("infinite spawning ^1flase");}
	}
}
function do_the_infinite_spawning()
{
	level endon("end_game");
	level endon(INFINITE_ZOMBIE_SPAWNING_NOTIFY);
	
	while(1)
	{
		level flag::wait_till( "spawn_zombies" );
		if( zombie_utility::get_current_zombie_count() < level.zombie_ai_limit )
		{level.zombie_total = level.zombie_ai_limit;}
		level.zombie_respawns++; 
		wait( level.zombie_vars["zombie_spawn_delay"] );
		if(DEBUG == true){IPrintLnBold("infinite spawning ^3True");}
	}
}
///////////////////////////////
//  TELEPORT ZOMBIE TRIGGER  //
///////////////////////////////
function teleport_zombie(zombie)
{
	level endon("end_game");
	zombie endon("death");

	loc = GetEntArray( self.target, "targetname" );

	if(isdefined(self.script_flag) && self.script_flag != "")
	{flag = self.script_flag;}

	while(isdefined(zombie) && isdefined(self))
	{
		self waittill("trigger",ent);
		if(zombie == ent)
		{
			//if teleport trigger flag is not active do nothing.
			if(isdefined(flag) && !level flag::get(flag))
			{wait.05; if(DEBUG == true){IPrintLnBold("^1Notify^7: Zombie touched teleport trig but flag is false!");} continue;}

			if(DEBUG == true){IPrintLnBold("^1Notify^7: Zombie touched teleport trig!");}

			if(isdefined(self.script_notify) && self.script_notify != "")
			{level notify(self.script_notify);}

			if(isdefined(self.script_sound))
			{zombie PlaySound(self.script_sound);}

			PlayFX(BEASTMODE_FX, zombie.origin);
			rand = RandomInt(loc.size);
			zombie ForceTeleport( loc[rand].origin );
			PlayFX(BEASTMODE_FX, zombie.origin);
		}
		wait(0.05);
	}
}
function hide_models()
{
	loc = GetEntArray( self.target, "targetname" );
	foreach(ent in loc){ent SetModel("tag_origin");}
}
///////////////////////////
//  AI SACRIFICE DEFEND  //
///////////////////////////
function autoexec ai_sacrifice_defend()
{
	level waittill("all_players_connected");
	sacrifice_defend = struct::get_array("sacrifice_defend","targetname");
	foreach(ent in sacrifice_defend){ent thread sacrifice_defend_setup();}
	
	trig = GetEntArray( "teleport_ai", "targetname" );
	foreach(ent in trig){ent thread hide_models();}
}
function sacrifice_defend_setup()
{
	level endon("end_game");
	targets = GetEntArray(self.target,"targetname");
	size = targets.size;
	if(!isdefined(targets)){if(DEBUG == true){IPrintLnBold("^1Error^7: Defend objective has no targets!");}return;}
	for(i=0;i<size;i++)
	{
		if(!isdefined(targets[i].script_noteworthy))
		{struct[i] = SpawnStruct(); struct[i].origin = targets[i].origin; struct[i].angles = targets[i].angles; targets[i] Delete();}
		else{trig = targets[i];}
	}
	
	//how many souls it takes to fail the challenge
	if(isdefined(self.script_damage))
	{self.damage = self.script_damage;}
	else{self.damage = 30;}
	health = self.damage;
	while(isdefined(self))
	{
		//if loops to top we want to ensure were at its original max health
		self.damage = health; self.script_damage = health;
		//waittill flag is ready
		if(isdefined(self.script_flag) && self.script_flag != "")
		{level flag::init(self.script_flag); level flag::wait_till(self.script_flag);}
		else{if(DEBUG == true){IPrintLnBold("^1Error^7: Defend objective has not flag to wait for!");}return;}

		//get min/max time between zombie spawns
		if(isdefined(self.script_int) && self.script_int > 0)
		{min = self.script_int;}
		else{min = 1;}
		if(isdefined(self.script_num) && self.script_num > 0)
		{max = self.script_num;}
		else{max = 3;}	

		if(!isdefined(self.script_string) || self.script_string == ""){self.script_string = "super_sprint";}

		thread DisplayChallengeHud(self.script_damage,self);

		//while flag is active && damage != 0 continue the defence
		while(level flag::get(self.script_flag) && self.damage > 0)
		{
			rand = RandomInt(size - 1);
			spawner = array::random( level.zombie_spawners );
			zombie = zombie_utility::spawn_zombie(spawner, undefined, struct[rand]);
			if(isdefined(zombie)){
			zombie zm_spawner::zombie_spawn_init(undefined);
			wait .2;
			zombie SetTeam("axis");
			zombie.hit_objective = 0;
			//PlaySoundAtPosition(ZOMBIE_SPAWN, struct[rand].origin);
			PlayFX(ZOMBIE_SPAWN_FX, zombie.origin);
			zombie setgoalentity(self.origin, true);
			zombie zombie_utility::set_zombie_run_cycle_override_value(self.script_string);
			zombie thread is_touching_objective(trig,self);
			zombie thread monitor_death();
			}
			wait_time = RandomIntRange(min,max);
			wait(wait_time);		
		}

		if(self.damage <= 0)
		{level flag::clear(self.script_flag); if(DEBUG == true){IPrintLnBold("Defend objective ^1FAILED^7!");}
		//if lost loop to top and wait for the flag to be active again.
		thread DestroyChallengeHud(); wait(1);
		}
		else{if(DEBUG == true){IPrintLnBold("Defend objective ^3WON^7! sending notify ^6"+self.script_notify); if(isdefined(self.script_notify) && self.script_notify != ""){level notify(self.script_notify);}
		//delete everything if won and send the custom winning notify
		for(i=0;i<size;i++){if(isdefined(struct[i])){struct[i] Delete();}}
		if(isdefined(trig)){trig Delete();} if(isdefined(self)){self Delete();} thread DestroyChallengeHud(); return;
		}}
	}
}
function monitor_death()
{//plays a different fx if player kills them before they hith the end goal
	self waittill("death");
	if(self.hit_objective == 0)
	{PlayFX("blood/fx_blood_impact_exp_body_lg_zmb", self.origin);}
}
function is_touching_objective(trig,obj)
{
	PlayFXOnTag(SOULBOX_TRAIL_FX, self, "j_spinelower");
	//while alive and flag is still true
	while(IsAlive(self) && level flag::get(obj.script_flag) && isdefined(self))
	{
		trig waittill("trigger",ai);
		if(isdefined(self) && self == ai)
		{
			obj.damage = obj.damage - 1;PlaySoundAtPosition(ZOMBIE_SPAWN, self.origin);PlayFX(BEASTMODE_FX, self.origin); 
			if(DEBUG == true){IPrintLnBold("Defend Health = ^6+"+obj.damage+"^7!");}
			obj thread UpdateChallengeHud(obj.damage, obj.script_damage,obj);
			self.hit_objective = 1; self Kill(self.origin); return;
		}
	}
	if(isdefined(self)){self Kill(self.origin);}
}
/////////////////////////////////////
//  Health Depletion Progress Bar  //
/////////////////////////////////////
function DisplayChallengeHud(max,ent)
{
	if(!isdefined(self.script_hint) || self.script_hint == ""){self.script_hint = "Health Remaining...";}
    level.challenge_hud_bar = hud::createServerBar((0.463, 1, 0), 250, 10, 0, "allies", true);
    level.challenge_hud_bar hud::SetPoint("TOPCENTER", "TOPCENTER");
    level.challenge_hud_text = hud::createServerFontString("big", 1, "allies");
    level.challenge_hud_text hud::SetPoint("TOPCENTER", "TOPCENTER", 0, 10);
    level.challenge_hud_text SetText(self.script_hint, 100);
    level.challenge_hud_bar thread hud::updateBar((1 / 1));
}
function UpdateChallengeHud(newPercentage,max,ent)
{
	if(!isdefined(self.script_hint) || self.script_hint == ""){self.script_hint = "Health Remaining...";}
    level.challenge_progression_percentage = newPercentage;
    level.challenge_hud_bar thread hud::updateBar((newPercentage / max));
	level.challenge_hud_text SetText(self.script_hint, newPercentage / max * 100);
}
function DestroyChallengeHud()
{
    level.challenge_hud_bar hud::destroyelem();
    level.challenge_hud_text hud::destroyelem();
}
///////////////////////////
//  KILL ZOMBIE TRIGGER  //
///////////////////////////
function kill_zombie(zombie)
{
	level endon("end_game");
	zombie endon("death");

	if(isdefined(self.script_flag) && self.script_flag != "")
	{flag = self.script_flag;}

	while(isdefined(zombie) && isdefined(self))
	{
		self waittill("trigger",ent);
		if(zombie == ent)
		{
			//if kill trigger flag is not active do nothing.
			if(isdefined(flag) && !level flag::get(flag))
			{wait.05; if(DEBUG == true){IPrintLnBold("^1Notify^7: Zombie touched kill trig but flag is false!");} continue;}

			if(DEBUG == true){IPrintLnBold("^1Notify^7: Zombie touched kill trig!");}
			if(isdefined(self.script_sound) && isdefined(zombie))
			{zombie PlaySound(self.script_sound);}

			if(isdefined(self.script_notify) && self.script_notify != "")
			{level notify(self.script_notify);}

			PlayFX(BEASTMODE_FX, zombie.origin);
			zombie DoDamage(zombie.health,zombie.origin);
		}
		wait(0.05);
	}
}
///////////////////////
//  MOVE PACKAPUNCH  //
///////////////////////
function autoexec move_pap()
{
    level waittill("initial_blackscreen_passed");
	triggers = zm_pap_util::get_triggers();
    for(i=0;i<triggers.size;i++)
	{
		level.pap[i] = Spawn("script_model",triggers[i].zbarrier.origin);
		level.pap[i] SetModel("tag_origin");
		triggers[i] EnableLinkTo();
		triggers[i] LinkTo(triggers[i].zbarrier);
		triggers[i].clip EnableLinkTo();
		triggers[i].clip LinkTo(triggers[i].zbarrier);
		triggers[i].zbarrier EnableLinkTo();
		triggers[i].zbarrier LinkTo(level.pap[i]);
	}
	/*Example:
	while(level flag::get("pack_machine_in_use"))
	{wait(.5);}
	level.pap[0] moveto(struct.origin,5);
	level.pap[1] moveto(struct2.origin, 5);
	*/
}
///////////////////////////
//  END GAME CAMERA PAN  //
///////////////////////////
function custom_intermission()
{
	wait(4);
	players = GetPlayers();
	start = struct::get("intermission", "targetname");
	end = struct::get(start.target, "targetname");
	focus_point = struct::get(end.target, "targetname");
	if (!IsDefined(focus_point))
	{
		IPrintLnBold("Error: Missing focus point struct.");
		return;
	}
	temp_ent = util::spawn_model("tag_origin", start.origin, start.angles);
	foreach (player in players)
	{
		player thread end_game_player_setup();
	}
	wait(1.5);
	foreach (player in players)
	{
		player StartCameraTween(0.1);
		player CameraActivate(true);
		player CameraSetPosition(temp_ent);
		player CameraSetLookAt(focus_point.origin);
	}
	speed = 12; // default speed if not defined via KVP
	if (IsDefined(end.script_transition_time))
	{
		speed = end.script_transition_time;
	}
	temp_ent MoveTo(end.origin, speed);
	temp_ent RotateTo(end.angles, speed);
	wait(9);
	level thread lui::screen_fade_out(3);
	wait(3);
	temp_ent Delete();
}
function end_game_player_setup()
{
	self FreezeControls(true);
	wait(0.5);
	self thread lui::screen_flash( 0.5, 1.5, 0.5, 1, "black" );
	self setClientUIVisibilityFlag( "hud_visible", 0 );
	wait(0.5);
	self Ghost();
}
//////////////
//  LADDER  //
//////////////
function isladder(ladder)
{
	self endon("disconnect");
	self endon("end_game");
	
	mantle = getent(ladder.target,"targetname");
	said = 0;
	while(isdefined(self) && isdefined(ladder))
	{
		ladder waittill("trigger",player);
		while(self == player && self IsTouching(ladder))
		{
			if(self IsOnLadder())
			{
				if(DEBUG == true){IPrintLnBold(self.name + " is ^3touching^7 a ladder trigger");}
				while(self IsOnLadder())
				{
					self.ignoreme = true;
					self EnableInvulnerability();
					wait(.1);
					if(self IsTouching(mantle) && said == 0)
					{
						said = 4;//the delay between sending this message on screen again
						self thread zm_equipment::show_hint_text("Press ^3[{+gostand}]^7 to mantle",4);
					}
					if(said > 0)
					{
						said = said -.1;
					}
				}
				//incase player falls off ladder lets not kill them from fall damage...
				while(self IsOnGround() == 0)
				{
					self EnableInvulnerability();
					wait(.05);
				}
				if(DEBUG == true){IPrintLnBold(self.name + " has ^1exited^7 the ladder trigger");}
				said = 0;
				self.ignoreme = false;
				if(self.cheat4 != true || self.cheat3 != true)
				{
					self DisableInvulnerability();
				}
			}
			wait(.05);
		}
		wait(.05);
	}
}
////////////
//  LAVA  //
////////////
function autoexec lava_sound()
{
	level waittill("all_players_connected");
	fire = struct::get_array("lava_sound","targetname");
	foreach(ent in fire)
	{ent thread play_lava_sound();}
}
function play_lava_sound()
{
	sound = Spawn("script_model", self.origin);
	sound SetModel("tag_origin");
	sound PlayLoopSound("lava_loop_sound");
	self Delete();
}
function get_trig()
{
	trig_fire = GetEntArray("lava_trig","targetname");
	foreach(trig in trig_fire )
	{
		self thread zombie_watch_for_trig(trig);
	}
}
function zombie_watch_for_trig(trig)
{
	self endon("death");
	level endon("end_game");

	//if player joins mid game if trigger is active then dont use waittill
	if(!isdefined(self.set_active))
	{self.set_active = false;}
	if(self.set_active == false)
	{
		if(isdefined(self.script_waittill) && self.script_waittill != "")
		{level waittill(self.script_waittill);}
		self.set_active = true;
	}

	while(isdefined(self))
	{
		trig waittill("trigger",zombie);
		if(zombie == self)
		{
			self.zombie_on_fire = 1;
			self.flame_fx_timeout = 15;
			self thread zombie_death::flame_death_fx();
			wait 15;
			self.zombie_on_fire = 0;
		}
		wait(.05);
	}
}
function watch_for_death()
{
	level endon("end_game");

    if(!isdefined(self.zombie_on_fire))
    {self.zombie_on_fire = 0;}
	if(self.zombie_on_fire == 1)
	{
		PlayFX("explosions/fx_vexp_raps_death",self.origin);
		PlaySoundAtPosition("explode_flesh",self.origin);
		self thread zombie_explodes_intopieces(false);
		self PlaySound("z_explode");
		self ghost();
		self clientfield::set("zombie_ragdoll_explode", 1);
		//if player is within zombies explosive radius do damage to them if they dont have phdflopper 
		foreach(player in GetPlayers() )
		if ( distance2dSquared( player.origin, self.origin ) < 7000 && !player hasPerk( "specialty_phdflopper" ) )
		{
			player DoDamage( 40, self.origin);
			player shellShock( "explosion", 0.6 );
			Earthquake(0.2,0.6,self.origin,200);
		}	
	}
}
function zombie_explodes_intopieces( random_gibs )
{
    if ( isdefined(self) && IsActor(self) )
    {
        if( (!random_gibs) || (randomint(100) < 50) )
            gibserverutils::gibhead( self );
        if( (!random_gibs) || (randomint(100) < 50) )
            gibserverutils::gibleftarm( self );
        if( (!random_gibs) || (randomint(100) < 50) )
            gibserverutils::gibrightarm( self );
        if( (!random_gibs) || (randomint(100) < 50) )
            gibserverutils::giblegs( self );
    }
}
function lava_on_player()
{
	trig_fire = GetEntArray("lava_trig","targetname");
	foreach(trig in trig_fire )
	{
		self thread watch_player_step_on_lava_trig(trig);
	}
}
function watch_player_step_on_lava_trig(trig)
{
	self endon("disconnect");
	level endon("end_game");

	self.is_burning = false;

	//if player joins mid game if trigger is active then dont use waittill
	if(!isdefined(self.set_active))
	{self.set_active = false;}
	if(self.set_active == false)
	{
		if(isdefined(self.script_waittill) && self.script_waittill != "")
		{level waittill(self.script_waittill);}
		self.set_active = true;
	}

	while(1)
	{
		trig waittill("trigger",player);
		if(self.is_burning != true && self IsOnGround() && player == self && self IsWallRunning() == 0)
		{
			self.is_burning = true;
			self do_player_fire_damage();
			wait 1.5;
			self.is_burning = false;
		}

		wait 0.05;
	}
}
function do_player_fire_damage( damage )
{    
    self endon("death");
    self endon("disconnect");
    time = 4;
	self.is_burning = true;
    if ( self hasPerk( "specialty_phdflopper" ) )
    {
		self burnplayer::setPlayerBurning( time, .5, 0, self, undefined );
        wait time;
        self.is_burning = false;
    }
    else
    {
		self burnplayer::setPlayerBurning(time, .5, 6, self, undefined );
        self AllowSprint(false);
        wait time;
        self AllowSprint(true);
        self.is_burning = false;
    }
}
/////////////////////
// BUYABLE ENDING  //
/////////////////////
function autoexec buyable_ending()
{
	buyable_ending = GetEnt("buyable_ending","targetname");
	//if buyable ending is not in the map stop this code
	if(!isdefined(buyable_ending))
	{
		return;
	}
	
	if(isdefined(buyable_ending.zombie_cost) && buyable_ending.zombie_cost > 0)
	{level.buyable_ending_cost = buyable_ending.zombie_cost;}
	else{level.buyable_ending_cost = 30000;}

	ent = GetEnt(buyable_ending.target,"targetname");
	ent PlayLoopSound(BUYABLE_ENDING_LOOP_SOUND);

	if(isdefined(buyable_ending.script_waittill))
	{buyable_ending SetHintString(BUYABLE_ENDING_NOT_READY_TEXT); level waittill(buyable_ending.script_waittill);}
	
	//while buyable ending is not paid for
	while(level.buyable_ending_cost > 0 && isdefined(buyable_ending))
	{
		buyable_ending SetHintString(USE + "end the game! Costs: $^3"+ level.buyable_ending_cost +"\n^3Melee ^7to withdraw funds");	
		buyable_ending waittill("trigger",player);
		if(player.score >= 5000 && player.score < level.buyable_ending_cost)
		{
			player.score -= 5000;
			player PlayLocalSound(PURCHASE_ACCEPT);
			level.buyable_ending_cost -= 5000;
		}
		//player can only invest $1000
		else if(player.score >= 1000 && player.score < level.buyable_ending_cost)
		{
			player.score -= 1000;
			player PlayLocalSound(PURCHASE_ACCEPT);
			level.buyable_ending_cost -= 1000;
		}
		//player has not enough money
		else if(player.score < 1000)
		{
			player PlayLocalSound(PURCHASE_DENY);
			buyable_ending SetHintString("^3Error^7: insufficient funds!");
			wait(1);
		}
		//player paid for buyable ending
		else if(player.score >= level.buyable_ending_cost)
		{
			player.score -= level.buyable_ending_cost;
			level.buyable_ending_cost = 0;
			level.wongame = true;
			thread zombie_goto_round(level.round_number);
			ent StopLoopSound();
			wait.05;
			player PlayLocalSound(PURCHASE_ACCEPT);
			buyable_ending Delete();
			level notify("end_game");
		}
		wait(.05);
	}
}
function autoexec withdraw_from_ending()
{
	level waittill("initial_blackscreen_passed");
	withdraw = GetEnt("withdraw","targetname");
	buyable_ending = GetEnt("buyable_ending","targetname");

	//if buyable ending is not in the map stop this code
	if(!isdefined(buyable_ending))
	{
		return;
	}

	if(isdefined(buyable_ending.script_waittill))
	{level waittill(buyable_ending.script_waittill);}

	ent = GetEnt(buyable_ending.target,"targetname");
	withdraw UseTriggerRequireLookAt();
	while(isdefined(buyable_ending) && isdefined(withdraw))
	{
		buyable_ending SetHintString(USE + "end the game! Costs: $^3"+ level.buyable_ending_cost +"\n^3Melee ^7to withdraw funds");		
		withdraw waittill("trigger",player);
		diff = buyable_ending.zombie_cost - level.buyable_ending_cost;
		//if $5000 + is invested you can withdraw it. 
		if(diff >= 5000)
		{
			player.score += 5000;
			level.buyable_ending_cost += 5000;
			player PlayLocalSound(PURCHASE_ACCEPT);
			player PlayLocalSound(RADIO_WITHDRAW);
		}
		//else if $1000 + is invested you can withdraw it
		else if(diff >= 1000)
		{
			player.score += 1000;
			level.buyable_ending_cost += 1000;
			player PlayLocalSound(PURCHASE_ACCEPT);
			player PlayLocalSound(RADIO_WITHDRAW);
		}
		//if no money is invested you cannot withdraw
		else if(level.buyable_ending_cost == buyable_ending.zombie_cost)
		{
			player PlayLocalSound(PURCHASE_DENY);
		}
		//if buyable ending is paid for you cannot withdraw
		else if(level.buyable_ending_cost <= 0)
		{
			break;
		}
		wait(.05);
	}
}
/////////////////
// GOTO ROUND  //
/////////////////
function zombie_goto_round(round)
{
	if(	level flag::get("dog_round"))
	{
		return;
	}
	level notify( "restart_round" );
	if ( round < 1 )
	{
		level.round_number = 1;
	}
	else 
	{
		level.zombie_total = 0;
		zombie_utility::ai_calculate_health( round );
		wait(0.05);
		zm::set_round_number( round );
	}
	
	// kill all active zombies
	zombies = zombie_utility::get_round_enemy_array();
	if ( isdefined( zombies ) )
	{
		array::run_all( zombies, &Kill );
	}
	
	level.sndGotoRoundOccurred = true;

	level waittill( "between_round_over" );
}
/////////////////////////
// HUD OVERLAY TRIGGER //
/////////////////////////
function hud_overlay(trig)
{
	if(level flag::get("initial_blackscreen_passed")){}
	else{level waittill("initial_blackscreen_passed");}
	level endon("end_game");
	self endon("disconnect");
	while(isdefined(self) && isdefined((trig)))
	{
		if(self IsTouching(trig))
		{
			wait(.05);
		}
		else 
		{
			trig waittill("trigger",player);
			if(self != player)
			{
				wait(.05);
				continue;
			}
		}
		if(self.touching_mask_trigger != true)
		{
			self.touching_mask_trigger = true;
			self thread lui::screen_fade_out(.1);
			wait(.1);
			self.mask = NewClientHudElem(self);
			self.mask.alignX = "center";
			self.mask.alignY = "middle";
			self.mask.horzAlign = "user_center";
			self.mask.vertAlign = "user_center";	

			if(self IsSplitScreen())
			{
				self.mask SetShader(HUD_OVERLAY, 960, 240); 
			}
			else
			{
				self.mask SetShader(HUD_OVERLAY, 960, 480); 
			}
			self.mask.alpha = 1;
			self thread lui::screen_fade_in(.1);
			if(DEBUG == true){IPrintLnBold(self.name + " is ^3touching^7 hud_overlay");}
		}
		self notify("entered_hud_overlay");
		while(self IsTouching(trig))
		{
			self.touching_mask_trigger = true;
			wait(.05);
		}
		self notify("exited_hud_overlay");
		if(DEBUG == true){IPrintLnBold(self.name + " ^1exited^7 a hud_overlay trigger");}
		self.touching_mask_trigger = false;
		wait(.15);
		if(self.touching_mask_trigger != true)
		{
			self thread lui::screen_fade_out(.1);
			wait(.1);
			self thread lui::screen_fade_in(.1);
			self.mask Destroy();
			wait(.05);
		}
	}
}
/////////////////////
// GAME OVER TEXT  //
/////////////////////
function Ending(player, game_over, survived) 
{  
	if(END_GAME_CAMERA_PAN == true)
	{
		level.custom_intermission =&custom_intermission;
	}
	if(isdefined(level.gungamewinner))  
	{   
		text = level.gungamewinner + " Won!";  
	}  
	//if player won the game
	else if(level.wongame == true) 
	{   
		level.endgame_prefix = "";  
		text = WIN_TEXT;

		//hide you survived rounds
		survived.alignX = "center";  
		survived.alignY = "middle";  
		survived.horzAlign = "center";  
		survived.vertAlign = "middle";  
		survived.y -= 9100;  
		survived.foreground = true;  
		survived.fontScale = .01;  
		survived.alpha = 0;  
		survived.color = ( 1.0, 1.0, 1.0 );  
		survived.hidewheninmenu = true;  
		if ( player isSplitScreen() )  
		{   
		survived.fontScale = 0;   
		survived.y += 9100;  
		} 
	}  
	//else if player lost
	else  
	{   
		text = LOSE_TEXT;

		//show you survived rounds
		survived.alignX = "center";  
		survived.alignY = "middle";  
		survived.horzAlign = "center";  
		survived.vertAlign = "middle";  
		survived.y -= 100;  
		survived.foreground = true;  
		survived.fontScale = 2;  
		survived.alpha = 0;  
		survived.color = ( 1.0, 1.0, 1.0 );  
		survived.hidewheninmenu = true;  
		if ( player isSplitScreen() )  
		{   
		survived.fontScale = 1.5;   
		survived.y += 40;  
		} 
	}
	game_over.alignX = "center";
	game_over.alignY = "middle";
	game_over.horzAlign = "center";  
	game_over.vertAlign = "middle";  
	game_over.y -= 130;  
	game_over.foreground = true;  
	game_over.fontScale = 3;  
	game_over.alpha = 0;  
	game_over.color = ( 1.0, 1.0, 1.0 );  
	game_over.hidewheninmenu = true;
	game_over SetText( END_GAME_PREFIX + " " + text );
	game_over FadeOverTime( 1 );  
	game_over.alpha = 1;  if ( player isSplitScreen() )  {   
	game_over.fontScale = 2;   
	game_over.y += 40;  }   
} 
//////////////////////////////////////////////////
//  CONTROL ZOMBIE MODELS AT EACH RISER STRUCT  //   
//////////////////////////////////////////////////
function getActiveMultiSpawner()
{
    spawners = [];
    activeScriptInts = [];
    players = GetPlayers();

    foreach(player in players)
    {
       if(!zm_utility::is_player_valid(player))
            continue;

        zone = player zm_utility::get_current_zone(true);
        adjacentZones = GetArrayKeys(zone.adjacent_zones);

        foreach(volume in zone.volumes)
                    array::add(activeScriptInts, volume.script_int, false);

        foreach(zoneName in adjacentZones)
        {
            adjacentZone = level.zones[zoneName];

            if(IS_TRUE(adjacentZone.is_active))
            {
                foreach(volume in adjacentZone.volumes)
                    array::add(activeScriptInts, volume.script_int, false);
            }
        }
    }

    foreach(spawner in level.zombie_spawners)
    {
        if(array::contains(activeScriptInts, spawner.script_int))
            array::add(spawners, spawner);
    }

    return array::random(spawners);
}
///////////////////
//	WALLRUNNING  //
///////////////////
function setup_wallrun()
{
	self AllowWallRun(false);
	self.iswallrunning = false;

	wallrun_trigger = GetEntArray("wallrun_trigger", "targetname");
	foreach(trig in wallrun_trigger)
	{
		trig thread wallrun_logic(self);
	}
}
function wallrun_logic(client)
{
	level endon("end_game");
	client endon("disconnect");
	client endon("death");

	while(isdefined(self))
	{
		self waittill("trigger", player);
		if(!player.iswallrunning && player == client)
		{
			client thread enable_wallrun(self);
		}
	}
}
function enable_wallrun(trig)
{
	self endon("death");
	self endon("disconnect");
	self endon("end_game");

	self.iswallrunning = true;
	self thread zm_equipment::show_hint_text("Wallrunning is ^3Enabled^7.",4);
	if(DEBUG == true){IPrintLnBold(self.name + " is ^3touching^7 a wallrun trigger");}
	while(self IsTouching(trig))
	{
		self AllowWallRun(true);
		wait(.05);
	}
	self thread zm_equipment::show_hint_text("Wallrunning is ^1Disabled^7.",4);
	if(DEBUG == true){IPrintLnBold(self.name + " has ^1exited^7 a wallrun trigger");}
	self.iswallrunning = false;
	self AllowWallRun(false);
}
//////////////////////
//  DOUBLE JUMPING  //
//////////////////////
function setup_doublejump()
{
	self AllowDoubleJump(false);
	self.isdoublejumping = false;

	doublejump_trigger = GetEntArray("doublejump_trigger", "targetname");
	foreach(trig in doublejump_trigger)
	{
		trig thread doublejump_logic(self);
	}
}
//if self touch trigger thread to enable_doublejump
function doublejump_logic(client)
{
	level endon("end_game");
	client endon("disconnect");
	client endon("death");

	while(isdefined(self))
	{
		self waittill("trigger", player);
		if(!player.isdoublejumping && player == client)
		{
			client thread enable_doublejump(self);
		}
	}
}
//enables doublejumping while player is touching trigger
function enable_doublejump(trig)
{
	self endon("death");
	self endon("disconnect");
	self endon("end_game");

	self.isdoublejumping = true;
	self thread zm_equipment::show_hint_text("Double Jump is ^3Enabled^7.",4);
	if(DEBUG == true){IPrintLnBold(self.name + " is ^3touching^7 a doublejump trigger");}
	while(self IsTouching(trig))
	{
		self AllowDoubleJump(true);
		wait(.05);
	}
	if(DEBUG == true){IPrintLnBold(self.name + " has ^1exited^7 a doublejump trigger");}
	self.isdoublejumping = false;
	self thread zm_equipment::show_hint_text("Double Jump is ^1Disabled^7.",4);
	self AllowDoubleJump(false);
}
////////////////////
//  FALL TRIGGER  //
////////////////////
function setup_falltrigger()
{
	fall_trigger = GetEntArray("fall_trigger","targetname");
	if(isdefined (fall_trigger))
	{
		foreach(ent in fall_trigger)
		{ent thread fall_trigger(self);}
	}
}
function fall_trigger(client)
{
	client endon("death");
	client endon("disconnect");
	level endon("end_game");
	
	if(isdefined(self.target))
	{target = GetEntArray(self.target,"targetname");}
	else{return;}

	spawn_points = [ ];

	for(i=0;i<target.size;i++)
	{
		if(isdefined(target[i].script_noteworthy)){target[i] Hide();}
		else{target[i] SetModel("tag_origin"); spawn_points[ spawn_points.size ] = target[i];}
	}

	//if player joins mid game if trigger is active then dont use waittill
	if(!isdefined(self.set_active))
	{self.set_active = false;}
	if(self.set_active == false)
	{
		if(isdefined(self.script_waittill) && self.script_waittill != "")
		{level waittill(self.script_waittill);}
		self.set_active = true;
	}

	for(i=0;i<target.size;i++)
	{if(isdefined(target[i].script_noteworthy)){target[i] Show();}}
	
	while(isdefined(self) && isdefined(client))
	{
		self waittill("trigger",player);
		{
			if(player == client)
			{
				if(isdefined(self.script_notify)){level notify(self.script_notify); player notify(self.script_notify);}
				if(DEBUG == true){IPrintLnBold(client.name + " touched a fall/teleport trigger");}
				players = GetPlayers();
				for(i=0;i<players.size;i++)
				{
					if(client == players[i])
					{
						client EnableInvulnerability();
						if(isdefined(self.script_noteworthy) && self.script_noteworthy != "" && isdefined(self.script_float) && self.script_float > 0)
						{
							players[i] FreezeControls(true);
							players[i] DisableWeapons();
							players[i].ignoreme = true;
							players[i] thread lui::play_movie_with_timeout( self.script_noteworthy, "fullscreen",self.script_float); 
							if(isdefined(self.script_sound)){player PlayLocalSound(self.script_sound);}
							time = self.script_float - 1;
							if(time <= 0){time = 0;}
							wait(time);
							players[i] EnableWeapons();
							players[i] FreezeControls(false);
						}
						free = false;
						while(free == false)
						{
							if(!isdefined(spawn_points) || spawn_points.size <= 0)
							{if(DEBUG == true){IPrintLnBold("^1ERROR^7: NO SPAWN POINTS ARE SET FOR THIS FALL/TELEPORT TRIGGER!!!");} break;}
							for(i=0;i<spawn_points.size;i++)
							{
								free = thread check_location_free(spawn_points[i].origin);
								if(free == true)
								{
									client SetOrigin( spawn_points[i].origin );
									client SetPlayerAngles( spawn_points[i].angles );
									PlayFX(BEASTMODE_FX, player.origin);
									client thread hasphd(self);
									break;
								}
								else 
								{
									if(DEBUG == true){IPrintLnBold("^1Error^7: Another player was standing in your spawn point!! picking a new location");}
									if(i<spawn_points.size){i++;}
									else{i=0;wait.05;}
								}
							}
						}
					}
				}
			}
		}
		WAIT_SERVER_FRAME;
	}
}
function hasphd(trig)
{
	while(!self IsOnGround())
	{
		wait.1;
	}
	wait.5;
	self DisableInvulnerability();

	//if they do not have phd flopper damage player
	if(!self HasPerk("specialty_phdflopper"))
	{
		if(isdefined(trig.script_damage) && IsInt(trig.script_damage) && trig.script_damage > 0)
		{self DoDamage(trig.script_damage, self.origin);}

		self.ignoreme = true;
		wait(.2);

		if(isdefined(trig.script_firefx) && trig.script_firefx != "")
		{self ShellShock(trig.script_firefx, 2);}

		wait(.80);
		self.ignoreme = false;
	}
	else{self.ignoreme = true; wait(1); self.ignoreme = false;}
}
function check_location_free(location)
{
    foreach(player in GetPlayers())
    {
        if( DistanceSquared( player.origin, location ) < ( 48 * 48 ) )
        {
            return false;
        }
    }
    return true;
}
////////////////
//  MINECART  //
////////////////
function autoexec minecart()
{
	level waittill("all_players_connected");
	trig = GetEntArray("ridable_minecart","targetname");
	foreach(ent in trig){ent thread ride_minecart();}
}
function ride_minecart()
{
	level endon("end_game");

	self UseTriggerRequireLookAt();

	if(isdefined(self.script_hint)){self SetHintString(self.script_hint);}else{self SetHintString("Currently Unavalible.");}
	
	targets = getentarray(self.target,"targetname");
	for(i=0;i<targets.size;i++)
	{
		if(isdefined(targets[i].script_noteworthy))
		{
			if(targets[i].script_noteworthy == "cart")
			{cart = targets[i];}
			if(targets[i].script_noteworthy == "clip")
			{clip = targets[i];}
			if(targets[i].script_noteworthy == "end")
			{struct = targets[i];}
		}
	}

	end_spawn = GetEntArray(struct.target,"targetname");
	for(i=0;i<end_spawn.size;i++)
	{
		end_spawn[i] SetModel("tag_origin");
	}
	cart.link = Spawn("script_model",cart.origin);
	cart.link SetModel("tag_origin");
	cart.link.angles = cart.angles;
	wait.05;
	cart EnableLinkTo();
	cart LinkTo(cart.link, "tag_origin");

	clip EnableLinkTo();
	clip LinkTo(cart.link,"tag_origin");

	//wait for power or something...
	if(isdefined(self.script_waittill) && self.script_waittill != "")
	{level waittill(self.script_waittill);}

	if(isdefined(self.zombie_cost)){cost = self.zombie_cost;}else{cost = 0;}
	while(1)
	{
		//set hintstring
		self SetHintString(USE+"use transportation. Costs: [$^3"+cost+"^7]");

		self waittill("trigger",player);
		if(player.score >= cost)
		{player.score -= cost; player PlayLocalSound(PURCHASE_ACCEPT);}
		else{player PlayLocalSound(PURCHASE_DENY); wait.05; continue;}

		self SetHintString("Currently in use.");

		free = false;
		while(free == false)
		{
			free = thread check_location_free(cart.origin);
			if(free == true){break;}
			else 
			{
				if(DEBUG == true){IPrintLnBold("^1Error^7: Another player was standing in your spawn point!! picking a new location");}
				else{wait.1;}
			}
		}
		player SetStance("stand");
		player SetOrigin(cart.origin);
		player SetPlayerAngles(cart.angles);
		player PlayerLinkTo(cart.link, "tag_origin");
		PlayFX(BEASTMODE_FX, player.origin);

		if(isdefined(self.script_sound))
		{cart PlayLoopSound(self.script_sound);}
		target = struct::get(cart.target,"targetname");
		looped = 0;
		while(isdefined(target))
		{
			//get time it takes to move to new struct
			if(isdefined(target.script_float))
			{time = target.script_float;}
			else{time = 1;}
			//move cart & player
			cart.link MoveTo(target.origin, time);
			cart.link RotateTo(target.angles,time);
			wait(time);
			if(isdefined(target.target))
			{
				//retain all previous structs origin/angles/time
				org[looped] = target.origin;
				angles[looped] = target.angles;
				times[looped] = time;
				looped++;
				target = struct::get(target.target,"targetname");
			}
			else{break;}
		}
		
		player thread lui::screen_fade_out(.1);
		wait(.1);

		i=0;
		free = false;
		while(free == false)
		{
			free = thread check_location_free(end_spawn[i].origin);
			if(free == true)
			{break;}
			else 
			{
				if(DEBUG == true){IPrintLnBold("^1Error^7: Another player was standing in your spawn point!! picking a new location");}
				if(i<end_spawn.size){i++;}
				else{i=0; wait.05;}
			}
		}

		player Unlink();
		player SetStance("stand");

		player SetOrigin(end_spawn[i].origin);
		player thread lui::screen_fade_in(.1);

		PlayFX(BEASTMODE_FX, player.origin);
		player PlayLocalSound(PLAYER_REVIVED_SOUND);
		cart StopLoopSound();

		wait(1);

		if(isdefined(self.script_sound))
		{cart PlayLoopSound(self.script_sound);}
	
		//reverse the cart back (take 5x longer to reverse back to starting position as cooldown)
		while(1)
		{
			if(isdefined(org[looped]) && isdefined(angles[looped]))
			{
				cart.link MoveTo(org[looped],times[looped] * 5);
				cart.link RotateTo(angles[looped], times[looped] * 5);
			}
			if(isdefined(times[looped]))
			{wait(times[looped] * 5);}

			if(looped == 0){ cart StopLoopSound(); wait(1); break;}
			else{looped--;}
		}
	}
}
/////////////////////
//  KNUCKLE CRACK  //
/////////////////////
function private do_knuckle_crack()
{
	self endon("disconnect");
	self upgrade_knuckle_crack_begin();
 
	self util::waittill_any( "fake_death", "death", "player_downed", "weapon_change_complete" );
 
	self upgrade_knuckle_crack_end();
 
}
function private upgrade_knuckle_crack_begin()
{
	self zm_utility::increment_is_drinking();
 
	self zm_utility::disable_player_move_states(true);

	primaries = self GetWeaponsListPrimaries();

	original_weapon = self GetCurrentWeapon();
	weapon = GetWeapon( PAP_WEAPON_KNUCKLE_CRACK );
	self GiveWeapon( weapon );
	self SwitchToWeapon( weapon );
}
function private upgrade_knuckle_crack_end()
{
	self zm_utility::enable_player_move_states();
 
	weapon = GetWeapon( PAP_WEAPON_KNUCKLE_CRACK );

	// TODO: race condition?
	if ( self laststand::player_is_in_laststand() || IS_TRUE( self.intermission ) )
	{
		self TakeWeapon(weapon);
		return;
	}

	self zm_utility::decrement_is_drinking();

	self TakeWeapon(weapon);
	primaries = self GetWeaponsListPrimaries();
	if(self.IS_DRINKING > 0)
	{
		return;
	}
	else
	{
		self zm_weapons::switch_back_primary_weapon();
	}
	self DisableInvulnerability();
	self.ignoreme = false;
}
//////////////////////
//  AMBIENT SOUNDS  //
//////////////////////
function ambient_sounds()
{
	self endon("disconnect");
	self endon("death");
	self endon("reset_player_ambient_sounds");
	level endon("end_game");


	zone = getentarray( "player_volume", "script_noteworthy" );

	zones = 0;
	for(i=0;i<zone.size;i++)
	{
		if(!isdefined(zone[i].script_sound))
		{
			zones++;
		}
		//if zones == zone.size that means NO volumes have a script_sound which means theres no point in running this function...
		if(zones == zone.size)
		{
			wait(20);
			if(DEBUG == true){IPrintLnBold("NO AMBIENT VOLUMES WERE FOUND! (add script_sound kvp to player_volumes with a 3d sound name to add player ambience to ceratin volumes.");}
			return;
		}
	}
	while(isdefined(self))
	{
		zones = 0;
		for(i=0;i<zone.size;i++)
		{
			//if player is touching volume with a script_sound
			if(self IsTouching(zone[i]) && isdefined(zone[i].script_sound))
			{
				sound = zone[i].script_sound;
				if(IsInt(self.ambient_sound) || self.ambient_sound != sound)
				{
					if(DEBUG == true){IPrintLnBold("^6" + self.name + " ^7has left ^1" + self.ambient_sound + " ^7volume!");}
					self StopLoopSound(2);
					self.ambient_sound = sound;
					wait(.1);
					self PlayLoopSound(sound, 2);
					if(DEBUG == true){IPrintLnBold("^6" + self.name + " ^7is touching ^3" + zone[i].script_sound + " ^7volume!");}
				}
				while(self IsTouching(zone[i]))
				{
					wait(.5);
				}
			}
			//if their touching a volume with no script_sound
			else if(self IsTouching(zone[i]))
			{
				//if their touching a volume with no script_int then ensure their is no loopsound played on player
				if(DEBUG == true && self.ambient_sound != false){IPrintLnBold("^6" + self.name + " ^7has left ^1" + self.ambient_sound + " ^7volume!");}
				if(DEBUG == true){IPrintLnBold("^6" + self.name + " ^7is touching a volume with no ambience sounds attached!");}
				self.ambient_sound = false;
				self StopLoopSound(2);
				while(self IsTouching(zone[i]))
				{
					wait.5;
				}
			}
			//if player is not touching the specified volume add it in a tally
			else
			{
				zones++;
				//if tally is same as zone.size then player is not touching any player_volume...
				if(zones == zone.size)
				{
					self StopLoopSound();
					self.ambient_sound = false;
					if(DEBUG == true){IPrintLnBold("^1Error^7: ^6"+self.name +"^7 is not touching a any player_volumes...");}
					wait(2);
				}
			}
		}
		wait.05;
	}
}
/////////////////
//  WATER/MUD  //
/////////////////
function stuck_in_water(client)
{
	client endon("disconnect");
	client endon("death");
	level endon("end_game");

	if(isdefined(self.script_sound)){sound = self.script_sound;}

	while(isdefined(self) && isdefined(client))
	{
		if(client IsTouching(self)){player = client;}
		else{self waittill("trigger",player);}
		if(player == client)
		{
			if(DEBUG == true){IPrintLnBold(client.name + "has ^3entered^7 a stuck_in_water zone");}
			//get their current speed
			speed = player GetMoveSpeedScale();
			if(isdefined(self.script_sound)){client thread water_sound(self);}
			while(player IsTouching(self))
			{
				//Reduce player speed
				player SetMoveSpeedScale(speed / 1.5);
				player AllowSlide(false);
				player AllowProne(false);
				wait(.1);
			}
			//restore with original speed
			player SetMoveSpeedScale(speed);
			player AllowProne(true);
			player AllowSlide(true);
			if(DEBUG == true){IPrintLnBold(client.name + "has ^1left^7 a stuck_in_water zone");}
			if(isdefined(self.script_sound)){client notify("not_in_water");client StopSound(sound);}
		}
		wait(.05);
	}
	//incase trigger is deleted therefore undefined and player was touching it restore their original speed
	client SetMoveSpeedScale(speed);
	client AllowProne(true);
	client AllowSlide(true);
	client notify("not_in_water");
	client StopSound(sound);
}
function water_sound(trig)
{
	self endon("disconnect");
	self endon("death");
	level endon("end_game");
	self endon("not_in_water");
	
	sound = trig.script_sound;
	while(isdefined(self) && isdefined(trig))
	{
		self PlaySoundWithNotify(sound,"done_splash");
		self waittill("done_splash");
		old_org = self GetOrigin();
		org = self GetOrigin();
		//player has not moved so no splash
		while(old_org == org)
		{
			org = self GetOrigin();
			wait(.2);
		}
		wait(.05);
	}
}
///////////////////
// INTRO FLY IN  //
///////////////////
function fly_in()
{
	if(level.intro_fly_in == true)
	{
		self SetMoveSpeedScale(0);
		self AllowSprint(false);
		self AllowJump(false);
		self AllowCrouch(false);
		self AllowProne(false);
		self AllowMelee(false);
		self FreezeControls(true);
		self.ignoreme = true;

		self thread lui::screen_fade_out(0);
		if(level flag::get("initial_blackscreen_passed"))
		{
			self thread lui::screen_fade_out(0);
			wait(1);
		}
		else 
		{
			level waittill("initial_blackscreen_passed");
			self thread lui::screen_fade_out(0);
			wait(1);
		}

		//get player origins to setup camera above the player
		org = self GetOrigin();
		angles = self GetPlayerAngles();
		rand = RandomInt(3);
		if(rand == 0)
		{
			self thread move_camera(undefined, .02,(org[0],org[1],org[2] + 879), (90, angles[1], angles[2]));
			self waittill("camera_moved");
			self thread lui::screen_fade_in(0);
			self PlayLocalSound(FLY_IN_SOUND);
			wait.3;
			self thread move_camera(undefined, 1, (org[0],org[1],org[2] + 95), (90, angles[1], angles[2]));
			self waittill("camera_moved");
			self thread move_camera(undefined, .2,(org[0],org[1],org[2] + 66), (0,angles[1],angles[2]));
			self waittill("camera_moved");
			self SetPlayerAngles((0,angles[1],angles[2]));
		}

		else if(rand == 1)
		{
			self thread move_camera(undefined, .2,(org[0],org[1] + 879,org[2] + 66), (0, -90, 0));
			self waittill("camera_moved");
			self thread lui::screen_fade_in(0);
			self PlayLocalSound(FLY_IN_SOUND);
			wait(.3);
			self thread move_camera(undefined,1,(org[0],org[1]+ 95, org[2] + 66), (0, -90, 0));
			self waittill("camera_moved");
			self thread move_camera(undefined,.2,(org[0],org[1]+ 66, org[2] + 66), (0,angles[1],angles[2]));
			self waittill("camera_moved");
			self SetPlayerAngles((0,angles[1],angles[2]));
		}

		else
		{
			self thread move_camera(undefined,.2,(org[0],org[1] - 879,org[2] + 66), (0, 90, 0));
			self waittill("camera_moved");
			self thread lui::screen_fade_in(0);
			self PlayLocalSound(FLY_IN_SOUND);
			wait(.3);
			self thread move_camera(undefined,1,(org[0],org[1] - 95, org[2] + 66), (0, 90, 0));
			self waittill("camera_moved");
			self thread move_camera(undefined,.2,(org[0],org[1] - 66, org[2] + 66), (0, angles[1],angles[2]));
			self waittill("camera_moved");
			self SetPlayerAngles((0,angles[1],angles[2]));
		}

		self thread end_camera();
		
		self SetMoveSpeedScale(1);
		self AllowSprint(true);
		self AllowJump(true);
		self AllowCrouch(true);
		self AllowProne(true);
		self AllowMelee(true);
		self FreezeControls(false);
		self.ignoreme = false;

		self notify("flew_in");
		level notify("flew_in");
		if(DEBUG == true){IPrintLnBold("^3" + self.name + "^7 did fly in transition");}
	}
	self.flying_in = false;
}
//////////////////////
//  DISABLE WEAPON  //
//////////////////////
function disable_weapon(player)
{
	player endon("disconnect");
	level endon("end_game");
	while(isdefined(player) && isdefined(self))
	{
		self waittill("trigger",client);
		if(player == client)
		{
			if(DEBUG == true){IPrintLnBold(player.name + " ^3touched^7 a disable_weapons trigger");}
			while(player IsTouching(self))
			{
				player DisableWeapons();
				player.ignoreme = true;
				wait.1;
			}
			if(DEBUG == true){IPrintLnBold(player.name + " ^1exited^7 a disable_weapons trigger");}
			player EnableWeapons();
			player.ignoreme = false;
		}
		wait(.1);
	}
}
/////////////////////
//  LOWER WEAPONS  //
/////////////////////
function lower_weapons(player)
{
	player endon("disconnect");
	level endon("end_game");
	while(isdefined(player) && isdefined(self))
	{
		self waittill("trigger",client);
		if(player == client)
		{
			if(DEBUG == true){IPrintLnBold(player.name + " ^3touched^7 a lower_weapons trigger");}
			while(player IsTouching(self))
			{
				player SetLowReady(true);
				player.ignoreme = true;
				wait.1;
			}
			if(DEBUG == true){IPrintLnBold(player.name + " ^1exited^7 a lower_weapons trigger");}
			player SetLowReady(false);
			player.ignoreme = false;
		}
		wait(.1);
	}
}
///////////////
//  GRAVITY  //
///////////////
function gravity(trig)
{
	self endon("disconnect");
	level endon("end_game");

	if(isdefined(trig.script_waittill) && trig.script_waittill != "")
	{level waittill(trig.script_waittill);}

	while(isdefined(self) && isdefined(trig))
	{
		trig waittill("trigger",player);
		if(player == self && IsPlayer(self))
		{
			if(DEBUG == true){IPrintLnBold(self.name + " has ^3entered^7 a gravity trigger");}
			if(isdefined(trig.script_int))
			{gravity = trig.script_int;}
			else{gravity = 132;}
			while(self IsTouching(trig))
			{
				//set their new gravity
				self SetPlayerGravity(gravity);
				wait(.1);
			}
			if(DEBUG == true){IPrintLnBold(self.name + " has ^1left^7 a gravity trigger");}
			//restore their gravity
			self ClearPlayerGravity();
		}
		wait(.05);
	}
}
///////////////////
//  FAST TRAVEL  //
///////////////////
function autoexec fast_travel_system()
{
	fast_travel_system = GetEntArray("fast_travel_system","targetname");
	foreach(ent in fast_travel_system)
	{
		ent thread interact_with_fast_travel_system();
	}
}
function interact_with_fast_travel_system()
{
	spawns = GetEntArray(self.target,"targetname");
	for(i=0;i<spawns.size;i++)
	{spawns[i] SetModel("tag_origin");}

	self UseTriggerRequireLookAt();
	if(isdefined(self.script_waittill) && self.script_waittill != "")
	{if(isdefined(self.script_hint)){self SetHintString(self.script_hint);}else{self SetHintString("Currently Unavalible.");} level waittill(self.script_waittill);}

	if(isdefined(self.zombie_cost))
	{cost = self.zombie_cost;}
	else{cost = 500;}
	self UseTriggerRequireLookAt();
	self SetHintString(USE + "use fast travel Cost: [$"+ cost + "]");
	while(isdefined(self))
	{
		self waittill("trigger",player);
		//accept
		if(player.score >= cost && player.fast_travel != true)
		{
			player.score -= cost;
			player PlayLocalSound(PURCHASE_ACCEPT);
			player thread using_fast_travel(self,spawns);
		}
		//deny
		else if(player.score < cost)
		{
			player PlayLocalSound(PURCHASE_DENY);
		}
		wait(.5);
	}
}
function using_fast_travel(target,spawns)
{
	self endon("disconnect");
	
	self.fast_travel = true;

	visionset_mgr::activate( "overlay", "zm_bgb_in_plain_sight", self, 2, 1, 2 );
		
	self thread play_fast_travel_sound();
	target = struct::get(target.target,"targetname");

	if(isdefined(target.script_wait))
	{time = target.script_wait;}
	else{time = 1;}
	self thread move_camera(target,time);
	wait(time);

	target = struct::get(target.target,"targetname");

	while(isdefined(target) && self.fast_travel == true)
	{
		if(isdefined(target.script_wait))
		{time = target.script_wait;}
		else{time = 1;}
		self thread move_camera(target,time);
		wait(time);
		if(isdefined(target.target)){target = struct::get(target.target,"targetname");}
		else{break;}
	}
	org = target.origin;

	visionset_mgr::deactivate( "overlay", "zm_bgb_in_plain_sight", self );

	i=0;
	free = false;
	while(free == false)
	{
		free = thread check_location_free(spawns[i].origin);
		if(free == true){break;}
		else 
		{
			if(DEBUG == true){IPrintLnBold("^1Error^7: Another player was standing in your spawn point!! picking a new location");}
			if(i<spawns.size){i++;}
			else{i=0; wait.05;}
		}
	}
	
	self SetOrigin(spawns[i].origin);
	self SetPlayerAngles(spawns[i].angles);
	self thread end_camera();

	self.fast_travel = false;
	self SetStance("stand");
	self notify("used_fast_travel");
	if(isdefined(target.script_notify)){level notify(target.script_notify); self notify(target.script_notify);}
	self thread reset_player_ambience();
}
function play_fast_travel_sound()
{
	self PlayLocalSound(FAST_TRAVEL_AND_BEAST_MODE_SOUND); 
	self waittill("used_fast_travel");
	self StopSound(FAST_TRAVEL_AND_BEAST_MODE_SOUND);
	self PlayLocalSound(PLAYER_REVIVED_SOUND);
}
function reset_player_ambience()
{
	self notify("reset_player_ambient_sounds");
	wait(.5);
	self StopLoopSound();
	wait(.5);
	self.ambient_sound = false;
	self thread ambient_sounds();
}
//////////////
//  CAMERA  //
//////////////
function move_camera(target,time,org,angles,lookat)
{
	if(!isdefined(self) || !IsPlayer(self)){if(DEBUG == true){IPrintLnBold("^1Error^7: Camera must be called on a player!");}return;}
	if(isdefined(target)){location_org = target.origin; location_angles = target.angles;}
	else if(isdefined(org) && isdefined(angles)){location_org = org; location_angles = angles;}
	else {if(DEBUG == true){IPrintLnBold("^1ERROR^7: Camera is missing a location!");}return;}
	//setup player
	self EnableInvulnerability();
	self.ignoreme = 1;
	self SetClientUIVisibilityFlag( "hud_visible", 0 );
	self setClientUIVisibilityFlag( "weapon_hud_visible", 0 );
	self FreezeControls(1);	
	//setup camera
	self CameraActivate( 1 );
	self StartCameraTween(time);
	self CameraSetPosition( location_org );
	self CameraSetAngles( location_angles );
	if(isdefined(lookat)){self CameraSetLookAt( lookat );}
	wait(time);
	self notify("camera_moved");
}
function end_camera()
{
	//return player hud and deactivate cinermatic camera
	if(self.cheat4 != true || self.cheat3 != true)
	{self DisableInvulnerability();}
	self.ignoreme = 0;
    self SetClientUIVisibilityFlag( "hud_visible", 1 );
    self setClientUIVisibilityFlag( "weapon_hud_visible", 1 );
    self FreezeControls( 0 );
	self CameraActivate( 0 );	
}
////////////////////////////////
//  KEEP WEAPONS AFTER DEATH  //
////////////////////////////////
function give_weapons() //get players loadout on laststand then if they die restore their weapons upon respawn
{
	self endon( "disconnect" );
	level endon ( "end_game" );

	//get player weapons
	weapons = self GetWeaponsList(true);

	for(i = 0; i < weapons.size; i++)
	{
		stock[i] = self GetWeaponAmmoStock(weapons[i]);
		clip[i] = self GetWeaponAmmoClip(weapons[i]);
		fuel[i] = self GetWeaponAmmoFuel(weapons[i]);
	}
	
	while(self laststand::player_is_in_laststand() && self.sessionstate != "spectator")
	{
		wait(.05);
	}
	if(self.sessionstate == "spectator")
	{
		if(DEBUG == true){IPrintLnBold(self.name + " has died and their loadout has been saved! Awaiting them to respawn.");}
		while(self.sessionstate == "spectator")
		{
			wait(.1);
		}
		if(level.intro_fly_in == true)
		{
			self waittill("flew_in");
		}

		//wait so player gets their spawn weapons so we can take them
		wait(.05);
		self EnableInvulnerability();
		self.ignoreme = true;

		self TakeAllWeapons();
		for(i=0; i < weapons.size; i++)
		{
			if(zm_weapons::is_weapon_upgraded(weapons[i]))
			{
				weapon_options = self GetBuildKitWeaponOptions( weapons[i], level.pack_a_punch_camo_index); 
				acvi = self GetBuildKitAttachmentCosmeticVariantIndexes( weapons[i], true );
				self GiveWeapon( weapons[i], weapon_options, acvi );
			}	
			else
			{
				self GiveWeapon(weapons[i]);
			}

				self SetWeaponAmmoClip(weapons[i], clip[i]);
				self SetWeaponAmmoStock(weapons[i], stock[i]);
				self SetWeaponAmmoFuel(weapons[i], fuel[i]);
		}
		
		wait(.1);
		self SwitchToWeapon(weapons[1]);
		wait(.1);
		if(weapons.size <= 1)
		{
			self GiveWeapon(level.start_weapon);
		}
		if(self.cheat4 != true || self.cheat3 != true)
		{
			self DisableInvulnerability();
		}
		self.ignoreme = false;
		if(DEBUG == true){IPrintLnBold(self.name + "'s weapons have been restored.");}
	}
}
///////////////////
//  CHECKPOINTS  //
///////////////////
function autoexec save_checkpoint()
{
	level endon("end_game");
	level waittill("initial_blackscreen_passed");
	thread checkpoint();
	num = level.round_number;
	if(num <= 1){num = 0;}
	
	//num = roundnumber at the start of each round check if num is greater than level.roundnumber if it is then we save a checkpoint
	//by default a checkpoint is saved at the start of a new round if the new round is greater than the last saved round
	while(1)	
	{
		level waittill("end_of_round");
		if(DEBUG == true && level.no_end_game_check == true){IPrintLnBold("num = ^3" + num + " ^7round number = ^3" + level.round_number);}
		
		//if num is greater than level.round_number save a new checkpoint
		if(level.round_number > num && level.no_end_game_check == true && level.respawning_players != true)
		{
			num = level.round_number;
			if(level.no_end_game_check == true)
			{
				thread checkpoint();
				if(DEBUG == true){IPrintLnBold("^3Saving Checkpoint^7!");}
			}
		}
		else if(level.no_end_game_check == true){if(DEBUG == true){IPrintLnBold("^1NOT^7 Saving Checkpoint");}}
	}
} 
//call this thread to save the players loadout & score
function checkpoint()
{
	if(level.no_end_game_check == true)
	{
		zombie_utility::set_zombie_var( "spectators_respawn", 				false );		// Respawn in the spectators in between rounds
		players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			if(players[i].sessionstate == "spectator")
			{
				client = players[i];
				players[i] thread globallogic_spawn::spawnPlayer();
				wait(.2);
				players[i] notify ("respawned_players");			
			}
		}
		wait(2);
		players = GetPlayers();
		for(i=0;i<players.size;i++)
		{
			//we dont want to update players weapons if their spectating or they'll spawn with nothing on next respawn
			if(players[i].sessionstate != "spectator")
			{
				players[i] notify("checkpoint");
				players[i] thread no_end_game_check_save_weapons();
				players[i] thread zm_equipment::show_hint_text("^5Checkpoint^7: ^3Saved",4);
			}		
			players[i].ignoreme = false;
		}
		wait(2);
		foreach(player in GetPlayers())
		{
			player.ignoreme = false;
		}
	}
	else{	zombie_utility::set_zombie_var( "spectators_respawn", 				true );}
}
function no_end_game_check()
{
	dead = 0;
	downed = laststand::player_num_in_laststand();
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		if(players[i].sessionstate == "spectator")//counts all spectators
		{dead++;}
	}
	//count downd + spectators against player size
	total = downed + 1 + dead;
	if(DEBUG == true){IPrintLnBold("there are ^6"+total+ "^7 players dead of ^6" +players.size+" ^7players.");}
	if(total == players.size)//if all players are either spectating or downed
	{
		//if game is solo and player has quick revive don't proceed
		if(players.size == 1)
		{
			for(k = 0; k < players.size; k++)
			{
				players[k].end_game_check = true;
			}	
		}
		level notify("all_players_dead");
		wait(1);
		for(z = 0; z < players.size; z++)
		{
			players[z] thread respawn_players();
		}
		level notify("respawning_players");
	}
}
//if all players are spectating or in laststand respawn them & resest round
function respawn_players()
{
	setdvar( "cg_drawCrosshair",  0);

	level.respawning_players = true;

	if(DEBUG == true){IPrintLnBold("respawning players");}

	//freeze controls and fade out
	self FreezeControls(true);
	self EnableInvulnerability();
	self thread lui::screen_fade_out(.5);

	wait(.7);
	
	//reset round
	thread zombie_goto_round(level.round_number);

	wait(1);

	level.respawning_players = false;

	//if in laststand revive them
	if(self laststand::player_is_in_laststand()){self thread zm_laststand::revive_success(self);}

	//respawn players
	self thread globallogic_spawn::spawnPlayer();
	wait(.2);
	self notify("respawned_players");

	if(DEBUG == true){IPrintLnBold("all players respawned!");}

	wait(2);
	//unfreeze controlls and fade in
	self thread lui::screen_fade_in(3);
	self FreezeControls(false);
	self AllowJump(true);
	self.ignoreme = true;
	self thread zm_equipment::show_hint_text("Returned to start of round!");

	//reset score if its round 1
	if(level.round_number <= 1){self.score = 500;}

	wait(5);
	self DisableInvulnerability();
	self.ignoreme = false;

	setdvar( "cg_drawCrosshair",  1);
}
function no_end_game_check_save_weapons(weapons,score,perk_list,gum)
{
	self endon( "disconnect" );
	level endon ( "end_game" );

	//if a new checkpoint is made this function stops and restarts updating the players score + loadout
	self endon("checkpoint");

	if(!isdefined(weapons))
	{
		//get guns/score/perks/gums quickly
		weapons = self GetWeaponsList(true);
		score = self.score;
		if(!self IsInVehicle()){org = self.origin;}

		players = GetPlayers();
		perk_list = [];
		keys = GetArrayKeys( level._custom_perks );

		if(isdefined(keys))
		{
			for ( i = 0; i < keys.size; i++ )
			{
				perk = keys[ i ];
				if ( self hasPerk( perk ) )
				{	
					perk_list[ perk_list.size ] = perk;
				}	
			}
		}
		for(i=0;i<self.bgb_pack.size;i++)
		{
			if(self bgb::is_enabled(self.bgb_pack[i]))
			{
				gum = self.bgb_pack[i];
			}
		}
		//wait for players to finish using packapunch before getting their weapons 
		while (isdefined(level flag::get("pack_machine_in_use")) && level flag::get("pack_machine_in_use"))
		{wait.05; if(DEBUG == true){IPrintLnBold("PACKAPUNCH MACHINE IS IN USE! NOT GETTING PLAYERS WEAPONS YET.");}}

		//get players guns/score/perks
		weapons = self GetWeaponsList(true);
		score = self.score;
		if(!self IsInVehicle()){org = self.origin;}
		perk_list = [];
		keys = GetArrayKeys( level._custom_perks );

		if(isdefined(keys))
		{
			for ( i = 0; i < keys.size; i++ )
			{
				perk = keys[ i ];
				if ( self hasPerk( perk ) )
				{	
					perk_list[ perk_list.size ] = perk;
					if(DEBUG == true){IPrintLnBold("player has ^6" + perk);}	
				}
				else if(DEBUG == true){IPrintLnBold("player does not have ^6" + perk);}	
			}
		}
		for(i=0;i<self.bgb_pack.size;i++)
		{
			if(self bgb::is_enabled(self.bgb_pack[i]))
			{
				gum = self.bgb_pack[i];
			}
		}
	}
	for(i = 0; i < weapons.size; i++)
	{
		stock[i] = self GetWeaponAmmoStock(weapons[i]);
		clip[i] = self GetWeaponAmmoClip(weapons[i]);
		fuel[i] = self GetWeaponAmmoFuel(weapons[i]);
	}
	if(DEBUG == true){IPrintLnBold(self.name + "'s weapons + score has been saved");}
	//waittill the player is respawned from death
	self waittill("respawned_players");
	
	if(DEBUG == true){IPrintLnBold(self.name + " respawn weapons notified");}

	//reset player score
	self.score = score;

	//reset players perks

	players = GetPlayers();
	for ( i = 0; i < perk_list.size; i++ )
	{
		self zm_perks::give_perk(perk_list[i]);	
		if(DEBUG == true){IPrintLnBold( self.name + " had ^3"+ perk_list[i]);}
	}

	//restore with their gumball
	if(isdefined(gum))
	{self bgb::give(gum);}

	//restore with their weapons
	wait(.05);
	self EnableInvulnerability();
	self.ignoreme = true;

	self TakeAllWeapons();
	for(i=0; i < weapons.size; i++)
	{
		if(zm_weapons::is_weapon_upgraded(weapons[i]))
		{
			weapon_options = self GetBuildKitWeaponOptions( weapons[i], level.pack_a_punch_camo_index); 
			acvi = self GetBuildKitAttachmentCosmeticVariantIndexes( weapons[i], true );
			self GiveWeapon( weapons[i], weapon_options, acvi );
		}	
		else
		{
			self GiveWeapon(weapons[i]);
		}

			self SetWeaponAmmoClip(weapons[i], clip[i]);
			self SetWeaponAmmoStock(weapons[i], stock[i]);
			self SetWeaponAmmoFuel(weapons[i], fuel[i]);
			deathmachine = level.zombie_powerup_weapon[ "minigun" ];
			if(DEBUG == true){IPrintLnBold(deathmachine.name);}
			if(weapons[i].name == deathmachine.name)
			{
				weapons[i] TakeWeapon(weapons[i]);
			}
	}
	
	wait(.1);
	self SwitchToWeapon(weapons[1]);
	wait(.1);
	if(weapons.size <= 1)
	{
		self GiveWeapon(level.start_weapon);
	}
	self DisableInvulnerability();
	self.ignoreme = false;

	if(DEBUG == true){IPrintLnBold(self.name + "'s weapons have been restored from latest checkpoint.");}

	//retains their last updated weapon information and score information
	self thread no_end_game_check_save_weapons(weapons,score,perk_list,gum);
}
//////////////////////
//  REVOLVING DOOR  //
//////////////////////
function autoexec rotating_door()
{
	level waittill("all_players_connected");
	rotating_door = GetEntArray("rotating_door","targetname");
	revolving_door = GetEntArray("revolving_door","targetname");
	
	foreach(door in rotating_door)
	{door thread rotate_door();}
	level waittill("rolving_doors_rotating");
	foreach(door in revolving_door)
	{door PlayLoopSound(REVOLVING_DOOR_LOOP_SOUND);}
}
function rotate_door()
{
	level endon ("end_game");

	//wait for power or something...
	if(isdefined(self.script_waittill))
	{level waittill(self.script_waittill);}

	wait.5;
	//send notify so the middle pieces of each rolving door plays the sound
	level notify("rolving_doors_rotating");

	while(isdefined(self))
	{
		self RotateYaw(-360, 8);
		wait(8);
	}
}
///////////////
//  SPEAKER  //
///////////////
function autoexec speaker()
{
	level waittill("all_players_connected");
	trig = GetEntArray("speaker_trigger","targetname");
	foreach(trig in trig)
	{
		trig thread speaker_play_loopsound();
	}
}
function speaker_play_loopsound()
{
	level endon("end_game");

	if(isdefined(self.script_waittill) && self.script_waittill != "")
	{level waittill(self.script_waittill);}

	target = getent(self.target,"targetname");

	sound = self.script_sound;
	target PlayLoopSound(sound);

	self waittill("trigger",player);
	player thread PlayHitMarker();
	target StopLoopSound();
	wait(.05);
	self Delete();
}
////////////////////////
//  MOVING PLATFORMS  //
////////////////////////
function autoexec moving_platform()
{
	level waittill("all_players_connected");
	platform = GetEntArray("moving_platform","targetname");
	if(isdefined(platform)){
	foreach(ent in platform)
	{ent thread move_platform();}
	}
}
function move_platform()
{
	if(!isdefined(self)){return;}
	model = Spawn("script_model", self.origin);
	model SetModel("tag_origin");
	mantle = GetEntArray(self.target,"targetname");
	for(i=0;i<mantle.size;i++){if(mantle[i].script_noteworthy == "mantle"){clip = mantle[i];}}
	if(isdefined(clip))
	{
		clip EnableLinkTo();
		clip LinkTo(model, "tag_origin");
	}
	self EnableLinkTo();
	self LinkTo(model, "tag_origin");
	//dont start moving the platform until a notify is sent (if defined)
	if(isdefined(self.script_waittill) && self.script_waittill != "")
	{level waittill(self.script_waittill);}
	
	while(isdefined(self))
	{
		target = struct::get_array(self.target,"targetname");
		for(i=0;i<target.size;i++){if(target[i].script_noteworthy != "mantle"){target = target[i];}}
		if(!isdefined(target)){if(DEBUG == true){IPrintLnBold("^1Error^7: Moving platform has nothing to do.");} model Delete(); return;}

		while(isdefined(self) && isdefined(target))
		{
			//the time platform remains stationary at its new location
			if(isdefined(target.script_wait))
			{hold = target.script_wait;}
			else{hold = 5;}

			//the time the platform takes to move from point A - B
			if(isdefined(target.script_transition_time))
			{time = target.script_transition_time;}
			else{time = 5;}

			if(target.script_noteworthy == "yaw")
			{model RotateYaw(360, time -.05);}

			if(target.script_noteworthy == "pitch")
			{model RotatePitch(360, time - .05);}

			if(target.script_noteworthy == "roll")
			{model RotateRoll(360, time - .05);}			

			model MoveTo(target.origin, time);
			wait(time + hold);
			if(isdefined(target.target)){target = struct::get(target.target,"targetname");}
			else{break;}
		}
	}
}
////////////////////////////
//  SPAWN ZOMBIE TRIGGER  //
////////////////////////////
function autoexec spawn_z()
{
	spawn_z = GetEntArray("spawnz_trigger","targetname");
	for(i=0;i < spawn_z.size; i++){thread watch_for_trigger_spawn_z(spawn_z[i]);}
}

//each individual spawn_z trigger waits for trigger
function watch_for_trigger_spawn_z(trig)
{
	target = GetEntArray(trig.target,"targetname");
	for(i=0;i < target.size; i++)
	{target[i] SetModel("tag_origin");
	struct[i] = SpawnStruct();
	struct[i].origin = target[i].origin;
	struct[i].angles = target[i].angles;
	struct[i].targetname = target[i].targetname;
}
	trig waittill("trigger",player);
	if(DEBUG == true){IPrintLnBold(player.name + " touched a spawn_z trigger");}
	
	//get array of linked script structs
	for(i=0;i < target.size; i++)
	{
		//spawn zombies on each linked structs
		struct[i].origin = target[i].origin;
		struct[i].angles = target[i].angles;
		spawner = array::random( level.zombie_spawners );
		zombie = zombie_utility::spawn_zombie(spawner, undefined, struct[i]);
		zombie.script_string = "find_flesh";
		zombie zm_spawner::zombie_spawn_init(undefined);
		wait.05;
		PlaySoundAtPosition(ZOMBIE_SPAWN, struct[i].origin);
		PlayFX(ZOMBIE_SPAWN_FX, struct[i].origin);
		wait(.2);
	}
	//delete everything
	for(i=0;i < target.size; i++)
	{target[i] Delete();}
}
//////////////////////////////
//  AUTOMATIC SLIDING DOOR  //
//////////////////////////////
function autoexec sliding_door()
{
	level waittill("initial_blackscreen_passed");
	sliding_door_trigger = GetEntArray("sliding_door_trigger","targetname");
	foreach(ent in sliding_door_trigger)
	{
		ent thread make_door_slide();
	}
}
function make_door_slide()
{
	slide_time = .25;
	target = GetEntArray(self.target,"targetname");
	for(i=0;i<target.size;i++)
	{
		if(isdefined(target[i].script_noteworthy))
		{
			if(target[i].script_noteworthy == "waittill_clip")
			{
				wait_clip = target[i];
			}
			if(target[i].script_noteworthy == "trigger_use")
			{
				use = target[i];
			}
		}
	}

	if(isdefined(self.script_waittill) && self.script_waittill != "")
	{if(isdefined(self.script_hint)){use SetHintString(self.script_hint);}else{use SetHintString("Requires ^3"+self.script_waittill+"^7.");} level waittill(self.script_waittill);}

	if(isdefined(self.zombie_cost) && self.zombie_cost > 0)
	{
		use SetHintString(USE+"open door Costs: [$^3"+self.zombie_cost+"^7]");
		while(1)
		{
			use waittill("trigger",player);
			if(player.score >= self.zombie_cost){player.score -= self.zombie_cost; player PlayLocalSound(PURCHASE_ACCEPT);break;}
			else{player PlayLocalSound(PURCHASE_DENY);wait.05;}
		}
	}

	wait_clip Delete();
	use Delete();
	target = GetEntArray(self.target,"targetname");
	while(isdefined(self))
	{
		self waittill("trigger",player);
		for(i=0;i<target.size;i++)
		{
			target[i] thread slide_open_closed(self,slide_time);
			if(target[i] == target[1])
			{
				target[i] PlaySound(SLIDING_DOOR_OPEN);
			}
		}
		wait(slide_time + .1);
		if(DEBUG == true){IPrintLnBold("Door slid open");}
		touching = true;
		//if a player or an ai is found touching the trigger keep on waiting.
		while(isdefined(self) && touching == true)
		{
			touching = false;
			players = GetPlayers();
			for(i=0; i < players.size; i++)
			{
				if(players[i] IsTouching(self))
				{
					//a player was found touching trigger continue the loop
					touching = true;
				}
			}
			zombies = GetAiSpeciesArray("axis");
			for(k=0;k<zombies.size;k++)
			{
				if(zombies[k] IsTouching(self))
				{
					//an ai was found touching trigger continue the loop
					touching = true;
				}
			}
			wait(.05);
		}
		self notify("untouched");
		if(DEBUG == true){IPrintLnBold("trigger is untouched");}
		
		//allow door to close properly
		self waittill("ready_to_go_again");
		if(DEBUG == true){IPrintLnBold("Door is ready to slide again");}
	}
}
function slide_open_closed(trig,slide_time)
{
	org = self GetOrigin();
	//slide location
	target = struct::get(self.target,"targetname");
	//move self to target
	self MoveTo(target.origin,slide_time);
	wait(slide_time +.1);

	trig waittill("untouched");

	target = GetEntArray(trig.target,"targetname");
	for(i=0;i<target.size;i++)
	{
		if(target[i] == target[1])
		{
			target[i] PlaySound(SLIDING_DOOR_CLOSE);
		}
	}

	self MoveTo(org,slide_time);
	wait(slide_time +.15);
	trig notify("ready_to_go_again");
}
//////////////////////////////////
//  MONITOR POWER & LIGHTSTATES //
//////////////////////////////////
function autoexec monitor_power()
{
	level endon("end_game");


	//initial lightstate setup
	if(USE_LIGHT_STATES == true)
	{
		//if power on set lightstate to power on
		if(INITIAL_POWER_ON == true)
		{
			//i found if your using fx states then the lightstates need to be flicked off on to actualy hide the fx you want hidden
			level util::set_lighting_state(POWER_OFF_LIGHT_STATE);
			wait(2);
			level util::set_lighting_state(POWER_ON_LIGHT_STATE);
			if(DEBUG == true){IPrintLnBold("POWER_ON_LIGHT_STATE");}
		}
		//if power off set lightstate to power off
		else
		{
			//i found if your using fx states then the lightstates need to be flicked on off to actualy hide the fx you want hidden
			level util::set_lighting_state(POWER_ON_LIGHT_STATE);
			wait(2);
			level util::set_lighting_state(POWER_OFF_LIGHT_STATE);
			if(DEBUG == true){IPrintLnBold("POWER_OFF_LIGHT_STATE");}
		}
	}

	//wait for power to be turned on/off then update the lightstate if its not a doground (if it is doground then wait for it to end first.)
	while(1)
	{
		//if power is on wait for it to be turned off
		if(level flag::get("power_on"))
		{level flag::wait_till_clear("power_on");}
		
		//else if power is off wait for it to be turned on
		else
		{ level waittill( "power_on" );}

		wait(.05);

		//once power has changed check if its a dog round
		if(level flag::get("dog_round") && level.use_light_states == true)
		{
			//if its a dog round dog_lightstate function will handle the lights
		}
		//if power is on
		else if(level flag::get("power_on") && level.use_light_states == true)
		{
			level util::set_lighting_state(POWER_ON_LIGHT_STATE);
			if(DEBUG == true){IPrintLnBold("POWER_ON_LIGHT_STATE");}
		}
		//if power is off
		else if(level.use_light_states == true)
		{
			level util::set_lighting_state(POWER_OFF_LIGHT_STATE);
			if(DEBUG == true){IPrintLnBold("POWER_OFF_LIGHT_STATE");}
		}
		wait.05;
	}
}
function autoexec dog_light_state()
{
	level endon("end_game");

	level endon("end_game");
	while(1)
	{
		//waittill start of every round
		level waittill("start_of_round");
		//check if new round is a dog round
		if(level flag::get("dog_round") && level.use_light_states == true)
		{
			level util::set_lighting_state(DOG_ROUND_LIGHT_STATE);
			if(DEBUG == true){IPrintLnBold("DOGROUND_LIGHT_STATE");}
			level waittill("dog_round_ending");
			if(level flag::get("power_on") && level.use_light_states == true)
			{
				level util::set_lighting_state(POWER_ON_LIGHT_STATE);
				if(DEBUG == true){IPrintLnBold("POWER_ON_LIGHT_STATE");}
			}
			else if(level.use_light_states == true)
			{
				level util::set_lighting_state(POWER_OFF_LIGHT_STATE);
				if(DEBUG == true){IPrintLnBold("POWER_OFF_LIGHT_STATE");}
			}
		}
	}
}
////////////////
//  ELEVATOR  //
////////////////
//threads all elevators to function independently
function autoexec get_elevators()
{
	level waittill ("all_players_connected");
	
	elevator_door_move_time = 1;//the time it takes for doors to open/close
	if(isdefined(self.script_wait) && IsInt(self.script_wait)  && self.script_wait > 0){elevator_move_time = self.script_wait;}
	else{elevator_move_time = 3;}//the time it takes for elevator to move from floor to floor this is then * by the difference in how many floors it has to travel so A to B = elevator_move_time but A to C = elevator_move_time * 2 A-D = elevator_move_time * 4
	
	elevator = struct::get_array("elevator","targetname");
	foreach(ent in elevator)
	{
		ent thread elevator(elevator_door_move_time, elevator_move_time);
	}
}

//the individual elevator
function elevator(door_time,move_time)
{
	//get structs linked to self
	targets = struct::get_array(self.target, "targetname");
	for(i=0;i<targets.size;i++)
	{
		//get all the linked floor locations.
		if(targets[i].script_noteworthy == "floors")
		{
			floors = struct::get_array(targets[i].target,"targetname");
		}
		//get all the elevator models/brushes
		else if(targets[i].script_noteworthy == "models")
		{
			models = GetEntArray(targets[i].target,"targetname");
		}
		//get the elevator door brushes
		else if(targets[i].script_noteworthy == "doors")
		{
			elevator_doors = GetEntArray(targets[i].target,"targetname");
		}
	}
	
	if(DEBUG == true){IPrintLnBold("An elevator has ^6" + floors.size + " ^7floors.");}

	//get the starting floor to open its doors at beginning
	for(i=0;i<floors.size;i++)
	{
		if(floors[i].script_int == 0)
		{
			floor_doors_struct = floors[i];
		}
		floors[i] thread set_elevator_model_to_tag_origin();
	}

	//link elevator together
	self.link = Spawn("script_model", floor_doors_struct.origin);
	self.link SetModel("tag_origin");
	self.link EnableLinkTo();

	//get the elevator trigger
	for(i=0;i<models.size;i++)
	{
		models[i] EnableLinkTo();
		if(isdefined(models[i].script_noteworthy))
		{
			if(models[i].script_noteworthy == "elevator_pad")
			{
				trig_model = models[i];
				trig = GetEnt(models[i].target,"targetname");
				trig EnableLinkTo();
				trig LinkTo(self.link,"tag_origin");
			}
			if(models[i].script_noteworthy == "link_to_elevator")
			{
				link_to_elevator = models[i];
			}
			if(models[i].script_noteworthy == "elevator_hide")
			{
				elevator_hide = models[i];
				models[i] LinkTo(self.link,"tag_origin");
			}
			if(models[i].script_noteworthy == "elevator_floor")
			{
				elevator_floor = models[i];
				models[i] LinkTo(self.link,"tag_origin");
			}
			if(models[i].script_noteworthy == "elevator_model")
			{
				elevator_model = models[i];
				models[i] LinkTo(self.link,"tag_origin");
			}
		}
	}

	for(i=0;i<elevator_doors.size;i++)
	{
		elevator_doors[i] LinkTo(self.link,"tag_origin"); 
		elevator_doors[i] thread link_open_close(self);
	}

	//open elevator doors
	floor_doors = GetEntArray(floor_doors_struct.target,"targetname");
	foreach(ent in floor_doors){ent thread open_door(.05,self);}
	foreach(ent in elevator_doors){ent thread open_door(.05,self);}

	for(i=0;i<elevator_doors.size;i++)
	{
		if(isdefined(elevator_doors[i].target))
		{
			target = GetEnt(elevator_doors[i].target,"targetname");
			target SetModel("tag_origin");
			if(isdefined(target.target))
			{
				target2 = getent(target.target,"targetname");
				target2 SetModel("tag_origin"); 
			}
		}
	}
	for(i=0;i<floor_doors.size;i++)
	{
		if(isdefined(floor_doors[i].target))
		{
			target = GetEnt(floor_doors[i].target,"targetname");
			target SetModel("tag_origin");
			if(isdefined(target.target))
			{
				target2 = getent(target.target,"targetname");
				target2 SetModel("tag_origin"); 
			}
		}
	}
	
	done = 0;

	trig UseTriggerRequireLookAt();
	trig SetHintString(USE + "use elevator. Costs: [" + self.zombie_cost + "]");

	wait(.1);

	self.moving = false;

	foreach(struct in floors)
	{
		self thread call_elevator(struct,door_time,move_time,link_to_elevator,trig,elevator_model);
	}

	if(isdefined(self.script_sound))
	{
		wait(20);
		//play elevator music
		trig_model PlayLoopSound(self.script_sound);
		if(DEBUG == true){IPrintLnBold("elevator is playing^6 " + self.script_sound +"^7!"); IPrintLnBold("music");}
	}

	//elevator starts on the struct with script_int = 0
	self.current_floor = 0; 

	if(isdefined(self.zombie_cost))
	{cost = self.zombie_cost;}
	else{cost = 1000;}

	while(isdefined(self))
	{
		if(done <= floors.size + 1){ if(DEBUG == true) {if(DEBUG == true){IPrintLnBold("Elevator is moving to every floor!"); IPrintLnBold("done == ^6" + done + "^7 floors == ^6" + floors.size + "^7!");}}}
		else
		{
			self notify("elevator_setup");
			if(isdefined(self.script_waittill) && self.script_waittill != "" && !isdefined(self.is_active))
			{if(isdefined(self.script_hint)){trig SetHintString(self.script_hint);}else{trig SetHintString("^1Error^7: Elevator requires ^3"+self.script_waittill+"^7.");} level waittill(self.script_waittill);}
			self.is_active = true;
			self.moving = false;
			trig SetHintString(USE + "use elevator. Costs: [" + cost + "]");
			trig waittill("trigger",player);
			trig SetHintString(USE + "use elevator. Costs: [" + cost + "]");
			if(isdefined(player) && self.moving == false && player.score >= cost){player.score -= cost; player PlayLocalSound(PURCHASE_ACCEPT);}
			else if(isdefined(player) && player.score < cost){player PlayLocalSound(PURCHASE_DENY); wait(.1); continue;}
		}

		self.moving = true;

		//if the elevator has a floor to go to.
		if(floors.size > 1)
		{
			trig Hide();
			
			//playsounds
			if(done <= floors.size + 1){}
			else{elevator_model PlaySound(ELEVATOR_DOOR_CLOSE);}
			
			//close elevator doors
			self notify("close_doors");

			if(done > floors.size + 1){wait(door_time + .3);}
			if(DEBUG == true) {IPrintLnBold("doors closing!");}
			
			zombies = GetAiSpeciesArray("axis");
			for(k=0;k<zombies.size;k++)
			{
				if(isdefined(link_to_elevator) && zombies[k] IsTouching(link_to_elevator))
				{
					zombies[k] LinkTo(self.link,"tag_origin");
				}
			}

			//randomly pick which floor to go to
			while(isdefined(self))
			{
				//on startup elevator moves to every floor 1ce(this is needed to allow zombie pathing)
				if(done <= floors.size + 1){if(isdefined(floors[done])){rand = done;} else {rand = RandomInt(floors.size);}}
				
				//pick a random floor to go to
				else
				{rand = RandomInt(floors.size);}
				
				//if random int is not the current floor proceed (else pick another random number.)
				if(isdefined(floors[rand]) && (floors[rand].script_int != self.current_floor || done <= floors.size + 1))
				{
					if(DEBUG == true) {IPrintLnBold("Elevator is moving to floor ^6" + floors[rand].script_int + "^7! ");}

					//get the two script_int's of both floors 
					goto_floor = floors[rand].script_int;
					current_floor = self.current_floor;

					//get the difference in how many floors apart the 2 floors are
					max = Max(goto_floor, current_floor);
					min = Min(goto_floor, current_floor);

					//difference is * by move_time so it will take longer or shorter depending on how many floors apart the two points are
					difference = max - min;
					if(DEBUG == true) {IPrintLnBold("elevator move_time == ^6" + move_time * difference + "^7!");}

					//update the current floor the elevator is on (make sure each struct in elevator_floor has a unique script_int)
					self.current_floor = floors[rand].script_int; 
					
					//playsounds
					if(done <= floors.size + 1){}
					else
					{
						elevator_model PlaySound(ELEVATOR_SERVICE_CONTROL);
						elevator_model PlayLoopSound(ELEVATOR_MOVE_LOOP);
					}
					
					if(!isdefined(link_to_elevator) && DEBUG == true){IPrintLnBold("^1ERROR^7: There is no ^6elevator_link_to^7 trigger!!!");}

					//move elevator
					if(done <= floors.size + 1){self.link MoveTo(floors[rand].origin,.1);}
					else{self.link MoveTo(floors[rand].origin,move_time * difference);}

					//get the new floor door
					floor_doors_struct = floors[rand];

					//wait for elevator finish moving
					if(done <= floors.size + 1){wait(.2);}
					else
					{
						wait(move_time * difference - 2);
						elevator_model StopLoopSound(.5);
						elevator_model PlaySound(ELEVATOR_MOVE_STOP);
						wait(2.5);
					}

					zombies = GetAiSpeciesArray("axis");
					for(k=0;k<zombies.size;k++)
					{
						if(isdefined(link_to_elevator) && zombies[k] IsTouching(link_to_elevator))
						{
							zombies[k] Unlink();
						}
					}

					//playsounds
					if(done <= floors.size + 1){ done++; if(done > floors.size + 1){self.setup = true; elevator_hide Delete();}}
					else{elevator_model PlaySound(ELEVATOR_DOOR_OPEN);}

					//open elevator doors
					if(done <= floors.size + 1){
					floor_doors = GetEntArray(floor_doors_struct.target,"targetname");
					foreach(ent in floor_doors){ent thread open_door(.1,self);}
					foreach(ent in elevator_doors){ent thread open_door(.1,self);}
					}
					else{
					floor_doors = GetEntArray(floor_doors_struct.target,"targetname");
					foreach(ent in floor_doors){ent thread open_door(door_time,self);}
					foreach(ent in elevator_doors){ent thread open_door(door_time,self);}						
					}

					if(DEBUG == true) {IPrintLnBold("Opening Elevator Doors!");}

					if(done <= floors.size + 1){wait(.2);}
					else{wait(door_time + .5);}
					
					//break loop
					break;
				}
				else if(DEBUG == true){IPrintLnBold("picked the same floor re-picking!");}
				wait(.05);
				
			}
			trig show();
		}
		//if theres nowhere to go then theres a problem...
		else
		{
			if(DEBUG == true) {IPrintLnBold("^1ERROR^7: Elevator has nowhere to go!");}
			trig SetHintString("^1ERROR^7: This elevator has 1 or less floors to go to!");
			return;
		}
	}
}
function open_door(time,elevator)
{
	//get structs linked to self
	targets = struct::get_array(elevator.target, "targetname");
	for(i=0;i<targets.size;i++)
	{
		if(isdefined(targets[i].script_noteworthy))
		{
			if(targets[i].script_noteworthy == "models")
			{
				models = GetEntArray(targets[i].target,"targetname");
			}
		}
	}
	if(!isdefined(self.script_int)){return;}
	//
	//open door
	//
	//opening door hide middle piece
	if(isdefined(self.script_noteworthy))
	{
		if(self.script_noteworthy == "elevator_door"){self Unlink();}
	}
	for(i=0;i<models.size;i++)
	{
		models[i] ConnectPaths();
	}
	if(self.script_int == 0)
	{self Hide();}

	//open door
	if(self.script_int != 0)
	{
		target = GetEnt(self.target,"targetname");
		self MoveTo(target.origin, time); 
	}
	
	//waittill ready to close the opened doors
	elevator waittill("close_doors");

	//
	//close door
	//
	//move doors back to position
	if(self.script_int != 0)
	{
		target2 = getent(target.target,"targetname"); 
		self MoveTo(target2.origin, time);
	}

	//if self is middle piece
	else if(self.script_int == 0){wait(time); self Show(); self ConnectPaths();}
	
	//if self is not middle piece
	if(self.script_int != 0){wait(time); self ConnectPaths();}

	for(i=0;i<models.size;i++)
	{
		models[i] ConnectPaths();
	}
	if(isdefined(self.script_noteworthy))
	{if(self.script_noteworthy == "elevator_door"){self LinkTo(elevator.link, "tag_origin");}}
}

//link the open/close positions for the elevator doors to the elevator
function link_open_close(link)
{
	if(isdefined(self.target))
	{
		target = GetEnt(self.target,"targetname");
		target EnableLinkTo();
		target LinkTo(link.link, "tag_origin");
		if(isdefined(target.target))
		{
			target2 = GetEnt(target.target,"targetname");
			target2 EnableLinkTo();
			target2 LinkTo(link.link,"tag_origin");
		}
	}
}

//self == the main elevator struct
//struct == the unique floor per trigger
function call_elevator(struct,door_time,move_time,link_to_elevator,trigger,elevator_model)
{
	self waittill("elevator_setup");
	//target == elevator_call trigger & elevator floor doors
	target = GetEntarray(struct.target,"targetname");
	for(i=0;i<target.size;i++)
	{
		//get the trigger
		if(isdefined(target[i].script_noteworthy))
		{if(target[i].script_noteworthy == "trigger"){trig = target[i];}}
	}

	//get structs linked to self
	targets = struct::get_array(self.target, "targetname");
	for(i=0;i<targets.size;i++)
	{
		//get all the linked floor locations.
		if(isdefined(targets[i].script_noteworthy))
		{
			if(targets[i].script_noteworthy == "floors")
			{
				floors = struct::get_array(targets[i].target,"targetname");
			}
			//get all the elevator models/brushes
			else if(targets[i].script_noteworthy == "models")
			{
					models = GetEntArray(targets[i].target,"targetname");
			
			}
			//get the elevator door brushes
			else if(targets[i].script_noteworthy == "doors")
			{
				elevator_doors = GetEntArray(targets[i].target,"targetname");
			}
		}
	}
	trig UseTriggerRequireLookAt();
	trig SetHintString(USE + "call the elevator");
	
	while(isdefined(struct))
	{
		if(!isdefined(trig)){if(DEBUG == true){IPrintLnBold("Call Elevator Trigger ^1Undefined^7 on floor ^6" + struct.script_int + "^7!");} return;}
		trig Show();
		trig SetHintString(USE + "call the elevator");
		trig waittill("trigger",player);
		//(deny)
		if(!isdefined(self.is_active))
		{
			if(isdefined(self.script_hint)){trig SetHintString(self.script_hint);}else{trig SetHintString("^1Error^7: Elevator requires ^3"+self.script_waittill+"^7.");} 
			player PlayLocalSound(PURCHASE_DENY);
			wait(1);
			continue;
		}
		else if(self.moving == true)
		{
			player PlayLocalSound(PURCHASE_DENY);
			trig SetHintString("^1Error^7: Elevator is currently in motion, try again later.");
			wait(1);
			continue;
		}
		//if elevator is on the same floor as the one being called do nothing. (deny)
		else if(self.current_floor == struct.script_int)
		{
			trig SetHintString("^1Error^7: Elevator is already here."); 
			player PlayLocalSound(PURCHASE_DENY);
			wait(1);
			continue;
		}
		//if elevator is not moving and elevator is on a unique floor (accept)
		else if(self.moving == false && self.current_floor != struct.script_int)
		{
			trigger hide();
			//get the difference in how many floors apart the 2 floors are
			max = Max(self.current_floor, struct.script_int);
			min = Min(self.current_floor, struct.script_int);
			//difference is * by move_time
			difference = max - min;
			if(DEBUG == true) {IPrintLnBold("elevator move_time == ^6" + move_time * difference + "^7!");}
			//self notify("elevator_called");
			player PlayLocalSound(PURCHASE_ACCEPT);
			trig Hide();
			self.moving = true;
			self notify("close_doors");
			elevator_model PlaySound(ELEVATOR_DOOR_CLOSE);
			wait(door_time + .3);
			elevator_model PlaySound(ELEVATOR_SERVICE_CONTROL);
			elevator_model PlayLoopSound(ELEVATOR_MOVE_LOOP);
			zombies = GetAiSpeciesArray("axis");
			for(k=0;k<zombies.size;k++)
			{
				if(isdefined(link_to_elevator) && zombies[k] IsTouching(link_to_elevator))
				{
					zombies[k] LinkTo(self.link,"tag_origin");
				}
			}
			//move elevator and waittill complete
			self.link MoveTo(struct.origin, move_time * difference);
			
			wait(move_time * difference - 2);
			elevator_model StopLoopSound(.5);
			elevator_model PlaySound(ELEVATOR_MOVE_STOP);
			wait(2.5);
			elevator_model PlaySound(ELEVATOR_DOOR_OPEN);
			//open elevator doors
			floor_doors = GetEntArray(struct.target,"targetname");
			foreach(ent in floor_doors){ent thread open_door(door_time,self);}
			foreach(ent in elevator_doors){ent thread open_door(door_time,self);}
			wait(door_time + .5);
			self.moving = false;
			trig Show();
			trigger Show();
			//update the current floor the elevator is on
			self.current_floor = struct.script_int;
		}
		else
		{
			player PlayLocalSound(PURCHASE_DENY);
			wait(1);
		}
	}
}
//hide the bar stools
function set_elevator_model_to_tag_origin()
{
	targets = GetEntArray(self.target,"targetname");
	for(i=0;i<targets.size;i++)
	{
		if(isdefined(targets[i]))
		{
			if(isdefined(targets[i].target))
			{
				target = GetEnt(targets[i].target,"targetname");
				target SetModel("tag_origin");
				if(isdefined(target.target))
				{
					target = getent(target.target,"targetname");
					target SetModel("tag_origin");
				}
			}
		}
	}
}
/////////////////////
//	CODE EXAMPLES  //
/////////////////////
//to activate a zombie sacrifice defend event
function zombie_sacrifice_example()
{
	level endon("a_custom_notify_name_upon_winning");//this ends the loop
	level waittill("initial_blackscreen_passed");
	thread proceed_with_quest();
	while(1)
	{
		wait(5);
		level flag::set("custom_flag_name");//this starts the event
		wait(60);//duration of the event
		level flag::clear("custom_flag_name");//if zombies have not cleared the flag before us that means we won and the notify gets sent automaticly
	}
}
function proceed_with_quest()
{
	level waittill("a_custom_notify_name_upon_winning");//we can proceed with easter egg...
	//the next step of the quest
}
////////////////////////////////////////////////////////////
//to activate a zombie lockdown event
function lockdown_event_example()
{
	level waittill("initial_blackscreen_passed");
	
	//send it once to activate down (once its activated it wont lock the area/spawn zombies until a player is inside and the clips are also visible per player)
	level notify("make_a_unique_notify_name");
	
	level waittill("all_souls_complete");// waittill soul boxes are filled before ending the lockdown

	//send it twice to remove lockdown
	level notify("make_a_unique_notify_name");
}
////////////////////////////////////////////////////////////
//to infinite zombie spawning (no prefab)
function infinite_zombie_spawning_example()
{
	level waittill("initial_blackscreen_passed");
	while(1)
	{
		//toggles it on
		level notify("infinite_zombie_spawning");
		
		wait(60);

		//toggles it off
		level notify("infinite_zombie_spawning");
	}
}
