/atom/Initialize(mapload, ...)
	. = ..()
	if(uses_integrity)
		if(islist(subarmor))
			subarmor = getSubarmor(arglist(subarmor))
		else if(!subarmor)
			subarmor = getSubarmor()
		else if(!istype(subarmor, /datum/subarmor))
			stack_trace("Invalid type [subarmor.type] found in .subarmor during /atom Initialize()")

/atom

	///any atom that uses integrity and can be damaged must set this to true, otherwise the integrity procs will throw an error
	var/uses_integrity = FALSE

	var/datum/armor/armor
	VAR_PRIVATE/atom_integrity //defaults to max_integrity
	var/max_integrity = 500
	var/integrity_failure = 0 //0 if we have no special broken behavior, otherwise is a percentage of at what point the atom breaks. 0.5 being 50%
	///Damage under this value will be completely ignored
	var/damage_deflection = 0

	var/resistance_flags = NONE // INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ON_FIRE | UNACIDABLE | ACID_PROOF
