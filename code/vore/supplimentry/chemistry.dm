/datum/reagent/vore/vore/semen
	data = list("adjective"=null, "type"=null, "digested"=null, "blood_DNA"=null, "blood_type"=null, "digested_type"=null, "donor_DNA"=null)
	name = "Semen"
	id = "semen"
	description = "A clear-ish white-ish liquid produced by the... sexual parts of mammals."
	color = "#DFDFDF" // rgb: 223, 223, 223

/datum/reagent/vore/vore/semen/reaction_turf(turf/simulated/T, reac_volume)
	if (!istype(T)) return
	if(reac_volume <= 3) return
	var/obj/effect/decal/cleanable/sex/sex_prop = locate() in T
	if(!sex_prop)
		sex_prop = new/obj/effect/decal/cleanable/sex/semen(T)
		sex_prop.blood_DNA[data["blood_DNA"]] = data["blood_type"]

/datum/reagent/vore/vore/femjuice
	data = list("adjective"=null, "type"=null, "digested"=null, "blood_DNA"=null, "digested_type"=null, "donor_DNA"=null)
	name = "Fem Cum"
	id = "femjuice"
	description = "A clear-ish white-ish liquid produced by the... sexual parts of mammals."
	color = "#AFAFAF"

/datum/reagent/vore/femjuice/reaction_turf(turf/simulated/T, reac_volume)
	if (!istype(T)) return
	if(reac_volume <= 3) return
	var/obj/effect/decal/cleanable/sex/sex_prop = locate() in T
	if(!sex_prop)
		sex_prop = new/obj/effect/decal/cleanable/sex/femjuice(T)
		sex_prop.blood_DNA[data["blood_DNA"]] = data["blood_type"]

/datum/reagent/vore/milk
	data = list("adjective"=null, "type"=null, "digested"=null, "digested_DNA"=null, "digested_type"=null, "donor_DNA"=null)

/datum/reagent/vore/milk/reaction_turf(turf/simulated/T, reac_volume)
	if (!istype(T)) return
	if (reac_volume <= 3) return
	var/obj/effect/decal/cleanable/sex/sex_prop = locate() in T
	if(!sex_prop)
		sex_prop = new/obj/effect/decal/cleanable/sex/milk(T)
		sex_prop.blood_DNA[data["blood_DNA"]] = data["blood_type"]

/datum/reagent/vore/shrinkchem
	name = "Shrink Chemical"
	id = "shrinkchem"
	description = "Shrinks people."
	reagent_state = LIQUID
	color = "#C8A5FF" // rgb: 200, 165, 220
	var/cnt_digested=0

/datum/reagent/vore/shrinkchem/on_mob_life(var/mob/living/carbon/M as mob)
	if(!M) M = holder.my_atom
	for(var/size in list(RESIZE_BIG, RESIZE_NORMAL, RESIZE_SMALL))
		if(volume>=1)
			cnt_digested++
		if(cnt_digested==5&&volume>1)
			if(M.playerscale > size)
				M.resize(size)
				M<<"You shrink."
		if(cnt_digested==20)
			cnt_digested=0
			M.playerscale = size
		if(volume<=1&&volume>0&&M.playerscale < size)
			M.resize(size)
			M<<"You grow back a little."
		holder.remove_reagent(src.id, 1)
		return
//		if(M.playerscale > size)
//			M.resize(size)
//			M << "<span class='alert'>You shrink!</span>"
		holder.remove_reagent(src.id, 1)
	..()
	return

/datum/reagent/vore/growchem
	name = "Grow Chemical"
	id = "growchem"
	description = "Enlarges people."
	reagent_state = LIQUID
	color = "#FFA5DC" // rgb: 200, 165, 220
	var/cnt_digested=0

/datum/reagent/vore/growchem/on_mob_life(var/mob/living/carbon/M as mob)
	if(!M) M = holder.my_atom
	for(var/size in list(RESIZE_NORMAL, RESIZE_BIG, RESIZE_HUGE))
		if(volume>=1)
			cnt_digested++
		if(cnt_digested==5&&volume>1)
			if(M.playerscale < size)
				M.resize(size)
				M<<"You grow."
		if(cnt_digested==20)
			cnt_digested=0
			M.playerscale = size
		if(volume<=1&&volume>0&&M.playerscale < size)
			M<<"You grow back a little."
			M.resize(size)
		holder.remove_reagent(src.id, 1)
	..()
	return

/datum/reagent/vore/vorechem
	name = "Vorarium"
	id = "vorechem"
	description = "Can be used to do an assortment of things."
	color = "#FF55A0" //I dunno =D

/datum/reagent/vore/narkychem
	name = "Narkanian Honey"
	id = "narkychem"
	description = "This lets you see lots of colours."
	color = "#CCAAFF"

/datum/reagent/vore/narkychem/on_mob_life(mob/living/M)
	if(!M) M = holder.my_atom
	if(data)
		M.druggy = max(M.druggy, 30)
		switch(data["count"])
			if(1 to 5)
				if(prob(5)) M.emote("giggle")
				else if(prob(10))
					if(prob(50))M.emote("dance")
					for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
						M.dir = i
						sleep(1)
			if(5 to 10)
				M.druggy = max(M.druggy, 35)
				if(prob(5)) M.emote("giggle")
				else if(prob(20))
					if(prob(30))M.emote("dance")
					for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
						M.dir = i
						sleep(1)
			if (10 to INFINITY)
				M.druggy = max(M.druggy, 40)
				if(prob(5)) M.emote("giggle")
				else if(prob(30))
					if(prob(20))M.emote("dance")
					for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2))
						M.dir = i
						sleep(1)
		data["count"]++
		holder.remove_reagent(src.id, 0.5)
		return

/datum/reagent/vore/vomitchem
	name = "Emetic"
	id = "vomitchem"
	description = "Makes you vomit."
	color = "#FFDD99"
	data = list("count"=1)

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		if(data)
			switch(data["count"])
				if(6,8)
					M.emote("choke")
				if (10 to INFINITY)
					M.Stun(rand(1,2))
					if(prob(35))
						regurgitate
						M.nutrition -= 50
						M.adjustToxLoss(-1)
						data["count"]=0
						holder.remove_any(holder.total_volume)

/datum/reagent/vore/hornychem
	name = "Aphrodisiac"
	id = "hornychem"
	description = "Is it warmer in here, or am I just too sexy?"
	color = "#FF9999"
	data = list("count"=1)
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/vore/hornychem/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(data)
		switch(data["count"])
			if(1 to 30)
				if(prob(9)) M.emote("blush")
			if (30 to INFINITY)
				if(prob(3)) M.emote("blush")
				if(prob(5)) M.emote("moan")
				if(prob(10))
					ejaculate
		data["count"]++


/datum/chemical_reaction/growchem
	name = "Growchem"
	id = "growchem"
	result = "growchem"
	required_reagents = list("hydrogen" = 1, "vorechem" = 1)
	result_amount = 2

/datum/chemical_reaction/shrinkchem
	name = "Shrinkchem"
	id = "shrinkchem"
	result = "shrinkchem"
	required_reagents = list("sodium" = 1, "vorechem" = 1)
	result_amount = 2

/datum/chemical_reaction/vomitchem
	name = "Vomitchem"
	id = "vomitchem"
	result = "vomitchem"
	required_reagents = list("chlorine" = 1, "vorechem" = 1)
	result_amount = 2

/datum/chemical_reaction/hornychem
	name = "Hornychem"
	id = "hornychem"
	result = "hornychem"
	required_reagents = list("lithium" = 1, "vorechem" = 1)
	result_amount = 2

/obj/item/weapon/reagent_containers/pill/shrink
	name = "shrink pill"
	desc = "Used to shrink people."
	icon_state = "pill18"
	New()
		..()
		reagents.add_reagent("shrinkchem", 10)

/obj/item/weapon/reagent_containers/pill/grow
	name = "grow pill"
	desc = "Used to make people larger."
	icon_state = "pill19"
	New()
		..()
		reagents.add_reagent("growchem", 10)

/datum/chemical_reaction/narkychem
	name = "Narkychem"
	id = "narkychem"
	result = "narkychem"
	required_reagents = list("vorechem" = 1, "spacemountainwind" = 1, "femjuice" = 2)
	//required_catalysts = list("femjuice" = 2)
	result_amount=4

/datum/chemical_reaction/narkychem/on_reaction(var/datum/reagents/holder, var/created_volume, var/data_send)

	//var/datum/reagent/vore/femjuice/F = locate(/datum/reagent/vore/femjuice) in holder.reagent_list
	var/list/F=null
	if(data_send)
		F=data_send["femjuice"]
	var/datum/reagent/vore/narkychem/A = locate(/datum/reagent/vore/narkychem) in holder.reagent_list
	if(F)
		A.on_merge(F)

//objects
/obj/effect/decal/cleanable/sex/semen
	name = "semen"
	desc = "A puddle of hot, sticky spooge."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "semen1"
	random_icon_states = list("semen1", "semen2", "semen3")

/obj/effect/decal/cleanable/sex/femjuice
	name = "femjuice"
	desc = "A puddle of warm fem-cum. Someone got excited."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "fem1"
	random_icon_states = list("fem1", "fem2", "fem3")

/obj/effect/decal/cleanable/sex/milk
	name = "breast milk"
	desc = "A puddle of warm breast-milk."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "milk1"
	random_icon_states = list("milk1", "milk2", "milk3")

/atom/proc/add_femjuice_floor(mob/living/carbon/M)
	if( istype(src, /turf/simulated) )
		var/obj/effect/decal/cleanable/sex/femjuice/this = new /obj/effect/decal/cleanable/sex/femjuice(src)
		if(M.reagents)
			M.reagents.trans_to(this, M.reagents.total_volume / 10)

/atom/proc/add_semen_floor(mob/living/carbon/M)
	if( istype(src, /turf/simulated) )
		var/obj/effect/decal/cleanable/sex/semen/this = new /obj/effect/decal/cleanable/sex/semen(src)
		if(M.reagents)
			M.reagents.trans_to(this, M.reagents.total_volume / 10)

/atom/proc/add_milk_floor(mob/living/carbon/M)
	if( istype(src, /turf/simulated) )
		var/obj/effect/decal/cleanable/sex/milk/this = new /obj/effect/decal/cleanable/sex/milk(src)
		if(M.reagents)
			M.reagents.trans_to(this, M.reagents.total_volume / 10)




// ====================
// Mean Poojy things
// ====================

/datum/chemical_reaction/rotatium
	name = "Rotatium"
	id = "Rotatium"
	result = "rotatium"
	required_reagents = list("mindbreaker" = 1, "vorechem" = 1, "neurotoxin2" = 1)
	result_amount = 3
	mix_message = "<span class='danger'>After sparks, fire, and the smell of mindbreaker, the mix is constantly spinning with no stop in sight.</span>"
	required_temp = 400

/datum/reagent/toxin/rotatium //Rotatium. Fucks up your rotation and is hilarious
	name = "Rotatium"
	id = "rotatium"
	description = "A constantly swirling, oddly colourful fluid. Causes the consumer's sense of direction and hand-eye coordination to become wild."
	reagent_state = LIQUID
	color = "#FFFF00" //RGB: 255, 255, 0 Bright ass yellow
	metabolization_rate = 0.6 * REAGENTS_METABOLISM
	toxpwr = 0
	var/rotate_timer = 0

/datum/reagent/toxin/rotatium/on_mob_life(mob/living/M)
	rotate_timer++
	if(M.reagents.get_reagent_amount("rotatium") < 2)
		M.client.dir = NORTH
		..()
		return
	if(rotate_timer >= rand(5,30)) //Random rotations are wildly unpredictable and hilarious
		rotate_timer = 0
		M.client.dir = pick(NORTH, EAST, SOUTH, WEST)
	..()
/datum/reagent/toxin/rotatium/on_mob_delete(mob/living/M)
	M.client.dir = NORTH
	..()