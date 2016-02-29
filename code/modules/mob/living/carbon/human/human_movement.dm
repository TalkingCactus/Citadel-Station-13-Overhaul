/mob/living/carbon/human/movement_delay()
	. += dna.species.movement_delay(src)
	. += ..()
	. += config.human_delay
	if((locate(/obj/structure/alien/weeds) in src.loc) && has_gravity())
		. += 2

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0)
	if(..())
		return 1
	if(!isturf(loc)) // In a mecha? A locker? Who knows!
		return 0

	// Do we have a jetpack (and is it on)?
	var/obj/item/weapon/tank/jetpack/J = back
	if(!istype(J) && istype(wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/C = wear_suit
		J = C.jetpack
	if(istype(J) && J.allow_thrust(0.01, src))
		return 1

/mob/living/carbon/human/Move(NewLoc, direct)// Footstep sounds
	. = ..()
	if(health > 0 && !resting && !sleeping && !paralysis && has_gravity(src) && !buckled && !stat && isturf(loc) && alpha > 0)
		if(footstep > 0 && src.loc == NewLoc && (m_intent == "run"))
			if(shoes)
				playsound(src, pick('code/cactus/sound/misc/step/stepShoes1.ogg', 'code/cactus/sound/misc/step/stepShoes2.ogg', 'code/cactus/sound/misc/step/stepShoes3.ogg', 'code/cactus/sound/misc/step/stepShoes4.ogg', 'code/cactus/sound/misc/step/stepShoes5.ogg', 'code/cactus/sound/misc/step/stepShoes6.ogg', 'code/cactus/sound/misc/step/stepShoes7.ogg'), 50, 0, 0)
				footstep = 0
			if(!shoes)
				playsound(src, pick('code/cactus/sound/misc/step/stepBare1.ogg', 'code/cactus/sound/misc/step/stepBare2.ogg', 'code/cactus/sound/misc/step/stepBare3.ogg', 'code/cactus/sound/misc/step/stepBare4.ogg', 'code/cactus/sound/misc/step/stepBare5.ogg'),25, 0, 0)
				footstep = 0
		else if(src.loc == NewLoc)
			footstep++

/mob/living/carbon/human/slip(s_amount, w_amount, obj/O, lube)
	if(isobj(shoes) && (shoes.flags&NOSLIP) && !(lube&GALOSHES_DONT_HELP))
		return 0
	return ..()

/mob/living/carbon/human/experience_pressure_difference()
	playsound(src, 'sound/effects/space_wind.ogg', 50, 1)
	if(shoes && shoes.flags&NOSLIP)
		return 0
	return ..()

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return shoes && shoes.negates_gravity()

/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	for(var/datum/mutation/human/HM in dna.mutations)
		HM.on_move(src, NewLoc)
	if(shoes)
		if(!lying && !buckled)
			if(loc == NewLoc)
				if(!has_gravity(loc))
					return
				var/obj/item/clothing/shoes/S = shoes

				//Bloody footprints
				var/turf/T = get_turf(src)
				if(S.bloody_shoes && S.bloody_shoes[S.blood_state])
					var/obj/effect/decal/cleanable/blood/footprints/oldFP = locate(/obj/effect/decal/cleanable/blood/footprints) in T
					if(oldFP && oldFP.blood_state == S.blood_state)
						return
					else
						//No oldFP or it's a different kind of blood
						S.bloody_shoes[S.blood_state] = max(0, S.bloody_shoes[S.blood_state]-BLOOD_LOSS_PER_STEP)
						var/obj/effect/decal/cleanable/blood/footprints/FP = new /obj/effect/decal/cleanable/blood/footprints(T)
						FP.blood_state = S.blood_state
						FP.entered_dirs |= dir
						FP.bloodiness = S.bloody_shoes[S.blood_state]
						FP.update_icon()
						update_inv_shoes()
				//End bloody footprints

				S.step_action()

