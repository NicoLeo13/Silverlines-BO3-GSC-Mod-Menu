PlayerClone(type, player)
{
    player endon("disconnect");

    switch(type)
    {
        case "Clone":
            clone = player ClonePlayer(10, player GetCurrentWeapon(), player);
            break;
        
        case "Dead":
            clone = player ClonePlayer(10, player GetCurrentWeapon(), player);
            clone StartRagdoll(1);
            break;
        
        default:
            break;
    }
    wait 5;
    clone delete();
}

FrogJump(player)
{
    self endon("disconnect");
    
    player.FrogJump = isDefined(player.FrogJump) ? undefined : true;
    
    if(isDefined(player.DoubleJump))
        player thread DoubleJump();

    while(isDefined(player.FrogJump))
    {
        if(self jumpbuttonpressed() && !isDefined(self.reviveTrigger))
        {
            forward = anglesToForward(self getPlayerAngles());
            self setOrigin(self.origin+(0,0,5));
            self setVelocity((forward[0]*700, forward[1]*700, 400));
            wait 1;
        }
        wait .05;
    }
}

