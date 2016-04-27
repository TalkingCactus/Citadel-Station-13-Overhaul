
// Cross-defined vars to keep vore code isolated.

/mob/living
	var/digestable = 1					//Can the mob be digested inside a belly?
	var/datum/voretype/vorifice = null	// Default to no vore capability.

	var/vore_banned_methods=0

	// TODO - Rename this! It is too conflicty with belly.internal_contents
	var/list/internal_contents = list()

/mob/living/simple_animal
	var/isPredator = 0 					//Are they capable of performing and pre-defined vore actions for their species?
	var/swallowTime = 30 				//How long it takes to eat its prey in 1/10 of a second. The default is 3 seconds.
	var/backoffTime = 50 				//How long to exclude an escaped mob from being re-eaten.
	var/gurgleTime = 600				//How long between stomach emotes at prey
	var/datum/belly/insides				//The place where food goes. Just one on mobs.
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

	if(insides.digest_mode == "Hold")
		var/confirm = alert(usr, "Enabling digestion on [name] will cause it to digest all stomach contents. Using this to break OOC prefs is against the rules. Digestion will disable itself after 20 minutes.", "Enabling [name]'s Digestion", "Enable", "Cancel")
		if(confirm == "Enable")
			insides.digest_mode = "Digest"
			spawn(12000) //12000=20 minutes
				if(src)	insides.digest_mode = "Hold"
	else
		var/confirm = alert(usr, "This mob is currently set to digest all stomach contents. Do you want to disable this?", "Disabling [name]'s Digestion", "Disable", "Cancel")
		if(confirm == "Disable")
			insides.digest_mode = "Hold"

//	This is an "interface" type.  No instances of this type will exist, but any type which is supposed
//  to be vore capable should implement the vars and procs defined here to be vore-compatible!
/vore/pred_capable
	var/list/internal_contents
	var/datum/voretype/vorifice

//
//	Check if an object is capable of eating things.
//	For now this is just simple_animals and carbons
//
/proc/is_vore_predator(var/mob/O)
	return (O != null && (istype(O, /mob/living/simple_animal) || istype(O, /mob/living/carbon)) && O:vorifice)

//
//	Verb for toggling which orifice you eat people with!
//
/mob/living/carbon/human/proc/orifice_toggle()
	set name = "Choose Vore Mode"
	set category = "Vore"

	var/type = input("Choose Vore Mode") in list("Oral Vore", "Unbirth", "Anal Vore", "Cock Vore", "Breast Vore", "Tail Vore")
	// This is hard coded for now, but should be fixed later!
	vorifice = SINGLETON_VORETYPE_INSTANCES[type];

	// TODO LESHANA - This is bad!
	// Vorifice objects have no member vars, so are effectively immutable!
	// Given this, we shouldn't be creating new instances for every mob!  Instead we should have global singletons.
	// TODO - Implement this.  even better would be function pointers, but eh.
	src << "<span class='notice'>[vorifice.name] selected.</span>"

/mob/living/carbon/human/proc/vore_release()
	set name = "Release"
	set category = "Vore"
	var/releaseorifice = input("Choose Orifice") in list("Stomach (by Mouth)", "Stomach (by Anus)", "Womb", "Cock", "Breasts", "Tail", "Absorbed")

	// TODO LESHANA - This should all be refactored into procs on voretype that are overriden...
	switch(releaseorifice)
		if("Stomach (by Mouth)")
			var/datum/belly/belly = internal_contents["Stomach"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] hurls out the contents of their stomach!</b></font>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

		if("Stomach (by Anus)")
			var/datum/belly/belly = internal_contents["Stomach"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] releases their stomach contents out of their rear!</b></font>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

		if("Womb")
			var/datum/belly/belly = internal_contents["Womb"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] gushes out the contents of their womb!</b></font>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)
			else if (belly.is_full)
				belly.is_full = 0
				visible_message("<span class='danger'>[src] gushes out a puddle of liquid from their folds!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

		if("Cock")
			var/datum/belly/belly = internal_contents["Cock"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] splurts out the contents of their cock!</b></font>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)
			else if (belly.is_full)
				belly.is_full = 0
				visible_message("<span class='danger'>[src] gushes out a puddle of cum from their cock!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

		if("Breasts")
			var/datum/belly/belly = internal_contents["Boob"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] squirts out the contents of their breasts!</b></font>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)
			else if(belly.is_full)
				belly.is_full = 0
				visible_message("<span class='danger'>[src] squirts out a puddle of milk from their breasts!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		if("Tail")
			var/datum/belly/belly = internal_contents["Tail"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] releases a few things from their tail!</b></font>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)
			else if (belly.is_full)
				belly.is_full = 0
				visible_message("<span class='danger'>[src] releases a few things from their tail!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

		if("Absorbed")
			var/datum/belly/belly = internal_contents["Absorbed"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] releases something from ther body!</b></font>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)
			else if (belly.is_full)
				belly.is_full = 0
				visible_message("<span class='danger'>[src] releases something from their body!</span>") //They should never see this. Can't digest someone in you.
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

/////////////////////////////
////   OOC Escape Code	 ////
/////////////////////////////

/mob/living/proc/escapeOOC()
	set name = "OOC escape"
	set category = "Vore"

	//You're in an animal!
	if(istype(src.loc,/mob/living/simple_animal))
		var/mob/living/simple_animal/pred = src.loc
		var/confirm = alert(src, "You're in a mob and don't want to be?", "Confirmation", "Okay", "Cancel")
		if(confirm == "Okay")
			pred.prey_excludes += src
			spawn(pred.backoffTime)
				if(pred)	pred.prey_excludes -= src
			pred.insides.release_specific_contents(src)
			message_admins("[key_name(src)] used the OOC escape button to get out of [key_name(pred)] (MOB) ([pred ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[pred.x];Y=[pred.y];Z=[pred.z]'>JMP</a>" : "null"])")
/*
	//You're in a PC!
	else if(istype(src.loc,/mob/living/carbon))
		var/mob/living/carbon/pred = src.loc
		var/confirm = alert(src, "You're in a player-character. This is for escaping from preference-breaking and if your predator disconnects/AFKs. If you are in more than one pred, use this more than once. If your preferences were being broken, please admin-help as well.", "Confirmation", "Okay", "Cancel")
		if(confirm == "Okay")
			for(var/O in pred.internal_contents)
				var/datum/belly/CB = pred.internal_contents[O]
				CB.release_specific_contents(src)
			message_admins("[key_name(src)] used the OOC escape button to get out of [key_name(pred)] (PC) ([pred ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[pred.x];Y=[pred.y];Z=[pred.z]'>JMP</a>" : "null"])")

	//You're in a dogborg!
	else if(istype(src.loc, /obj/item/device/dogborg/sleeper))
		var/mob/living/silicon/pred = src.loc.loc //Thing holding the belly!
		var/obj/item/device/dogborg/sleeper/belly = src.loc //The belly!

		var/confirm = alert(src, "You're in a player-character cyborg. This is for escaping from preference-breaking and if your predator disconnects/AFKs. If your preferences were being broken, please admin-help as well.", "Confirmation", "Okay", "Cancel")
		if(confirm == "Okay")
			message_admins("[key_name(src)] used the OOC escape button to get out of [key_name(pred)] (BORG) ([pred ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[pred.x];Y=[pred.y];Z=[pred.z]'>JMP</a>" : "null"])")
			belly.go_out() //Just force-ejects from the borg as if they'd clicked the eject button.

			/* Use native code to avoid leaving vars all set wrong on the borg
			forceMove(get_turf(src)) //Since they're not in a vore organ, you can't eject them "normally"
			reset_view() //This will kick them out of the borg's stomach sleeper in case the borg goes AFK or whatnot.
			message_admins("[key_name(src)] used the OOC escape button to get out of a cyborg..") //Not much information,
			*/ */
	else
		src << "<span class='alert'>You aren't inside anyone, you clod.</span>"

/////////////////////////
///    Vore Toggles   ///
/////////////////////////

//Makeshift vore toggles

/*

/mob/living/proc/set_vore_abil()
	set name = "Enable Vore Ability"
	set category = "Vore"
	var/selection = input("People will be able to feed you, and it will be an option to you on other menus.") in list("Cancel", "Anal", "Cock", "Unbirth")
	if(selection=="Cancel")return
	if(selection=="Anal")
		vore_possible_methods |= VORE_METHOD_ANAL
	if(selection=="Cock")
		vore_possible_methods |= VORE_METHOD_COCK
	if(selection=="Unbirth")
		vore_possible_methods |= VORE_METHOD_UNBIRTH
	if(selection=="Breast")
		vore_possible_methods |= VORE_METHOD_BREAST
	if(selection=="Tail")
		vore_possible_methods |= VORE_METHOD_TAIL
	src << "[selection] added."

/mob/living/proc/set_vore_debil()
	set name = "Disable Vore Ability"
	set category = "Vore"
	var/selection = input("Will prevent you from devouring people this way.") in list("Cancel", "Anal", "Cock", "Unbirth")
	if(selection=="Cancel")return
	if(selection=="Anal")
		vore_possible_methods &= ~VORE_METHOD_ANAL
	if(selection=="Cock")
		vore_possible_methods &= ~VORE_METHOD_COCK
	if(selection=="Unbirth")
		vore_possible_methods &= ~VORE_METHOD_UNBIRTH
	if(selection=="Breast")
		vore_banned_methods &= ~VORE_METHOD_BREAST
	if(selection=="Tail")
		vore_banned_methods &= ~VORE_METHOD_TAIL
	src << "[selection] removed."



/mob/living/proc/set_vore_mode()
	set name = "Change Vore Mode"
	set category = "Vore"
	var/selection = input("Set the type of vore used when eating or feeding others.") in list("Oral", "Anal", "Cock", "Unbirth", "Put in Shoe", "Place under suit")
	if(selection=="Oral")
		vore_current_method = VORE_METHOD_ORAL
	if(selection=="Anal")
		vore_current_method = VORE_METHOD_ANAL
	if(selection=="Cock")
		vore_current_method = VORE_METHOD_COCK
	if(selection=="Unbirth")
		vore_current_method = VORE_METHOD_UNBIRTH
	if(selection=="Put in Shoe")
		vore_current_method = VORE_METHOD_INSOLE
	if(selection=="Place under suit")
		vore_current_method = VORE_METHOD_INSUIT
		src << "(Not really much of a vore method, but, gotta put it in the debug panel.)"
	src << "[selection] is your current vore type."
	if(!(src.vore_possible_methods&vore_current_method))
		src<<"Note: You do not have this vore type enabled for yourself. This will only work when feeding people."


/mob/living/proc/set_vore_ban()
	set name = "Ban Vore Type"
	set category = "Vore"
	var/selection = input("People will not be able to engage you in this type, and will instead orally vore.") in list("Cancel", "Anal", "Cock", "Unbirth", "Breast", "Tail")
	if(selection=="Anal")
		vore_banned_methods |= VORE_METHOD_ANAL
	if(selection=="Cock")
		vore_banned_methods |= VORE_METHOD_COCK
	if(selection=="Unbirth")
		vore_banned_methods |= VORE_METHOD_UNBIRTH
	if(selection=="Breast")
		vore_banned_methods |= VORE_METHOD_BREAST
	if(selection=="Tail")
		vore_banned_methods |= VORE_METHOD_TAIL
	src << "[selection] banned."

/mob/living/proc/set_vore_unban()
	set name = "Unban Vore Type"
	set category = "Vore"
	if(!src.vore_banned_methods)
		src<<"No banned vore methods."
		return
	var/selection = input("People will be able to engage you in this type of vore again.") in list("Cancel", "Anal", "Cock", "Unbirth", "Breast", "Tail")
	if(selection=="Anal")
		vore_banned_methods &= ~VORE_METHOD_ANAL
	if(selection=="Cock")
		vore_banned_methods &= ~VORE_METHOD_COCK
	if(selection=="Unbirth")
		vore_banned_methods &= ~VORE_METHOD_UNBIRTH
	if(selection=="Breast")
		vore_banned_methods &= ~VORE_METHOD_BREAST
	if(selection=="Tail")
		vore_banned_methods &= ~VORE_METHOD_TAIL
	src << "[selection] unbanned." */

/mob/living/proc/set_vore_digest()
	set name = "Digestion Toggle"
	set category = "Vore"
	var/type = input("Toggle Digestion") in list("Stomach", "Womb", "Cock", "Breast", "Tail")
	var/datum/belly/B = internal_contents[type]
	B.toggle_digestion()
/*
/mob/living/proc/underwear_toggle()
	set name = "Force Update"
	set category = "Vore"
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/humz=src
		humz.underwear_active=!humz.underwear_active
		//updateappearance(src)
		src.update_body()
	else
		src<<"Humans only."
*/

/mob/living/carbon/human/proc/I_am_not_mad()
	set name = "Toggle digestability"
	set category = "Vore"

	if(alert(src, "This button is for those who don't like being digested. It will make you undigestable. Don't abuse. Note that this cannot be toggled inside someone's belly.", "", "Okay", "Cancel") == "Okay")
		digestable = !digestable
		usr << "<span class='alert'>You are [digestable ?  "now" : "no longer"] digestable.</span>"

/proc/vore_admins(var/msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">VORE LOG:</span> <span class=\"message\">[msg]</span></span>"
	admins << msg