override_player_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime)
{
    if(isDefined(self.NoExplosiveDamage) && zm_utility::is_explosive_damage(smeansofdeath))
        return 0;

    if(isDefined(self.DemiGod))
    {
        self FakeDamageFrom(vdir);
        return 0;
    }

    if(isDefined(self.PhdFlopper) || isDefined(self.DoubleJump) || isDefined(self.ExoSuit) || isDefined(self.FrogJump))
        if(smeansofdeath == "MOD_FALLING" || smeansofdeath == "MOD_IMPACT")
        {
            iDamage = 0;
            return 0;
        }

    if(isDefined(self.Noclip) || isDefined(self.UFOMode))
        if(smeansofdeath == "MOD_FALLING" || smeansofdeath == "MOD_IMPACT" || smeansofdeath == "MOD_UNKNOWN" || smeansofdeath == "MOD_TRIGGER_HURT")
        {
            iDamage = 0;
            return 0;
        }

    return zm::player_damage_override(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime);
}
