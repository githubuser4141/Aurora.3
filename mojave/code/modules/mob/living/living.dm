/mob/living
	var/voice_type

/mob/living/Initialize(mapload)
	. = ..()
	update_nv()

/// Wielding procs
/mob/living/proc/wield_active_hand()
	var/obj/item/active = get_active_held_item()
	if(istype(active))
		return active.wield_act(src)
	else
		to_chat(src, SPAN_WARNING("You have nothing to wield!"))
		return FALSE

/mob/living/proc/wield_ui_update(active = FALSE)
	if(!hud_used)
		return FALSE
	hud_used.wield_active = active
	for(var/atom/movable/screen/wield/wield_button in hud_used.hotkeybuttons)
		wield_button.update_appearance()
	var/atom/movable/screen/inventory/hand_hud
	for(var/hand in hud_used.hand_slots)
		hand_hud = hud_used.hand_slots[hand]
		hand_hud?.update_appearance()
	var/obj/item/active_item = hud_used.mymob?.get_active_held_item()
	if(active_item?.wield_info)
		var/datum/wield_info/wield_info = GLOB.path_to_wield_info[active_item.wield_info]
		var/wield_pixel_x = !active ? 0 : (!(hud_used.mymob.active_hand_index % RIGHT_HANDS) ? wield_info.pixel_x_wielded : -wield_info.pixel_x_wielded)
		active_item.screen_loc = ui_hand_position(hud_used.mymob.active_hand_index, wield_pixel_x)
	return TRUE

/// Alter speech when a mob is buried in a grave
/mob/living/proc/handle_buried_speech(mob/living/carbon/speaker, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		speech_args[SPEECH_MESSAGE] = stars(message, 40)


/// Updates canmove, lying and icons. Could perhaps do with a rename but I can't think of anything to describe it.
/mob/proc/update_canmove()
	if(in_neck_grab())
		lying = FALSE
		for(var/obj/item/grab/G in grabbed_by)
			if(G.force_down)
				lying = TRUE
				break
	else if(!resting && cannot_stand() && can_stand_overridden())
		lying = FALSE
		lying_is_intentional = FALSE
		canmove = TRUE
	else
		if(istype(buckled_to, /obj/vehicle))
			var/obj/vehicle/V = buckled_to
			if(is_physically_disabled() && !HAS_TRAIT(src, TRAIT_FORCED_STANDING))
				lying = TRUE
				lying_is_intentional = FALSE
				canmove = FALSE
				pixel_y = V.mob_offset_y - 5
			else
				if(buckled_to.buckle_lying != -1) lying = buckled_to.buckle_lying
				lying_is_intentional = FALSE
				canmove = TRUE
				pixel_y = V.mob_offset_y
		else if(buckled_to)
			anchored = TRUE
			canmove = FALSE
			if(isobj(buckled_to))
				if(buckled_to.buckle_lying != -1)
					lying = buckled_to.buckle_lying
					lying_is_intentional = FALSE
				if(buckled_to.buckle_movable)
					anchored = FALSE
					canmove = TRUE
		else if(captured)
			anchored = TRUE
			canmove = FALSE
			lying = FALSE
		else if(m_intent == M_LAY && !incapacitated() && !HAS_TRAIT(src, TRAIT_FORCED_STANDING))
			lying = TRUE
			lying_is_intentional = TRUE
			canmove = TRUE
		else if(sleeping && !HAS_TRAIT(src, TRAIT_FORCED_STANDING))
			lying = resting || is_dead() || (MOB_IS_INCAPACITATED(INCAPACITATION_KNOCKDOWN) && sleeps_horizontal()) // Vaurca, IPCs and Diona sleep standing up, unless they were already lying down
			lying_is_intentional = FALSE
			canmove = !MOB_IS_INCAPACITATED(INCAPACITATION_KNOCKOUT) && !weakened
		else if(!HAS_TRAIT(src, TRAIT_FORCED_STANDING))
			lying = resting || is_dead() || MOB_IS_INCAPACITATED(INCAPACITATION_KNOCKDOWN) && !recently_slept
			lying_is_intentional = FALSE
			canmove = !MOB_IS_INCAPACITATED(INCAPACITATION_KNOCKOUT) && !weakened

	if(lying)
		ADD_TRAIT(src, TRAIT_UNDENSE, TRAIT_SOURCE_LYING_DOWN)
		if(!lying_is_intentional)
			if(l_hand) unEquip(l_hand)
			if(r_hand) unEquip(r_hand)
	else
		REMOVE_TRAIT(src, TRAIT_UNDENSE, TRAIT_SOURCE_LYING_DOWN)

	for(var/obj/item/grab/G in grabbed_by)
		if(G.wielded)
			canmove = FALSE
			lying = TRUE
			break
		if(G.state >= GRAB_AGGRESSIVE)
			canmove = 0
			break

	//Temporarily moved here from the various life() procs
	//I'm fixing stuff incrementally so this will likely find a better home.
	//It just makes sense for now. ~Carn
	if( update_icon )	//forces a full overlay update
		update_icon = 0
		regenerate_icons()
	else if( lying != lying_prev )
		update_icon()

	return canmove
