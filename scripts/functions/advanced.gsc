CustomFxPlayer(fx, delete)
{
	if(isDefined(delete))
	{
		for(i = 0; i < level.customFxSpawned.size; i++)
		{
			self iPrintLnBold(i);
			level.customFxSpawned[i] delete();
		}
		level.customFxOrigin delete();
		level.customFxOrigin = undefined;
		level.customFxSpawned = [];
		return;
	}

	// origin = self.origin + AnglesToForward(self.angles) * 150;
	origin = self TraceBullet();
	level.customFxOrigin = util::spawn_model("tag_origin", origin);

	level.customFxSpawned[level.customFxSpawned.size] = PlayFXOnTag(level._effect[fx], level.customFxOrigin, "tag_origin");
	// PlayFXOnTag(fx_name, entity, tag, ignore_pause);
	// PlayFX(fx_name, position, forward, up, ignore_pause)
}