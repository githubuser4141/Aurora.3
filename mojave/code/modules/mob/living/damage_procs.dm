/mob/living/proc/adjustOrganLoss(slot, amount, maximum)
	return

/mob/living/proc/setOrganLoss(slot, amount, maximum)
	return

/mob/living/proc/getOrganLoss(slot)
	return

/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/adjustStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	return

/mob/living/proc/setStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	return

//cabron

/mob/living/carbon/adjustStaminaLoss(amount)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(amount > 0 && stamina < 100)
		stamina -= amount
	else
		stamina += amount
	return amount

/mob/living/carbon/setStaminaLoss(amount)
	var/current = stamina
	var/diff = amount - current
	if(!diff)
		return
	adjustStaminaLoss(diff)
