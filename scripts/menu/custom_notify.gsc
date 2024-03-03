// function hintmessage(hinttext, duration)
// {
// 	notifydata = spawnstruct();
// 	notifydata.notifytext = hinttext;
// 	notifydata.duration = duration;
//     notifydata.color = (1, 1, 1);
//     notifydata.glowcolor = (1, 1, 1);
// 	notifymessage(notifydata);
// }

// function notifymessage(notifydata)
// {
// 	self endon(#"death");
// 	self endon(#"disconnect");
// 	if(!isdefined(self.messagenotifyqueue))
// 	{
// 		self.messagenotifyqueue = [];
// 	}
// 	self.messagenotifyqueue[self.messagenotifyqueue.size] = notifydata;
// 	self notify(#"hash_2528173");
// }


