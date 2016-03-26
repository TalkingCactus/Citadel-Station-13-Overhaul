
// Cross-defined vars to keep vore code isolated.

/mob/living
	var/digestable = 1					//Can the mob be digested inside a belly?
	var/datum/voretype/vorifice = null	// Default to no vore capability.
	var/underwear_active=1
	var/vore_last_relay=0
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
		var/confirm = alert(usr, "Enabling digestion on [name] will cause it to digest all stomach contents. Digestion will disable itself after 20 minutes.", "Enabling [name]'s Digestion", "Enable", "Cancel")
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

/mob/living/carbon/human/proc/vore_release(mob/living/carbon/M)
	set name = "Release"
	set category = "Vore"
	var/turf/T = get_turf(src)
	var/releaseorifice = input("Choose Orifice") in list("Stomach (by Mouth)", "Stomach (by Anus)", "Womb", "Cock", "Breasts", "Tail")

	// TODO LESHANA - This should all be refactored into procs on voretype that are overriden...
	switch(releaseorifice)
		if("Stomach (by Mouth)")
			var/datum/belly/belly = internal_contents["Stomach"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] hurls out the contents of their stomach!</b></font>")
				T.add_vomit_floor(src)

		if("Stomach (by Anus)")
			var/datum/belly/belly = internal_contents["Stomach"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] releases their stomach contents out of their rear!</b></font>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)

		if("Womb")
			var/datum/belly/belly = internal_contents["Womb"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] gushes out the contents of their womb!</b></font>")
				T.add_femjuice_floor(src)

			else if (belly.is_full)
				belly.is_full = 0
				visible_message("<span class='danger'>[src] gushes out a puddle of liquid from their folds!</span>")
				T.add_femjuice_floor(src)

		if("Cock")
			var/datum/belly/belly = internal_contents["Cock"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] splurts out the contents of their cock!</b></font>")
				T.add_semen_floor(src)

			else if (belly.is_full)
				belly.is_full = 0
				visible_message("<span class='danger'>[src] gushes out a puddle of cum from their cock!</span>")
				T.add_semen_floor(src)

		if("Breasts")
			var/datum/belly/belly = internal_contents["Boob"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] squirts out the contents of their breasts!</b></font>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)
				T.add_milk_floor(src)

			else if(belly.is_full)
				belly.is_full = 0
				visible_message("<span class='danger'>[src] squirts out a puddle of milk from their breasts!</span>")
				playsound(loc, 'sound/effects/splat.ogg', 50, 1)
				T.add_milk_floor(src)

		if("Tail")
			var/datum/belly/belly = internal_contents["Tail"]
			if (belly.release_all_contents())
				visible_message("<font color='green'><b>[src] releases a few things from their tail!</b></font>")
				T.add_vomit_floor(src)

			else if (belly.is_full)
				belly.is_full = 0
				visible_message("<span class='danger'>[src] releases a few things from their tail!</span>")
				T.add_vomit_floor(src)
/*
/////////////////////////////
////   OOC Escape Code	 ////
/////////////////////////////

/mob/living/proc/escapeOOC()
	set name = "OOC escape"
	set category = "Vore"

	//You're in an animal!
	if(istype(src.loc,/mob/living/simple_animal))
		var/mob/living/simple_animal/pred = src.loc
		var/confirm = alert(src, "You're in a mob. Don't use this as a trick to get out of hostile animals. This is for escaping from preference-breaking and if you're otherwise unable to escape from endo. If you are in more than one pred, use this more than once.", "Confirmation", "Okay", "Cancel")
		if(confirm == "Okay")
			pred.prey_excludes += src
			spawn(pred.backoffTime)
				if(pred)	pred.prey_excludes -= src
			pred.insides.release_specific_contents(src)
			message_admins("[key_name(src)] used the OOC escape button to get out of [pred] (MOB) ([pred ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[pred.x];Y=[pred.y];Z=[pred.z]'>JMP</a>" : "null"])")

	//You're in a PC!
	else if(istype(src.loc,/mob/living/carbon))
		var/mob/living/carbon/pred = src.loc
		var/confirm = alert(src, "You're in a player-character. This is for escaping from preference-breaking and if your predator disconnects/AFKs. If you are in more than one pred, use this more than once. If your preferences were being broken, please admin-help as well.", "Confirmation", "Okay", "Cancel")
		if(confirm == "Okay")
			for(var/O in pred.internal_contents)
				var/datum/belly/CB = pred.internal_contents[O]
				CB.release_specific_contents(src)
			message_admins("[key_name(src)] used the OOC escape button to get out of [pred] (PC) ([pred ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[pred.x];Y=[pred.y];Z=[pred.z]'>JMP</a>" : "null"])")

	else
		src << "<span class='alert'>You aren't inside anyone, you clod.</span>"


*/////////////////////////
/// NW's Inside Panel ///
/////////////////////////

/mob/living/carbon/human/proc/insidePanel() //mob/user as mob)
	set name = "Inside"
	set category = "Vore"

	var/datum/vore_look/picker_holder = new()
	picker_holder.loop=picker_holder

	var/dat = picker_holder.gen_ui(src)

	picker_holder.popup = new(src, "insidePanel","Inside!", 700, 400, picker_holder)
	picker_holder.popup.set_content(dat)
	picker_holder.popup.open()

//
// Callback Handler for the Inside form
//
/datum/vore_look
	var/datum/browser/popup
	var/loop = null;  // Magic self-reference to stop the handler from being GC'd before user takes action.
/datum/vore_look/Topic(href,href_list[])
	if (ui_interact(href, href_list))
		popup.set_content(gen_ui(usr))
		usr << output(popup.get_content(), "insidePanel.browser")

/datum/vore_look/proc/gen_ui(var/mob/living/carbon/human/user)
	var/dat
	if (is_vore_predator(user.loc))
		var/vore/pred_capable/eater = user.loc
		var/datum/belly/inside_belly		// Which of predator's bellies are we inside?

		//This big block here figures out where the prey is
		for (var/bellytype in eater.internal_contents)
			var/datum/belly/B = eater.internal_contents[bellytype]
			for (var/mob/living/M in B.internal_contents)
				if (M == user)
					inside_belly = B
					break
		// ASSERT(inside_belly != null) // Make sure we actually found ourselves.

		dat += "<font color = 'green'>You are currently inside</font> <font color = 'yellow'>[eater]'s</font> <font color = 'red'>[inside_belly.belly_name]</font>!<br><br>"
		dat += "[inside_belly.inside_flavor]<br><br>"
		if (inside_belly.internal_contents.len > 0)
			dat += "<font color = 'green'>You can see the following around you:</font><br>"
			for (var/atom/movable/M in inside_belly.internal_contents)
				if(M != user) dat += "[M] <a href='?src=\ref[src];look=\ref[M]'>Examine</a> <a href='?src=\ref[src];helpout=\ref[M]'>Help out</a><br>"
		dat += "<br>"
	else
		dat += "You aren't inside anyone.<br><br>"

	// List people inside you
	dat += "<font color = 'purple'><b><center>Contents</center></b></font><br>"
	for (var/bellytype in user.internal_contents)
		var/datum/belly/belly = user.internal_contents[bellytype]
		var/inside_count = 0
		dat += "<font color = 'green'>[belly.belly_type] </font> <a href='?src=\ref[src];toggle_digestion=\ref[belly]'>Digestion: [belly.digest_mode]</a><br>"
		for (var/atom/movable/M in belly.internal_contents)
			dat += "[M] <a href='?src=\ref[src];look=\ref[M]'>Examine</a> <br>"
			inside_count += 1
		if (inside_count == 0)
			dat += "You have not consumed anything<br>"

	// Offer flavor text customization options
	dat += "<font color = 'purple'><b><center>Customisation options</center></b></font><br><br>"
	for (var/bellytype in user.internal_contents)
		var/datum/belly/belly = user.internal_contents[bellytype]
		dat += "<b>[belly.belly_type]</b><br>[belly.inside_flavor] <a href='?src=\ref[src];set_description=\ref[belly]'>Change text</a><br>"

	return dat;

/datum/tgui/proc/vore_look(href, href_list)
//	log_debug("vore_look.Topic([href])")
	if(href_list["look"])
		// TODO - This probably should be ATOM not mob/living
		var/mob/living/subj=locate(href_list["look"])
		subj.examine(usr)

	if(href_list["helpout"])
		var/mob/living/subj=locate(href_list["helpout"])
		var/mob/living/eater = usr.loc
		usr << "<font color='green'>You begin to push [subj] to freedom!</font>"
		subj << "[usr] begins to push you to freedom!"
		eater << "<span class='warning'>Someone is trying to escape from inside you!<span>"
		sleep(50)
		if(prob(33))
			// TODO - Properly escape with updating internal_contents
			subj.loc = eater.loc
			usr << "<font color='green'>You manage to help [subj] to safety!</font>"
			subj << "<font color='green'>[usr] pushes you free!</font>"
			eater << "<span class='alert'>[subj] forces free of the confines of your body!</span>"
		else
			usr << "<span class='alert'>[subj] slips back down inside despite your efforts.</span>"
			subj << "<span class='alert'> Even with [usr]'s help, you slip back inside again.</span>"
			eater << "<font color='green'>Your body efficiently shoves [subj] back where they belong.</font>"

	if(href_list["set_description"])
		var/datum/belly/B = locate(href_list["set_description"])
		B.inside_flavor = input(usr, "Input a new flavor text!", "[B.belly_type] flavor text", B.inside_flavor) as message
		return 1 // TODO Will this make it refresh the ui?

	if (href_list["toggle_digestion"])
		var/datum/belly/B = locate(href_list["toggle_digestion"])
		B.toggle_digestion()
		return 1 // TODO Will this make it refresh the ui?

	if (href_list["close"])
		del(src)  // Cleanup

/mob/living/carbon/human/proc/I_am_not_mad()
	set name = "Toggle digestability"
	set category = "Vore"

	if(alert(src, "Turn off digestion damage to your character.", "", "Okay", "Cancel") == "Okay")
		digestable = !digestable
		usr << "<span class='alert'>You are [digestable ?  "now" : "no longer"] digestable.</span>"

/proc/vore_admins(var/msg)
	msg = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[msg]</span></span>"
	admins << msg