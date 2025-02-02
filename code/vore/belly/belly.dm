//
//	The belly object is what holds onto a mob while they're inside a predator.
//	It takes care of altering the pred's decription, digesting the prey, relaying struggles etc.
//	It is not, however, for printing messages about entering/exiting the belly. That is done in voretype etc.
//

/*
belly_prefs["name"] = STRING
belly_prefs["digest_mode"] = CONSTANT (see belly.dm)
belly_prefs["digest_modes"] = LIST
belly_prefs["inside_flavor"] = STRING
belly_prefs["vore_sound"] = FILE
belly_prefs["vore_verb"] = STRING
belly_prefs["human_prey_swallow_time"] = INTEGER
belly_prefs["nonhuman_prey_swallow_time"] = INTEGER
belly_prefs["digest_brute"] = INTEGER
belly_prefs["digest_burn"] = INTEGER
belly_prefs["digest_tickrate"] = INTEGER
belly_prefs["immutable"] = BOOLEAN
*/

/*
* Parent type of all the various "belly" varieties.
*/

/datum/belly
	var/name								// Name of this location
	var/list/digest_modes = list(DM_HOLD,DM_DIGEST,DM_HEAL,DM_DIGESTF)	// Possible digest modes
	var/inside_flavor						// Flavor text description of inside sight/sound/smells/feels.
	var/vore_sound = 'sound/vore/gulp.ogg'	// Sound when ingesting someone
	var/vore_verb = "ingest"				// Verb for eating with this in messages
	var/human_prey_swallow_time = 100		// Time in deciseconds to swallow /mob/living/carbon/human
	var/nonhuman_prey_swallow_time = 30		// Time in deciseconds to swallow anything else
	var/emoteTime = 600						// How long between stomach emotes at prey
	var/digest_brute = 1					// Brute damage per tick in digestion mode
	var/digest_burn = 1						// Burn damage per tick in digestion mode
	var/digest_tickrate = 3					// Modulus this of air controller tick number to iterate gurgles on
	var/immutable = 0						// Prevents this belly from being deleted
	var/integrity = 100

	var/tmp/digest_mode = DM_HOLD				// Whether or not to digest. Default to not digest.
	var/tmp/mob/living/owner					// The mob whose belly this is.
	var/tmp/list/internal_contents = list()		// People/Things you've eaten into this belly!
	var/tmp/is_full								// Flag for if digested remeans are present. (for disposal messages)
	var/tmp/recent_struggle = 0					// Flag to prevent struggle emote spam
	var/tmp/emotePend = 0						// If there's already a spawned thing counting for the next emote

	// Don't forget to watch your commas at the end of each line if you change these.
	var/list/struggle_messages_outside = list(
		"%pred's %belly wobbles with a squirming meal.",
		"%pred's %belly jostles with movement.",
		"%pred's %belly briefly swells outward as someone pushes from inside.",
		"%pred's %belly fidgets with a trapped victim.",
		"%pred's %belly jiggles with motion from inside.",
		"%pred's %belly sloshes around.",
		"%pred's %belly gushes softly.",
		"%pred's %belly lets out a wet squelch.")

	var/list/struggle_messages_inside = list(
		"Your useless squirming only causes %pred's slimy %belly to squelch over your body.",
		"Your struggles only cause %pred's %belly to gush softly around you.",
		"Your movement only causes %pred's %belly to slosh around you.",
		"Your motion causes %pred's %belly to jiggle.",
		"You fidget around inside of %pred's %belly.",
		"You shove against the walls of %pred's %belly, making it briefly swell outward.",
		"You jostle %pred's %belly with movement.",
		"You squirm inside of %pred's %belly, making it wobble around.")

	var/list/digest_messages_owner = list(
		"You feel %prey's body succumb to your digestive system, which breaks it apart into soft slurry.",
		"You hear a lewd glorp as your %belly muscles grind %prey into a warm pulp.",
		"Your %belly lets out a rumble as it melts %prey into sludge.",
		"You feel a soft gurgle as %prey's body loses form in your %belly. They're nothing but a soft mass of churning slop now.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your thighs.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your rump.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your belly.",
		"Your %belly groans as %prey falls apart into a thick soup. You can feel their remains soon flowing deeper into your body to be absorbed.",
		"Your %belly kneads on every fiber of %prey, softening them down into mush to fuel your next hunt.",
		"Your %belly churns %prey down into a hot slush. You can feel the nutrients coursing through your digestive track with a series of long, wet glorps.")

	var/list/digest_messages_prey = list(
		"Your body succumbs to %pred's digestive system, which breaks you apart into soft slurry.",
		"%pred's %belly lets out a lewd glorp as their muscles grind you into a warm pulp.",
		"%pred's %belly lets out a rumble as it melts you into sludge.",
		"%pred feels a soft gurgle as your body loses form in their %belly. You're nothing but a soft mass of churning slop now.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's thighs.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's rump.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's belly.",
		"%pred's %belly groans as you fall apart into a thick soup. Your remains soon flow deeper into %pred's body to be absorbed.",
		"%pred's %belly kneads on every fiber of your body, softening you down into mush to fuel their next hunt.",
		"%pred's %belly churns you down into a hot slush. Your nutrient-rich remains course through their digestive track with a series of long, wet glorps.")

	var/list/examine_messages = list(
		"They have something solid in their %belly!",
		"It looks like they have something in their %belly!")

	var/list/vore_sounds = list(
		"Gulp" = 'sound/vore/gulp.ogg',
		"Insert" = 'sound/vore/insert.ogg',
		"Insertion1" = 'sound/vore/insertion1.ogg',
		"Insertion2" = 'sound/vore/insertion2.ogg',
		"Insertion3" = 'sound/vore/insertion3.ogg',
		"Schlorp" = 'sound/vore/schlorp.ogg',
		"Squish1" = 'sound/vore/squish1.ogg',
		"Squish2" = 'sound/vore/squish2.ogg',
		"Squish3" = 'sound/vore/squish3.ogg',
		"Squish4" = 'sound/vore/squish4.ogg')

	//Mostly for being overridden on precreated bellies on mobs. Could be VV'd into
	//a carbon's belly if someone really wanted. No UI for carbons to adjust this.
	var/list/emote_lists = list()

// Constructor that sets the owning mob
// @Override
/datum/belly/New(var/mob/living/owning_mob)
	owner = owning_mob

// Toggle digestion on/off and notify user of the new setting.
// If multiple digestion modes are avaliable (i.e. unbirth) then user should be prompted.
/datum/belly/proc/toggle_digestion()
	return


// Checks if any mobs are present inside the belly
// @return True if the belly is empty.
/datum/belly/proc/is_empty()
	return internal_contents.len == 0

// Release all contents of this belly into the owning mob's location.
// If that location is another mob, contents are transferred into whichever of its bellies the owning mob is in.
// Returns the number of mobs so released.
/datum/belly/proc/release_all_contents()
	var/tick = 0 //easiest way to check if the list has anything
	for (var/atom/movable/M in internal_contents)
		M.loc = owner.loc  // Move the belly contents into the same location as belly's owner.
		src.internal_contents -= M  // Remove from the belly contents

		if (isliving(owner.loc)) // This makes sure that the mob behaves properly if released into another mob
			var/mob/living/carbon/loc_mob = owner.loc
			for (var/bellytype in loc_mob.vore_organs)
				var/datum/belly/belly = loc_mob.vore_organs[bellytype]
				if (owner in belly.internal_contents)
					belly.internal_contents += M
		tick++
	owner.visible_message("<font color='green'><b>[owner] expels everything from their [lowertext(name)]!</b></font>")
	return tick

// Release a specific atom from the contents of this belly into the owning mob's location.
// If that location is another mob, the atom is transferred into whichever of its bellies the owning mob is in.
// Returns the number of atoms so released.
/datum/belly/proc/release_specific_contents(var/atom/movable/M)
	if (!(M in internal_contents))
		return 0 // They weren't in this belly anyway

	M.loc = owner.loc  // Move the belly contents into the same location as belly's owner.
	src.internal_contents -= M  // Remove from the belly contents

	var/datum/belly/B = check_belly(M.loc)
	if(B)
		B.internal_contents += M

	owner.visible_message("<font color='green'><b>[owner] expels [M] from their [lowertext(name)]!</b></font>")
	owner.update_icons()
	return 1

// Actually perform the mechanics of devouring the tasty prey.
// The purpose of this method is to avoid duplicate code, and ensure that all necessary
// steps are taken.
// @param prey Mob to be eaten
// @param user Optional: 3rd party is the one making this happen.
/datum/belly/proc/nom_mob(var/mob/prey, var/mob/user)
	if (prey.buckled)
		prey.buckled.unbuckle_mob()

	prey.loc = owner
	internal_contents += prey

	if(inside_flavor)
		prey << "<span class='notice'><B>[inside_flavor]</B></span>"

// Get the line that should show up in Examine message if the owner of this belly
// is examined.   By making this a proc, we not only take advantage of polymorphism,
// but can easily make the message vary based on how many people are inside, etc.
// Returns a string which shoul be appended to the Examine output.
/datum/belly/proc/get_examine_msg()
	if(internal_contents.len && examine_messages.len)
		var/formatted_message
		var/raw_message = pick(examine_messages)

		formatted_message = replacetext(raw_message,"%belly",lowertext(name))

		return("<span class='warning'>[formatted_message]</span><BR>")

// The next function gets the messages set on the belly, in human-readable format.
// This is useful in customization boxes and such. The delimiter right now is \n\n so
// in message boxes, this looks nice and is easily delimited.
/datum/belly/proc/get_messages(var/type, var/delim = "\n\n")
	ASSERT(type == "smo" || type == "smi" || type == "dmo" || type == "dmp" || type == "em")
	var/list/raw_messages

	switch(type)
		if("smo")
			raw_messages = struggle_messages_outside
		if("smi")
			raw_messages = struggle_messages_inside
		if("dmo")
			raw_messages = digest_messages_owner
		if("dmp")
			raw_messages = digest_messages_prey
		if("em")
			raw_messages = examine_messages

	var/messages = list2text(raw_messages,delim)
	return messages

// The next function sets the messages on the belly, from human-readable var
// replacement strings and linebreaks as delimiters (two \n\n by default).
// They also sanitize the messages.
/datum/belly/proc/set_messages(var/raw_text, var/type, var/delim = "\n\n")
	ASSERT(type == "smo" || type == "smi" || type == "dmo" || type == "dmp" || type == "em")

	var/list/raw_list = text2list(html_encode(raw_text),delim)
	if(raw_list.len > 10)
		raw_list.Cut(11)
		log_admin("[owner] tried to set [name] with 11+ messages")

	for(var/i = 1, i <= raw_list.len, i++)
		if(length(raw_list[i]) > 160 || length(raw_list[i]) < 10) //160 is fudged value due to htmlencoding increasing the size
			raw_list.Cut(i,i)
			log_admin("[owner] tried to set [name] with >121 or <10 char message")
		else
			raw_list[i] = readd_quotes(raw_list[i])
			//Also fix % sign for var replacement
			raw_list[i] = replacetext(raw_list[i],"&#37;","%")

	ASSERT(raw_list.len <= 10) //Sanity

	switch(type)
		if("smo")
			struggle_messages_outside = raw_list
		if("smi")
			struggle_messages_inside = raw_list
		if("dmo")
			digest_messages_owner = raw_list
		if("dmp")
			digest_messages_prey = raw_list
		if("em")
			examine_messages = raw_list

	return
// Relay the sounds of someone struggling in a belly to those outside!
// Called from /mob/living/carbon/relaymove()
/datum/belly/proc/relay_struggle(var/mob/user, var/direction)
	return

// Handle the death of a mob via digestion.
// Called from the process_Life() methods of bellies that digest prey.
// Default implementation calls M.death() and removes from internal contents.
// Indigestable items are removed, and M is deleted.
/datum/belly/proc/digestion_death(var/mob/living/M, var/mob/living/prey, var/mob/living/pred, var/obj/item/W)
	is_full = 1
	M.death(1)
	internal_contents -= M


	// If digested prey is also a pred... anyone inside their bellies gets moved up.
	if (is_vore_predator(M))
		var/vore/pred_capable/P = M
		for (var/bellytype in P.vore_organs)
			var/datum/belly/belly = P.vore_organs[bellytype]
			for (var/obj/SubPrey in belly.internal_contents)
				SubPrey.loc = src.owner
				internal_contents += SubPrey
				if (istype(SubPrey, /mob))
					SubPrey << "As [M] melts away around you, you find yourself in [src.owner]'s [name]"

	//Drop all items into the belly.
	W.loc = src.owner
	internal_contents += W

	// Delete the digested mob
	del(M)
	vore_admins("[key_name(pred)] digested [key_name(prey)].")
	log_attack("[key_name(pred)] digested [key_name(prey)].")


/* // Way, way too overpowered and prone to abuse on an "Action" server
// Handle a mob being absorbed
/datum/belly/proc/absorb_living(var/mob/living/M)
	M.absorbed = 1
	M << "<span class='notice'>[owner]'s [name] absorbs your body, making you part of them.</span>"
	owner << "<span class='notice'>Your [name] absorbs [M]'s body, making them part of you.</span>"

	//This is probably already the case, but for sub-prey, it won't be.
	M.loc = owner

	//Seek out absorbed prey of the prey, absorb them too.
	//This in particular will recurse oddly because if there is absorbed prey of prey of prey...
	//it will just move them up one belly. This should never happen though since... when they were
	//absobred, they should have been absorbed as well!
	for(var/I in M.vore_organs)
		var/datum/belly/B = M.vore_organs[I]
		for(var/mob/living/Mm in B.internal_contents)
			if(Mm.absorbed)
				internal_contents += Mm
				B.internal_contents -= Mm
				absorb_living(Mm) */