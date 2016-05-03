/atom/movable/proc/vore_host()
	return src

/obj/vore_module/vore_host()
	return loc


/atom/movable/proc/CanUseTopic(var/mob/user, href_list, var/datum/vtopic_state/custom_state)
	return user.can_use_vtopic(vore_host(), custom_state)


/mob/proc/can_use_vtopic(var/mob/user, var/datum/vtopic_state/custom_state)
	return VSTATUS_CLOSE // By default no mob can do anything with voreUI

/mob/dead/observer/can_use_vtopic()
	if(check_rights(R_ADMIN, 0, src))
		return VSTATUS_INTERACTIVE				// Admins are more equal
	return VSTATUS_UPDATE						// Ghosts can view updates

/mob/living/proc/shared_living_vore_interaction(var/src_object)
	if (src.stat != CONSCIOUS)
		return VSTATUS_CLOSE						// no updates, close the interface
	else if (restrained() || lying || stat || stunned || weakened)
		return VSTATUS_UPDATE					// update only (orange visibility)
	return VSTATUS_INTERACTIVE

//Some atoms such as vehicles might have special rules for how mobs inside them interact with voreUI.
/atom/proc/contents_vore_distance(var/src_object, var/mob/living/user)
	return user.shared_living_vore_distance(src_object)

/mob/living/proc/shared_living_vore_distance(var/atom/movable/src_object)
	if(!isturf(src_object.loc))
		if(src_object.loc == src)				// Item in the inventory
			return VSTATUS_INTERACTIVE
		if(src.contents.Find(src_object.loc))	// A hidden uplink inside an item
			return VSTATUS_INTERACTIVE

	if (!(src_object in view(4, src))) 	// If the src object is not in visable, disable updates
		return VSTATUS_CLOSE

	var/dist = get_dist(src_object, src)
	if (dist <= 1)
		return VSTATUS_INTERACTIVE	// interactive (green visibility)
	else if (dist <= 2)
		return VSTATUS_UPDATE 		// update only (orange visibility)
	else if (dist <= 4)
		return VSTATUS_DISABLED 		// no updates, completely disabled (red visibility)
	return VSTATUS_CLOSE

/mob/living/can_use_vtopic(var/src_object, var/datum/vtopic_state/custom_state)
	. = shared_living_vore_interaction(src_object)
	if(. == VSTATUS_INTERACTIVE && !(custom_state.flags & NANO_IGNORE_DISTANCE))
		if(loc)
			. = loc.contents_vore_distance(src_object, src)
		else
			. = shared_living_vore_distance(src_object)
	if(VSTATUS_INTERACTIVE)
		return VSTATUS_UPDATE

/mob/living/carbon/human/can_use_vtopic(var/src_object, var/datum/vtopic_state/custom_state)
	. = shared_living_vore_interaction(src_object)
	if(. == VSTATUS_INTERACTIVE && !(custom_state.flags & NANO_IGNORE_DISTANCE))
		. = shared_living_vore_distance(src_object)

/var/global/datum/vtopic_state/default_vstate = new()

/datum/vtopic_state
	var/flags = 0

/datum/vtopic_state/proc/href_list(var/mob/user)
	return list()