//
//	Implementation of Oral Vore by the "Stomach" belly type.
//	Note: This also handles Anal Vore.   Possibly consider more differentiation.
//

/datum/belly/stomach
	belly_type = "Stomach"
	belly_name = "stomach"
	inside_flavor = "There is nothing interesting about this stomach."

// @Override
/datum/belly/stomach/get_examine_msg(t_He, t_his, t_him, t_has, t_is)
	if (internal_contents.len)
		return "[t_He] [t_has] something solid in [t_his] stomach!\n"

// @Override
/datum/belly/stomach/toggle_digestion()
	digest_mode = input("Stomach Mode") in list("Hold", "Digest", "Absorb")
	switch (digest_mode)
		if("Digest")
			owner << "<span class='notice'>You will now digest people.</span>"
		if("Hold")
			owner << "<span class='notice'>You will now harmlessly hold people.</span>"
		if("Absorb")
			owner << "<span class='notice'>You will now absorb people and make them part of you..</span>"

// @Override
/datum/belly/stomach/process_Life()
	if(length(internal_contents) && air_master.current_cycle%3==1 && digest_mode == DM_DIGEST)
		var/churnsound = pick(digestion_sounds)
		for(var/mob/hearer in range(1,owner))
			hearer << sound(churnsound,volume=80)

	for (var/mob/living/M in internal_contents)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/R = M
			if (!R.digestable)
				continue

		if (owner.stat != DEAD && digest_mode == DM_DIGEST) //According to vore.dm, stendo being true means people should digest. // also: For some reason this can't be checked in the if statement below.
			if (iscarbon(M) || isanimal(M)) // If human or simple mob and you're set to digest.

				if(M.stat == DEAD)
					var/digest_alert = rand(1,9) // Increase this number per emote.
					switch(digest_alert)
						if(1)
							owner << "<span class='notice'>You feel [M]'s body succumb to your digestive system, which breaks it apart into soft slurry.</span>"
							M << "<span class='notice'>Your body succumbs to [owner]'s digestive system, which breaks you apart into soft slurry.</span>"
						if(2)
							owner << "<span class='notice'>You hear a lewd glorp as your stomach muscles grind [M] into a warm pulp.</span>"
							M << "<span class='notice'>[owner]'s stomach lets out a lewd glorp as their muscles grind you into a warm pulp.</span>"
						if(3)
							owner << "<span class='notice'>Your stomach lets out a rumble as it melts [M] into sludge.</span>"
							M << "<span class='notice'>[owner]'s stomach lets out a rumble as it melts you into sludge.</span>"
						if(4)
							owner << "<span class='notice'>You feel a soft gurgle as [M]'s body loses form in your stomach. They're nothing but a soft mass of churning slop now.</span>"
							M << "<span class='notice'>[owner] feels a soft gurgle as your body loses form in their stomach. You're nothing but a soft mass of churning slop now.</span>"
						if(5)
							var/weight_msg; // Temp holder
							if(owner.gender == "female")
								weight_msg = rand(1,5)
							else // you don't have boobs
								weight_msg = rand(1,4) // Impossible to pick the boobs option.
							switch(weight_msg)
								if(1)
									owner << "<span class='notice'>Your stomach begins gushing [M]'s remains through your system, adding some extra weight to your thighs.</span>"
									M << "<span class='notice'>[owner]'s stomach begins gushing your remains through their system, adding some extra weight to [owner]'s thighs.</span>"
								if(2)
									owner << "<span class='notice'>Your stomach begins gushing [M]'s remains through your system, adding some extra weight to your rump.</span>"
									M << "<span class='notice'>[owner]'s stomach begins gushing your remains through their system, adding some extra weight to [owner]'s rump.</span>"
								if(3)
									owner << "<span class='notice'>Your stomach begins gushing [M]'s remains through your system, adding some extra weight to your hips.</span>"
									M << "<span class='notice'>[owner]'s stomach begins gushing your remains through their system, adding some extra weight to [owner]'s hips.</span>"
								if(4)
									owner << "<span class='notice'>Your stomach begins gushing [M]'s remains through your system, adding some extra weight to your belly.</span>"
									M << "<span class='notice'>[owner]'s stomach begins gushing your remains through their system, adding some extra weight to [owner]'s belly.</span>"
								if(5)
									owner << "<span class='notice'>Your stomach begins gushing [M]'s remains through your system, adding some extra weight to your tits.</span>"
									M << "<span class='notice'>[owner]'s stomach begins gushing your remains through their system, adding some extra weight to [owner]'s tits.</span>"
						if(6)
							owner << "<span class='notice'>Your stomach groans as [M] falls apart into a thick soup. You can feel their remains soon flowing deeper into your body to be absorbed.</span>"
							M << "<span class='notice'>[owner]'s stomach groans as you fall apart into a thick soup. Your remains soon flow deeper into [owner]'s body to be absorbed.</span>"
						if(7)
							owner << "<span class='notice'>Your gut kneads on every fiber of [M], softening them down into mush to fuel your next hunt.</span>"
							M << "<span class='notice'>[owner]'s gut kneads on every fiber of your body, softening you down into mush to fuel their next hunt.</span>"
						if(8)
							owner << "<span class='notice'>Your belly churns [M] down into a hot slush. You can feel the nutrients coursing through your digestive track with a series of long, wet glorps.</span>"
							M << "<span class='notice'>[owner]'s belly churns you down into a hot slush. Your nutrient-rich remains course through their digestive track with a series of long, wet glorps.</span>"
						if(9)
							owner << "<span class='notice'>You feel a rush of warmth as [M]'s now-liquified remains start pumping through your intestines.</span>"
							M << "<span class='notice'>Your now-liquified remains start pumping through [owner]'s intestines, filling their body with a rush of warmth.</span>"
					owner.nutrition += 20 // so eating dead mobs gives you *something*.
					var/deathsound = pick(death_sounds)
					for(var/mob/hearer in range(1,owner))
						hearer << deathsound
					digestion_death(M)
					continue

				// Deal digestion damage (and feed the pred)
				if(air_master.current_cycle%3==1)
					if(!(M.status_flags & GODMODE))
						M.adjustBruteLoss(1)
						M.adjustFireLoss(1)
						owner.nutrition += 10



// @Override
/datum/belly/stomach/relay_struggle(var/mob/user, var/direction)
	if (!(user in internal_contents) || recent_struggle)
		return  // User is not in this belly, or struggle too soon.

	recent_struggle = 1
	spawn(25)
		recent_struggle = 0

	//if(prob(80)) //Using the cooldown above to prevent spam instead
	var/struggle_outer_message
	var/struggle_user_message
	var/stomach_noun = pick("stomach","gut","tummy","belly") // To randomize the word for 'stomach'

	switch(rand(1,8)) // Increase this number per emote.
		if(1)
			struggle_outer_message = "<span class='alert'>[owner]'s [stomach_noun] wobbles with a squirming meal.</span>"
			struggle_user_message = "<span class='alert'>You squirm inside of [owner]'s [stomach_noun], making it wobble around.</span>"
		if(2)
			struggle_outer_message = "<span class='alert'>[owner]'s [stomach_noun] jostles with movement.</span>"
			struggle_user_message = "<span class='alert'>You jostle [owner]'s [stomach_noun] with movement.</span>"
		if(3)
			struggle_outer_message = "<span class='alert'>[owner]'s [stomach_noun] briefly swells outward as someone pushes from inside.</span>"
			struggle_user_message = "<span class='alert'>You shove against the walls of [owner]'s [stomach_noun], making it briefly swell outward.</span>"
		if(4)
			struggle_outer_message = "<span class='alert'>[owner]'s [stomach_noun] fidgets with a trapped victim.</span>"
			struggle_user_message = "<span class='alert'>You fidget around inside of [owner]'s [stomach_noun].</span>"
		if(5)
			struggle_outer_message = "<span class='alert'>[owner]'s [stomach_noun] jiggles with motion from inside.</span>"
			struggle_user_message = "<span class='alert'>Your motion causes [owner]'s [stomach_noun] to jiggle.</span>"
		if(6)
			struggle_outer_message = "<span class='alert'>[owner]'s [stomach_noun] sloshes around.</span>"
			struggle_user_message = "<span class='alert'>Your movement only causes [owner]'s [stomach_noun] to slosh around you.</span>"
		if(7)
			struggle_outer_message = "<span class='alert'>[owner]'s [stomach_noun] gushes softly.</span>"
			struggle_user_message = "<span class='alert'>Your struggles only cause [owner]'s [stomach_noun] to gush softly around you.</span>"
		if(8)
			struggle_outer_message = "<span class='alert'>[owner]'s [stomach_noun] lets out a wet squelch.</span>"
			struggle_user_message = "<span class='alert'>Your useless squirming only causes [owner]'s slimy [stomach_noun] to squelch over your body.</span>"

	for(var/mob/M in hearers(4, owner))
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