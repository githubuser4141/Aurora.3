/client/Move(new_loc, direct)
	if(moving || world.time < move_delay) //do not move anything ahead of this check please
		return FALSE

	var/old_move_delay = move_delay
	move_delay = world.time + world.tick_lag

	if(!direct || !new_loc)
		return FALSE
	if(!mob?.loc)
		return FALSE

	if(mob.control_object)
		Move_object(direct)

	if(mob.incorporeal_move && isabstractmob(mob))
		Process_Incorpmove(direct, mob)
		return

	if(mob.stat == DEAD && isliving(mob))
		mob.ghostize()
		return

	// handle possible Eye movement
	if(mob.eyeobj)
		return mob.EyeMove(new_loc,direct)

	if(mob.transforming)
		return	//This is sota the goto stop mobs from moving var

	var/add_delay = mob.cached_multiplicative_slowdown

	if(isliving(mob))
		if(SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, new_loc, direct) & COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE)
			return FALSE

		var/mob/living/L = mob
		if(L.incorporeal_move && isturf(mob.loc))//Move though walls
			Process_Incorpmove(direct, mob)
			return
		if(mob.client && ((mob.client.view != world.view) || (mob.client.pixel_x != 0) || (mob.client.pixel_y != 0)))		// If mob moves while zoomed in with device, unzoom them.
			for(var/obj/item/item in mob)
				if(item.zoom)
					item.zoom(mob)
					break
		if(istype(mob.machine,/obj/machinery/computer/security))
			// Has to be here specfically to allow WASD/arrow movement of cameras while buckled.
			// TODO: Remove when machinery/computer finally dies.
			var/obj/machinery/computer/security/console = mob.machine
			if(console.current_camera)
				var/turf/T = get_turf(console.current_camera)
				for(var/i;i<10;i++)
					T = get_step(T,direct)
				console.jump_on_click(mob,T)
				return

		if(length(mob.grabbed_by))
			var/turf/target_turf = get_step(mob, direct)
			for(var/obj/item/grab/G in mob.grabbed_by)
				// can't move, try resisting and stop movement
				if(G.state > GRAB_PASSIVE || get_dist(G.assailant, target_turf) > 1)
					L.resist()
					return

		for(var/obj/item/grab/G in list(mob.l_hand, mob.r_hand))
			G.reset_kill_state() //no wandering across the station/asteroid while choking someone

	if(!mob.canmove || mob.paralysis)
		return

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	if(isobj(mob.loc) || ismob(mob.loc))	//Inside an object, tell it we are moving out
		var/atom/O = mob.loc
		move_delay += (mob.movement_delay() + GLOB.config.walk_speed) * GLOB.config.walk_delay_multiplier
		return O.relaymove(mob, direct)

	if(isturf(mob.loc))
		if(!mob.check_solid_ground())
			var/allowmove = mob.Allow_Spacemove(0)
			if(!allowmove)
				return 0
			else if(allowmove == -1 && mob.handle_spaceslipping()) //Check to see if we slipped
				return 0
			else
				mob.inertia_dir = 0 //If not then we can reset inertia and move


		if(mob.restrained())		//Why being pulled while cuffed prevents you from moving
			var/mob/puller = mob.pulledby
			if(puller)
				if(!puller.restrained() && puller.stat == 0 && puller.canmove && mob.Adjacent(puller))
					to_chat(src, SPAN_NOTICE("You're restrained! You can't move!"))
					return FALSE
				else
					puller.stop_pulling()

		if(length(mob.pinned))
			to_chat(src, SPAN_WARNING("You're pinned to a wall by [mob.pinned[1]]!"))
			move_delay = world.time + 1 SECOND // prevent spam
			return FALSE

		//If the move was recent, count using old_move_delay
		//We want fractional behavior and all
		if(old_move_delay + world.tick_lag > world.time)
			//Yes this makes smooth movement stutter if add_delay is too fractional
			//Yes this is better then the alternative
			move_delay = old_move_delay
		else
			move_delay = world.time

		if(mob.buckled_to)
			if(istype(mob.buckled_to, /obj/vehicle))
				//manually set move_delay for vehicles so we don't inherit any mob movement penalties
				//specific vehicle move delays are set in code\modules\vehicles\vehicle.dm
				move_delay = (old_move_delay + world.tick_lag > world.time) ? old_move_delay : world.time
				//drunk driving
				if(mob.confused && prob(25))
					direct = pick(GLOB.cardinals)
				return mob.buckled_to.relaymove(mob,direct)

			//TODO: Fuck wheelchairs.
			//Toss away all this snowflake code here, and rewrite wheelchairs as a vehicle.
			else if(istype(mob.buckled_to, /obj/structure/bed/stool/chair/office/wheelchair))
				var/min_move_delay = 0
				if(ishuman(mob.buckled_to))
					var/mob/living/carbon/human/driver = mob.buckled_to
					var/obj/item/organ/external/l_hand = driver.get_organ(BP_L_HAND)
					var/obj/item/organ/external/r_hand = driver.get_organ(BP_R_HAND)
					if((!l_hand || l_hand.is_stump()) && (!r_hand || r_hand.is_stump()))
						return // No hands to drive your chair? Tough luck!
					min_move_delay = driver.min_walk_delay
				//drunk wheelchair driving
				if(mob.confused && prob(25))
					direct = pick(GLOB.cardinals)
				move_delay += max((mob.movement_delay() + GLOB.config.walk_speed) * GLOB.config.walk_delay_multiplier, min_move_delay)
				return mob.buckled_to.relaymove(mob,direct)

		var/tally = mob.movement_delay() + GLOB.config.walk_speed

		// Apply human specific modifiers.
		var/mob_is_human = ishuman(mob)	// Only check this once and just reuse the value.
		var/sprint_tally = 0
		if (mob_is_human)
			var/mob/living/carbon/human/H = mob
			//If we're sprinting and able to continue sprinting, then apply the sprint bonus ontop of this
			if (H.m_intent == M_RUN && (H.status_flags & GODMODE || H.species.handle_sprint_cost(H, tally, TRUE))) //This will return false if we collapse from exhaustion
				sprint_tally = tally
				tally = (tally / (1 + H.sprint_speed_factor)) * GLOB.config.run_delay_multiplier
			else if (H.m_intent == M_LAY && (H.status_flags & GODMODE || H.species.handle_sprint_cost(H, tally, TRUE)))
				tally = (tally / (1 + H.lying_speed_factor)) * GLOB.config.lying_delay_multiplier
			else
				tally = max(tally * GLOB.config.walk_delay_multiplier, H.min_walk_delay) //clamp walking speed if its limited
		else
			tally *= GLOB.config.walk_delay_multiplier

		move_delay += tally
		move_delay += add_delay

		if(mob_is_human && mob.lying)
			var/mob/living/carbon/human/H = mob
			var/crawl_tally = H.get_crawl_tally()
			if(crawl_tally >= 120)
				return FALSE

		if(istype(mob.machine, /obj/machinery))
			if(mob.machine.relaymove(mob,direct))
				return

		//Wheelchair pushing goes here for now.
		//TODO: Fuck wheelchairs.
		if(istype(mob.pulledby, /obj/structure/bed/stool/chair/office/wheelchair) || istype(mob.pulledby, /obj/structure/cart))
			var/obj/structure/S = mob.pulledby
			move_delay += S.slowdown
			return mob.pulledby.relaymove(mob, direct)

		var/old_loc = mob.loc

		//We are now going to move
		moving = 1
		if(mob_is_human)
			for(var/obj/item/grab/G in list(mob.l_hand, mob.r_hand))
				switch(G.get_grab_type())
					if(MOB_GRAB_FIREMAN)
						move_delay++
					if(MOB_GRAB_NORMAL)
						move_delay = max(move_delay, world.time + 7)
						step(G.affecting, get_dir(G.affecting.loc, mob.loc))
						SEND_SIGNAL(mob, COMSIG_MOB_CLIENT_MOVED, src, direct, new_loc, old_loc, add_delay)

		if(mob.confused && prob(25) && mob.m_intent == M_RUN)
			step(mob, pick(GLOB.cardinals))
		else
			. = mob.SelfMove(new_loc, direct)

		for (var/obj/item/grab/G in list(mob.l_hand, mob.r_hand))
			if (G.state == GRAB_NECK)
				mob.set_dir(REVERSE_DIR(direct))
			G.adjust_position()

		for (var/obj/item/grab/G in mob.grabbed_by)
			G.adjust_position()

		moving = 0

		if(sprint_tally && mob.loc != old_loc)
			var/mob/living/carbon/human/H = mob
			H.species.handle_sprint_cost(H, sprint_tally, FALSE)
