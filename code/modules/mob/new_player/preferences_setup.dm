
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE,FEMALE)
	underwear = random_underwear(gender)
	undershirt = random_undershirt(gender)
	socks = random_socks()
	skin_tone = random_skin_tone()
	hair_style = random_hair_style(gender)
	facial_hair_style = random_facial_hair_style(gender)
	hair_color = random_short_color()
	facial_hair_color = hair_color
	eye_color = random_eye_color()
	if(!pref_species)
		var/rando_race = pick(config.roundstart_races)
		pref_species = new rando_race()
	backbag = 1
	features = random_features()
	age = rand(AGE_MIN,AGE_MAX)

/datum/preferences/proc/update_preview_icon()
	// Silicons only need a very basic preview since there is no customization for them.
	if(job_engsec_high)
		switch(job_engsec_high)
			if(AI)
				preview_icon = icon('icons/mob/AI.dmi', "AI", SOUTH)
				preview_icon.Scale(64, 64)
				return
			if(CYBORG)
				preview_icon = icon('icons/mob/robots.dmi', "robot", SOUTH)
				preview_icon.Scale(64, 64)
				return

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = new()
	copy_to(mannequin)

	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob
	var/highRankFlag = job_civilian_high | job_medsci_high | job_engsec_high

	if(job_civilian_low & ASSISTANT)
		previewJob = SSjob.GetJob("Assistant")
	else if(highRankFlag)
		var/highDeptFlag
		if(job_civilian_high)
			highDeptFlag = CIVILIAN
		else if(job_medsci_high)
			highDeptFlag = MEDSCI
		else if(job_engsec_high)
			highDeptFlag = ENGSEC

		for(var/datum/job/job in SSjob.occupations)
			if(job.flag == highRankFlag && job.department_flag == highDeptFlag)
				previewJob = job
				break

	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE)

	var/mutant_race=pref_species.id
	if(pref_species.id == "human" || !config.mutant_races)
		preview_icon = new /icon('icons/mob/human.dmi', "[skin_tone]_[g]_s")
	else
		/*preview_icon = new /icon('icons/mob/human.dmi', "[pref_species.id]_[g]_s")
		preview_icon.Blend("#[mutant_color]", ICON_MULTIPLY)*/
		preview_icon = new /icon('icons/mob/human.dmi', "[mutant_race]_[g]_s")
		var/icon/chk=new/icon('icons/mob/human.dmi')
		var/list/available_states=chk.IconStates()
		if(special_color[1]&&available_states.Find("[mutant_race]_[g]_s_1"))
			var/icon/sp_one = new/icon("icon" = 'icons/mob/human.dmi', "icon_state" = "[mutant_race]_[g]_s_1")
			sp_one.Blend("#[special_color[1]]", ICON_MULTIPLY)
			preview_icon.Blend(sp_one, ICON_OVERLAY)
		if(special_color[2]&&available_states.Find("[mutant_race]_[g]_s_2"))
			var/icon/sp_two = new/icon("icon" = 'icons/mob/human.dmi', "icon_state" = "[mutant_race]_[g]_s_2")
			sp_two.Blend("#[special_color[2]]", ICON_MULTIPLY)
			preview_icon.Blend(sp_two, ICON_OVERLAY)
		if(special_color[3]&&available_states.Find("[mutant_race]_[g]_s_3"))
			var/icon/sp_thr = new/icon("icon" = 'icons/mob/human.dmi', "icon_state" = "[mutant_race]_[g]_s_3")
			sp_thr.Blend("#[special_color[3]]", ICON_MULTIPLY)
			preview_icon.Blend(sp_thr, ICON_OVERLAY)

	preview_icon = icon('icons/effects/effects.dmi', "nothing")
	preview_icon.Scale(48+32, 16+32)

	mannequin.dir = NORTH
	var/icon/stamp = getFlatIcon(mannequin)
	preview_icon.Blend(stamp, ICON_OVERLAY, 25, 17)

	mannequin.dir = WEST
	stamp = getFlatIcon(mannequin)
	preview_icon.Blend(stamp, ICON_OVERLAY, 1, 9)

	mannequin.dir = SOUTH
	stamp = getFlatIcon(mannequin)
	preview_icon.Blend(stamp, ICON_OVERLAY, 49, 1)

	preview_icon.Scale(preview_icon.Width() * 2, preview_icon.Height() * 2) // Scaling here to prevent blurring in the browser.
	qdel(mannequin)
