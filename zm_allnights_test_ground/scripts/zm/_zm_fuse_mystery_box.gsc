#using scripts\codescripts\struct;

#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_utility;

#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\array_shared;
#using scripts\shared\system_shared;

#using_animtree("generic"); 

#insert scripts\shared\shared.gsh;

#define PRICE_OF_BOX            1
#define UNLOCK_ROUND            1
#define BOX_STRING              "Hold ^3[{+activate}]^7 to gain a random Packed Weapon. Cost ^8 " + PRICE_OF_BOX + " ^7 fuse(s)."
#define BOX_LOCKED_STRING       "Locked till round ^3 " + UNLOCK_ROUND + " ^7..."
#define BOX_MUSIC               "pap_box_music"
#define WEAPON_PICKUP_STRING    "Hold ^3[{+activate}]^7 pick up weapon."

#precache( "fx", "dlc5/tomb/fx_tomb_magicbox_amb" );
#precache( "fx", "dlc5/tomb/fx_tomb_magicbox_amb_base");
#precache( "fx", "dlc5/tomb/fx_tomb_magicbox_open");

#namespace zm_fuse_mystery_box;

REGISTER_SYSTEM_EX( "zm_fuse_mystery_box", &__init__, &__main__, undefined )

function __init__() {}

function __main__() {
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
	self SetHintString(BOX_LOCKED_STRING);

    //locks pap box till round 20
    for(;;) {
        level waittill("start_of_round");

        if(level.round_number >= UNLOCK_ROUND) {
            break;
        }
    }

    for(;;) {
        self SetHintString(BOX_STRING);

        self waittill( "trigger", player );
        
        if (player.fuses_obtained >= PRICE_OF_BOX) {
            player.fuses_obtained -= PRICE_OF_BOX;
            player notify( "local_fuse_changed" );

            self Hide();

            top_fx = util::spawn_model("tag_origin", top_struct.origin, top_struct.angles);
            base_fx = util::spawn_model("tag_origin", base_struct.origin, base_struct.angles);
            bottom_fx = util::spawn_model("tag_origin", bottom_struct.origin, bottom_struct.angles);

            top_fx PlaySound(BOX_MUSIC);

            top_fx_play = PlayFXOnTag("dlc5/tomb/fx_tomb_magicbox_amb", top_fx, "tag_origin", true);
            base_fx_play = PlayFXOnTag("dlc5/tomb/fx_tomb_magicbox_amb_base", base_fx, "tag_origin", true);
            bottom_fx_play = PlayFXOnTag("dlc5/tomb/fx_tomb_magicbox_open", bottom_fx, "tag_origin", true);

            pap_box scene::play("pap_box_anims", pap_box);
            weapon = zm_magicbox::treasure_chest_ChooseWeightedRandomWeapon( player );

            weapon_model = util::spawn_model("tag_origin", weapon_struct.origin, weapon_struct.angles);
            weapon_model MoveTo(weapon_top.origin, 1.5);

            unparsed_keys = array::randomize( GetArrayKeys( level.zombie_weapons ) );
            keys = [];
            i = 0;
            foreach (gun in unparsed_keys) {
                if(zm_weapons::get_is_in_box( gun )) {
                    keys[i] = gun;
                    i++;
                }
            }
                for(i = 0; i < keys.size/2; i++) {
                    if( self zm_weapons::can_upgrade_weapon( keys[i] ) ) {
			            upgraded_weapon = zm_weapons::get_upgrade_weapon( keys[i] );
                        weapon_model SetModel(upgraded_weapon.worldmodel);
		            }
                    else {
                        weapon_model SetModel(keys[i].worldmodel);
                        upgraded_weapon = keys[i];
                    }
                    
                    wait 0.2;
                }

            weapon_model SetModel(weapon.worldmodel);
            weapon_model MoveTo(weapon_struct.origin, 12);

            pickup_trig thread handlePickUpTrig(weapon, weapon_model);
            thread pickupCountDown(pickup_trig);
            level waittill("pap_box_weapon_pickedup");
            
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

            level notify("kill_pap_box_weapon_pickedup");

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

    wait 12;
    trig Hide();

    level notify("pap_box_weapon_pickedup");
}

function handlePickUpTrig(weapon, weapon_model){
    level endon("end_game");
    level endon("kill_pap_box_weapon_pickedup");

    self SetCursorHint( "HINT_NOICON" );
	self SetHintString(WEAPON_PICKUP_STRING);

    self Show();

    for (;;) {
        self waittill( "trigger", player );

        if (player zm_magicbox::can_buy_weapon()) {
            if( zm_weapons::can_upgrade_weapon( weapon ) ) {
			    weapon = zm_weapons::get_upgrade_weapon( weapon );
		    }

            player zm_weapons::weapon_give(weapon);

            self Hide();
            weapon_model Delete();
            level notify("pap_box_weapon_pickedup");
            break;
        }
    }
}