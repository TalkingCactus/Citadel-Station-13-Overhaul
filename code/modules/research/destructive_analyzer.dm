//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/destructive_analyzer
	name = "Destructive Analyzer"
	desc = "Learn science by destroying things!"
	icon_state = "d_analyzer"
	var/decon_mod = 0

/obj/machinery/r_n_d/destructive_analyzer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/destructive_analyzer(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T


/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/obj/machinery/r_n_d/destructive_analyzer/Insert_Item(obj/item/O, mob/user)
	if(user.a_intent != "harm")
		. = 1
		if(!is_insertion_ready(user))
			return
		if(!O.origin_tech)
			user << "<span class='warning'>This doesn't seem to have a tech origin!</span>"
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if (temp_tech.len == 0)
			user << "<span class='warning'>You cannot deconstruct this item!</span>"
			return
		if(!user.drop_item())
			user << "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the [src.name]!</span>"
			return
		busy = 1
		loaded_item = O
		O.loc = src
		user << "<span class='notice'>You add the [O.name] to the [src.name]!</span>"
		flick("d_analyzer_la", src)
		spawn(10)
			busy = 0
