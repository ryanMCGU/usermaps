#using scripts\codescripts\struct;

#using scripts\shared\util_shared;
#using scripts\shared\array_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;

//#precache( "fx", "dlc5/cosmo/fx_zmb_blackhole_looping" );

function autoexec init() {
    thread SetupLockerRewards();
}

function SetupLockerRewards() {
    //level._effect["reward_light"] = "dlc5/cosmo/fx_zmb_blackhole_looping";

    RegisterLockerRewards();

    lockers = GetEntArray("openable_locker", "targetname");
    foreach(locker in lockers) {
        locker thread SetupLocker();
    }
}

function RegisterLockerRewards() {
    RegisterLockerReward("low_points", 1, &GivePoints, 500);
    RegisterLockerReward("nuke", 1, &SpawnPowerup, "nuke", true);
    RegisterLockerReward("carpenter", 1, &SpawnPowerup, "carpenter", true);
    RegisterLockerReward("minigun", 1, &SpawnPowerup, "minigun", true);

    RegisterLockerReward("maxammo", 2, &SpawnPowerup, "full_ammo", true);
    RegisterLockerReward("instakill", 2, &SpawnPowerup, "insta_kill", true);
    RegisterLockerReward("doublepoints", 2, &SpawnPowerup, "double_points", true);
    RegisterLockerReward("fuse", 2, &SpawnPowerup, "fuse", true);
    RegisterLockerReward("firesale", 2, &SpawnPowerup, "fire_sale", true);

    RegisterLockerReward("freeperk", 3, &SpawnPowerup, "free_perk", true);
    RegisterLockerReward("high_points", 3, &GivePoints, 2500);
}

function RegisterLockerReward(rewardScriptName, rewardTier, rewardActivateCB, rewardActivateArg = undefined, rewardUsesWorld = undefined) {
    if(!IsDefined(level.LockerRewards)) {
        level.LockerRewards = [];
    }

    reward = SpawnStruct();
    reward.name = rewardScriptName;
    reward.tier = rewardTier;
    reward.activateCB = rewardActivateCB;
    reward.activateArg = rewardActivateArg;
    reward.usesWorld = rewardUsesWorld;

    level.LockerRewards[rewardScriptName] = reward;
}

function SetupLocker() {
    trigger = GetEnt(self.target, "targetname");
    trigger TriggerEnable(true);
    trigger SetHintString("Press ^3[{+activate}]^7 to Open the Locker.");
    if(IsDefined(trigger.zombie_cost)) {
        if(IsTokenLocker(trigger)) {
            trigger SetHintString("Press ^3[{+activate}]^7 to Recieve Your Reward [Cost: &&1 Token(s)]", trigger.zombie_cost);
        }
        else {
            trigger SetHintString("Press ^3[{+activate}]^7 to Recieve Your Reward [Cost: &&1]", trigger.zombie_cost);
        }
    }

    door_pivot = GetEnt(trigger.target, "targetname");
    
    self LinkTo(door_pivot);
    trigger.pivot = door_pivot;
    trigger.door = self;

    self.fxEnt = util::spawn_model("tag_origin", self.origin);
    //PlayFXOnTag(level._effect["reward_light"], self.fxEnt, "tag_origin");
    trigger thread WatchForLockerInteract();
}

function GetLockerReward() {
    reward = GetWeightedRandomReward();
    if(IsDefined(self.script_string)) {
        reward = level.LockerRewards[self.script_string];
    }
    else if(IsDefined(self.script_int)) {
        //IPrintLnBold("Tier " + self.script_int);
        while(!IsDefined(reward) || reward.tier != self.script_int) {
            reward = array::random(level.LockerRewards);
            wait(0.05);
        }
    }

    //IPrintLnBold("Reward " + reward.name);
    return reward;
}

function GetWeightedRandomReward() {
    random_int = RandomIntRange(1, 100);
    tier_1 = [];
    tier_2 = [];
    tier_3 = [];

    foreach(a_reward in level.LockerRewards) {
        switch (a_reward.tier) {
            case 1:
                tier_1[a_reward.name] = a_reward;
                break;
            case 2:
                tier_2[a_reward.name] = a_reward;
                break;
            case 3:
                tier_3[a_reward.name] = a_reward;
                break;
        }
    }

    if (random_int <= 5) {
        reward = array::random(tier_3);
    }
    else if (random_int <= 35) {
        reward = array::random(tier_2);
    }
    else {
        reward = array::random(tier_1);
    }

    return reward;
}

function WatchForLockerInteract() {
    self endon("locker_disabled");
    
    for(;;) {
        self waittill("trigger", who);        

        if(!IsDefined(who.tokens)) {
            //IPrintLnBold("resetting tokens..");
            who.tokens = 0;
        }

        if(who CanUseLocker(self)) {
            if(IsDefined(self.zombie_cost)) {
                if(IsTokenLocker(self)) {
                    // minus tokens
                    who.tokens -= self.zombie_cost;
                    //who IPrintLn("Spent " + self.zombie_cost + " tokens..");
                    //who IPrintLn("You have " + who.tokens + " tokens..");
                }
                else {
                    who zm_score::minus_to_player_score(self.zombie_cost);
                }
            }

            self thread DoLockerAnimation();

            reward = self GetLockerReward();
            if(IsDefined(reward.activateArg)) {
                if(IsDefined(reward.usesWorld)) {
                    who thread [[reward.activateCB]](reward.activateArg, self); // pass the trigger for access to connected objects
                }
                else {
                    who thread [[reward.activateCB]](reward.activateArg);
                }
            }
            else {
                if(IsDefined(reward.usesWorld)) {
                    who thread [[reward.activateCB]](self); // pass the trigger for access to connected objects
                }
                else {
                    who thread [[reward.activateCB]]();
                }
            }

            self.door.fxEnt Delete();
            self TriggerEnable(false);
            self notify("locker_disabled");
        }
    }
}

function DoLockerAnimation() {
    pivot = self.pivot;
    pivot RotateTo(pivot.angles + (0,135,0), 1);
    
    door = self.door;
    //PlayFX(level._effect["poltergeist"], door.origin);

    pivot waittill("rotatedone");

    wait RandomIntRange(1, 5) * 60; // Random wait from 1 to 8 minutes for locker to reset

    self DoCloseLockerAnimation();
}

function DoCloseLockerAnimation() {
    pivot = self.pivot;
    pivot RotateTo(pivot.angles - (0,135,0), 10);
    pivot waittill("rotatedone");

    self.door SetupLocker();
}

function SpawnPowerup(powerupType, trigger) {
    door = trigger.door;

    powerup = level thread zm_powerups::specific_powerup_drop(powerupType, door.origin + VectorScale(AnglesToForward(door.angles), 12));
    powerup SetScale(0.4);
}

function GivePoints(points) {
    zm_utility::play_sound_at_pos( "purchase", self.origin );
    self zm_score::add_to_player_score(points);
}

function CanUseLocker(trigger) {
    if(IsDefined(trigger.zombie_cost)) {
        if(IsTokenLocker(trigger)) {
            if(self.tokens < trigger.zombie_cost) {
                return false;
            }
        }
        else {
            if(self.score < trigger.zombie_cost) {
                return false;
            }
        }
    }
    
    return true;
}

function IsTokenLocker(trigger) {
    return IsDefined(trigger.script_flag) && trigger.script_flag == "token";
}