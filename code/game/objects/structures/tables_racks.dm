/* Tables and Racks
 * Contains:
 *		Tables
 *		Glass Tables
 *		Wooden Tables
 *		Reinforced Tables
 *		Racks
 *		Rack Parts
 */

/*
 * Tables
 */

/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/smooth_structures/table.dmi'
	icon_state = "table"
	density = 1
	anchored = 1
	layer = 2.8
	climbable = TRUE
	pass_flags = LETPASSTHROW //You can throw objects over this, despite it's density.")
	var/frame = /obj/structure/table_frame
	var/framestack = /obj/item/stack/rods
	var/buildstack = /obj/item/stack/sheet/metal
	var/busy = 0
	var/buildstackamount = 1
	var/framestackamount = 2
	var/deconstruction_ready = 1
	var/health = 100
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/table, /obj/structure/table/reinforced)

/obj/structure/table/New()
	..()
	for(var/obj/structure/table/T in src.loc)
		if(T != src)
			qdel(T)

/obj/structure/table/update_icon()
	if(smooth)
		queue_smooth(src)
		queue_smooth_neighbors(src)

/obj/structure/table/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			take_damage(rand(80,120), BRUTE, 0)
		if(3)
			take_damage(rand(40,80), BRUTE, 0)

/obj/structure/table/blob_act()
	if(prob(75))
		qdel(src)

/obj/structure/table/narsie_act()
	if(prob(20))
		new /obj/structure/table/wood(src.loc)

/obj/structure/table/mech_melee_attack(obj/mecha/M)
	playsound(src.loc, 'sound/weapons/punch4.ogg', 50, 1)
	visible_message("<span class='danger'>[M.name] smashes [src]!</span>")
	take_damage(200, M.damtype, 0)

/obj/structure/table/attack_alien(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(src.loc, 'sound/weapons/bladeslice.ogg', 50, 1)
	visible_message("<span class='danger'>[user] slices [src]!</span>")
	take_damage(100, BRUTE, 0)


/obj/structure/table/attack_animal(mob/living/simple_animal/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(user.melee_damage_upper)
		var/dmg_dealt = user.melee_damage_upper
		if(user.environment_smash)
			dmg_dealt = 100
		visible_message("<span class='warning'>[user] smashes [src]!</span>")
		playsound(src.loc, 'sound/weapons/Genhit.ogg', 50, 1)
		take_damage(dmg_dealt, user.melee_damage_type, 0)


/obj/structure/table/attack_paw(mob/user)
	attack_hand(user)

/obj/structure/table/attack_hulk(mob/living/carbon/human/user)
	..(user, 1)
	playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
	visible_message("<span class='danger'>[user] smashes [src]!</span>")
	user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
	take_damage(rand(180,280), BRUTE, 0)
	return 1


/obj/structure/table/attack_tk() // no telehulk sorry
	return

/obj/structure/table/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type, 0)

/obj/structure/table/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(mover.throwing)
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	else
		return !density

/obj/structure/table/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSTABLE)

/obj/structure/table/proc/tablepush(obj/item/I, mob/user)
	if(get_dist(src, user) < 2)
		var/obj/item/weapon/grab/G = I
		if(G.affecting.buckled)
			user << "<span class='warning'>[G.affecting] is buckled to [G.affecting.buckled]!</span>"
			return 0
		if(G.state < GRAB_AGGRESSIVE)
			user << "<span class='warning'>You need a better grip to do that!</span>"
			return 0
		if(!G.confirm())
			return 0
		G.affecting.loc = src.loc
		if(istype(src, /obj/structure/table/optable))
			var/obj/structure/table/optable/OT = src
			G.affecting.resting = 1
			G.affecting.update_canmove()
			visible_message("<span class='notice'>[G.assailant] has laid [G.affecting] on [src].</span>")
			OT.patient = G.affecting
			OT.check_patient()
			qdel(I)
			return 1
		G.affecting.Weaken(2)
		G.affecting.visible_message("<span class='danger'>[G.assailant] pushes [G.affecting] onto [src].</span>", \
									"<span class='userdanger'>[G.assailant] pushes [G.affecting] onto [src].</span>")
		add_logs(G.assailant, G.affecting, "pushed")
		qdel(I)
		return 1
	qdel(I)

/obj/structure/table/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/grab))
		tablepush(I, user)
		return
	if(!(flags & NODECONSTRUCT))
		if(istype(I, /obj/item/weapon/screwdriver) && deconstruction_ready)
			table_deconstruct(user, 1)
			return

		if(istype(I, /obj/item/weapon/wrench) && deconstruction_ready)
			table_deconstruct(user, 0)
			return

	if(istype(I, /obj/item/weapon/storage/bag/tray))
		var/obj/item/weapon/storage/bag/tray/T = I
		if(T.contents.len > 0) // If the tray isn't empty
			var/list/obj/item/oldContents = T.contents.Copy()
			T.quick_empty()

			for(var/obj/item/C in oldContents)
				C.loc = src.loc

			user.visible_message("[user] empties [I] on [src].")
			return
		// If the tray IS empty, continue on (tray will be placed on the table like other items)

	if(user.a_intent != "harm" && !(I.flags & ABSTRACT))
		if(user.drop_item())
			I.Move(loc)
			var/list/click_params = params2list(params)
			//Center the icon where the user clicked.
			if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = Clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = Clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
			return 1
	else
		return ..()

/obj/structure/table/attacked_by(obj/item/I, mob/living/user)
	..()
	take_damage(I.force, I.damtype)

/obj/structure/table/proc/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			if(sound_effect)
				playsound(loc, 'sound/items/Welder.ogg', 40, 1)
		else
			return
	health -= damage
	if(health <= 0)
		table_destroy()

/*
 * TABLE DESTRUCTION/DECONSTRUCTION
 */



/obj/structure/table/proc/table_destroy()
	if(!(flags & NODECONSTRUCT))
		var/turf/T = get_turf(src)
		for(var/i = 1, i <= framestackamount, i++)
			new framestack(T)
		for(var/i = 1, i <= buildstackamount, i++)
			new buildstack(T)
	qdel(src)


/obj/structure/table/proc/table_deconstruct(mob/user, disassembling = 0)
	if(flags & NODECONSTRUCT)
		return
	if(disassembling)
		user << "<span class='notice'>You start disassembling [src]...</span>"
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20, target = src))
			new frame(src.loc)
			for(var/i = 1, i <= buildstackamount, i++)
				new buildstack(get_turf(src))
			qdel(src)
	else
		user << "<span class='notice'>You start deconstructing [src]...</span>"
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 40, target = src))
			for(var/i = 1, i <= framestackamount, i++)
				new framestack(get_turf(src))
			for(var/i = 1, i <= buildstackamount, i++)
				new buildstack(get_turf(src))
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			qdel(src)


/*
 * Glass tables
 */
/obj/structure/table/glass
	name = "glass table"
	desc = "What did I say about leaning on the glass tables? Now you need surgery."
	icon = 'icons/obj/smooth_structures/glass_table.dmi'
	icon_state = "glass_table"
	buildstack = /obj/item/stack/sheet/glass
	canSmoothWith = null
	health = 50

/obj/structure/table/glass/tablepush(obj/item/I, mob/user)
	if(..())
		visible_message("<span class='warning'>[src] breaks!</span>")
		playsound(src.loc, "shatter", 50, 1)
		new frame(src.loc)
		new /obj/item/weapon/shard(src.loc)
		qdel(src)


/obj/structure/table/glass/climb_structure(mob/user)
	if(..())
		visible_message("<span class='warning'>[src] breaks!</span>")
		playsound(src.loc, "shatter", 50, 1)
		new frame(src.loc)
		new /obj/item/weapon/shard(src.loc)
		qdel(src)
		user.Weaken(5)

/*
 * Wooden tables
 */

/obj/structure/table/wood
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon = 'icons/obj/smooth_structures/wood_table.dmi'
	icon_state = "wood_table"
	frame = /obj/structure/table_frame/wood
	framestack = /obj/item/stack/sheet/mineral/wood
	buildstack = /obj/item/stack/sheet/mineral/wood
	burn_state = FLAMMABLE
	burntime = 20
	canSmoothWith = list(/obj/structure/table/wood, /obj/structure/table/wood/poker)

/obj/structure/table/wood/narsie_act()
	return

/obj/structure/table/wood/poker //No specialties, Just a mapping object.
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'icons/obj/smooth_structures/poker_table.dmi'
	icon_state = "poker_table"
	buildstack = /obj/item/stack/tile/carpet
	canSmoothWith = list(/obj/structure/table/wood/poker, /obj/structure/table/wood)

/obj/structure/table/wood/poker/narsie_act()
	new /obj/structure/table/wood(src.loc)

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A reinforced version of the four legged table, much harder to simply deconstruct."
	icon = 'icons/obj/smooth_structures/reinforced_table.dmi'
	icon_state = "r_table"
	deconstruction_ready = 0
	buildstack = /obj/item/stack/sheet/plasteel
	canSmoothWith = list(/obj/structure/table/reinforced, /obj/structure/table)
	health = 200

/obj/structure/table/reinforced/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
			if(deconstruction_ready)
				user << "<span class='notice'>You start weakening the reinforced table...</span>"
				if (do_after(user, 50/W.toolspeed, target = src))
					if(!src || !WT.isOn()) return
					user << "<span class='notice'>You weaken the table.</span>"
					deconstruction_ready = 0
			else
				user << "<span class='notice'>You start strengthening the reinforced table...</span>"
				if (do_after(user, 50/W.toolspeed, target = src))
					if(!src || !WT.isOn()) return
					user << "<span class='notice'>You strengthen the table.</span>"
					deconstruction_ready = 1
	else
		return ..()


/*
 * Surgery Tables
 */

/obj/structure/table/optable
	name = "operating table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "optable"
	buildstack = /obj/item/stack/sheet/mineral/silver
	smooth = SMOOTH_FALSE
	can_buckle = 1
	buckle_lying = 1
	buckle_requires_restraints = 1
	var/mob/living/carbon/human/patient = null
	var/obj/machinery/computer/operating/computer = null

/obj/structure/table/optable/New()
	..()
	for(var/dir in cardinal)
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if(computer)
			computer.table = src
			break

/obj/structure/table/optable/proc/check_patient()
	var/mob/M = locate(/mob/living/carbon/human, loc)
	if(M)
		if(M.resting)
			patient = M
			return 1
	else
		patient = null
		return 0



/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = 1
	anchored = 1
	pass_flags = LETPASSTHROW //You can throw objects over this, despite it's density.
	var/health = 20

/obj/structure/rack/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				rack_destroy()
			else
				qdel(src)
		if(3)
			take_damage(rand(5,25), BRUTE, 0)

/obj/structure/rack/blob_act()
	if(prob(75))
		qdel(src)
	else
		rack_destroy()


/obj/structure/rack/mech_melee_attack(obj/mecha/M)
	visible_message("<span class='danger'>[M.name] smashes [src] apart!</span>")
	rack_destroy()

/obj/structure/rack/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0) return 1
	if(src.density == 0) //Because broken racks -Agouri |TODO: SPRITE!|
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/structure/rack/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSTABLE)

/obj/structure/rack/MouseDrop_T(obj/O, mob/user)
	if ((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
		return
	if(!user.drop_item())
		return
	if(O.loc != src.loc)
		step(O, get_dir(O, src))


/obj/structure/rack/attackby(obj/item/weapon/W, mob/user, params)
	if (istype(W, /obj/item/weapon/wrench) && !(flags&NODECONSTRUCT))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		rack_destroy()
		return
	if(user.a_intent == "harm")
		return ..()
	if(user.drop_item())
		W.Move(loc)
		return 1

/obj/structure/rack/attacked_by(obj/item/I, mob/living/user)
	..()
	take_damage(I.force, I.damtype)

/obj/structure/rack/attack_paw(mob/living/user)
	attack_hand(user)

/obj/structure/rack/attack_hulk(mob/living/carbon/human/user)
	..(user, 1)
	rack_destroy()
	return 1

/obj/structure/rack/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message("<span class='warning'>[user] kicks [src].</span>", \
						 "<span class='danger'>You kick [src].</span>")
	take_damage(rand(4,8), BRUTE)

/obj/structure/rack/attack_alien(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(src.loc, 'sound/weapons/bladeslice.ogg', 50, 1)
	visible_message("<span class='warning'>[user] slices [src] apart.</span>")
	rack_destroy()


/obj/structure/rack/attack_animal(mob/living/simple_animal/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(user.melee_damage_upper)
		if(user.environment_smash)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
			visible_message("<span class='warning'>[user] smashes [src] apart.</span>")
			rack_destroy()
		else
			take_damage(user.melee_damage_upper, user.melee_damage_type)


/obj/structure/rack/attack_tk() // no telehulk sorry
	return

/obj/structure/rack/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type, 0)

/obj/structure/rack/proc/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(loc, 'sound/items/dodgeball.ogg', 80, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			if(sound_effect)
				playsound(loc, 'sound/items/Welder.ogg', 40, 1)
		else
			return
	health -= damage
	if(health <= 0)
		rack_destroy()


/*
 * Rack destruction
 */

/obj/structure/rack/proc/rack_destroy()
	if(!(flags&NODECONSTRUCT))
		density = 0
		var/obj/item/weapon/rack_parts/newparts = new(loc)
		transfer_fingerprints_to(newparts)
	qdel(src)


/*
 * Rack Parts
 */

/obj/item/weapon/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/items.dmi'
	icon_state = "rack_parts"
	flags = CONDUCT
	materials = list(MAT_METAL=2000)

/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W, mob/user, params)
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( user.loc )
		qdel(src)
		return
	else
		return ..()

/obj/item/weapon/rack_parts/attack_self(mob/user)
	user << "<span class='notice'>You start constructing rack...</span>"
	if (do_after(user, 50, target = src))
		if(!user.drop_item())
			return
		var/obj/structure/rack/R = new /obj/structure/rack( user.loc )
		R.add_fingerprint(user)
		qdel(src)
		return

