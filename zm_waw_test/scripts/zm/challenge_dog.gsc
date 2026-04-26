#using scripts\shared\flag_shared;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_powerup_free_perk;

function autoexec main() {
	level thread start_check();
}

function start_check() {
	level flag::wait_till( "dog_round" );
	level thread drop_reward(true);
}

function drop_reward(passed) {
	level waittill( "last_ai_down", e_last );
	if (passed) {
		power_up_origin = level.last_dog_origin;
		if ( isdefined(e_last) )
		{
			power_up_origin = e_last.origin;
		}

		if( isdefined( power_up_origin ) )
		{
			level thread zm_powerups::specific_powerup_drop( "free_perk", power_up_origin );
		}
	}
}

/* function check_challenge_passed() {
	level flag::wait_till( "dog_round" );

	passed = true;

	while (zombie_utility::get_current_zombie_count() != 0 && passed) {
		health = check_player_health();
		bullet = true;

		if (!(health && bullet)) {
			passed = false;
		}

		wait 1;
	}

	thread drop_reward(passed);
}

function check_player_health() {
    passed = true;
    players = GetPlayers();

    foreach (player in players) {
        if (isdefined(player.maxHealth)) {
            if (player.health != player.maxHealth) {
                passed = false;
            }
        } else {
            if (player.health != 100) {
                passed = false;
            }
        }
    }

    return passed;
} */



/* function autoexec move_pap()
{
    level waittill("initial_blackscreen_passed");
    array::thread_all(zm_pap_util::get_triggers(), &move_packapunch);
}
function move_packapunch()
{
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

    ////////////////////////////////////////////////////////////////
    //EXAMPLES TO MOVE PACKAPUNCH WORKS IN ANY FUNCTION/SCRIPT
    //will not work (this way) if your map has multiple packapunches
    ////////////////////////////////////////////////////////////////
    level.pap_location MoveX(200, 5);
    level.pap_location RotateYaw(-180, 5);
    level flag::get("pack_machine_in_use");//dont move pap until "in_use" is cleared
    wait(7);
    //if player is using pap dont move until their done
    while(1)
    {
        if(level flag::get("pack_machine_in_use"))
        {
            wait(.05);
        }
        else{break;}
    }
    random_location = struct::get("random_location","targetname");
    level.pap_location MoveTo(random_location.origin, 5);
}*/
