//
// Implementation of Cock vore via "cock" belly type
//

/datum/belly/cock
	belly_type = "Cock"
	belly_name = "balls"
	inside_flavor = "Generic sac description"
	milk_type="semen"
	assoc_fluid="semen"

// @Override
/datum/belly/cock/get_examine_msg(t_He, t_his, t_him, t_has, t_is)
	if(internal_contents.len || is_full == 1)
		return "[t_He] has a throbbing large sack below [t_his] hips!\n"

// @Override
/datum/belly/cock/toggle_digestion()
	digest_mode = (digest_mode == DM_DIGEST) ? DM_HOLD : DM_DIGEST
	owner << "<span class='notice'>You will [digest_mode == DM_DIGEST ? "now" : "no longer"] cummify people.</span>"

// @Override
/datum/belly/cock/process_Life()
	for(var/mob/living/M in internal_contents)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/R = M
			if(!R.digestable)
				continue

		if(owner.stat != DEAD && digest_mode == DM_DIGEST) // For some reason this can't be checked in the if statement below.
			if(iscarbon(M) || isanimal(M)) // If human or simple mob and you're set to digest.
				if(M.stat == DEAD)
					owner << "<span class='notice'>You feel [M] dissolve into hot cum in your throbbing, swollen groin.</span>"
					M << "<span class='notice'>You dissolve into hot cum in [owner]'s throbbing, swollen groin.</span>"
					digestion_death(M)
					continue

				// Deal digestion damage
				if(SSair.times_fired%3==1)
					if(!(M.status_flags & GODMODE))
					//	M.adjustBruteLoss(2)
						M.adjustFireLoss(2)
