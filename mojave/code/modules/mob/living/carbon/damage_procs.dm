/**
 * If an organ exists in the slot requested, and we are capable of taking damage (we don't have [GODMODE] on), call the damage proc on that organ.
 *
 * Arguments:
 * * slot - organ slot, like [ORGAN_SLOT_HEART]
 * * amount - damage to be done
 * * maximum - currently an arbitrarily large number, can be set so as to limit damage
 */
/mob/living/carbon/adjustOrganLoss(slot, amount, maximum)
	var/obj/item/organ/O = getorganslot(slot)
	if(O && !(status_flags & GODMODE))
		O.applyOrganDamage(amount, maximum)

/**
 * If an organ exists in the slot requested, and we are capable of taking damage (we don't have [GODMODE] on), call the set damage proc on that organ, which can
 * set or clear the failing variable on that organ, making it either cease or start functions again, unlike adjustOrganLoss.
 *
 * Arguments:
 * * slot - organ slot, like [ORGAN_SLOT_HEART]
 * * amount - damage to be set to
 */
/mob/living/carbon/setOrganLoss(slot, amount)
	var/obj/item/organ/O = getorganslot(slot)
	if(O && !(status_flags & GODMODE))
		O.setOrganDamage(amount)

/**
 * If an organ exists in the slot requested, return the amount of damage that organ has
 *
 * Arguments:
 * * slot - organ slot, like [ORGAN_SLOT_HEART]
 */
/mob/living/carbon/getOrganLoss(slot)
	var/obj/item/organ/O = getorganslot(slot)
	if(O)
		return O.damage
