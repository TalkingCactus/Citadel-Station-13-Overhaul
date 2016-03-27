#define UPGRADE_COOLDOWN	40
#define UPGRADE_KILL_TIMER	100

/obj/item/weapon/grab
	name = "grab"
	flags = NOBLUDGEON | ABSTRACT
	var/obj/screen/grab/hud = null
	var/mob/affecting = null
	var/mob/assailant = null
	var/state = GRAB_PASSIVE

	var/allow_upgrade = 1
	var/last_upgrade = 0

	layer = 21
	item_state = "nothing"
	w_class = 5


/obj/item/weapon/grab/New(mob/user, mob/victim)
	..()
	assailant = user
	affecting = victim

	hud = new /obj/screen/grab(src)
	hud.icon_state = "reinforce"
	hud.name = "reinforce grab"
	hud.master = src

	affecting.grabbed_by += src


/obj/item/weapon/grab/Destroy()
	if(affecting)
		affecting.grabbed_by -= src
		affecting = null
	if(assailant)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	qdel(hud)
	return ..()

//Used by throw code to hand over the mob, instead of throwing the grab. The grab is then deleted by the throw code.
/obj/item/weapon/grab/proc/get_mob_if_throwable()
	if(affecting)
		if(affecting.buckled)
			return null
		if(state >= GRAB_AGGRESSIVE)
			return affecting
	return null


//This makes sure that the grab screen object is displayed in the correct hand.
/obj/item/weapon/grab/proc/synch()
	if(affecting)
		if(assailant.r_hand == src)
			hud.screen_loc = ui_rhand
		else
			hud.screen_loc = ui_lhand


/obj/item/weapon/grab/process()
	if(!confirm())
		return 0

	if(assailant.client)
		assailant.client.screen -= hud
		assailant.client.screen += hud

	if(assailant.pulling == affecting)
		assailant.stop_pulling()

	if(state <= GRAB_AGGRESSIVE)
		allow_upgrade = 1
		if((assailant.l_hand && assailant.l_hand != src && istype(assailant.l_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.l_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if((assailant.r_hand && assailant.r_hand != src && istype(assailant.r_hand, /obj/item/weapon/grab)))
			var/obj/item/weapon/grab/G = assailant.r_hand
			if(G.affecting != affecting)
				allow_upgrade = 0
		if(state == GRAB_AGGRESSIVE)
			var/h = affecting.hand
			affecting.hand = 0
			affecting.drop_item()
			affecting.hand = 1
			affecting.drop_item()
			affecting.hand = h
			for(var/X in affecting.grabbed_by)
				var/obj/item/weapon/grab/G = X
				if(G == src) continue
				if(G.state == GRAB_AGGRESSIVE)
					allow_upgrade = 0
		if(allow_upgrade)
			hud.icon_state = "reinforce"
		else
			hud.icon_state = "!reinforce"
	else
		if(!affecting.buckled)
			affecting.loc = assailant.loc

	var/breathing_tube = affecting.getorganslot("breathing_tube")

	if(state >= GRAB_NECK)
		affecting.Stun(5)	//It will hamper your voice, being choked and all.
		if(isliving(affecting) && !breathing_tube)
			var/mob/living/L = affecting
			L.adjustOxyLoss(1)

	if(state >= GRAB_KILL)
		affecting.Weaken(5)	//Should keep you down unless you get help.
		if(!breathing_tube)
			affecting.losebreath = min(affecting.losebreath + 2, 3)

/obj/item/weapon/grab/attack_self(mob/user)
	s_click(hud)

/obj/item/weapon/grab/proc/s_click(obj/screen/S)
	if(!affecting)
		return
	if(state == GRAB_UPGRADING)
		return
	if(assailant.next_move > world.time)
		return
	if(world.time < (last_upgrade + UPGRADE_COOLDOWN))
		return
	if(!assailant.canmove || assailant.lying)
		qdel(src)
		return

	last_upgrade = world.time

	if(state < GRAB_AGGRESSIVE)
		if(!allow_upgrade)
			return
		assailant.visible_message("<span class='warning'>[assailant] grabs [affecting] aggressively!</span>")
		state = GRAB_AGGRESSIVE
		icon_state = "grabbed1"
	else
		if(state < GRAB_NECK)
			if(isslime(affecting))
				assailant << "<span class='warning'>You squeeze [affecting], but nothing interesting happens!</span>"
				return

			assailant.visible_message("<span class='warning'>[assailant] moves \his grip to [affecting]'s neck!</span>")
			state = GRAB_NECK
			icon_state = "grabbed+1"
			if(!affecting.buckled)
				affecting.loc = assailant.loc
			add_logs(assailant, affecting, "neck-grabbed")
			hud.icon_state = "disarm/kill"
			hud.name = "disarm/kill"
		else
			if(state < GRAB_UPGRADING)
				assailant.visible_message("<span class='danger'>[assailant] starts to tighten \his grip on [affecting]'s neck!</span>")
				hud.icon_state = "disarm/kill1"
				state = GRAB_UPGRADING
				if(do_after(assailant, UPGRADE_KILL_TIMER, target = affecting))
					if(state == GRAB_KILL)
						return
					if(!affecting)
						qdel(src)
						return
					if(!assailant.canmove || assailant.lying)
						qdel(src)
						return
					state = GRAB_KILL
					assailant.visible_message("<span class='danger'>[assailant] tightens \his grip on [affecting]'s neck!</span>")
					add_logs(assailant, affecting, "strangled")

					assailant.changeNext_move(CLICK_CD_TKSTRANGLE)
					if(!affecting.getorganslot("breathing_tube"))
						affecting.losebreath += 1
				else
					if(assailant)
						assailant.visible_message("<span class='warning'>[assailant] is unable to tighten \his grip on [affecting]'s neck!</span>")
						hud.icon_state = "disarm/kill"
						state = GRAB_NECK


//This is used to make sure the victim hasn't managed to yackety sax away before using the grab.
/obj/item/weapon/grab/proc/confirm()
	if(!assailant || !affecting)
		qdel(src)
		return 0

	if(affecting)
		if(!isturf(assailant.loc) || ( !isturf(affecting.loc) || assailant.loc != affecting.loc && get_dist(assailant, affecting) > 1) )
			qdel(src)
			return 0

	return 1


//
//	TODO LESHANA - This is actually kind of backwards.
// 		Here we define the eating code in the grab object, but that is only one of two says of eating.
//		Plus it really needs to do a better job of checking if the target is even capable of vore!
//
//		Another way to do it is to override attackby() on things that ARE vore-capable, and detect
//		if they are being attacked by something they can eat (a grab or micro holder)
//
//		Rationale: There are potentially many things that can do vore, but only TWO vectors by which
//		something can be eaten:
//			A) Attacking with a grab containing an edible item.
//			B) Attacking with a micro holder.
//
//		Things capable of vore are (at least, this list expands):
//			A) /mob/living/carbon objects
//			B) /mob/living/simple_animal objects (which unfortunately are not classes as carbon for some reason)
//
//		Things capable of being eaten:
//			A) Anything that can be grabbed
//			B) Anything contained within a micro holder.
//


/obj/item/weapon/grab/attack(mob/M, mob/user)
	if(!affecting)
		return

	//Vore code swallowing emotes, modifying existing alien vore stuff.
	if(state >= GRAB_AGGRESSIVE)
		if( (ishuman(user) && !issilicon(affecting)) || (isalien(user) && !issilicon(affecting)) )

			// Alright, let's see if we can get this to work for feeding others as well as yourself - NW
			// Refactored to use centralized vore code system - Leshana

			var/mob/living/carbon/human/attacker = user  // Typecast to human

			// If you click yourself...
			if(M == assailant)
				if (is_vore_predator(user))
					// Feed what you're holding (affecting) to yourself (user)
					var/datum/voretype/vore_type = attacker.vorifice
					if (vore_type.feed_grabbed_to_self(user, affecting)) del(src)
				else
					vore_admins("[attacker] attempted to feed [affecting] to [user] ([user.type]) but it is not predator-capable")

			// If you click your target...
			if(M == affecting)
				if (is_vore_predator(affecting))
					// Feed yourself (user) to what you're holding (affecting)!
					var/datum/voretype/vore_type = attacker.vorifice  // Attacker's choice of what vorifice
					if (vore_type.feed_self_to_grabbed(user, affecting)) del(src)
				else
					vore_admins("[attacker] attempted to feed [user] to [affecting] ([affecting.type]) but it is not predator-capable")

			// If you click someone else...
			else
				// Feed what you're holding (affecting) to what you clicked (M)
				if (is_vore_predator(M))
					var/datum/voretype/vore_type = M:vorifice
					if (vore_type.feed_grabbed_to_other(user, affecting, M)) del(src)
				else
					vore_admins("[attacker] attempted to feed [affecting] to [M] ([M.type]) but it is not predator-capable")
	//End vore code.

/obj/item/weapon/grab/dropped()
	..()
	qdel(src)

#undef UPGRADE_COOLDOWN
#undef UPGRADE_KILL_TIMER
