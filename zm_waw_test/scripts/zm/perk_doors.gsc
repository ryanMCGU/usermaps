#using scripts\zm\_zm_score;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_utility;

function autoexec main() {
    level.array_of_perk_doors = [];
    level.array_of_perk_doors[0] = "perk_door_1";
    level.array_of_perk_doors[1] = "perk_door_2";
    level.array_of_perk_doors[2] = "perk_door_3";
    level.array_of_perk_doors[3] = "perk_door_4";
    level.array_of_perk_doors[4] = "perk_door_5";
    level.array_of_perk_doors[5] = "perk_door_6";
    level.array_of_perk_doors[6] = "perk_door_7";
    level.array_of_perk_doors[7] = "perk_door_8";

    handleFuse("fuse_trig_1", "fuse_model_1");

    handleDoor("perk_door_1", "perk_door_1_clip", "perk_door_1_right", "perk_door_1_left");
    handleDoor("perk_door_2", "perk_door_2_clip", "perk_door_2_right", "perk_door_2_left");
    handleDoor("perk_door_3", "perk_door_3_clip", "perk_door_3_right", "perk_door_3_left");
    handleDoor("perk_door_4", "perk_door_4_clip", "perk_door_4_right", "perk_door_4_left");
    handleDoor("perk_door_5", "perk_door_5_clip", "perk_door_5_right", "perk_door_5_left");
    handleDoor("perk_door_6", "perk_door_6_clip", "perk_door_6_right", "perk_door_6_left");
    handleDoor("perk_door_7", "perk_door_7_clip", "perk_door_7_right", "perk_door_7_left");
    handleDoor("perk_door_8", "perk_door_8_clip", "perk_door_8_right", "perk_door_8_left");

    handleVending();
}

function handleVending() {
    trigs = GetEntArray("fuse_vending_trig", "targetname");

    foreach(trig in trigs) {
        trig thread handleFuseVendingTrig();
    }
}

function handleFuseVendingTrig() {
    level endon("end_game");

    self SetCursorHint( "HINT_NOICON" );
	self SetHintString("Hold ^3[{+activate}]^7 to gain a perk slot. Cost ^8 1 ^7 fuse. You have ^3" + level.fuses_obtained + "^7 fuses.");

    for (;;) {
        self waittill( "trigger", player );

        if (level.perk_purchase_limit != 10) {
            if (level.fuses_obtained > 0) {
                level.fuses_obtained--;
                updateDoorHintString();
                
                level.perk_purchase_limit++;
                zm_utility::play_sound_at_pos( "purchase", player.origin );

                if (level.perk_purchase_limit == 10) {
                    self SetHintString("Hold ^3[{+activate}]^7 for ^8 1500 ^7 points. Cost ^8 1 ^7 fuse. You have ^3" + level.fuses_obtained + "^7 fuses.");
                }
            }
            else {
                self PlaySound("evt_perk_deny");
                player zm_audio::create_and_play_dialog( "general", "sigh" );
            }  
        }
        else {
            if (level.fuses_obtained > 0) {
                level.fuses_obtained--;
                updateDoorHintString();
                zm_utility::play_sound_at_pos( "purchase", player.origin );
                player zm_score::add_to_player_score(1500);
            }
            else {
                self PlaySound("evt_perk_deny");
                player zm_audio::create_and_play_dialog( "general", "sigh" );
            }  
        }

        wait 0.5;
    }
}

function handleFuse(fuse_trig, fuse_model) {
    level.fuses_obtained = 0;

    trigs = GetEntArray(fuse_trig, "targetname");

    foreach(trig in trigs) {
        trig thread handleFuseTrig(fuse_model);
    }
}

function handleFuseTrig(fuse_model) {
    level endon("end_game");

    self SetCursorHint( "HINT_NOICON" );
	self SetHintString("");

    self waittill( "trigger", player );

    level.fuses_obtained++;

    updateDoorHintString();

    self Delete();

    fuses = GetEntArray(fuse_model, "targetname");

    foreach(fuse in fuses) {
        fuse Delete();
    }
}

function updateDoorHintString() {
    foreach( trigName in level.array_of_perk_doors) {
        trigs = GetEntArray(trigName, "targetname");

        foreach(trig in trigs) {
            trig SetHintString("Door costs ^3 1 ^7 fuse. You have ^3" + level.fuses_obtained + "^7 fuses.");
        }
    }

    trigs = GetEntArray("fuse_vending_trig", "targetname");

    foreach(trig in trigs) {
        if (level.perk_purchase_limit >= 10)
            trig SetHintString("Hold ^3[{+activate}]^7 for ^8 1500 ^7 points. Cost ^8 1 ^7 fuse. You have ^3" + level.fuses_obtained + "^7 fuses.");
        else
            trig SetHintString("Hold ^3[{+activate}]^7 to gain a perk slot. Cost ^8 1 ^7 fuse. You have ^3" + level.fuses_obtained + "^7 fuses.");
    }

    if(level.round_number >= 20) {
        trigs = GetEntArray("pap_box_trig", "targetname");

        foreach(trig in trigs) {
            trig SetHintString("Hold ^3[{+activate}]^7 to gain a random Packed Weapon. Cost ^8 1 ^7 fuse. You have ^3" + level.fuses_obtained + "^7 fuses.");
        }
    }
}

function handleDoor(triggerName, clip, door1, door2) {
    trigs = GetEntArray(triggerName, "targetname");

    foreach(trig in trigs) {
        trig thread handleDoorTrig(clip, door1, door2);
    }
}

function handleDoorTrig(clip, door1, door2) {
    level endon("end_game");

    self SetCursorHint( "HINT_NOICON" );
	self SetHintString("Door costs ^3 1 ^7 fuse. You have ^3" + level.fuses_obtained + "^7 fuses.");

    for (;;) {
        self waittill( "trigger", player );

        if (level.fuses_obtained > 0) {
            level.fuses_obtained--;
            updateDoorHintString();
            break;
        }
        
        wait 0.5;
    }

    self Delete();

    clips = GetEntArray(clip, "targetname");
    foreach(clip in clips) {
       clip Delete();
    }

    models = GetEntArray(door1, "targetname");
    
    foreach(model in models) {
        if (door1 == "perk_door_2_right" || door1 == "perk_door_4_right" || door1 == "perk_door_8_right")
            model MoveX(106, 1.5);
        else
            model MoveY(106, 1.5);
        playsoundatposition("madhouse_door_open", model.origin);
    }

    models = GetEntArray(door2, "targetname");
    
    foreach(model in models) {
        if (door2 == "perk_door_2_left" || door2 == "perk_door_4_left" || door2 == "perk_door_8_left")
            model MoveX(-106, 1.5);
        else
            model MoveY(-106, 1.5);
        playsoundatposition("madhouse_door_open", model.origin);
    }
}