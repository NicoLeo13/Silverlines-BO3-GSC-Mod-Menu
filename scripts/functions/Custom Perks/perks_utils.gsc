// Custom Perk Drink
CustomPerkDrink(perk)
{
    self endon("player_downed");
	self endon("disconnect");
	self endon("end_game");
	self endon("perk_abort_drinking");

    sound = "evt_bottle_dispense";
    playsoundatposition(sound, self.origin);
    
    gun = self zm_perks::perk_give_bottle_begin(perk);
	evt = self util::waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete", "perk_abort_drinking", "disconnect");
	if(evt == "weapon_change_complete")
    {
		self util::waittill_any_timeout(0.5, "burp", "player_downed", "disconnect", "end_game", "perk_abort_drinking");
        // self thread zm_perks::give_perk_presentation(perk);
    }
    self zm_perks::perk_give_bottle_end(gun, perk);
    // self zm_perks::give_perk_presentation(perk);
}

//  Utils
CustomPerksMonitor()
{
    self endon("disconnect");

    self.perkMonitorOn = true;
    self waittill("player_downed");

    self iPrintLnBold("^3Entered");

    if(isDefined(self.keepPerks))
    {
        wait 1;
        if(self.virtualperks.size > 0)
            self thread CustomPerksMonitor();
        return;
    }
    else
    {
        wait 1;
        if(isDefined(self.PhdFlopper))
            self thread PhdFlopper(self);
        if(isDefined(self.ElectricCherry))
        {
            // self thread ElectricCherry(self);
            ArrayRemoveValue(self.virtualperks, "ElectricCherry");
            self.ElectricCherry = undefined;
            self thread RemoveElectricCherry();
            self notify("end_electric_cherry");
        }
        if(isDefined(self.AirFryer))
            self thread AirFryer(self);
    }
}

VirtualPerksPos(perk)
{
    if (!isDefined(self.perks_active) || self.perks_active.size <= 0)
        activePerks = 0;
    else
        activePerks = self.perks_active.size;

    virtualPerks = self.virtualperks.size;

    x = 130 + (activePerks * 40);
    if (activePerks >= 3)
        x = x - (4 * int(Floor(activePerks / 2)));

    for (i = 0; i < self.virtualperks.size; i++)
    {
        if(perk == self.virtualperks[i])
        {
            perk = self.virtualperks[i];
            posOffset = i;

            x_offset = x + (40 * posOffset);
            return x_offset;
        }
    }
}

// zombie zm_utility::display_message(titletext, notifytext, duration)

// level.weaponrevivetool = getweapon("syrette");
// level.weaponzmdeaththroe = getweapon("death_throe");
// level.weaponzmfists = getweapon("zombie_fists");