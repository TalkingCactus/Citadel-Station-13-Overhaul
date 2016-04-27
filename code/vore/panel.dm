
obj/vore_preferences
	// 0 = current vore mode, 1 = inside view, 2 = vore abilities, 3 = banned vores
	var/current_tab = 0
	var/tab_mod = 0

	var/mob/living/target

	var/loop //might as well make this a global list later instead

/obj/vore_preferences/New(client/C)
	//Get preferences
	loop=src
	if(!target) return

/obj/vore_preferences

	proc/GetOrgan(var/organ)
		switch(organ)

			if("Cock vore")
				return target.belly_balls
			if("Unbirth")
				return target.belly_womb
			if("Breast Vore")
				return target.belly_boobs
			if("tail vore")
				return target.belly_tail
//			if("insole")
//				return target.vore_insole_datum
//			if("insuit")
//				return target.vore_insuit_datum
			else
				return target.belly_stomach


	proc/GenerateMethodSwitcher(var/method,var/alt_name)
		var/dat=""
		dat += "<a href='?src=\ref[src];preference=current;method=[method]' [target.vore_current_method == method ? "class='linkOn'" : ""]>[alt_name]</a> "
		return dat

	proc/GenerateAbilitySwitcher(var/method,var/alt_name)
		var/dat=""
		dat += "<B>[alt_name]:</B> "
		if(method!=VORE_METHOD_ORAL)
			dat += AbilityHelper(method,VORE_SIZEDIFF_DISABLED,"Disable")
		dat += AbilityHelper(method,VORE_SIZEDIFF_TINY,"Tiny")
		dat += AbilityHelper(method,VORE_SIZEDIFF_SMALLER,"Smaller")
		dat += AbilityHelper(method,VORE_SIZEDIFF_SAMESIZE,"Same-Size")
		dat += AbilityHelper(method,VORE_SIZEDIFF_DOUBLE,"Bigger")
		if(target.vore_ability[num2text(VORE_METHOD_ORAL)]==VORE_SIZEDIFF_ANY)
			dat += AbilityHelper(method,VORE_SIZEDIFF_ANY,"Any")
		dat += "<BR>"
		return dat