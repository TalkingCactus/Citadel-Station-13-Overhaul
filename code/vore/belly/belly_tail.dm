//
//	Implementation of Tail Vore via the "Tail" belly type
//

/datum/belly/tail
	belly_type = "Tail"
	belly_name = "tail"
	inside_flavor = "Generic tail description"

// @Override
/datum/belly/tail/get_examine_msg(t_He, t_his, t_him, t_has, t_is)
	if (internal_contents.len || is_full == 1)
		return "[t_He] has a lump in their tail!\n"

// @Override
/datum/belly/tail/toggle_digestion()
	digest_mode = (digest_mode == DM_DIGEST) ? DM_HOLD : DM_DIGEST
	owner << "<span class='notice'>You will [digest_mode == DM_DIGEST ? "now" : "no longer"] digest people.</span>"

// @Override
/datum/belly/tail/process_Life()
	for(var/mob/living/M in internal_contents)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/R = M
			if(!R.digestable)
				continue

		if(owner.stat != DEAD && digest_mode == DM_DIGEST) // For some reason this can't be checked in the if statement below.
			if(iscarbon(M) || isanimal(M)) // If human or simple mob and you're set to digest.
				if(M.stat == DEAD)
					owner << "<span class='notice'>You feel [M] melt away inside of your tail, making it a tad thicker.</span>"
					M << "<span class='notice'>You melt away inside of [owner]'s tail, leaving it a tad thicker.</span>"
					digestion_death(M)
					continue

				// Deal digestion damage
				if(SSair.times_fired%3==1)
					if(!(M.status_flags & GODMODE))
				//		M.adjustBruteLoss(2)
						M.adjustFireLoss(2)
