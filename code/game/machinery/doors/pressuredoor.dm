#define PRESSUREDOOR_MAX_PRESSURE_DIFF 25 // kPa

/obj/machinery/door/firedoor/pressure
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "door_open"
	req_one_access = list(access_atmospherics, access_engine_equip)
	closingLayer = 3.12 // Just above firelocks and doors when closed
	var/blocked = 0
	var/lockdown = 0 // When the door has detected a problem, it locks.
	var/pdiff_alert = 0
	var/pdiff = 0
	explosion_block = 5

/obj/machinery/door/firedoor/pressure/Bumped(atom/AM)
	if(panel_open || operating)
		return
	if(!density)
		return ..()
	return 0


/obj/machinery/door/firedoor/pressure/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
		latetoggle()
	else
		stat |= NOPOWER
	return
/obj/machinery/door/firedoor/pressure/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.

	if(blocked)
		user << "<span class='warning'>\The [src] is welded solid!</span>"
		return

	var/alarmed = lockdown
	for(var/area/A in areas_added)		//Checks if there are fire alarms in any areas associated with that firedoor
		if(A.fire || A.air_doors_activated)
			alarmed = 1

	var/answer = alert(user, "Would you like to [density ? "open" : "close"] this [src.name]?[ alarmed && density ? "\nNote that by doing so, you acknowledge any damages from opening this\n[src.name] as being your own fault, and you will be held accountable under the law." : ""]",\
	"\The [src]", "Yes, [density ? "open" : "close"]", "No")
	if(answer == "No")
		return
	if(user.incapacitated() || (get_dist(src, user) > 1  && !issilicon(user)))
		user << "Sorry, you must remain able bodied and close to \the [src] in order to use it."
		return
	if(density && (stat & (BROKEN|NOPOWER))) //can still close without power
		user << "\The [src] is not functioning, you'll have to force it open manually."
		return

	if(alarmed && density && lockdown && !allowed(user))
		user << "<span class='warning'>Access denied.  Please wait for authorities to arrive, or for the alert to clear.</span>"
		return
	else
		user.visible_message("<span class='notice'>\The [src] [density ? "open" : "close"]s for \the [user].</span>",\
		"\The [src] [density ? "open" : "close"]s.",\
		"You hear a beep, and a door opening.")

	var/needs_to_close = 0
	if(density)
		if(alarmed)
			// Accountability!
			users_to_open |= user.name
			needs_to_close = !issilicon(user)
		spawn()
			open()
	else
		spawn()
			close()

	if(needs_to_close)
		spawn(50)
			alarmed = 0
			for(var/area/A in areas_added)		//Just in case a fire alarm is turned off while the firedoor is going through an autoclose cycle
				if(A.fire || A.air_doors_activated)
					alarmed = 1
			if(alarmed)
				nextstate = FIREDOOR_CLOSED
				close()


/obj/machinery/door/firedoor/pressure/attackby(obj/item/weapon/C, mob/user, params)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.

	if(istype(C, /obj/item/weapon/wrench) && panel_open)
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] starts undoing [src]'s bolts...</span>", \
							 "<span class='notice'>You start unfastening [src]'s floor bolts...</span>")
		if(!do_after(user, 50/C.toolspeed, target = src))
			return
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] unfastens [src]'s bolts.</span>", \
							 "<span class='notice'>You undo [src]'s floor bolts.</span>")
		var/obj/structure/firelock_frame/F = new(get_turf(src))
		F.reinforced = 1
		F.constructionStep = CONSTRUCTION_PANEL_OPEN
		F.update_icon()
		qdel(src)
		return

	if(istype(C, /obj/item/weapon/screwdriver))
		default_deconstruction_screwdriver(user, icon_state, icon_state, C)
		return

	return ..()


/obj/machinery/door/firedoor/pressure/try_to_weld(obj/item/weapon/weldingtool/W, mob/user)
	if(W.remove_fuel(0, user))
		welded = !welded
		user << "<span class='danger'>You [welded?"welded":"unwelded"] \the [src]</span>"
		update_icon()

/obj/machinery/door/firedoor/pressure/try_to_crowbar(obj/item/I, mob/user)
	if(welded || operating)
		return
	if(density)
		open()
	else
		close()

/obj/machinery/door/firedoor/pressure/attack_ai(mob/user)
	add_fingerprint(user)
	if(welded || operating || stat & NOPOWER)
		return
	if(density)
		open()
	else
		close()

/obj/machinery/door/firedoor/pressure/attack_alien(mob/user)
	add_fingerprint(user)
	if(welded)
		user << "<span class='warning'>[src] refuses to budge!</span>"
		return
	open()

/obj/machinery/door/firedoor/pressure/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)

/obj/machinery/door/firedoor/pressure/update_icon()
	overlays.Cut()
	if(density)
		icon_state = "door_closed"
		if(welded)
			overlays += "welded"
	else
		icon_state = "door_open"
		if(welded)
			overlays += "welded_open"

/obj/machinery/door/firedoor/pressure/open()
	. = ..()
	latetoggle()

/obj/machinery/door/firedoor/pressure/close()
	. = ..()
	latetoggle()

/obj/machinery/door/firedoor/pressure/proc/latetoggle()
	if(operating || stat & NOPOWER || !nextstate)
		return
	switch(nextstate)
		if(OPEN)
			nextstate = null
			open()
		if(CLOSED)
			nextstate = null
			close()


/obj/machinery/door/firedoor/pressure/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	flags = ON_BORDER

/obj/machinery/door/firedoor/pressure/border_only/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	else
		return 1

/obj/machinery/door/firedoor/pressure/border_only/CheckExit(atom/movable/mover as mob|obj, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/firedoor/pressure/border_only/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

/obj/item/weapon/electronics/firelock/pressure
	name = "pressure lock circuitry"
	desc = "A circuit board used in construction of pressure locks."
	icon_state = "mainboard"

/obj/structure/pressurelock_frame
	name = "pressurelock frame"
	desc = "A partially completed pressurelock."
	icon = 'icons/obj/doors/Doorfire.dmi'
	icon_state = "frame1"
	anchored = 0
	density = 1
	var/constructionStep = CONSTRUCTION_NOCIRCUIT
	var/reinforced = 0

/obj/structure/pressurelock_frame/examine(mob/user)
	..()
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			user << "There is a small metal plate covering the wires."
		if(CONSTRUCTION_WIRES_EXPOSED)
			user << "Wires are trailing from the maintenance panel."
		if(CONSTRUCTION_GUTTED)
			user << "The circuit board is visible."
		if(CONSTRUCTION_NOCIRCUIT)
			user << "There are no electronics in the frame."

		if(pdiff >= PRESSUREDOOR_MAX_PRESSURE_DIFF)
			user << "<span class='warning'>WARNING: Current pressure differential is [pdiff]kPa! Opening door may result in injury!</span>"


/obj/structure/pressurelock_frame/update_icon()
	..()
	icon_state = "frame[constructionStep]"

/obj/structure/pressurelock_frame/attackby(obj/item/weapon/C, mob/user)
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			if(istype(C, /obj/item/weapon/crowbar))
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] starts prying something out from [src]...</span>", \
									 "<span class='notice'>You begin prying out the wire cover...</span>")
				if(!do_after(user, 50/C.toolspeed, target = src)) return
				if(constructionStep != CONSTRUCTION_PANEL_OPEN) return
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] pries out a metal plate from [src], exposing the wires.</span>", \
									 "<span class='notice'>You remove the cover plate from [src], exposing the wires.</span>")
				constructionStep = CONSTRUCTION_WIRES_EXPOSED
				update_icon()
				return
			if(istype(C, /obj/item/weapon/wrench))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] starts bolting down [src]...</span>", \
									 "<span class='notice'>You begin bolting [src]...</span>")
				if(!do_after(user, 30/C.toolspeed, target = src)) return
				user.visible_message("<span class='notice'>[user] finishes the pressurelock.</span>", \
									 "<span class='notice'>You finish the pressurelock.</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				else
					new /obj/machinery/door/firedoor/pressurelock(get_turf(src))
				qdel(src)
				return
		if(CONSTRUCTION_WIRES_EXPOSED)
			if(istype(C, /obj/item/weapon/wirecutters))
				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] starts cutting the wires from [src]...</span>", \
									 "<span class='notice'>You begin removing [src]'s wires...</span>")
				if(!do_after(user, 60/C.toolspeed, target = src)) return
				if(constructionStep != CONSTRUCTION_WIRES_EXPOSED) return
				user.visible_message("<span class='notice'>[user] removes the wires from [src].</span>", \
									 "<span class='notice'>You remove the wiring from [src], exposing the circuit board.</span>")
				var/obj/item/stack/cable_coil/B = new(get_turf(src))
				B.amount = 5
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
			if(istype(C, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/W = C
				if(W.remove_fuel(1, user))
					playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
					user.visible_message("<span class='notice'>[user] starts welding a metal plate into [src]...</span>", \
										 "<span class='notice'>You begin welding the cover plate back onto [src]...</span>")
					if(!do_after(user, 80/C.toolspeed, target = src)) return
					if(constructionStep != CONSTRUCTION_WIRES_EXPOSED) return
					playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("<span class='notice'>[user] welds the metal plate into [src].</span>", \
										 "<span class='notice'>You weld [src]'s cover plate into place, hiding the wires.</span>")
				constructionStep = CONSTRUCTION_PANEL_OPEN
				update_icon()
				return
		if(CONSTRUCTION_GUTTED)
			if(istype(C, /obj/item/weapon/crowbar))
				user.visible_message("<span class='notice'>[user] begins removing the circuit board from [src]...</span>", \
									 "<span class='notice'>You begin prying out the circuit board from [src]...</span>")
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				if(!do_after(user, 50/C.toolspeed, target = src)) return
				if(constructionStep != CONSTRUCTION_GUTTED) return
				user.visible_message("<span class='notice'>[user] removes [src]'s circuit board.</span>", \
									 "<span class='notice'>You remove the circuit board from [src].</span>")
				new /obj/item/weapon/electronics/firelock/pressure(get_turf(src))
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				constructionStep = CONSTRUCTION_NOCIRCUIT
				update_icon()
				return
			if(istype(C, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/B = C
				if(B.amount < 5)
					user << "<span class='warning'>You need more wires to add wiring to [src].</span>"
					return
				user.visible_message("<span class='notice'>[user] begins wiring [src]...</span>", \
									 "<span class='notice'>You begin adding wires to [src]...</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(!do_after(user, 60, target = src)) return
				if(constructionStep != CONSTRUCTION_GUTTED) return
				user.visible_message("<span class='notice'>[user] adds wires to [src].</span>", \
									 "<span class='notice'>You wire [src].</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				B.use(5)
				constructionStep = CONSTRUCTION_WIRES_EXPOSED
				update_icon()
				return
		if(CONSTRUCTION_NOCIRCUIT)
			if(istype(C, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/W = C
				if(W.remove_fuel(1,user))
					playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
					user.visible_message("<span class='notice'>[user] begins cutting apart [src]'s frame...</span>", \
										 "<span class='notice'>You begin slicing [src] apart...</span>")
					if(!do_after(user, 80/C.toolspeed, target = src)) return
					if(constructionStep != CONSTRUCTION_NOCIRCUIT) return
					user.visible_message("<span class='notice'>[user] cuts apart [src]!</span>", \
										 "<span class='notice'>You cut [src] into metal.</span>")
					playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
					var/obj/item/stack/sheet/metal/M = new(get_turf(src))
					M.amount = 3
					qdel(src)
				return
			if(istype(C, /obj/item/weapon/electronics/firelock/pressure))
				user.visible_message("<span class='notice'>[user] starts adding [C] to [src]...</span>", \
									 "<span class='notice'>You begin adding a circuit board to [src]...</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(!do_after(user, 40, target = src)) return
				if(constructionStep != CONSTRUCTION_NOCIRCUIT) return
				user.drop_item()
				qdel(C)
				user.visible_message("<span class='notice'>[user] adds a circuit to [src].</span>", \
									 "<span class='notice'>You insert and secure [C].</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
	return ..()

	// CHECK PRESSURE
/obj/machinery/door/firedoor/pressure/process()
	..()

	if(density && next_process_time <= world.time)
		next_process_time = world.time + 100		// 10 second delays between process updates
		var/changed = 0
		lockdown=0
		// Pressure alerts
		pdiff = getOPressureDifferential(src.loc)
		if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
			lockdown = 1
			if(!pdiff_alert)
				pdiff_alert = 1
				changed = 1 // update_icon()
		else
			if(pdiff_alert)
				pdiff_alert = 0
				changed = 1 // update_icon()

		tile_info = getCardinalAirInfo(src.loc,list("temperature","pressure"))
		var/old_alerts = dir_alerts
		for(var/index = 1; index <= 4; index++)
			var/list/tileinfo=tile_info[index]
			if(tileinfo==null)
				continue // Bad data.
			var/celsius = convert_k2c(tileinfo[1])

			var/alerts=0

			// Temperatures
			if(celsius >= FIREDOOR_MAX_TEMP)
				alerts |= FIREDOOR_ALERT_HOT
				lockdown = 1
			else if(celsius <= FIREDOOR_MIN_TEMP)
				alerts |= FIREDOOR_ALERT_COLD
				lockdown = 1

			dir_alerts[index]=alerts

		if(dir_alerts != old_alerts)
			changed = 1
		if(changed)
			update_icon()