#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_perks;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache( "fx", "dirt/fx_dust_fall_md_impact_lit" );

#namespace dive;

function autoexec __init__system__()
{
	system::register( "dive", &__init__, undefined, undefined );
}

#define VEL_MULTIPLIER 1.3 // forward lunge
#define N_DIVE_JUMP 30 // upward lunge
#define N_DIVE_FORCE 165 // fall strength
#define N_DIVE_FORCE_LOWGRAV 150 // lowgrav fall strength
#define GROUNDDIST_CHECK 400 // ground proximity to end dive
#define DIVE_COOLDOWN 1 // wait before can dive again
#define DEVPRINT 0

function __init__()
{
    level._effect["dive_impact"] = "dirt/fx_dust_fall_md_impact_lit";
	callback::on_connect( &on_player_connect );
}

function on_player_connect()
{
    self.maxfps = GetDvarInt( "com_maxfps" );
    self thread disable_slide();
    //self thread sprint_cancels_reload();
    //self thread reload_cancels_sprint();
    self thread monitor_stance_response();
    //self thread give_phd();
}

function give_phd()
{
    level waittill( "initial_blackscreen_passed" );
    self zm_perks::give_perk( "specialty_phdflopper", 0 );
}

function disable_slide()
{
    self endon( "disconnect" );
    for(;;) {
        self AllowSlide(0);
        wait 3;
    }
}

function sprint_cancels_reload()
{
    self endon( "disconnect" );
    for(;;) {
        while( !self IsReloading())
            wait 1;
        while( self IsReloading()) {
            wait .05;
            if( self IsSprinting()) {
                if( DEVPRINT )
                    IPrintLnBold( "RELOAD CANCEL" );
                self cancel_reload();
            }
        }
    }
}

function cancel_reload()
{
    self endon( "disconnect" );
    weapons = self GetWeaponsListPrimaries();
    weapon = self GetCurrentWeapon();
    if( weapons.size == 1 ) {
        altweapon = self GetCurrentWeaponAltWeapon();
        if( altweapon.name != "none" ) {
            // self sys::Kill();
            return; // because im lazy. if someone wants to make this extremely rare case work go for it
        }
        clip = self GetWeaponAmmoClip( weapon );
        stock = self GetWeaponAmmoStock( weapon );
        self TakeWeapon( weapon );
        wait .05;
        self GiveWeapon( weapon );
        self SetWeaponAmmoClip( weapon, clip );
        self SetWeaponAmmoStock( weapon, stock );
        self SwitchToWeapon( weapon );
        self ShouldDoInitialWeaponRaise( weapon, 0 );
    }
    else {
        self SwitchToWeaponImmediate(); // this is switching to secondary to cancel reload
        wait .05;
        self SwitchToWeaponImmediate( weapon ); // switch back to the weapon you canceled reload on
    }
}

function reload_cancels_sprint()
{
    self endon( "disconnect" );
    for(;;) {
        while( !self IsSprinting())
            wait 1;
        while( self IsSprinting()) {
            wait .05;
            if( self IsReloading()) {
                if( DEVPRINT )
                    IPrintLnBold( "SPRINT CANCEL" );
                self cancel_sprint();
            }
        }
    }
}

function cancel_sprint()
{
    self AllowSprint(0);
    wait .05;
    self AllowSprint(1);
}

function monitor_stance_response()
{
    self endon( "disconnect" );
    for(;;) {
    	wait .05;
        while(!self StanceButtonPressed()) {
        	wait .05;
            continue;
        }
        if( !self IsSprinting()) {
        	if( DEVPRINT )
        		IPrintLnBold( "NOT SPRINTING" );
        	continue;
        }
        if( self GamepadUsedLast()) {
            wait .2;
            if(!self StanceButtonPressed()) {
            	if( DEVPRINT )
            		IPrintLnBold( "PRESS LONGER" );
                continue;
            }
        }
        /* "superdive" patch
        if( !self JumpButtonPressed())
            self dive();
        */
        if( DEVPRINT )
        	IPrintLnBold( "DIVE START" );
        self PlaySoundToPlayer("dive_start", self);
        self dive(); // Neo dive
    }
}

function dive()
{
    self endon( "disconnect" );
    self notify( "diving" );
    self endon( "diving" );
    SetDvar( "com_maxfps", 120 );
    force = self GetVelocity();
    forceX = force[0] * VEL_MULTIPLIER;
    forceY = force[1] * VEL_MULTIPLIER;
    self.divetoprone = 1;
    self AllowJump(0);
    self SetOrigin( self.origin + ( 0, 0, N_DIVE_JUMP ) );
	self SetVelocity( ( forceX, forceY, ( IS_TRUE( self.in_low_gravity ) ? N_DIVE_FORCE_LOWGRAV : N_DIVE_FORCE ) ) );
    self notify( "dive_begin" );
    for(;;) {
    	wait .05;
    	floor = GetClosestPointOnNavMesh( self.origin );
        if( isdefined( floor ) && DEVPRINT ) {
    			IPrintLnBold( "Floor = ", floor, " Player Origin = ", self.origin, " Distance = ", DistanceSquared( floor, self.origin ));
    		}
    	if( isdefined( floor ) && DistanceSquared( floor, self.origin ) < GROUNDDIST_CHECK ) {
    		if( DEVPRINT ) {
    			IPrintLnBold( "DIVE STOP" );
    		}
            self PlaySoundToPlayer("dive_land", self);
            fx = PlayFX( level._effect["dive_impact"], floor );
    		break;
    	}
       
    }
    self notify( "dive_end" );
    SetDvar( "com_maxfps", self.maxfps );
    self.divetoprone = 0;
    self AllowJump(1);
    fx Delete();
    if( DIVE_COOLDOWN )
        wait DIVE_COOLDOWN;
}

/*
function watch_player_jump_events() // Remove jump cooldown
{
    self endon( "disconnect" );

    for(;;)
    {
        ret = util::waittill_any_return( "jump_begin", "jump_end");
        
        if ( isdefined(self.divetoprone) && !self.divetoprone) {
            
            switch(ret) {
            case "jump_begin":
                self SetDoubleJumpEnergy(0);
                self AllowDoubleJump(false);
                break;
            case "jump_end":
                self SetDoubleJumpEnergy(0);
                self AllowDoubleJump(true);
                break;
            }
        }
        wait 0.1;
    }
}
*/