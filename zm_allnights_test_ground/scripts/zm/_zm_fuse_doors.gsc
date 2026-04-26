#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;

#insert scripts\shared\shared.gsh;

#define DOOR_PRICE           1
#define RED_LIGHT_FX         "night_fuse/fuse_door_light_red"
#define GREEN_LIGHT_FX       "night_fuse/fuse_door_light_green"
#define SPARK_EFX            "night_fuse/fuse_spark"
#define ARK_EFX              "night_fuse/fuse_electric_arc_vista"
#define DOOR_STRING          "Hold ^3[{+activate}]^7 open door. Cost ^8 " + DOOR_PRICE +" ^7 fuse(s)."
#define DOOR_OPEN_SOUND      "madhouse_door_open"

#precache("fx", RED_LIGHT_FX);
#precache("fx", GREEN_LIGHT_FX);
#precache("fx", SPARK_EFX);
#precache("fx", ARK_EFX);

#namespace zm_fuse_doors;

REGISTER_SYSTEM_EX( "zm_fuse_doors", &__init__, &__main__, undefined )

function __init__() {}

function __main__() {
    trigs = GetEntArray("fuse_box_trigger", "targetname");

    foreach(trig in trigs) {
        trig thread HandleDoors();
    }
}

function HandleDoors() {
    level endon("end_game");
    self endon("death");

    self.clip = GetEnt(self.target, "targetname");
    self.clip DisconnectPaths();

    self.doors = GetEntArray(self.clip.target, "targetname");
    foreach(door in self.doors) {
        if(isdefined(self.door_1)) {
            self.door_2 = door;
        } else {
            self.door_1 = door;
        }
    }

    self.open_1 = GetEnt(self.door_1.target, "targetname");
    self.open_2 = GetEnt(self.door_2.target, "targetname");

    if(isdefined(self.open_1.target)) {
        self.red_fx = GetEnt(self.open_1.target, "targetname");
    } else {
        self.red_fx = GetEnt(self.open_2.target, "targetname");
    }

    self.green_fx = GetEnt(self.red_fx.target, "targetname");
    self.fuse_model = GetEnt(self.green_fx.target, "targetname");
    self.ark_fx = GetEnt(self.fuse_model.target, "targetname");
    self.spark_fx = GetEnt(self.ark_fx.target, "targetname");

    PlayFXOnTag( SPARK_EFX, self.spark_fx, "tag_origin" );

    self.fuse_model Hide();

    red_lit_fx = PlayFXOnTag( RED_LIGHT_FX, self.red_fx, "tag_origin" );

    self UseTriggerRequireLookAt();
    self SetCursorHint( "HINT_NOICON" );
    self SetHintString( "You must turn on Power first!" );

    level flag::wait_till("power_on");

	self SetHintString( DOOR_STRING );

    for (;;) {
        self waittill( "trigger", player );

        if (player.fuses_obtained > 0) {
            player.fuses_obtained--;
            player notify( "local_fuse_changed" );

            self Hide();

            self.fuse_model Show();
            PlayFXOnTag( ARK_EFX, self.ark_fx, "tag_origin" );

            self.sound = playsoundatposition(DOOR_OPEN_SOUND, self.clip.origin);

            if(isdefined(red_lit_fx)) {
                red_lit_fx Delete();
            }
            if(isdefined(self.red_fx)) {
                self.red_fx Delete();
            }
            PlayFXOnTag( GREEN_LIGHT_FX, self.green_fx, "tag_origin" );

            self.clip ConnectPaths();
            if(isdefined(self.clip)) {
                self.clip Delete();
            }

            self.door_1 thread OpenDoor();
            self.door_2 thread OpenDoor();

            wait 2;
            if(isdefined(self.sound)) {
                self.sound Delete();
            }
            self Delete();
            break;
        }
    }
}

function OpenDoor() {
    level endon("end_game");
    self endon("death");

    self.openPosition = GetEnt(self.target, "targetname");

    self MoveTo(self.openPosition.origin, 0.75);

    self waittill("movedone");

    if(isdefined(self.openPosition)) {
        self.openPosition Delete();
    }
    if(isdefined(self)) {
        self Delete();
    }
}