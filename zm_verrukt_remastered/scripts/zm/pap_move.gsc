#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\codescripts\struct;
#using scripts\shared\exploder_shared;
#using scripts\shared\util_shared;

#precache( "fx", "dlc3/mp_rome/fx_pool_bubbles_rome" );
#precache( "fx", "dlc5/sumpf/fx_water_surface_bubbles_md");

function autoexec move_pap() {
    level endon("end_game");

    level waittill("initial_blackscreen_passed");

    level.other_round_pap = 200;

    array::thread_all(zm_pap_util::get_triggers(), &move_packapunch);
    thread pap_fx();
}

function pap_fx() {
    level endon("end_game");

    level flag::wait_till("power_on");

    for(;;) {
        level waittill("pack_move");
    s_loc = struct::get("fx_sv", "targetname");
    bubble_fx = util::spawn_model("tag_origin", s_loc.origin, s_loc.angles);
    splash_fx = util::spawn_model("tag_origin", s_loc.origin, s_loc.angles);

    // wait 0.05;
    //IPrintLnBold("Play Server FX " + m_fx GetEntityNumber());
    bubble_playfx = PlayFXOnTag("dlc3/mp_rome/fx_pool_bubbles_rome", bubble_fx, "tag_origin", true);
    splash_playfx = PlayFXOnTag("dlc5/sumpf/fx_water_surface_bubbles_md", splash_fx, "tag_origin", true);
    bubble_fx PlaySound("fountain_splash");
    
    wait 5;
    if (level.other_round_pap > 0) {
        splash_fx PlaySound("bell_splash");
    }

    wait 10;
    //IPrintLnBold("Stop Server FX " + m_fx GetEntityNumber());
    if (isdefined(bubble_playfx))
        bubble_playfx Delete();

    if (isdefined(splash_playfx))
        splash_playfx Delete();

    if (isdefined(bubble_fx))
        bubble_fx Delete();
        
    if (isdefined(splash_fx))
        splash_fx Delete();

    wait 20;
    }
}
function move_packapunch() {
    level endon("end_game");

    level flag::wait_till("power_on");

    //Model to Link to PackaPunch
    level.pap_location = Spawn("script_model",self.zbarrier.origin);
    level.pap_location SetModel("tag_origin");

    //Link
    self EnableLinkTo();
    self LinkTo(self.zbarrier);
    self.clip EnableLinkTo();
    self.clip LinkTo(self.zbarrier);
    self.zbarrier EnableLinkTo();
    self.zbarrier LinkTo(level.pap_location);

    for (;;){
    level waittill( "start_of_round" );

    ////////////////////////////////////////////////////////////////
    //EXAMPLES TO MOVE PACKAPUNCH WORKS IN ANY FUNCTION/SCRIPT
    //will not work (this way) if your map has multiple packapunches
    ////////////////////////////////////////////////////////////////
    level flag::get("pack_machine_in_use");//dont move pap until "in_use" is cleared
    wait(7);
    //if player is using pap dont move until their done

    while(1)
    {
        if(level flag::get("pack_machine_in_use"))
        {
            wait(.05);
        }
        else{
            break;}
    }
    
    level.other_round_pap = level.other_round_pap * -1;
    level.pap_location MoveZ(level.other_round_pap, 13);

    level notify("pack_move");

    if (level.other_round_pap > 0) {
        self.clip DisconnectPaths(); 
        exploder::exploder("pap_lght");
    }
    else {
        self.clip ConnectPaths(); 
        exploder::stop_exploder("pap_lght");
    }
}
}