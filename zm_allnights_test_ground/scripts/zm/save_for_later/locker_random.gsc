#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\codescripts\struct;
#using scripts\shared\util_shared;

function autoexec main() {
    handleLockerTrig("locker_trig_1", "locker_door_1");
    handleLockerTrig("locker_trig_2", "locker_door_2");
    handleLockerTrig("locker_trig_3", "locker_door_3");
    handleLockerTrig("locker_trig_4", "locker_door_4");
    handleLockerTrig("locker_trig_5", "locker_door_5");
    handleLockerTrig("locker_trig_6", "locker_door_6");
    handleLockerTrig("locker_trig_7", "locker_door_7");
    handleLockerTrig("locker_trig_8", "locker_door_8");
    handleLockerTrig("locker_trig_9", "locker_door_9");
    handleLockerTrig("locker_trig_10", "locker_door_10");
}

function handleLockerTrig(trig_name, model_door) {
    trigs = GetEntArray(trig_name, "targetname");

    foreach(trig in trigs) {
        trig thread lockerThink(model_door);
    }
}

function lockerThink(model_door, locker_struct) {
    level endon("end_game");

    self SetCursorHint( "HINT_NOICON" );

    door = GetEnt(model_door, "targetname");
    //door_struct = SpawnStruct();
    //door_struct.origin = door.origin;
    //door_struct.angles = door.angles;
    //move_loc = struct::get(locker_struct,"targetname");
	
    for (;;) {
        self SetHintString("Hold ^3[{+activate}]^7 to open the locker");

        self waittill( "trigger", player );

        //door MoveTo(move_loc.origin, 2);
        door RotateYaw(180, 1.95);

        random_int = RandomIntRange(1, 5);

        switch (random_int) {
            case 1:
                level thread zm_powerups::specific_powerup_drop( "fuse", player.origin );
                break;
            case 2:
                player zm_score::add_to_player_score(500);
                zm_utility::play_sound_at_pos( "purchase", player.origin );
                break;
            case 3:
                random_int = RandomIntRange(1, 100);
                if (random_int == 73)
                    level thread zm_powerups::specific_powerup_drop( "free_perk", player.origin );
                else {
                    player zm_score::add_to_player_score(100);
                    zm_utility::play_sound_at_pos( "purchase", player.origin );
                }
                break;
            case 4:
                random_int = RandomIntRange(1, 100);
                if (random_int >= 84) {
                    random_int = RandomIntRange(1, 7);
                    switch (random_int) {
                        case 1:
                            level thread zm_powerups::specific_powerup_drop( "carpenter", player.origin );
                            break;
                        case 2:
                            level thread zm_powerups::specific_powerup_drop( "fire_sale", player.origin );
                            break;
                        case 3:
                            level thread zm_powerups::specific_powerup_drop( "full_ammo", player.origin );
                            break;
                        case 4:
                            level thread zm_powerups::specific_powerup_drop( "insta_kill", player.origin );
                            break;
                        case 5:
                            level thread zm_powerups::specific_powerup_drop( "nuke", player.origin );
                            break;
                        case 6:
                            level thread zm_powerups::specific_powerup_drop( "double_points", player.origin );
                            break;
                        default:
                            level thread zm_powerups::specific_powerup_drop( "weapon_minigun", player.origin );
                            break;
                    }
                }
                else {
                    player zm_score::add_to_player_score(200);
                    zm_utility::play_sound_at_pos( "purchase", player.origin );
                }
                break;
            default:
                player zm_score::add_to_player_score(50);
                zm_utility::play_sound_at_pos( "purchase", player.origin );
        }

        self SetHintString("Come back another time.");

        level waittill( "end_of_round" );

        random_int = RandomIntRange(1, 3);

        switch (random_int) {
            case 2:
                wait 10;
                level waittill( "end_of_round" );
                break;
            case 3:
                wait 10;
                level waittill( "end_of_round" );

                wait 10;
                level waittill( "end_of_round" );
                break;
        }

        //door MoveTo(door_struct.origin, 2);
        door RotateYaw(-180, 1.95);

        wait 0.5;
    }
}