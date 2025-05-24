// TODO: Swarms, Custom Behaviour, Upgrade variant

MaxisDroneWatcher(player)
{
	player thread MaxisDronePlayerDeathWatcher();
	player thread MaxisDroneControlThread();
	player waittill("drone_should_destroy");
	player.maxisQuadrotor = undefined;
	player.hasMaxisQuadrotor = undefined;
	// if(level flag::get("ee_quadrotor_disabled"))
	// {
	// 	level flag::wait_till_clear("ee_quadrotor_disabled");
	// }
	// quadrotor_set_available();
}

MaxisDronePlayerDeathWatcher()
{
	self notify("quadrotor_player_death_condition_watcher");
	self endon("quadrotor_player_death_condition_watcher");
	self endon("new_placeable_mine");
	self endon("player_drone_destroyed");
	self util::waittill_any("bled_out", "disconnect");
	
    if(isdefined(self.maxisQuadrotor))
		self notify("drone_should_destroy");
	// else
	// 	self notify("drone_available");
}

MaxisDroneControlThread()
{
	self notify("quadrotor_control_thread");
	self endon("quadrotor_control_thread");
	self endon("bled_out");
	self endon("disconnect");
	self endon("new_placeable_mine");
	self endon("player_drone_destroyed");
	while(true)
	{
		drone = getweapon("equip_dieseldrone");
		if(self actionslotfourbuttonpressed() && self hasweapon(drone))
		{
			self util::waittill_any_timeout(1, "weapon_change_complete");
			self playsound("veh_qrdrone_takeoff");
			self zm_weapons::switch_back_primary_weapon();
			self util::waittill_any_timeout(1, "weapon_change_complete");
			self zm_weapons::weapon_take(drone);
			self setactionslot(4, "");
			str_vehicle = "heli_quadrotor_zm";
			// if(level flag::get("ee_maxis_drone_retrieved"))
			// {
				str_vehicle = "heli_quadrotor_upgraded_zm";
			// }
			qr = spawnvehicle(str_vehicle, self.origin + vectorscale((0, 0, 1), 96), self.angles, "quadrotor_ai");
			// self thread MaxisDroneDeathWatcher(qr);
			qr thread MaxisDroneInstanceWatcher(self);
			return;
		}
		wait(0.05);
	}
}

MaxisDroneDeathWatcher(quadrotor)
{
	self endon("drone_should_destroy");
	quadrotor waittill("death");
	self notify("drone_should_destroy");
}

MaxisDroneInstanceWatcher(player_owner)
{
	self endon("death");
	self.player_owner = player_owner;
	self.health = 200;
	player_owner.maxisQuadrotor = self;
	player_owner.hasMaxisQuadrotor = true;
	self makevehicleunusable();
	self thread MaxisDroneFollowPlayer(player_owner);
	self thread MaxisDroneCustomTimer(player_owner);
	self thread MaxisDroneReturn(player_owner);
	player_owner thread MaxisDroneCoolDown(player_owner);
	player_owner util::waittill_any("drone_should_cooldown", "drone_should_destroy");
	self MaxisDronePlayerDestroy(player_owner);
}

MaxisDroneFollowPlayer(player_e_followee)
{
	level endon("end_game");
	self endon("death");
	while(isdefined(player_e_followee) && isdefined(self))
	{
		if(!self.maxisDroneDestroy)
		{
			v_facing = player_e_followee getplayerangles();
			v_forward = anglestoforward((0, v_facing[1], 0));
			candidate_goalpos = player_e_followee.origin + (v_forward * 128);
			trace_goalpos = physicstrace(self.origin, candidate_goalpos);
			if(trace_goalpos["position"] == candidate_goalpos)
			{
				self.current_pathto_pos = player_e_followee.origin + (v_forward * 128);
			}
			else
			{
				self.current_pathto_pos = player_e_followee.origin + vectorscale((0, 0, 1), 60);
			}
			self.current_pathto_pos = self getclosestpointonnavvolume(self.current_pathto_pos, 100);
			if(!isdefined(self.current_pathto_pos))
			{
				self.current_pathto_pos = self.origin;
			}
		}
		wait(randomfloatrange(1, 2));
	}
}

MaxisDroneCustomTimer(player_owner)
{
	self endon("death");
	player_owner endon("drone_should_destroy");
	wait(80);
	// vox_line = "vox_maxi_drone_cool_down_" + randomintrange(0, 2);
	// self thread zm_tomb_vo::maxissay(vox_line, self);
	wait(10);
	// vox_line = "vox_maxi_drone_cool_down_2";
	// self thread zm_tomb_vo::maxissay(vox_line, self);
	player_owner notify("drone_should_cooldown");
}

MaxisDroneReturn(player_ent)
{
	self endon("death");
	player_ent endon("drone_should_destroy");
	while(true)
	{
		player_ent util::waittill_any("teleport_finished", "gr_eject_sequence_complete");
		self clientfield::increment("teleport_arrival_departure_fx");
		self.origin = player_ent.origin + vectorscale((0, 0, 1), 100);
		self clientfield::increment("teleport_arrival_departure_fx");
	}
}

MaxisDronePlayerDestroy(player_owner)
{
	self endon("death");
	// player_owner endon("drone_should_destroy");
	// player_owner endon("drone_should_cooldown");

	if(isdefined(self))
	{
		self.maxisDroneDestroy = 1;
		self thread MaxisDroneDestroyTimeout(player_owner);
		
		playfx(level._effect["tesla_elec_kill"], self.origin);
		self playsound("zmb_qrdrone_leave");
		player_owner notify("player_drone_destroyed");
		self delete();
	}
}

MaxisDroneDestroyTimeout(player_owner)
{
	self endon("death");
	wait(30);
	if(isdefined(self))
		self delete();
}

MaxisDroneCoolDown(player_owner)
{
	player_owner endon("drone_should_destroy");
	player_owner waittill("player_drone_destroyed");
	waittime = 60;
	player_owner zm_equipment::show_hint_text("Maxis Drone cooling down for " + waittime + " seconds.");
	wait(waittime);

	drone = getweapon("equip_dieseldrone");
	if(!player_owner HasWeapon(drone) && isdefined(player_owner.hasMaxisQuadrotor))
		player_owner GivePlayerEquipment(drone, player_owner);
}