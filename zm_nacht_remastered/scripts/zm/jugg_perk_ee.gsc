#using scripts\zm\_zm_perks;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_audio;
#define IS_TRUE(__a) ( isdefined( __a ) && __a ) 

function autoexec main() {
    thread handlePerk("jugg1");
	thread handlePerk("jugg2");
	thread handlePerk("jugg3");
	thread handlePerk("jugg4");
}

function handlePerk(perk) {
	trigs = GetEntArray(perk + "_perk_trigger", "targetname");

    foreach(trig in trigs) {
        trig thread handleTrig(perk);
    }
}

function handleTrig(perk) {
    endCon = false;
    perkGive = "specialty_armorvest";

    self UseTriggerRequireLookAt();
    self SetCursorHint( "HINT_NOICON" );
	self SetHintString("");

    while( !endCon )
	{
		self waittill( "trigger", player );

		if ( !zm_perks::vending_trigger_can_player_use( player ) )
		{
			wait( 0.1 );
			continue;
		}

		if ( player HasPerk( perkGive ) )
		{
			cheat = false;

			if ( cheat != true )
			{
				//player iprintln( "Already using Perk: " + perk );
				self playsound("evt_perk_deny");

				
				continue;
			}
		}

        if ( !player zm_utility::can_player_purchase_perk() )
		{
			//player iprintln( "Too many perks already to buy Perk: " + perk );
			self playsound("evt_perk_deny");
			// COLLIN: do we have a VO that would work for this? if not we'll leave it at just the deny sound
			continue;
		}

        sound = "evt_bottle_dispense";
		playsoundatposition(sound, self.origin);

        player.perk_purchased = perkGive;
		player notify( "perk_purchased", perkGive );
		
        endCon = givePerk(player, perkGive, perk, self);
    }
}

function selfDelete(){ 
    self Delete();
}

function givePerk(player, perk, perkBottle, trigger) {
    player endon( "disconnect" );
	player endon( "end_game" );
	player endon( "perk_abort_drinking" );

    trigger Delete();
    models = GetEntArray(perkBottle + "_bottle", "targetname");
    
    foreach(model in models) {
       model thread selfDelete();
    }
	// do the drink animation
	gun = player zm_perks::perk_give_bottle_begin( perk );
	evt = player util::waittill_any_return( "fake_death", "death", "player_downed", "weapon_change_complete", "perk_abort_drinking", "disconnect" );
	
	// once they start drinking they get the perk - if the machine is disabled in mid drink they will have it disabled
	if (evt == "weapon_change_complete" )
	{
		player thread zm_perks::wait_give_perk( perk, true );
	}
	
	// restore player controls and movement
	player zm_perks::perk_give_bottle_end( gun, perk );

	// TODO: race condition?
	if ( player laststand::player_is_in_laststand() || IS_TRUE( player.intermission ) )
	{
		return false;
	}

	player notify("burp");
    return true;
}