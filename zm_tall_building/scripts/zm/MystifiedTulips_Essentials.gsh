//START WEAPON 
#define START_WEAPON							array( "pistol_m1911", "pistol_c96", "pistol_revolver38" )	

//PER PLAYER START WEAPON
#define USING_PER_PLAYER_START_WEAPON			false //if false players will be given START_WEAPON. if true players will be assigned a unique gun tied to their character
#define DEMPSEY 								array("pistol_m1911", "pistol_revolver38")
#define NIKOLAI									array("pistol_revolver38", "pistol_c96")
#define RICHTOFEN								array("pistol_c96", "pistol_revolver38")
#define TAKEO 									array("pistol_m1911", "pistol_c96")
#define FLOYD 									array("launcher_multi", "launcher_multi")
#define JACK									array("lmg_cqb", "lmg_cqb")
#define JESSICA									array("shotgun_pump", "shotgun_pump")
#define NERO									array("pistol_revolver38", "pistol_revolver38")
#define BEAST									array("ray_gun", "ray_gun")								

#define DEATHMACHINE                            array("thundergun","tesla_gun")
//LASTSTAND WEAPON (if keep weapons after death or disable_gameover_screen = true then these laststand weapon values are NOT used)
#define SOLO_LASTSTAND_WEAPON 					array("ray_gun","ray_gun")
#define LASTSTAND_WEAPON						array("pistol_c96_upgraded","pistol_c96_upgraded")

//ADD WEAPONS TO MYSTERY BOX MID GAME //specifiy the gun to add to box mid game do level notify("the_weapons_name"); to add the individual guns back to box you do not need to set IN_BOX to false for the guns but ya can if ya want...
#define LIST_OF_WEAPONS_TO_ADD_TO_BOX_LATER     array("", "", "")

//DEVELOPERS: specified gamertags will recieve cheat hotkeys - player.developer = true & level.developer = true;
#define DEVELOPER_NAMES							array("MystifiedTulip","Jason_Blundell")
//SPECIAL PEOPLE: gamertags will have a player variable of player.special = true; & level.special = true; (INSTRUCTIONS: to use do " if(player.special == true){something unique for the player...} " 
#define SPECIAL_PERSONS							array("MystifiedTulip","NoahJ456","MrTlexify","MrDalekJD","CodeNamePizza","Kunjora","M9Vendetta")

//NUMBER STATEMENTS
#define STARTING_POINTS							500000                                         //DEFAULT: 500
#define	PERK_PURCHASE_LIMIT						99                                          //DEFAULT: 99
#define PACKAPUNCH_CAMO							75                                          //DEFAULT: 75
#define PACKAPUNCH_CAMO_VARIANTS				5                                           //DEFAULT: 5
#define BLEEDOUT_TIME							25                                          //DEFAULT: 25
#define PLAYER_HEALTH							100                                         //DEFAULT: 100

//WEATHER CONTROL (may require the default fx pack to be installed) if using place a "setup_weather" prefab in map, stamp it and adjust accordingly (YOU NEED TO COMPILE LIGHTS OR WEATHER WILL APPEAR WHEN INSIDE BUILDINGS)
#define WEATHER                                 false                                       //OPTIONS: "rain" "snow" false
#define RAIN_FX                                 "custom/env/fx_rain_player_z_heavy"         //DEFAULT: "custom/env/fx_rain_player_z_heavy"
#define SNOW_FX                                 "weather/fx_snow_player_loop"               //DEFAULT: "weather/fx_snow_player_loop"  
#define LIGHTNING                               false                                       //if true place a "lightning_strikes" prefab and stamp it. Then copy and paste the fx you want where lightning will strike)
#define LIGHTNING_STRIKE_SOUND                  "lightning_strike"                          //DEFAULT: "lightning_strike"
#define LIGHTNING_DELAY_MAX                     60                                          //max delay between strikes
#define LIGHTNING_DELAY_MIN                     20                                          //min delay between strikes
//tip add kvp script_sound | "rain" to any player_volume to play certain rain sounds in certain areas     

//LIGHT STATES
#define USE_LIGHT_STATES						true                                        //true and lightstates are automatically changed upon power on/off & dog rounds
#define POWER_OFF_LIGHT_STATE 					0	                                        //value between 0-3
#define POWER_ON_LIGHT_STATE					1	                                        //value between 0-3
#define DOG_ROUND_LIGHT_STATE				 	0	                                        //value between 0-3

//GAME OVER TEXT (to show win text do level.wongame = true;)
#define WIN_TEXT								"         ^8Thanks for Playing^7. ^3You Won^7! \n^2If you enjoyed ^6like ^2and ^6favourite ^2the map^7."
#define LOSE_TEXT								"^1Bad Luck^8."
#define END_GAME_PREFIX							""
//GAMEOVER SOUNDS (to play win sound on gameover do level.wongame = true;)
#define GAMEOVER_LOSE							"gameover_lose"                             //DEFAULT: "gameover_lose"
#define GAMEOVER_WIN							"gameover_win"                              //DEFAULT: "gameover_win"

//INTRO TEXT
#define INTRO_TEXT                              false                                       //OPTIONS: "type_writer" "print" false
#define INTRO_TEXT_LINE1                        "^9Date^7: ^5April 17, 1961"                //enter any text
#define INTRO_TEXT_LINE2                        "^9Location^7: ^5South West - Germany"      //enter any text
#define INTRO_TEXT_LINE3                        "^9Mission Objective^7: ^5Survive"          //enter any text

//QUICK TRUE/FALSE STATEMENTS
#define DEBUG									true                                        //true to enable iprintlnbold statements
#define INITIAL_POWER_ON 						false                                        //true to enable power
#define DOG_ROUNDS_ALLOWED						true                                       //true to enable dog rounds
#define RANDOMISE_PERK_MACHINES                 false                                       //if true add script_notify = random_perk_machine to perk prefab then place script_structs in radiant on the script_struct target_name add perk_random_machine_location and perks will spawn randomly on the script_structs make sure you have the same amount of structs placed as perk machines with the kvp
#define INTRO_FLY_IN							false                                       //true to enable a fly in transition on spawn
#define OUTRO_DEATH_SCENE                       false                                       //true to play the outro scene
#define END_GAME_CAMERA_PAN                     false                                       //true to enable camera pan for end screen (REQUIRES "panning_end_game_camera" PREFAB TO BE PLACED AND ORIGIONAL INTERMISSION STRUCTS TO BE DELETED)
#define TIMED_GAMEPLAY							false                                       //true to enable timed gameplay
#define HOLD_BREATH_UNDERWATER                  true                                       //true and player can hold breath underwater forever
#define KEEP_WEAPONS_AFTER_DEATH				false                                       //true and players will keeep their guns upon respawning
#define KEEP_PERKS_AFTER_DOWNING				false                                       //true and players will keep their perks after laststand & bleedout
#define ZOMBIE_HITMARKERS						false                                       //true and zombies will playhitmarkers when shot 
#define DISABLE_GAMEOVER_SCREEN					false                                       //true and when everyone dies they will respawn with their points/guns/ammo from their last completed round 
#define ENABLE_MYSTERYBOX_AT_EVERY_LOCATION		false                                       //true and mystery box will be enabled everywhere (you should remove the firesale icon if from map if true)
#define RANDOM_MYSTERY_BOX_START				false                                       //true and mysterybox will spawn at a random spot rather than its start_location
#define DISABLE_POWER_UPS_IN_CERTAIN_AREAS		true                                        //true and zombies wont drop powerups in volumes with targetname of "no_powerups" 
#define CAN_PLAYERS_REVIVE						undefined                                   //false and players cant revive each other, undefined and they can
#define ENABLE_MAGIC							true                                        //true and mysterybox is enabled false and its disabled
#define HEADSHOTS_ONLY							false                                       //true and zombies can only be killed by headshots
#define DISABLE_POWERUPS						false                                       //true and zombies will never drop powerups
#define FRIENDLY_FIRE							false                                        //true and players can damage other players damage = weapon_damage / 20
#define ZOMBIE_MISSING_HEAD						false                                       //true and some zombies will be missing a head
#define ZOMBIE_MISSING_LEGS						false                                       //true and some zombies will be missing legs
#define ZOMBIE_SPRINTERS						false                                       //true and zombies will be sprinting immediatly
#define DISABLE_ZOMBIE_COLLISION			    true                                        //true and zombies wont collide with other zombies 
#define SPECTATORS_RESPAWN_END_OF_ROUND         true                                        //true and players respawn after round end 
#define SPECIFIC_ZOMBIE_MODELS_PER_RISER_LOC	false                                       //true and you can control what zombie models spawn at each riser location uses (to setup will need to give all player_volumes, zombie spawners and riser locations the same script_int kvp value. When entering a different player_volume you can give it a another script_int and all riser locations linked to that kvp will spawn if theres a spawner with the same kvp. checkout " zm_scripting " prefab in mystifiedtulip\essentials\zm_scripting.map where i have that setup with zones spawners and riser structs

//GENERIC SOUNDS
#define UNDERWATER_LOOP_SOUND					"underwater"								//DEFAULT: "underwater"
#define SLIDING_DOOR_OPEN						"sliding_door_open"							//DEFAULT: "sliding_door_open"	
#define SLIDING_DOOR_CLOSE						"sliding_door_close"						//DEFAULT: "sliding_door_close"
#define ELEVATOR_DOOR_CLOSE						"elevator_door_close"						//DEFAULT: "elevator_door_close"	
#define ELEVATOR_DOOR_OPEN						"elevator_door_open"						//DEFAULT: "elevator_door_open"
#define ELEVATOR_MOVE_LOOP						"elevator_move"								//DEFAULT: "elevator_move"	
#define ELEVATOR_MOVE_STOP						"elevator_move_end"							//DEFAULT: "elevator_move_end"	
#define ELEVATOR_SERVICE_CONTROL				"elevator_service_control"					//DEFAULT: "elevator_service_control"
#define BUYABLE_ENDING_LOOP_SOUND				"radio_amb"									//DEFAULT: "radio_amb"	
#define REVOLVING_DOOR_LOOP_SOUND				"revolving_door"							//DEFAULT: "revolving_door"
#define PICKUP									"pickup"									//DEFAULT: "pickup"
#define PURCHASE_ACCEPT							"accept"									//DEFAULT: "accept"	
#define PURCHASE_DENY							"deny"										//DEFAULT: "deny"	
#define RADIO_WITHDRAW							"radio_hit"									//DEFAULT: "radio_hit"	
#define FLY_IN_SOUND							"transition"								//DEFAULT: "transition"
#define ZOMBIE_SPAWN							"zom_spawn"									//DEFAULT: "zom_spawn"
#define FAST_TRAVEL_AND_BEAST_MODE_SOUND        "fast_travel_use_sound"                     //DEFAULT: "fast_travel_use_sound"

//PLAYER LASTSTAND SOUND
#define PLAYER_DOWNED_SOUND                     "zc_player_down"                            //OPTIONS: "zc_player_down" "classic_player_down" "cw_player_down"
#define PLAYER_REVIVED_SOUND                    "zc_player_revive"                          //OPTIONS: "zc_player_revive" "classic_player_revive" "cw_player_revive"
#define BLEEDOUT_LOOP_SOUND                     "zc_laststand_loop"                         //OPTIONS: "zc_laststand_loop" "classic_laststand_loop" "cw_laststand_loop"
#define PLAYER_NEAR_DEATH_SOUND                 "bo2_player_near_death"                     //DEFAULT: "bo2_player_near_death" "zc_player_near_death"
#define PLAYER_DEATH_SOUND                      "bo2_player_death_endgame"                  //DEFAULT: "bo2_player_death_endgame"

//SOULBOX 
#define SOULBOX_TRAIL_FX                        "dlc5/zmb_weapon/fx_staff_fire_trail_bolt"
#define SOULBOX_IDLE_FX                         "dlc3/stalingrad/fx_main_anomoly_loop_trail_talk"
#define SOULBOX_ENTER_FX                        "zombie/fx_powerup_grab_green_zmb"

//MUSIC EASTER EGG
#define EASTER_EGG_SONG_TRIGGER_CONFIRMATION    "meteor_affirm"                             //DEFAULT: "meteor_affirm"
#define EASTER_EGG_SONG_TRIGGER_LOOP            "meteor_loop"                               //DEFAULT: "meteor_loop"
#define EASTER_EGG_SONG                         "transition"                                //DEFAULT: (you need to create the song file yourself)
#define EASTER_EGG_SONG_TRIGGER_FX              "zombie/fx_powerup_grab_green_zmb"          //DEFAULT: "zombie/fx_powerup_grab_green_zmb"

//PERK BOTTLE EASTER EGG
#define PERK_BOTTLE_SHOT_SOUND                  "shot_bottle"                               //DEFAULT: "shot_bottle"
#define PERK_BOTTLE_FX                          "lensflares/fx_lensflare_sniper_glint"      //DEFAULT: "lensflares/fx_lensflare_sniper_glint"
//PERK_BOTTLE_REWARD OPTIONS: free_perk | perkaholic | free_perk_and_slot | weapon_upgrade | 2500 (any number of points)
#define PERK_BOTTLE_REWARD                      array("perkaholic", "weapon_upgrade")

//HITMARKER SHADERS 
#define ZOMBIE_HITMARKER                        "zombie_hitmarker"                          //DEFAULT: "zombie_hitmarker"   
#define ZOMBIE_KILL                             "zombie_hitmarker_death"                    //DEFAULT: "zombie_hitmarker_death"  
#define ZOMBIE_HITMARKER_HEADSHOT               "zombie_hitmarker_headshot"                 //DEFAULT: "zombie_hitmarker_headshot"
#define GENERIC_HITMARKER                       "damage_feedback"                           //DEFAULT: "damage_feedback"         
#define FRIENDLY_FIRE_HITMARKER                 "friendly_fire_hitmarker"                   //DEFAULT: "friendly_fire_hitmarker" 
//HITMARKER SOUNDS
#define ZOMBIE_HITMARKER_SOUND                  "hitmarker_zombie"                          //DEFAULT: "hitmarker_zombie" 
#define ZOMBIE_KILL_HEADSHOT_SOUND              "hitmarker_headshot_kill"                   //DEFAULT: "hitmarker_headshot"
#define ZOMBIE_HEADSHOT_SOUND                   "hitmarker_headshot"                        //DEFAULT: "hitmarker_headshot"
#define GENERIC_HITMARKER_SOUND                 "hitmarker"                                 //DEFAULT: "hitmarker" 

//AI STATS
#define ZOMBIE_START_HEALTH                     150                                         //DEFAULT: 150      starting health of a zombie at round 1
#define ZOMBIE_HEALTH_INCREASE                  100                                         //DEFAULT: 100      cumulatively add this to the zombies' starting health each round (up to round 10)
#define ZOMBIE_HEALTH_MULTIPLIER                .1                                          //DEFAULT: .1       after round 10 multiply the zombies' starting health by this amount
#define ZOMBIE_SPAWN_DELAY                      2                                           //DEFAULT: 2        Time to wait between spawning zombies.  This is modified based on the round number.
#define ZOMBIE_MOVE_SPEED_MULTIPLIER            4                                           //DEFAULT: 4        Multiply by the round number to give the base speed value.  0-40 = walk, 41-70 = run, 71+ = sprint
#define ZOMBIE_MAX_AI                           24                                          //DEFAULT: 24       Base number of zombies per player (modified by round #)
#define BETWEEN_ROUND_WAIT                      10                                          //DEFAULT: 10       How long to pause after the round ends                                               
#define ZOMBIE_SCORE_DAMAGE                     10                                          //DEFAULT: 10       points gained for a hit with a weapon
#define ZOMBIE_KILL_SCORE                       50                                          //DEFAULT: 50       Individual Points for a zombie kill in a 4 player game
#define ZOMBIE_SCORE_MELEE                      80                                          //DEFAULT: 80       Bonus points for a melee kill                               
#define ZOMBIE_SCORE_HEAD                       50                                          //DEFAULT: 50       Bonus points for a head shot kill
#define ZOMBIE_SCORE_NECK                       20                                          //DEFAULT: 20       Bonus points for a neck shot kill
#define ZOMBIE_SCORE_TORSO                      10                                          //DEFAULT: 10       Bonus points for a torso shot kill

//UNDERWATER (may require the default fx pack to be installed)
#define UNDERWATER_BLUR_AMOUNT					.5											//DEFAULT: .5
#define UNDERWATER_FX_1							"water/fx_water_floating_debris_biodomes" 	//DEFAULT: "water/fx_water_floating_debris_biodomes"		(requires fx pack)
#define UNDERWATER_FX_2							"dlc2/island/fx_plyr_swim_bubbles_body_isl"	//DEFAULT: "dlc2/island/fx_plyr_swim_bubbles_body_isl"		(requires fx pack)

//BEASTMODE 
#define BEASTMODE_FX                            "zombie/fx_bgb_anywhere_but_here_teleport_zmb" //DEFAULT: "zombie/fx_bgb_anywhere_but_here_teleport_zmb"
#define BEASTMODE_TIME                          20                                          //DEFAULT: 20
//HINT TEXT
#define USE                                     "Hold ^3[{+activate}] ^7to "
#define JUMP                                    "Hold ^3[{+gostand}] ^7to "
#define ACTIONSLOT1                             "Hold ^3[{+actionslot 1}] ^7to "
#define ACTIONSLOT2                             "Hold ^3[{+actionslot 2}] ^7to "
#define ACTIONSLOT3                             "Hold ^3[{+actionslot 3}] ^7to "
#define ACTIONSLOT4                             "Hold ^3[{+actionslot 4}] ^7to "
#define BUYABLE_ENDING_NOT_READY_TEXT           "Currently Unavalible."

//ZOMBIE SPAWN FX
#define ZOMBIE_SPAWN_FX 						"dlc1/castle/fx_demon_gate_portal_open"		//DEFAULT: "dlc1/castle/fx_demon_gate_portal_open"		(requires fx pack)

//NOTIFY
#define INFINITE_ZOMBIE_SPAWNING_NOTIFY         "infinite_zombie_spawning"                  //send this notify to toggle infinite spawning on and off

//HUD OVERLAY IMAGE
#define HUD_OVERLAY       						"cinermatic_mask" 							//change to a different 2d image if you want (youll need to update the zone file too if you do.) 

//GLOBAL SOUND NAME (play a 2d sound at anytime with level.GLOBAL_SOUND_NAME playsound ("a_sound");
#define LEVEL									level.playasound 							//the name of an invisible model you can call at anytime to play a 2d sound //LEVEL playsound("my_sound");

//KNUCKLE CRACK WEAPON
#define PAP_WEAPON_KNUCKLE_CRACK		        "zombie_knuckle_crack"

//firesale (used for mysterybox enable at every location)
#define FIRE_SALE_ON							"zombie_powerup_fire_sale_on"