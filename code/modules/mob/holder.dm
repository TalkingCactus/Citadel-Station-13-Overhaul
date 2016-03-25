//Helper object for picking dionaea (and other creatures) up.
/obj/item/weapon/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	icon = 'icons/obj/objects.dmi'
	slot_flags = SLOT_HEAD
	var/mob/living/carbon/human/holden_mob

/obj/item/weapon/holder/New()
	item_state = icon_state
	..()
	SSobj.processing.Add(src)

/obj/item/weapon/holder/Del()
	SSobj.processing.Remove(src)
	..()

/obj/item/weapon/holder/process()

	var/needs_resprite = 0

	for(var/obj/M in contents)
		M.loc = get_turf(src)
		needs_resprite = 1

	if(needs_resprite)
		overlays.Cut()
		icon = holden_mob.icon
		icon_state = holden_mob.icon_state
		for(var/I in holden_mob.overlays_standing)
			overlays += I

	if(istype(loc,/turf) || !(contents.len))

		for(var/mob/M in contents)
			var/atom/movable/mob_container
			mob_container = M
			mob_container.forceMove(get_turf(src))
			M.reset_perspective()

		for(var/obj/M in contents)
			M.loc = get_turf(src)

		del(src)

/obj/item/weapon/holder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	for(var/mob/M in src.contents)
		M.attackby(W,user)

/obj/item/weapon/holder/proc/show_message(var/message, var/m_type)
	for(var/mob/living/M in contents)
		M.show_message(message,m_type)

//Mob procs and vars for scooping up
/mob/living/var/holder_type

/mob/living/proc/get_scooped(var/mob/living/carbon/grabber)
	if(!holder_type || buckled)
		return

	var/mob/living/carbon/human/grubben = src
	var/obj/item/weapon/holder/H = new holder_type(loc)
	src.loc = H
	H.name = name
	H.attack_hand(grabber)
	grabber << "You scoop up [src]."
	src << "[grabber] scoops you up."
	grabber.status_flags |= PASSEMOTES

	//Going to update the icon to look like the person
	H.icon = src.icon
	H.icon_state = src.icon_state
	for(var/I in grubben.overlays_standing)
		H.overlays += I

	H.holden_mob = grubben

	return H

//Mob specific holders.


/obj/item/weapon/holder/drone
	name = "maintenance drone"
	desc = "It's a small maintenance robot."
	icon_state = "drone"
	origin_tech = "magnets=3;engineering=5"

/obj/item/weapon/holder/cat
	name = "cat"
	desc = "It's a cat. Meow."
	icon_state = "cat"
	origin_tech = null

//micro holders
/obj/item/weapon/holder/micro
	name = "micro"
	desc = "Another crewmember, small enough to fit in your hand."
	icon_state = "micro"
	slot_flags = SLOT_FEET | SLOT_HEAD | SLOT_ID
	w_class = 2

/obj/item/weapon/holder/micro/examine(var/mob/user)
	for(var/mob/living/M in contents)
		M.examine(user)

/obj/item/weapon/holder/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(usr == src) return
	if(!Adjacent(usr)) return
	if(istype(M,/mob/living/silicon/ai)) return
	for(var/mob/living/carbon/human/O in contents)
		O.show_inv(usr)

/obj/item/weapon/holder/GetAccess()
	var/list/access_sum = list()
	var/obj/item/M_hand = holden_mob.get_active_hand()
	var/obj/item/M_id = holden_mob.wear_id

	if(M_hand)
		access_sum += M_hand.GetAccess()
	if(M_id)
		access_sum += M_id.GetAccess()

	return(access_sum)

/obj/item/weapon/holder/micro/attack_self(var/mob/living/user)
	for(var/mob/living/carbon/human/M in contents)
		M.help_shake_act(user)

//This should most likely be preattack. Check whenever possible (doing a straight port)
/obj/item/weapon/holder/micro/afterattack(var/mob/living/carbon/target, var/mob/user, var/proximity)
	if(!proximity) return

	// Note! In old code, when feeding to an animal, the animals attackby() proc fired first, and this second.
	// By the time the thread got to this point, the micro had already been removed from contents.
	// That was the only thing preventing a crash due to bad typecast.
	// So lets start out by making sure!
	// TODO LESHANA - Review whether these procs should actually go into the classes of the vore-capable objects instead
	if (!is_vore_predator(target)) return

	for(var/mob/living/M in contents)
		if(M == target)
			return

		// TODO - Do we want to do any size comparisons? "micro" is relative after all, could be normal sized in macro paws!

		// NOTE! Which belly the micro goes into is based on the TARGET's vore setting
		// 	not the attacker's vore setting! This is the same behavior as old code. Keeping it for now -Leshana
		var/datum/voretype/target_voretype = target.vorifice
		if (target_voretype)
			target_voretype.eat_held_mob(user, M, target)

