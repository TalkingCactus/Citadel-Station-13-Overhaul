/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(check_shields(0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	if(..())
		if(M.a_intent == "harm")
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = (rand(5,15))
			if(M.mob_size > 2)
				damage = (rand(10,25))
			if(!damage)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has lunged at [src]!</span>", \
					"<span class='userdanger'>[M] has lunged at [src]!</span>")
				return 0
			var/obj/item/organ/limb/affecting = get_organ(ran_zone(M.zone_selected))
			var/armor_block = run_armor_check(affecting, "melee","","",10)

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] slashes at [src]!</span>", \
				"<span class='userdanger'>[M] has slashed at [src]!</span>")
			apply_damage(damage, BRUTE, affecting, armor_block)

			if (prob(10))
				visible_message("<span class='danger'>[M] has wounded [src]!</span>", \
					"<span class='userdanger'>[M] has wounded [src]!</span>")
				apply_effect(1, WEAKEN, armor_block)
				add_logs(M, src, "attacked")
			updatehealth()

		if(M.a_intent == "disarm")
			var/randn = rand(1, 100)
			if(M.mob_size > 2)
				randn = rand(1, 80)
			if (randn <= 30)
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				Weaken(2)
				add_logs(M, src, "tackled")
				visible_message("<span class='danger'>[M] has tackled down [src]!</span>", \
					"<span class='userdanger'>[M] has tackled down [src]!</span>")
			else
				if (randn <= 60)
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, -1)
					drop_item()
					visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
						"<span class='userdanger'>[M] disarmed [src]!</span>")
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					visible_message("<span class='danger'>[M] has tried to disarm [src]!</span>", \
						"<span class='userdanger'>[M] has tried to disarm [src]!</span>")
	return