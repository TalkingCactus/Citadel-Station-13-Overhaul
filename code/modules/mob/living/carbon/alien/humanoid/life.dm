//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/alien/humanoid/proc/adjust_body_temperature(current, loc_temp, boost)
	var/temperature = current
	var/difference = abs(current-loc_temp)	//get difference
	var/increments// = difference/10			//find how many increments apart they are
	if(difference > 50)
		increments = difference/5
	else
		increments = difference/10
	var/change = increments*boost	// Get the amount to change by (x per increment)
	var/temp_change
	if(current < loc_temp)
		temperature = min(loc_temp, temperature+change)
	else if(current > loc_temp)
		temperature = max(loc_temp, temperature-change)
	temp_change = (temperature - current)
	return temp_change

/mob/living/carbon/alien/humanoid/check_breath(datum/gas_mixture/breath) //BREATHING SOUNDS *SHIVER*
	if((breath && breath.total_moles() > 0) && health >= 1 && !sneaking)
		playsound(src.loc, pick('sound/alien/Voice/lowHiss2.ogg', 'sound/alien/Voice/lowHiss3.ogg', 'sound/alien/Voice/lowHiss4.ogg'), 50, 0, -5)
	..()