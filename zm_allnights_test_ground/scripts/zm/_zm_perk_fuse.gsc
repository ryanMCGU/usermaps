#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_score;

#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;

#insert scripts\shared\shared.gsh;

#define VENDING_PRICE           1
#define CONVERSION_RATE         1500
#define PERK_LIMIT              10
#define VENDING_ALT_STRING      "(If at max perk slots) Hold ^3[{+activate}]^7 for ^8 " + CONVERSION_RATE + " ^7 points. Cost ^8 " + VENDING_PRICE +"^7 fuse(s)."
#define VENDING_STRING          "Hold ^3[{+activate}]^7 to gain a perk slot. Cost ^8 " + VENDING_PRICE +" ^7 fuse(s). \n " + VENDING_ALT_STRING
#define VENDING_FX              "zombie/fx_perk_mule_kick_zmb"

#precache("fx", VENDING_FX);

#namespace zm_perk_fuse;

REGISTER_SYSTEM_EX( "zm_perk_fuse", &__init__, &__main__, undefined )

function __init__() {}

function __main__() {
    trig = GetEnt("fuse_vending_trig", "targetname");
    fx = GetEnt("fuse_vending_fx", "targetname");
    machine = GetEnt("fuse_vending_model", "targetname");

    level.get_player_perk_purchase_limit = &get_player_perk_purchase_limit;

    trig thread handleFuseVendingTrig();
    machine thread handlePowerOn(fx);
}

function get_player_perk_purchase_limit()
{
    if( isdefined( self.player_perk_purchase_limit ) )
        return self.player_perk_purchase_limit;
    return level.perk_purchase_limit;
}

function handlePowerOn(fx) {
    level endon("end_game");

    level flag::wait_till("power_on");

    self vibrate((0,-100,0), 0.3, 0.4, 3);

    wait 2.95;

    PlayFxOnTag(VENDING_FX, fx, "tag_origin");
}

function handleFuseVendingTrig() {
    level endon("end_game");

    self UseTriggerRequireLookAt();
    self SetCursorHint( "HINT_NOICON" );
    self SetHintString( "You must turn on Power first!" );

    level flag::wait_till("power_on");

	self SetHintString( VENDING_STRING );

    for (;;) {
        self waittill( "trigger", player );

        if (!isdefined(player.player_perk_purchase_limit)) {
		    player.player_perk_purchase_limit = level.perk_purchase_limit;
	    }

        if (player.player_perk_purchase_limit != PERK_LIMIT) {
            if (player.fuses_obtained > 0) {
                player.fuses_obtained--;
                player notify( "local_fuse_changed" );
                
                player.player_perk_purchase_limit++;
                zm_utility::play_sound_at_pos( "purchase", player.origin );
            }
            else {
                self PlaySound("evt_perk_deny");
                player zm_audio::create_and_play_dialog( "general", "sigh" );
            }  
        }
        else {
            if (player.fuses_obtained > 0) {
                player.fuses_obtained--;
                player notify( "local_fuse_changed" );

                zm_utility::play_sound_at_pos( "purchase", player.origin );
                player zm_score::add_to_player_score(CONVERSION_RATE);
            }
            else {
                self PlaySound("evt_perk_deny");
                player zm_audio::create_and_play_dialog( "general", "sigh" );
            }  
        }

        wait 0.5;
    }
}