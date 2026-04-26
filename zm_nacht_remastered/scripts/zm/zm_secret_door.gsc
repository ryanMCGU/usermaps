//****************************************
//	SECRET DOOR EASTER EGG
//	
//	By Program115
//****************************************

#using scripts\zm\_zm_zonemgr;
#using scripts\shared\flag_shared;
#using scripts\zm\_zm_audio;

function autoexec main()
{
	//Get an array of all the triggers
	trigs = GetEntArray("secret_door_trig", "targetname");
	foreach(trig in trigs) {
		trig thread MonitorTrigger();
	}

	//Loop until all the triggers have been activated
	triggersActivated = 0;
	while(triggersActivated < trigs.size) {
		//The code waits here until a triggers has been activated
		level waittill("secret_door_triggered");
		triggersActivated ++;
	}

	//Now all the triggers have been activated, get the door model and the clip

	doorModel = GetEntArray("secret_door", "targetname");
	doorClip = GetEnt("secret_door_clip", "targetname");
	
	doorClip PlaySound("doorOpened");

	foreach(door in doorModel) {
		door MoveZ(-128, 1);
	}

	level flag::set("enter_pap");

	doorClip Delete();
}
//Monitor each trigger press and notify the main loop
function MonitorTrigger()
{
	self UseTriggerRequireLookAt();
	self SetHintString("Press ^2[{+activate}]^7 to Activate");
	self waittill("trigger");
	
	self PlaySound("buttonPress");
	
	self Delete();
	adoorClip = GetEnt("secret_door_clip", "targetname");
	
	adoorClip PlaySound("doorSlide");

	level notify("secret_door_triggered");

	doorModels = GetEntArray("secret_door", "targetname");
	
	foreach(door in doorModels) {
		door MoveZ(-28, 1);
	}

}