#using scripts\shared\flag_shared;
#using scripts\shared\ai\zombie_utility;

//*****************************************************************************
// Make all zombies sprinters with a button press.
//*****************************************************************************
function autoexec main() {
    trigs = GetEntArray("rampage_trigger", "targetname");

    foreach(trig in trigs) {
        trig thread handleTrig();
    }
}

function handleTrig() {
    self UseTriggerRequireLookAt();
    self SetCursorHint( "HINT_NOICON" );
	self SetHintString("PRESS ^2[{+activate}]^7 TO ENGAGE THE RAMPAGE NEXT ROUND! (THERE IS NO GOING BACK FROM THIS)");

    self waittill( "trigger", player );

    self playsound("evt_perk_deny");
    self playsound("mus_dogstart1_intro");

    self thread startTheRampage();

    self Delete();
}

function startTheRampage() {
    zombie_utility::set_zombie_var("zombie_spawn_delay", 0.1, true, 2);
    zombie_utility::set_zombie_var("zombie_move_speed_multiplier", 71, false, 2);
    zombie_utility::set_zombie_var("zombie_move_speed_multiplier_easy", 71, false, 2);
    zombie_utility::set_zombie_var("zombie_between_round_time", 2);

    level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];

    //Affect the currently spawned in zombies
    //zombies = GetAiSpeciesArray("axis", "all");
    // for (i = 0; i < zombies.size; i++) {
    //    if (isdefined(zombies[i].zombie_move_speed)) {
    //        zombies[i].zombie_move_speed = "sprint";
    //    } else {
    //        continue;
    //    }
    //}
}