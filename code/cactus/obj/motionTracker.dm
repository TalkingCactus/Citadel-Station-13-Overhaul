//////////////////////
////MOTION TRACKER////
//////////////////////

/obj/item/device/t_scanner/motionTracker
	name = "motion tracker"
	icon = 'code/cactus/obj/obj.dmi'
	icon_state = "tracker"
	desc = "A nifty handheld motion tracker that requires meson scanners to function properly. Won't pick up slow moving or miniscule movements."
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/cooldown = 35
	var/on_cooldown = 0
	var/range = 7
	var/meson = TRUE
	var/battery
	var/charge
	origin_tech = "engineering=4;magnets=5"

/obj/item/device/t_scanner/motionTracker/attack_self(mob/user)

	on = !on
	if(on)
		SSobj.processing |= src

/obj/item/device/t_scanner/motionTracker


/obj/item/device/t_scanner/motionTracker/proc/updateIcons()
	var/chargeFull = image('code/cactus/obj/obj.dmi', loc = src, icon_state = "trackerLightPowerFull")
	var/chargeHalf = image('code/cactus/obj/obj.dmi', loc = src, icon_state = "trackerLightPowerHalf")
	var/chargeLow = image('code/cactus/obj/obj.dmi', loc = src, icon_state = "trackerLightPowerLow")
	var/chargeEmpty = image('code/cactus/obj/obj.dmi', loc = src, icon_state = "trackerLightPowerEmpty")
	if(!charge)
		overlays = chargeEmpty
	else if(battery && battery.charge < (battery.maxcharge/5))
		overlays = chargeLow
	else if(battery && battery.charge < (battery.maxcharge/2))
		overlays = chargeHalf
	else if(battery && battery.charge > (battery.maxcharge/2))
		overlays = chargeFull

/obj/item/device/t_scanner/motionTracker/scan(mob/living/carbon/user)
	if(!on_cooldown)
		on_cooldown = 1
		spawn(cooldown)
			on_cooldown = 0
		var/turf/t = get_turf(src)
		var/list/mobs = recursive_mob_check(t, 1,0,0)
		if(!mobs.len)
			return
		motionTrackScan(mobs, range)


/proc/motionTrackScan(list/mobs, turf/T, range = world.view)
	var/blip = image('code/cactus/obj/obj.dmi', loc = src, icon_state = "blip")
	for(var/mob/living/M in range(range, src.loc))