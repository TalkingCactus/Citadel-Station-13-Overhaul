//
//	Implementation of Unbirthing Vore via the "womb" belly type
//

/datum/belly/womb
	belly_type = "Womb"
	belly_name = "womb"
	inside_flavor = "Generic womb description"
	milk_type="femjuice"
	assoc_fluid="femjuice"
	oxygen=1


// @Override
/datum/belly/womb/get_examine_msg(t_He, t_his, t_him, t_has, t_is)
	if(internal_contents.len || is_full == 1)
		return "[t_He] [t_has] something in [t_his] lower belly!\n"

// @Override
/datum/belly/womb/toggle_digestion()
	digest_mode = input("Womb Mode") in list("Hold", "Heal", "Transform (Male)", "Transform (Female)", "Transform (Keep Gender)", "Transform (Change Species)","Digest")
	switch (digest_mode)
		if("Heal")
			owner << "<span class='notice'>You will now heal people you've unbirthed.</span>"
		if("Digest")
			owner << "<span class='notice'>You will now digest people you've unbirthed.</span>"
		if("Hold")
			owner << "<span class='notice'>You will now harmlessly hold people you've unbirthed.</span>"
/*		if("Transform (Male)")
			owner << "<span class='notice'>You will now transform people you've unbirthed into your son.</span>"
		if("Transform (Female)")
			owner << "<span class='notice'>You will now transform people you've unbirthed into your daughter.</span>"
		if("Transform (Keep Gender)")
			owner << "<span class='notice'>You will now transform people you've unbirthed, but they will keep their gender.</span>"
		if("Transform (Change Species)")
			owner << "<span class='notice'>You will now transform people you've unbirthed to look similar to your species.</span>"
*/
// @Override
/datum/belly/womb/process_Life()
	for(var/mob/living/M in internal_contents)
		//WOMB HEAL
		if(oxygen)
			M.setOxyLoss(0, 0)
		if(iscarbon(M) && owner.stat != DEAD && digest_mode == DM_HEAL && M.stat != DEAD)
			if(SSair.times_fired%3==1)
				if(!(M.status_flags & GODMODE))
					if(owner.nutrition > 90)
						M.adjustBruteLoss(-1, 0)
						M.adjustFireLoss(-1, 0)
						M.adjustOxyLoss(-5, 0)
						owner.nutrition -= 2
						if(M.nutrition <= 400)
							M.nutrition += 1

		//WOMB DIGEST
		if(iscarbon(M) && owner.stat != DEAD && digest_mode == DM_DIGEST)
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/R = M
				if(R.digestable == 0)
					continue

			if(M.stat == DEAD)
				owner << "<span class='notice'>You feel [M] dissolve into nothing but warm fluids inside your womb.</span>"
				M << "<span class='notice'>You dissolve into nothing but warm fluids inside [owner]'s womb.</span>"
				digestion_death(M)
				continue

			if(SSair.times_fired%3==1)
				if(!(M.status_flags & GODMODE))
					M.adjustBruteLoss(2, 0)
					M.adjustFireLoss(3, 0)
/*

		//WOMB TRANSFORM (FEM)
		if(ishuman(M) && ishuman(owner) && owner.stat != DEAD && digest_mode == "Transform (Female)" && M.stat != DEAD)
			var/mob/living/carbon/human/P = M
			var/mob/living/carbon/human/O = owner

			if(SSair.times_fired%3==1)
				if(!(M.status_flags & GODMODE))

					var/TFchance = prob(10)
					if(TFchance == 1)
						var/TFmodify = rand(1,3)
						if(TFmodify == 1)
							P << "<span class='notice'>You feel lightheaded and drowsy...</span>"
							owner << "<span class='notice'>Your belly feels warm as your womb makes subtle changes to your captive's body.</span>"
							P.update_body()

						if(TFmodify == 2)
							P.hair_style = "Bedhead"
							P << "<span class='notice'>Your body tingles all over...</span>"
							owner << "<span class='notice'>Your belly tingles as your womb makes noticeable changes to your captive's body.</span>"
							P.update_hair()

						if(TFmodify == 3 && P.gender != FEMALE)
							P.hair_style = "Shaved"
							P.gender = FEMALE
							P << "<span class='notice'>Your body feels very strange...</span>"
							owner << "<span class='notice'>Your belly feels strange as your womb alters your captive's gender.</span>"
							P.update_body()

					M.adjustBruteLoss(-1)
					M.adjustFireLoss(-1)

					if(O.nutrition > 0)
						O.nutrition -= 2
					if(P.nutrition < 400)
						P.nutrition += 1

		//WOMB TRANSFORM (MALE)
		if(ishuman(M) && ishuman(owner) && owner.stat != DEAD && digest_mode == "Transform (Male)" && M.stat != DEAD)
			var/mob/living/carbon/human/P = M
			var/mob/living/carbon/human/O = owner

			if(SSair.times_fired%3==1)
				if(!(M.status_flags & GODMODE))

					var/TFchance = prob(10)
					if(TFchance == 1)

						var/TFmodify = rand(1,3)
						if(TFmodify == 1)
							P << "<span class='notice'>You feel lightheaded and drowsy...</span>"
							owner << "<span class='notice'>Your belly feels warm as your womb makes subtle changes to your captive's body.</span>"
							P.update_body()

						if(TFmodify == 2)
							P << "<span class='notice'>Your body tingles all over...</span>"
							owner << "<span class='notice'>Your belly tingles as your womb makes noticeable changes to your captive's body.</span>"
							P.update_hair()

						if(TFmodify == 3 && P.gender != MALE)
							P.gender = MALE
							P << "<span class='notice'>Your body feels very strange...</span>"
							owner << "<span class='notice'>Your belly feels strange as your womb alters your captive's gender.</span>"
							P.update_body()

					M.adjustBruteLoss(-1)
					M.adjustFireLoss(-1)

					if(O.nutrition > 0)
						O.nutrition -= 2
					if(P.nutrition < 400)
						P.nutrition += 1

		//WOMB TRANSFORM (KEEP GENDER)
		if(ishuman(M) && ishuman(owner) && owner.stat != DEAD && digest_mode == "Transform (Keep Gender)" && M.stat != DEAD)
			var/mob/living/carbon/human/P = M
			var/mob/living/carbon/human/O = owner

			if(SSair.times_fired%3==1)
				if(!(M.status_flags & GODMODE))

					var/TFchance = prob(10)
					if(TFchance == 1)

						var/TFmodify = rand(1,2)
						if(TFmodify == 1)
							P << "<span class='notice'>You feel lightheaded and drowsy...</span>"
							owner << "<span class='notice'>Your belly feels warm as your womb makes subtle changes to your captive's body.</span>"
							P.update_body()

						if(TFmodify == 2)
							P.hair_style = "Bedhead"
							P << "<span class='notice'>Your body tingles all over...</span>"
							owner << "<span class='notice'>Your belly tingles as your womb makes noticeable changes to your captive's body.</span>"
							P.update_hair()

					M.adjustBruteLoss(-1)
					M.adjustFireLoss(-1)

					if(O.nutrition > 0)
						O.nutrition -= 2
					if(P.nutrition < 400)
						P.nutrition += 1

		//WOMB TRANSFORM (CHANGE SPECIES)
		if(ishuman(M) && ishuman(owner) && owner.stat != DEAD && digest_mode == "Transform (Change Species)" && M.stat != DEAD)
			var/mob/living/carbon/human/P = M
			var/mob/living/carbon/human/O = owner
		//	var/special_color[COLOUR_LIST_SIZE]
		//	var/datum/dna/change_dna=new_dna
			if(SSair.times_fired%3==1)
				if(!(M.status_flags & GODMODE))
					var/TFchance = prob(10)
					if(TFchance == 1)
						var/TFmodify = rand(1,3)
						if(TFmodify == 1)
							P.updateappearance()
							P << "<span class='notice'>You feel lightheaded and drowsy...</span>"
							owner << "<span class='notice'>Your belly feels warm as your womb makes subtle changes to your captive's body.</span>"
							P.update_body()

						if(TFmodify == 2)
							P.updateappearance()
							P.hair_style = "Bedhead"
							P << "<span class='notice'>Your body tingles all over...</span>"
							owner << "<span class='notice'>Your belly tingles as your womb makes noticeable changes to your captive's body.</span>"
							P.update_hair()
							//Omitted clause : P.race_icon != O.race_icon
							//No idea how to work with that one, species system got changed a lot
							//Also this makes it similar to the previous one until fixed


						if(TFmodify == 3)
					//		if(istype(new_dna,/datum/dna))
							P.dna.species = O.dna.species
					//		P.dna.species(change_dna.species.id)
					//		P.dna.mutant_tails=change_dna.mutant_tail
					//		P.dna.mutant_wings=change_dna.mutant_wing
					//		P.dna.special_color=change_dna.special_color
					//		P.dna.special_color=change_dna.special_color
							P.hair_style = "Bedhead"
							P.updateappearance()
							P << "<span class='notice'>You lose sensation of your body, feeling only the warmth of the womb...</span>"
							owner << "<span class='notice'>Your belly shifts as your womb makes dramatic changes to your captive's body.</span>"
							P.update_hair()

					M.adjustBruteLoss(-1)
					M.adjustFireLoss(-1)

					if(O.nutrition > 0)
						O.nutrition -= 2
					if(P.nutrition < 400)
						P.nutrition += 1
*/