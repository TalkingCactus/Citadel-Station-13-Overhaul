//
//	A simple belly type for mobs that only have one type.
//

/datum/belly/simple
	belly_type = "Simple"
	belly_name = "insides"
	inside_flavor = "There is nothing interesting about these insides."

	var/emoteBetween = 200 					//How long between belly emotes
	var/emoteAfter = 0						//Holder for next emote allowed time
	var/mob/living/simple_animal/animal		//Animal owner



/datum/belly/simple/New()
	..()
	animal = owner

// @Override
/datum/belly/simple/get_examine_msg(t_He, t_his, t_him, t_has, t_is)
	if (internal_contents.len)
		return "[t_He] [t_has] something solid inside [t_his] body!\n"

// @Override
/datum/belly/simple/toggle_digestion()
	digest_mode = (digest_mode == DM_DIGEST) ? DM_HOLD : DM_DIGEST
	animal << "<span class='notice'>You will [digest_mode == DM_DIGEST ? "now" : "no longer"] digest people inside you.</span>"

// @Override
/datum/belly/simple/process_Life()
	for (var/mob/living/M in internal_contents)

		if (animal.stat != DEAD && digest_mode == DM_DIGEST && M.digestable) //What to do if being digested
			if (iscarbon(M) || isanimal(M))


				if (world.time > emoteAfter) //Mob belly messages to people inside about digesting
					var/message = pick(animal.stomach_emotes_d)
					M << "<span class='alert'>[message]</span>"
					emoteAfter = world.time + animal.gurgleTime


				if(M.stat == DEAD && !animal.digest_emotes)
					var/digest_alert = rand(1,6) // Update this based on the highest emote below
					switch(digest_alert)
						if(1)
							animal << "<span class='notice'>You feel [M]'s body succumb to your digestive system, which breaks it apart into soft slurry.</span>"
							M << "<span class='notice'>Your body succumbs to [animal]'s digestive system, which breaks you apart into soft slurry.</span>"
						if(2)
							animal << "<span class='notice'>You hear a lewd glorp as your insides grind [M] into a warm pulp.</span>"
							M << "<span class='notice'>[animal]'s stomach lets out a lewd glorp as their insides grind you into a warm pulp.</span>"
						if(3)
							animal << "<span class='notice'>Your insides let out a rumble as it melts [M] into more of yourself.</span>"
							M << "<span class='notice'>[animal]'s insides let out a rumble as it melts you into more of [animal].</span>"
						if(4)
							animal << "<span class='notice'>You feel a soft gurgle as [M]'s body loses form inside you. They're nothing but a soft mass of churning slop now.</span>"
							M << "<span class='notice'>[animal] feels a soft gurgle as your body loses form. You're nothing but a soft mass of churning slop now.</span>"
						if(5)
							animal << "<span class='notice'>Your stomach groans as [M] falls apart into a thick soup. You can feel their remains soon flowing deeper into your body to be absorbed.</span>"
							M << "<span class='notice'>[animal]'s stomach groans as you fall apart into a thick soup. Your remains soon flow deeper into [animal]'s body to be absorbed.</span>"
						if(6)
							animal << "<span class='notice'>Your gut kneads on every fiber of [M], softening them down into mush to fuel your next hunt.</span>"
							M << "<span class='notice'>[animal]'s gut kneads on every fiber of your body, softening you down into mush to fuel their next hunt.</span>"
					animal.nutrition += 20 // so eating dead mobs gives you *something*.
					digestion_death(M)
					continue

				else if(M.stat == DEAD && animal.digest_emotes)	// Pred has a custom digestion message set. Pred message is 1, prey message is 2
					animal << animal.digest_emotes["Pred"]
					M << animal.digest_emotes["Prey"]
					animal.nutrition += 20
					digestion_death(M)
					continue

				// Deal digestion damage (and feed the pred)
				if(SSair.times_fired%3==1)
					if(!(M.status_flags & GODMODE))
						M.adjustBruteLoss(2)
						M.adjustFireLoss(3)
						var/difference = animal.playerscale / M.playerscale 	// LOOK HOW FUCKING CLEVER I AM.
						animal.nutrition += 10/difference 					// I AM SO PROUD OF MYSELF. -Ace 	 PROUD OF YOU -NW.

		else //Can't digest contents of the stomach, so we do the below.
			if (world.time > emoteAfter)
				var/message = pick(animal.stomach_emotes)
				M << "<span class='notice'>[message]</span>"
				emoteAfter = world.time + animal.gurgleTime



// @Override
/datum/belly/simple/relay_struggle(var/mob/user, var/direction)
	if (!(user in internal_contents))
		return  // User is not in this belly!

	if(prob(40))
		var/struggle_outer_message
		var/struggle_user_message
		var/stomach_noun = pick("stomach","gut","tummy","belly") // To randomize the word for 'stomach'

		switch(rand(1,8)) // Increase this number per emote.
			if(1)
				struggle_outer_message = "<span class='alert'>[animal]'s [stomach_noun] wobbles with a squirming meal.</span>"
				struggle_user_message = "<span class='alert'>You squirm inside of [animal]'s [stomach_noun], making it wobble around.</span>"
			if(2)
				struggle_outer_message = "<span class='alert'>[animal]'s [stomach_noun] jostles with movement.</span>"
				struggle_user_message = "<span class='alert'>You jostle [animal]'s [stomach_noun] with movement.</span>"
			if(3)
				struggle_outer_message = "<span class='alert'>[animal]'s [stomach_noun] briefly swells outward as someone pushes from inside.</span>"
				struggle_user_message = "<span class='alert'>You shove against the walls of [animal]'s [stomach_noun], making it briefly swell outward.</span>"
			if(4)
				struggle_outer_message = "<span class='alert'>[animal]'s [stomach_noun] fidgets with a trapped victim.</span>"
				struggle_user_message = "<span class='alert'>You fidget around inside of [animal]'s [stomach_noun].</span>"
			if(5)
				struggle_outer_message = "<span class='alert'>[animal]'s [stomach_noun] jiggles with motion from inside.</span>"
				struggle_user_message = "<span class='alert'>Your motion causes [animal]'s [stomach_noun] to jiggle.</span>"
			if(6)
				struggle_outer_message = "<span class='alert'>[animal]'s [stomach_noun] sloshes around.</span>"
				struggle_user_message = "<span class='alert'>Your movement only causes [animal]'s [stomach_noun] to slosh around you.</span>"
			if(7)
				struggle_outer_message = "<span class='alert'>[animal]'s [stomach_noun] gushes softly.</span>"
				struggle_user_message = "<span class='alert'>Your struggles only cause [animal]'s [stomach_noun] to gush softly around you.</span>"
			if(8)
				struggle_outer_message = "<span class='alert'>[animal]'s [stomach_noun] lets out a wet squelch.</span>"
				struggle_user_message = "<span class='alert'>Your useless squirming only causes [animal]'s slimy [stomach_noun] to squelch over your body.</span>"

		for(var/mob/M in hearers(4, animal))
			M.show_message(struggle_outer_message, 2) // hearable
		user << struggle_user_message

		switch(rand(1,4))
			if(1)
				playsound(user.loc, 'sound/vore/squish1.ogg', 50, 1)
			if(2)
				playsound(user.loc, 'sound/vore/squish2.ogg', 50, 1)
			if(3)
				playsound(user.loc, 'sound/vore/squish3.ogg', 50, 1)
			if(4)
				playsound(user.loc, 'sound/vore/squish4.ogg', 50, 1)
