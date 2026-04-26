#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\util_shared;

#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_powerup_fuse.gsh;

#precache( "string", "FUSE_OBTAIN" );
#precache( "eventstring", "zombie_notification" );

#namespace zm_powerup_fuse;

REGISTER_SYSTEM_EX( "zm_powerup_fuse", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__() {
	zm_powerups::register_powerup( FUSE_STRING, &grab_fuse );
	zm_powerups::add_zombie_powerup( FUSE_STRING, FUSE_MODEL, &"FUSE_OBTAIN", ( FUSE_CAN_ZOMBIES_DROP ? &zm_powerups::func_should_always_drop : &zm_powerups::func_should_never_drop ), !POWERUP_ONLY_AFFECTS_GRABBER, !POWERUP_ANY_TEAM, !POWERUP_ZOMBIE_GRABBABLE );
	zm_powerups::powerup_set_can_pick_up_in_last_stand( FUSE_STRING, FUSE_CAN_GRAB_IN_LASTSTAND );
	zm_powerups::powerup_set_statless_powerup( FUSE_STRING );
	zm_audio::sndAnnouncerVoxAdd( FUSE_STRING, FUSE_SOUND_ALIAS_SUFFIX );
}

function __main__() {
	callback::on_spawned( &init_fuse_watch );
}

function init_fuse_watch() {
	if(!isdefined(self.fuses_obtained)) {
		self.fuses_obtained = 0;
		self thread fuse_listener();
	}
}

function fuse_listener() {
	level endon("end_game");
	self endon("disconnect");

	if (!IsDefined (self.fuse_hud))
		self.fuse_hud = reap_create_hud_text (FUSE_ALIGN_X, FUSE_ALIGN_Y, FUSE_ALIGN_X, FUSE_ALIGN_Y, FUSE_X, FUSE_Y, .8, FUSE_COLOR, "Fuses: " + self.fuses_obtained, 2);

		self.fuse_hud SetText ("Fuses: " + self.fuses_obtained);

	for (;;) {
		result = level util::waittill_any_ex( "global_fuse_obtained", self, "local_fuse_changed" );

		if (result == "global_fuse_obtained") {
			self.fuses_obtained++;
		}

		self.fuse_hud SetText ("Fuses: " + self.fuses_obtained);
	}
}

function grab_fuse( e_player ) {	
	luiNotifyEvent( &"zombie_notification", 1, &"FUSE_OBTAIN" );

	level notify ("global_fuse_obtained");
}


function reap_create_hud_text (aligX, aligY, horzAlin, vertAlin, x, y, alp, color, text, size)
{
	hud = undefined;
	
	if (self == level)
		hud = newHudElem();
		
	else
		hud = NewClientHudElem (self);
		
	hud.alignX = aligX; 
	hud.alignY = aligY;
	hud.horzAlign = horzAlin; 
	hud.vertAlign = vertAlin;
	hud.x = x;
	hud.y = y;
	hud.alpha = alp;
	hud.color = color;
	hud.fontScale = size;
	hud setText (text);
	
	return hud;
}