//
//	Implementation of Breast Vore via the "Boob" belly type
//

/datum/belly/boob
	belly_type = "Boob"
	belly_name = "breast"
	inside_flavor = "Generic boob description"
	milk_type="milk"
	assoc_fluid="milk"
	oxygen=1

// @Override
/datum/belly/boob/get_examine_msg(t_He, t_his, t_him, t_has, t_is)
	if (internal_contents.len || is_full == 1)
		return "[t_He] has a swollen pair of breasts!\n"

// @Override
/datum/belly/boob/toggle_digestion()
	digest_mode = (digest_mode == DM_DIGEST) ? DM_HOLD : DM_DIGEST
	owner << "<span class='notice'>You will [digest_mode == DM_DIGEST ? "now" : "no longer"] milkify people.</span>"

// @Override
/datum/belly/boob/process_Life()
	for(var/mob/living/M in internal_contents)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/R = M
			if(!R.digestable)
				continue
		if(oxygen)
			M.setOxyLoss(0, 0)
		if(owner.stat != DEAD && digest_mode == DM_DIGEST) // For some reason this can't be checked in the if statement below.
			if(iscarbon(M) || isanimal(M)) // If human or simple mob and you're set to digest.
				if(M.stat == DEAD)
					owner << "<span class='notice'>You feel [M] melt into creamy milk, leaving your breasts full and jiggling.</span>"
					M << "<span class='notice'>You melt into creamy milk, leaving [owner]'s breasts full and jiggling.</span>"
					digestion_death(M)
					continue

				// Deal digestion damage
				if(SSair.times_fired%3==1)
					if(!(M.status_flags & GODMODE))
					//	M.adjustBruteLoss(2)
						M.adjustFireLoss(2)


