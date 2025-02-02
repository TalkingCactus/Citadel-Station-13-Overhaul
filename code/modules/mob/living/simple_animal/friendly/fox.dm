//Foxxy
/mob/living/simple_animal/pet/fox
	name = "fox"
	desc = "It's a fox."
	icon = 'icons/mob/pets.dmi'
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	speak = list("Ack-Ack","Ack-Ack-Ack-Ackawoooo","Geckers","Awoo","Tchoff")
	speak_emote = list("geckers", "barks")
	emote_hear = list("howls.","barks.")
	emote_see = list("shakes its head.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/fox/slab = 3)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	gold_core_spawnable = 2
	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target
	var/mob/flee_target


/obj/item/weapon/reagent_containers/food/snacks/meat/fox/slab
	name = "Fox meat"
	desc = "The fox doesn't say a god damn thing, now."

/mob/living/simple_animal/pet/fox/New()
	if(!vore_organs.len)
		var/datum/belly/B = new /datum/belly(src)
		B.immutable = 1
		B.name = "Stomach"
		B.inside_flavor = "Slick foxguts. Cute on the outside, slimy on the inside!"
		B.human_prey_swallow_time = swallowTime
		B.nonhuman_prey_swallow_time = swallowTime
		vore_organs[B.name] = B
		vore_selected = B.name

		B.emote_lists[DM_HOLD] = list(
			"The foxguts knead and churn around you harmlessly.",
			"With a loud glorp, some air shifts inside the belly.",
			"A thick drop of warm bellyslime drips onto you from above.",
			"The fox turns suddenly, causing you to shift a little.",
			"During a moment of relative silence, you can hear the fox breathing.",
			"The slimey stomach walls squeeze you lightly, then relax.")

		B.emote_lists[DM_DIGEST] = list(
			"The guts knead at you, trying to work you into thick soup.",
			"You're ground on by the slimey walls, treated like a mouse.",
			"The acrid air is hard to breathe, and stings at your lungs.",
			"You can feel the acids coating you, ground in by the slick walls.",
			"The fox's stomach churns hungrily over your form, trying to take you.",
			"With a loud glorp, the stomach spills more acids onto you.")
	..()

// All them complicated fox procedures.
/mob/living/simple_animal/pet/fox/Life()
	//MICE!
	if((loc) && isturf(loc))
		if(!stat && !resting && !buckled)
			for(var/mob/living/simple_animal/mouse/M in loc)
				if(isPredator) //If the fox is a predator,
					movement_target = null
					emote_see(1, "greedily stuffs [M] into their gaping maw!")
					if(M in oview(1, src))
						animal_nom(M)
					else
						M << "You just manage to slip away from [src]'s jaws before you can be sent to a fleshy prison!"
					break
				else
					if(!M.stat)
						M.splat()
						emote_see(pick("bites \the [M]!","toys with \the [M].","chomps on \the [M]!"))
						movement_target = null
						stop_automated_movement = 0
						break

	..()

	for(var/mob/living/simple_animal/mouse/snack in oview(src,5))
		if(snack.stat < DEAD && prob(15))
			emote_hear(pick("hunkers down!","acts stealthy!","eyes [snack] hungrily."))
		break

	if(!stat && !resting && !buckled) //SEE A MICRO AND ARE A PREDATOR, EAT IT!
		for(var/mob/living/carbon/human/food in oview(src, 5))

			if(food.playerscale <= RESIZE_A_SMALLTINY)
				if(prob(10))
					emote_see(1, pick("eyes [food] hungrily!","licks their lips and turns towards [food] a little!","pants as they imagine [food] being in their belly."))
					break
				else
					if(prob(5))
						movement_target = food
						break

		for(var/mob/living/carbon/human/bellyfiller in oview(1, src))
			if(bellyfiller in src.prey_excludes)
				continue

			if(bellyfiller.playerscale <= RESIZE_A_SMALLTINY && isPredator)
				movement_target = null
				emote_see(1, pick("slurps [bellyfiller] with their slimey tongue.","looms over [bellyfiller] with their maw agape.","sniffs at [bellyfiller], their belly grumbling hungrily."))
				sleep(10)
				emote_see(1, "starts to scoop [bellyfiller] into their maw!")
				if(bellyfiller in oview(1, src))
					animal_nom(bellyfiller)
				else
					bellyfiller << "You just manage to slip away from [src]'s jaws before you can be sent to a fleshy prison!"
				break

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if (turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0

			if (flee_target) //fleeing takes precendence
				handle_flee_target()
			else
				handle_movement_target()

/mob/living/simple_animal/pet/fox/proc/handle_movement_target()
	//if our target is neither inside a turf or inside a human(???), stop
	if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
		movement_target = null
		stop_automated_movement = 0
	//if we have no target or our current one is out of sight/too far away
	if( !movement_target || !(movement_target.loc in oview(src, 4)) )
		movement_target = null
		stop_automated_movement = 0
		for(var/mob/living/simple_animal/mouse/snack in oview(src)) //search for a new target
			if(isturf(snack.loc) && !snack.stat)
				movement_target = snack
				break

	if(movement_target)
		stop_automated_movement = 1
		walk_to(src,movement_target,0,10)

/mob/living/simple_animal/pet/fox/proc/handle_flee_target()
	//see if we should stop fleeing
	if (flee_target && !(flee_target.loc in view(src)))
		flee_target = null
		stop_automated_movement = 0

	if (flee_target)
		if(prob(25)) say("GRRRRR!")
		stop_automated_movement = 1
		walk_away(src, flee_target, 7, 2)

/mob/living/simple_animal/pet/fox/proc/set_flee_target(atom/A)
	if(A)
		flee_target = A
		turns_since_scan = 5

/mob/living/simple_animal/pet/fox/attackby(var/obj/item/O, var/mob/user)
	. = ..()
	if(O.force)
		set_flee_target(user? user : src.loc)


/mob/living/simple_animal/pet/fox/attack_hand(mob/living/carbon/human/M as mob)
	. = ..()
	if(M.a_intent == "hurt")
		set_flee_target(M)

/mob/living/simple_animal/pet/fox/ex_act()
	. = ..()
	set_flee_target(src.loc)

/mob/living/simple_animal/pet/fox/bullet_act(var/obj/item/projectile/proj)
	. = ..()
	set_flee_target(proj.firer? proj.firer : src.loc)

//Captain fox
/mob/living/simple_animal/pet/fox/Renault
	name = "Renault"
	desc = "Renault, the Captain's trustworthy fox."
	gold_core_spawnable = 0
	isPredator = 1

/mob/living/simple_animal/pet/fox/Renault/New()
	if(!vore_organs.len)
		var/datum/belly/B = new /datum/belly(src)
		B.immutable = 1
		B.name = "Stomach"
		B.inside_flavor = "Slick foxguts. They seem somehow more regal than perhaps other foxes!"
		B.human_prey_swallow_time = swallowTime
		B.nonhuman_prey_swallow_time = swallowTime
		vore_organs[B.name] = B
		vore_selected = B.name

		B.emote_lists[DM_HOLD] = list(
			"Renault's stomach walls squeeze around you more tightly for a moment, before relaxing, as if testing you a bit.",
			"There's a sudden squeezing as Renault presses a forepaw against his gut over you, squeezng you against the slick walls.",
			"The 'head fox' has a stomach that seems to think you belong to it. It might be hard to argue, as it kneads at your form.",
			"If being in the captain's fox is a promotion, it might not feel like one. The belly just coats you with more thick foxslime.",
			"It doesn't seem like Renault wants to let you out. The stomach and owner possessively squeeze around you.",
			"Renault's stomach walls squeeze closer, as he belches quietly, before swallowing more air. Does he do that on purpose?")

		B.emote_lists[DM_DIGEST] = list(
			"Renault's stomach walls grind hungrily inwards, kneading acids against your form, and treating you like any other food.",
			"The captain's fox impatiently kneads and works acids against you, trying to claim your body for fuel.",
			"The walls knead in firmly, squeezing and tossing you around briefly in disorienting aggression.",
			"Renault belches, letting the remaining air grow more acrid. It burns your lungs with each breath.",
			"A thick glob of acids drip down from above, adding to the pool of caustic fluids in Renault's belly.",
			"There's a loud gurgle as the stomach declares the intent to make you a part of Renault.")

	..()