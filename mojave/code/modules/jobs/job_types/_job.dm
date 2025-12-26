/datum/job
	var/forbid = ""
	var/enforce = ""
	var/stats_type = /datum/stats
	var/display_order = 0
	var/description = ""

/datum/job/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	spawned.stats = new stats_type(spawned)
	if(ishuman(spawned))
		try_open_job_info(spawned, player_client)

/datum/job/proc/try_open_job_info(mob/living/carbon/human/spawned, client/player_client)
	if(!player_client)
		return
	spawned.open_job_info()

/datum/job/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "JobInfo", title)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/job/ui_state(mob/user)
	return GLOB.always_state

/datum/job/ui_static_data(mob/user)
	var/list/data = list()

	data["title"] = title
	data["description"] = description
	data["supervisors"] = supervisors
	data["forbid"] = forbid
	data["enforce"] = enforce

	return data

/proc/cmp_job_display_asc(datum/job/A, datum/job/B)
	return A.display_order - B.display_order

/proc/cmp_department_display_asc(datum/job_department/A, datum/job_department/B)
	return A.display_order - B.display_order

#warn description and display_order are not connected to anything
