//
//	Type storing data/procs about the ways you can eat someone!
//

/datum/voretype
	var/name
	var/belly_target = "Stomach"	// Which belly does this voretype lead you to?
	var/human_prey_swallow_time = 100  // Humans get 100 ticks to escape by default
	var/nonhuman_prey_swallow_time = 30 // Others get only 30 ticks.

//
// Note: There are currently four ways to eat somone in VIRGO, via two main methods.
//
//	A) A micro holder in your hand can be fed to yourself or another.
//	B) A grabbed mob (aggressive or higher) can...
//		i) Be fed to yourself
//		ii) Be fed to someone else
//		iii) You can feed yourself to it!
//

/datum/voretype/proc/eat_held_mob(var/mob/user, var/mob/living/prey, var/mob/living/pred)
	return

/datum/voretype/proc/feed_self_to_grabbed(var/mob/living/carbon/human/user, var/vore/pred_capable/pred)
	return

/datum/voretype/proc/feed_grabbed_to_self(var/mob/living/carbon/human/user, var/mob/prey)
	return

/datum/voretype/proc/feed_grabbed_to_other(var/mob/living/carbon/human/user, var/mob/prey, var/vore/pred_capable/pred)
	return

//
// Method to actually execute the nomming and print the messages!
// This method removes duplicate code by consolidating the shared pieces.
// However, if any particular vore type whishes to do its own thing, simply don't call this method (or override it!)
//
/datum/voretype/proc/perform_the_nom(var/mob/user, var/mob/living/prey, var/vore/pred_capable/pred, attempt_msg, success_msg, sound)
	// Announce that we start the attempt!
	//user.visible_message(attempt_msg) //Doesn't work for micros and people in people

	for (var/mob/O in get_hearers_in_view(7, src))
		O << ("[attempt_msg]")

	// Now give the prey time to escape... return if they did
	var/swallow_time = istype(prey, /mob/living/carbon/human) ? human_prey_swallow_time : nonhuman_prey_swallow_time
	if (!do_mob(user, prey))
		return 0; // User is not able to act upon prey
	if(!do_after(user, swallow_time))
		return 0 // Prey escpaed (or user disabled) before timer expired.

	// If we got this far, nom successful! Announce it!
	for (var/mob/O in get_hearers_in_view(7, src))
		O << ("[success_msg]")

	//user.visible_message(success_msg) //Doesn't work for micros and people in people
	playsound(user, sound, 100, 1)

	// Actually shove prey into the belly.
	var/datum/belly/target_belly = pred.internal_contents[belly_target]
	target_belly.nom_mob(prey, user)

	// Inform Admins
	if (pred == user)
		log_attack("[key_name(pred)] [name]'d [key_name(prey)]")
		vore_admins("[key_name(pred)] [name]'d [key_name(prey)]")
	else
		log_attack("[key_name(user)] forced [key_name(pred)] to [name] [key_name(prey)]")
		vore_admins("[key_name(pred)] [name]'d [key_name(prey)]")
	return 1

// TODO LESHANA - This needs to be done much better in a cleaner way.
// This is a performance enhancement, single voretypes are immutable we don't need
// separate instances for every mob, they can share singleton instances.

var/list/SINGLETON_VORETYPE_INSTANCES = list(
		"Oral Vore" = new /datum/voretype/oral(),
		"Unbirth" = new /datum/voretype/unbirth(),
		"Anal Vore" = new /datum/voretype/anal(),
		"Cock Vore" = new /datum/voretype/cock(),
		"Breast Vore" = new /datum/voretype/boobs(),
		"Tail Vore" = new /datum/voretype/tail())