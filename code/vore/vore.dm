
/*
VVVVVVVV           VVVVVVVV     OOOOOOOOO     RRRRRRRRRRRRRRRRR   EEEEEEEEEEEEEEEEEEEEEE
V::::::V           V::::::V   OO:::::::::OO   R::::::::::::::::R  E::::::::::::::::::::E
V::::::V           V::::::V OO:::::::::::::OO R::::::RRRRRR:::::R E::::::::::::::::::::E
V::::::V           V::::::VO:::::::OOO:::::::ORR:::::R     R:::::REE::::::EEEEEEEEE::::E
 V:::::V           V:::::V O::::::O   O::::::O  R::::R     R:::::R  E:::::E       EEEEEE
  V:::::V         V:::::V  O:::::O     O:::::O  R::::R     R:::::R  E:::::E
   V:::::V       V:::::V   O:::::O     O:::::O  R::::RRRRRR:::::R   E::::::EEEEEEEEEE
    V:::::V     V:::::V    O:::::O     O:::::O  R:::::::::::::RR    E:::::::::::::::E
     V:::::V   V:::::V     O:::::O     O:::::O  R::::RRRRRR:::::R   E:::::::::::::::E
      V:::::V V:::::V      O:::::O     O:::::O  R::::R     R:::::R  E::::::EEEEEEEEEE
       V:::::V:::::V       O:::::O     O:::::O  R::::R     R:::::R  E:::::E
        V:::::::::V        O::::::O   O::::::O  R::::R     R:::::R  E:::::E       EEEEEE
         V:::::::V         O:::::::OOO:::::::ORR:::::R     R:::::REE::::::EEEEEEEE:::::E
          V:::::V           OO:::::::::::::OO R::::::R     R:::::RE::::::::::::::::::::E
           V:::V              OO:::::::::OO   R::::::R     R:::::RE::::::::::::::::::::E
            VVV                 OOOOOOOOO     RRRRRRRR     RRRRRRREEEEEEEEEEEEEEEEEEEEEE

-Aro <3 */

// Cross-defined vars to keep vore code isolated. //Somewhat. -Aro
/mob/living
	var/digestable = 1					// Can the mob be digested inside a belly?
	var/datum/belly/vore_selected		// Default to no vore capability.
	var/list/vore_organs = list()		// List of vore containers inside a mob
//	var/absorbed = 0					// If a mob is absorbed into another

/mob/living/simple_animal
	var/isPredator = 0 					//Are they capable of performing and pre-defined vore actions for their species?
	var/swallowTime = 30 				//How long it takes to eat its prey in 1/10 of a second. The default is 3 seconds.
	var/backoffTime = 50 				//How long to exclude an escaped mob from being re-eaten.
	var/gurgleTime = 600				//How long between stomach emotes at prey
	var/list/prey_excludes = list()		//For excluding people from being eaten.

	//We have some default emotes for mobs to do to their prey.
	var/list/stomach_emotes = list(
									"The insides knead at you gently for a moment.",
									"The guts glorp wetly around you as some air shifts.",
									"Your predator takes a deep breath and sighs, shifting you somewhat.",
									"The stomach squeezes you tight for a moment, then relaxes.",
									"During a moment of quiet, breathing becomes the most audible thing.",
									"The warm slickness surrounds and kneads on you.")
	var/list/stomach_emotes_d = list(
									"The caustic acids eat away at your form.",
									"The acrid air burns at your lungs.",
									"Without a thought for you, the stomach grinds inwards painfully.",
									"The guts treat you like food, squeezing to press more acids against you.",
									"The onslaught against your body doesn't seem to be letting up; you're food now.",
									"The insides work on you like they would any other food.")
	var/list/digest_emotes = list()		//To send when digestion finishes

/mob/living/simple_animal/verb/toggle_digestion()
	set name = "Toggle Animal's Digestion"
	set desc = "Enables digestion on this mob for 20 minutes."
	set category = "Vore"
	set src in oview(1)

	var/datum/belly/B = vore_organs[vore_selected]

	if(B.digest_mode == "Hold")
		var/confirm = alert(usr, "Enabling digestion on [name] will cause it to digest all stomach contents. Using this to break OOC prefs is against the rules. Digestion will disable itself after 20 minutes.", "Enabling [name]'s Digestion", "Enable", "Cancel")
		if(confirm == "Enable")
			B.digest_mode = "Digest"
			spawn(12000) //12000=20 minutes
				if(src)	B.digest_mode = "Hold"
	else
		var/confirm = alert(usr, "This mob is currently set to digest all stomach contents. Do you want to disable this?", "Disabling [name]'s Digestion", "Disable", "Cancel")
		if(confirm == "Disable")
			B.digest_mode = "Hold"

// Simple animal nom proc for if you get ckey'd into a simple_animal mob!
// Should be fine? Doesn't require grabbing.
/mob/living/proc/animal_nom(var/mob/living/T in oview(1))
	set name = "Animal Nom"
	set category = "Vore"
	set desc = "Since you can't grab, you get a verb!"

	feed_grabbed_to_self(src,T)

//	This is an "interface" type.  No instances of this type will exist, but any type which is supposed
//  to be vore capable should implement the vars and procs defined here to be vore-compatible!
/vore/pred_capable
	var/list/vore_organs
	var/datum/voretype/vorifice

//
//	Check if an object is capable of eating things.
//	For now this is just simple_animals and carbons
//
/proc/is_vore_predator(var/mob/living/O)
	if(istype(O,/mob/living))
		if(O.vore_organs.len > 0)
			return 1

	return 0
//
//	Verb for toggling which orifice you eat people with!
//
/mob/living/proc/belly_select()
	set name = "Choose Belly"
	set category = "Vore"

	vore_selected = input("Choose Belly") in vore_organs
	src << "<span class='notice'>[vore_selected] selected.</span>"

//
//	Verb for saving vore preferences to save file
//
/mob/living/proc/save_vore_prefs()
	set name = "Save Vore Prefs"
	set category = "Vore"

	var/result = 0

	if(client.prefs)
		result = client.prefs.save_vore_preferences()
	else
		src << "<span class='warning'>You attempted to save your vore prefs but somehow you're in this character without a client.prefs variable. Tell a dev.</span>"
		log_admin("[src] tried to save vore prefs but lacks a client.prefs var.")

	return result

//
//	Proc for applying vore preferences, given bellies
//
/mob/living/proc/apply_vore_prefs(var/list/bellies)
	if(!bellies || bellies.len == 0)
		log_admin("Tried to apply bellies to [src] and failed.")


//
//	Proc for updating vore organs and digestion/healing/absorbing
//
/mob/living/proc/handle_internal_contents()
	for (var/bellytype in vore_organs)
		var/datum/belly/B = vore_organs[bellytype]
		for(var/atom/movable/M in B.internal_contents)
			if(M.loc != src)
				B.internal_contents -= M
				log_admin("Had to remove [M] from belly [B] in [src]")
		B.process_Life()

//
//	Verb for toggling which orifice you eat people with!
// VTODO: Make this part of the inside panel (or whatever) instead
/mob/living/proc/vore_release()
	set name = "Release"
	set category = "Vore"
	var/release_organ = input("Choose Belly") in vore_organs

	if(release_organ) //Sanity
		var/datum/belly/belly = vore_organs[release_organ]
		if (belly.release_all_contents())
			visible_message("<font color='green'><b>[src] releases the contents of their [lowertext(belly)]!</b></font>")
			playsound(loc, 'sound/effects/splat.ogg', 50, 1)

/mob/living/proc/toggle_digestability()
	set name = "Toggle digestability"
	set category = "Vore"

	if(alert(src, "This button will make you undigestable.", "", "Okay", "Cancel") == "Okay")
		digestable = !digestable
		usr << "<span class='alert'>You are [digestable ?  "now" : "no longer"] digestable.</span>"
	//	message_admins("[key_name(src)] toggled their digestability to [digestable] ([loc ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>JMP</a>" : "null"])")
		if(client.prefs)
			client.prefs.digestable = digestable

/mob/living/proc/escapeOOC()
	set name = "OOC escape"
	set category = "Vore"

	//You're in an animal!
	if(istype(src.loc,/mob/living/simple_animal))
		var/mob/living/simple_animal/pred = src.loc
		var/confirm = alert(src, "You're in a mob. This is for being unable to escape from said mob.", "Confirmation", "Okay", "Cancel")
		if(confirm == "Okay")
			for(var/I in pred.vore_organs)
				var/datum/belly/B = pred.vore_organs[I]
				B.release_specific_contents(src)

	/*		for(var/mob/living/simple_animal/SA in range(10))
				SA.prey_exclusions += src
				spawn(18000)
					if(src && SA)
						SA.prey_exclusions -= src
	*/ //You're in a PC!
/*	else if(istype(src.loc,/mob/living))
		var/mob/living/carbon/pred = src.loc
		var/confirm = alert(src, "You're in a player-character. This is for escaping from preference-breaking and if your predator disconnects/AFKs. If you are in more than one pred, use this more than once. If your preferences were being broken, please admin-help as well.", "Confirmation", "Okay", "Cancel")
		if(confirm == "Okay")
			for(var/O in pred.vore_organs)
				var/datum/belly/CB = pred.vore_organs[O]
				CB.release_specific_contents(src)
			message_admins("[key_name(src)] used the OOC escape button to get out of [key_name(pred)] (PC) ([pred ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[pred.x];Y=[pred.y];Z=[pred.z]'>JMP</a>" : "null"])")

	//You're in a dogborg!
	else if(istype(src.loc, /obj/item/device/dogborg/sleeper))
		var/mob/living/silicon/pred = src.loc.loc //Thing holding the belly!
		var/obj/item/device/dogborg/sleeper/belly = src.loc //The belly!

		var/confirm = alert(src, "You're in a dogborg sleeper. This is for escaping from preference-breaking and if your predator disconnects/AFKs. If your preferences were being broken, please admin-help as well.", "Confirmation", "Okay", "Cancel")
		if(confirm == "Okay")
			message_admins("[key_name(src)] used the OOC escape button to get out of [key_name(pred)] (BORG) ([pred ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[pred.x];Y=[pred.y];Z=[pred.z]'>JMP</a>" : "null"])")
			belly.go_out(src) //Just force-ejects from the borg as if they'd clicked the eject button.
*/
			/* Use native code to avoid leaving vars all set wrong on the borg
			forceMove(get_turf(src)) //Since they're not in a vore organ, you can't eject them "normally"
			reset_view() //This will kick them out of the borg's stomach sleeper in case the borg goes AFK or whatnot.
			message_admins("[key_name(src)] used the OOC escape button to get out of a cyborg..") //Not much information,
			*/
	else
		src << "<span class='alert'>You aren't inside anyone, you clod.</span>"





///
/// Actual eating procs
///

/mob/living/proc/feed_grabbed_to_self(var/mob/living/user, var/mob/living/prey)
	var/belly = user.vore_selected
	return perform_the_nom(user, prey, user, belly)
/*
/mob/living/proc/eat_held_mob(var/mob/living/user, var/mob/living/prey, var/mob/living/pred)
	var/belly
	if(user != pred)
		belly = input("Choose Belly") in pred.vore_organs
	else
		belly = pred.vore_selected
	return perform_the_nom(user, prey, pred, belly)
*/
/mob/living/proc/feed_self_to_grabbed(var/mob/living/user, var/mob/living/pred)
	var/belly = input("Choose Belly") in pred.vore_organs
	return perform_the_nom(user, user, pred, belly)

/mob/living/proc/feed_grabbed_to_other(var/mob/living/user, var/mob/living/prey, var/mob/living/pred)
	var/belly = input("Choose Belly") in pred.vore_organs
	return perform_the_nom(user, prey, pred, belly)

/mob/living/proc/perform_the_nom(var/mob/living/user, var/mob/living/prey, var/mob/living/pred, var/belly)
	//Sanity
	if(!user || !prey || !pred || !belly || !(belly in pred.vore_organs))
		log_admin("[user] attempted to feed [prey] to [pred], via [belly] but it went wrong.")
		return

	// The belly selected at the time of noms
	var/datum/belly/belly_target = pred.vore_organs[belly]
	var/attempt_msg = "ERROR: Vore message couldn't be created. Notify a dev. (at)"
	var/success_msg = "ERROR: Vore message couldn't be created. Notify a dev. (sc)"

	// Prepare messages
	if(user == pred) //Feeding someone to yourself
		attempt_msg = text("<span class='warning'>[] is attemping to [] [] into their []!</span>",pred,belly_target.vore_verb,prey,lowertext(belly_target))
		success_msg = text("<span class='warning'>[] manages to [] [] into their []!</span>",pred,belly_target.vore_verb,prey,lowertext(belly_target))
	else //Feeding someone to another person
		attempt_msg = text("<span class='warning'>[] is attempting to make [] [] [] into their []!</span>",user,pred,belly_target.vore_verb,prey,lowertext(belly_target))
		success_msg = text("<span class='warning'>[] manages to make [] [] [] into their []!</span>",user,pred,belly_target.vore_verb,prey,lowertext(belly_target))

	// Announce that we start the attempt!
	for (var/mob/O in get_hearers_in_view(6, user))
		O.show_message(attempt_msg)

	// Now give the prey time to escape... return if they did
	var/swallow_time = istype(prey, /mob/living/carbon/human) ? belly_target.human_prey_swallow_time : belly_target.nonhuman_prey_swallow_time
	if (!do_mob(user, prey))
		return 0; // User is not able to act upon prey
	if(!do_after(user, swallow_time))
		return 0 // Prey escpaed (or user disabled) before timer expired.

	// If we got this far, nom successful! Announce it!
	for (var/mob/O in get_hearers_in_view(6, user))
		O.show_message(success_msg)

	playsound(user, belly_target.vore_sound, 100, 1)

	// Actually shove prey into the belly.
	belly_target.nom_mob(prey, user)

	// Inform Admins

	if (pred == user)
		message_admins("[key_name(pred)] ate [key_name(prey)]. ([pred ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[pred.x];Y=[pred.y];Z=[pred.z]'>JMP</a>" : "null"])")
		log_attack("[key_name(pred)] ate [key_name(prey)]")
	else if (prey == !client && stat != DEAD)
		message_admins("[key_name(pred)] ate [key_name(prey)] (braindead) ([pred ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[pred.x];Y=[pred.y];Z=[pred.z]'>JMP</a>" : "null"])")
		log_attack("[key_name(pred)] ate [key_name(prey)] (braindead)")
	else
		message_admins("[key_name(user)] forced [key_name(pred)] to eat [key_name(prey)]. ([pred ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[pred.x];Y=[pred.y];Z=[pred.z]'>JMP</a>" : "null"])")
		log_attack("[key_name(user)] forced [key_name(pred)] to eat [key_name(prey)].")
	return 1