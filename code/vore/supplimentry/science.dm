datum/design/shrinkray
	name = "Shrink Ray"
	desc = "Make people small."
	id = "shrinkray"
	req_tech = list("combat" = 5, "materials" = 3, "engineering" = 3, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000, "$diamond" = 1500)
	build_path = /obj/item/weapon/gun/energy/laser/sizeray/one
	category = list("Weapons")

datum/design/growthray
	name = "Growth Ray"
	desc = "Make people small... To the person you hit."
	id = "growthray"
	req_tech = list("combat" = 5, "materials" = 4, "engineering" = 3, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 1000, "$diamond" = 1500)
	build_path = /obj/item/weapon/gun/energy/laser/sizeray/two
	category = list("Weapons")

datum/design/stethoscope
	name = "Stethoscope"
	desc = "An ordinary stethoscope."
	id = "stethoscope"
	req_tech = list("biotech" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 50)
	build_path = /obj/item/clothing/tie/stethoscope
	category = list("Medical")

/*
datum/design/stethoscope_advanced
	name = "Stethoscope (Advanced)"
	desc = "An advanced stethoscope that can read micro-vibrations produced by DNA, or possibly something less silly."
	id = "stethoscope_advanced"
	req_tech = list("biotech" = 3, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 500)
	build_path = /obj/item/clothing/tie/stethoscope/advanced
	category = list("Medical")*/

/obj/item/projectile/sizeray
	name = "mystery beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	flag = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

/obj/item/projectile/sizeray/shrinkray/icon_state="bluelaser"
/obj/item/projectile/sizeray/growthray/icon_state="laser"

/obj/item/ammo_casing/energy/laser/growthray
	projectile_type = /obj/item/projectile/sizeray/growthray
	select_name = "redray"

/obj/item/ammo_casing/energy/laser/shrinkray
	projectile_type = /obj/item/projectile/sizeray/shrinkray
	select_name = "blueray"

/obj/item/projectile/sizeray/shrinkray/on_hit(var/atom/target, var/blocked = 0, var/mob/living/carbon/M as mob)
	for(var/size in list(RESIZE_BIG, RESIZE_NORMAL, RESIZE_SMALL, RESIZE_TINY))
		if(M.playerscale > size)
			M.resize(size)
	return 1

/obj/item/projectile/sizeray/growthray/on_hit(var/atom/target, var/blocked = 0, var/mob/living/carbon/M as mob)
	for(var/size in list(RESIZE_SMALL, RESIZE_NORMAL, RESIZE_BIG, RESIZE_HUGE))
		if(M.playerscale < size)
			M.resize(size)
	return 1




//Gun here
/obj/item/weapon/gun/energy/laser/sizeray
	name = "mystery raygun"
	icon_state = "bluetag"
	desc = "This will be fun!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/shrinkray)
	origin_tech = "combat=1;magnets=2"
	selfcharge = 1
	charge_delay = 5

	attackby(obj/item/W, mob/user)
		if(W==src)
			if(icon_state=="bluetag")
				icon_state="redtag"
				ammo_type = list(/obj/item/ammo_casing/energy/laser/growthray)
			else
				icon_state="bluetag"
				ammo_type = list(/obj/item/ammo_casing/energy/laser/shrinkray)
		return ..()


/obj/item/weapon/gun/energy/laser/sizeray/one
	name="shrink ray"
/obj/item/weapon/gun/energy/laser/sizeray/two
	name="growth ray"
	icon_state = "redtag"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/growthray)