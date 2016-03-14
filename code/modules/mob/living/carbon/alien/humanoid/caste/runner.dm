/mob/living/carbon/alien/humanoid/runner
	name = "alien runner"
	caste = "run"
	maxHealth = 100
	health = 100
	icon_state = "alienrun_s"
	alt_icon = 'icons/mob/aliencrawl.dmi'
	butcher_results = list(/obj/item/weapon/xeno_skull/run = 1,
	/obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno = 5,
	/obj/item/stack/sheet/animalhide/xeno = 1,
	/obj/item/weapon/xenos_tail = 1,
	/obj/item/weapon/xenos_claw = 1)

/mob/living/carbon/alien/humanoid/runner/New()
	update_icons()
	internal_organs += new /obj/item/organ/internal/alien/plasmavessel/small/tiny
	AddAbility(new /obj/effect/proc_holder/alien/sneak)
	AddAbility(new /obj/effect/proc_holder/alien/togglecrawl)
	..()

/mob/living/carbon/alien/humanoid/runner/movement_delay()
	. += ..()
	. -= crawling

/obj/effect/proc_holder/alien/togglecrawl
	name = "Crawl"
	desc = "If you're crawling, stop crawling. If you're not crawling, start crawling."
	plasma_cost = 0
	action_icon_state = "alien_crawl"

/obj/effect/proc_holder/alien/togglecrawl/fire(mob/living/carbon/alien/humanoid/user)
	if(user.getPlasma() < user.crawl_cost)
		user << "<span class='noticealien'>Not enough plasma stored.</span>"
		return
	user.crawling = !user.crawling
	user.update_icons()
	if(user.crawling)
		user.drop_r_hand()
		user.drop_l_hand()
		user.visible_message(
			"<span class='notice'>[user] drops down to all fours.</span>", \
			"<span class='notice'>You start running on all fours.</span>")


	if(!user.crawling)
		user.visible_message(
			"<span class='notice'>[user] stands up on their hind legs.</span>", \
			"<span class='notice'>You start walking on your hind legs.</span>")

	return

/mob/living/carbon/alien/humanoid/runner/Life()
	if(crawling)
		drop_r_hand()
		drop_l_hand()
		adjustPlasma(-crawl_cost)
		if(getPlasma() <= 0)
			crawling = 0
			update_icons()
			visible_message(
				"<span class='danger'>[src] stands up on their hind legs, seemingly exhausted from running.</span>", \
				"<span class='danger'>You've run out of plasma and can't continue running.</span>")

	..()