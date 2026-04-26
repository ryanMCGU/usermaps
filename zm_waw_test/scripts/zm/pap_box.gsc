#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\perk_doors;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_utility;
#using scripts\shared\scene_shared;
#using scripts\codescripts\struct;
#using scripts\shared\util_shared;
#using scripts\shared\array_shared;

#using_animtree("generic"); 

#precache( "fx", "dlc5/tomb/fx_tomb_magicbox_amb" );
#precache( "fx", "dlc5/tomb/fx_tomb_magicbox_amb_base");
#precache( "fx", "dlc5/tomb/fx_tomb_magicbox_open");

function autoexec main() {
    handleInitBox();
}

function handleInitBox() {
    trig = GetEnt("pap_box_trig", "targetname");
    pickup_trig = GetEnt("pap_box_pickup_trig", "targetname");
    pickup_trig Hide();
    trig thread handlePapBoxTrig(pickup_trig);
}

function handlePapBoxTrig(pickup_trig) {
    level endon("end_game");

    pap_box = GetEnt("pap_box_BOX", "targetname");
    top_struct = struct::get("pap_box_fx_top", "targetname");
    base_struct = struct::get("pap_box_fx_base", "targetname");
    bottom_struct = struct::get("pap_box_fx_bottom", "targetname");
    weapon_struct = struct::get("pap_box_weapon_model", "targetname");
    weapon_top = struct::get("pap_box_weapon_model_top", "targetname");

    self SetCursorHint( "HINT_NOICON" );
	self SetHintString("Locked till round ^3 20 ^7...");

    //locks pap box till round 20
    for(;;) {
        level waittill("start_of_round");

        if(level.round_number >= 20) {
            break;
        }
    }

    for(;;) {
        self SetHintString("Hold ^3[{+activate}]^7 to gain a random Packed Weapon. Cost ^8 1 ^7 fuse. You have ^3" + level.fuses_obtained + "^7 fuses.");

        self waittill( "trigger", player );
        
        if (level.fuses_obtained >= 1) {
            level.fuses_obtained = level.fuses_obtained - 1;
            perk_doors::updateDoorHintString();
            self Hide();

            top_fx = util::spawn_model("tag_origin", top_struct.origin, top_struct.angles);
            base_fx = util::spawn_model("tag_origin", base_struct.origin, base_struct.angles);
            bottom_fx = util::spawn_model("tag_origin", bottom_struct.origin, bottom_struct.angles);

            top_fx PlaySound("pap_box_music");

            top_fx_play = PlayFXOnTag("dlc5/tomb/fx_tomb_magicbox_amb", top_fx, "tag_origin", true);
            base_fx_play = PlayFXOnTag("dlc5/tomb/fx_tomb_magicbox_amb_base", base_fx, "tag_origin", true);
            bottom_fx_play = PlayFXOnTag("dlc5/tomb/fx_tomb_magicbox_open", bottom_fx, "tag_origin", true);

            pap_box scene::play("pap_box_anims", pap_box);
            weapon = zm_magicbox::treasure_chest_ChooseWeightedRandomWeapon( player );

            weapon_model = util::spawn_model("tag_origin", weapon_struct.origin, weapon_struct.angles);
            weapon_model MoveTo(weapon_top.origin, 1.5);

            keys = array::randomize( GetArrayKeys( level.zombie_weapons ) );
                for(i = 0; i < keys.size/2; i++) {
                    if( self zm_weapons::can_upgrade_weapon( keys[i] ) ) {
			            upgraded_weapon = zm_weapons::get_upgrade_weapon( keys[i] );
                        weapon_model SetModel(upgraded_weapon.worldmodel);
		            }
                    else {
                        weapon_model SetModel(keys[i].worldmodel);
                    }
                    
                    wait 0.2;
                }

            upgraded_weapon = zm_weapons::get_upgrade_weapon(weapon);
            weapon_model SetModel(upgraded_weapon.worldmodel);
            weapon_model MoveTo(weapon_struct.origin, 11);

            pickup_trig thread handlePickUpTrig(weapon, weapon_model);
            thread pickupCountDown(pickup_trig);
            level waittill("pap_box_weapon_pickedup");
            level notify("kill_pap_box_weapon_pickedup");
            
            if (isdefined(top_fx_play))
                top_fx_play Delete();

            if (isdefined(base_fx_play))
                base_fx_play Delete();

            if (isdefined(bottom_fx_play))
                bottom_fx_play Delete();

            if (isdefined(top_fx))
                top_fx Delete();
        
            if (isdefined(bottom_fx))
                bottom_fx Delete();

            if (isdefined(base_fx))
                base_fx Delete();

            pap_box scene::stop("pap_box_anims", pap_box);
            pap_box scene::play("pap_box_anims_close", pap_box);
            wait 0.3;
            pap_box scene::stop("pap_box_anims_close", pap_box);
            if (isdefined(weapon_model))
                weapon_model Delete();
            self Show();
	    }
        else {
            self PlaySound("evt_perk_deny");
            player zm_audio::create_and_play_dialog( "general", "sigh" );
        }
    }
}

function pickupCountDown(trig) {
    level endon("end_game");
    level endon("kill_pap_box_weapon_pickedup");

    wait 11;
    trig Hide();

    level notify("pap_box_weapon_pickedup");
}

function handlePickUpTrig(weapon, weapon_model){
    level endon("end_game");
    level endon("kill_pap_box_weapon_pickedup");

    self SetCursorHint( "HINT_NOICON" );
	self SetHintString("Hold ^3[{+activate}]^7 pick up weapon.");

    self Show();

    for (;;) {
        self waittill( "trigger", player );

        if (player zm_magicbox::can_buy_weapon() && (player GetCurrentWeapon() != GetWeapon("bo1_bouncingbetty"))) {
            weapon_limit = zm_utility::get_player_weapon_limit( player );
            guns = player GetWeaponsListPrimaries();
            if (guns.size == weapon_limit) {
                remove_weapon = player GetCurrentWeapon();
                player TakeWeapon(remove_weapon);
            }

            if( self zm_weapons::can_upgrade_weapon( weapon ) ) {
			    weapon = zm_weapons::get_upgrade_weapon( weapon );
		    }
            player GiveWeapon(weapon);
            player SwitchToWeaponImmediate(weapon);

            self Hide();
            weapon_model Delete();
            level notify("pap_box_weapon_pickedup");
            break;
        }
    }
}