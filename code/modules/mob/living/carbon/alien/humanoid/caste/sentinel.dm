/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 200
	health = 200
	icon_state = "aliens_s"
	butcher_results = list(/obj/item/weapon/xeno_skull/s = 1,
	/obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno = 5,
	/obj/item/stack/sheet/animalhide/xeno = 1,
	/obj/item/weapon/xenos_tail = 1,
	/obj/item/weapon/xenos_claw = 1)

/mob/living/carbon/alien/humanoid/sentinel/New()
	internal_organs += new /obj/item/organ/internal/alien/plasmavessel/sentinel
	internal_organs += new /obj/item/organ/internal/alien/acid
	internal_organs += new /obj/item/organ/internal/alien/neurotoxin

	AddAbility(new /obj/effect/proc_holder/alien/sneak)
	..()

/mob/living/carbon/alien/humanoid/sentinel/movement_delay()
	. = ..()
	. += 1

/mob/living/carbon/alien/humanoid/sentinel/MiddleClickOn(atom/A, params, mob/user)
	face_atom(A)
	spit_at(A)
