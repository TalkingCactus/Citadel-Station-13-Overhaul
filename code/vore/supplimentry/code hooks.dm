// ======== Flavor Text ==========

/mob
	var/flavor_text = ""

/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		usr << "No."
	var/msg = input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",html_decode(flavor_text)) as message|null

	if(msg != null)
		msg = copytext(msg, 1, MAX_MESSAGE_LEN)
		msg = html_encode(msg)

		flavor_text = msg

/mob/proc/warn_flavor_changed()
	if(flavor_text && flavor_text != "") // don't spam people that don't use it!
		src << "<h2 class='alert'>OOC Warning:</h2>"
		src << "<span class='alert'>Your flavor text is likely out of date! <a href='byond://?src=\ref[src];flavor_change=1'>Change</a></span>"

/mob/proc/print_flavor_text()
	if (flavor_text && flavor_text != "")
		var/msg = replacetext(flavor_text, "\n", " ")
		if(lentext(msg) <= 40)
			return "\blue [msg]"
		else
			return "\blue [copytext(msg, 1, 37)]... <a href='byond://?src=\ref[src];flavor_more=1'>More...</a>"

/mob/Topic(href, href_list)
	if(href_list["flavor_more"])
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", name, replacetext(flavor_text, "\n", "<BR>")), text("window=[];size=500x200", name))
		onclose(usr, "[name]")
	if(href_list["flavor_change"])
		update_flavor_text()

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	flavor_text =  copytext(sanitize(input(usr, "Please enter your new flavour text.", "Flavour text", null)  as text), 1)

//Used in preferences' SetFlavorText and human's set_flavor verb
//Previews a string of len or less length
proc/copytext_preserve_html(var/text, var/first, var/last)
	return html_encode(copytext(html_decode(text), first, last))

proc/TextPreview(var/string,var/len=40)
	if(lentext(string) <= len)
		if(!lentext(string))
			return "\[...\]"
		else
			return string
	else
		return "[copytext(string, 1, 37)]..."


/mob/proc/Examine_flavor()
	set name = "Examine Flavor Text"
	set category = "OOC"
	set src in view()
	if(client)
		src << "[src]'s flavor text:<br>[flavor_text]"
	else
		src << "[src] does not have any stored infomation!"

	return

// ========= Flavor Text required code injections =============
/*

code/modules/client/preferences.dm

var/flavor_text = "" // Replacing var/metadata = ""

Under custom deity name imput in /datum/preferences/proc/ShowChoices(mob/user)

			dat += "<a href='byond://?src=\ref[user];preference=flavor_text;task=input'><b>Set Flavor Text</b></a><br>"
			if(lentext(flavor_text) <= 40)
				if(!lentext(flavor_text))
					dat += "\[...\]"
				else
					dat += "[flavor_text]"
			else
				dat += "[TextPreview(flavor_text)]...<br>"

 Replace 'if("metadata")'

				if("flavor_text")
					var/msg = input(usr,"Set the flavor text in your 'examine' verb. This can also be used for OOC notes and preferences!","Flavor Text",html_decode(flavor_text)) as message

					if(msg != null)
						msg = copytext(msg, 1, MAX_MESSAGE_LEN)
						msg = html_encode(msg)

						flavor_text = msg
at the very bottom:

character.flavor_text = flavor_text

--------------
In /mob/living/carbon/human/examine

msg += "<EM>[src.name]</EM>! [t_He] [t_is] \a [lowertext(dna.species)]!\n" Right under the name in human/examine

	if(print_flavor_text()) msg += "[print_flavor_text()]\n" just above the ending ------ line

--------------
code/modules/client/preferences_savefile.dm

replace all instances of metadata with flavor_text :

-	S["OOC_Notes"]			>> metadata
+	S["flavor_text"]		>> flavor_text

-	metadata		= sanitize_text(metadata, initial(metadata))
+	flavor_text		= sanitize_text(flavor_text, initial(flavor_text))

-	S["OOC_Notes"]			<< metadata
+	S["flavor_text"]		<< flavor_text

------------------------
Remove from mob/living/living.dm

/mob/living/proc/Examine_OOC()

---------------------------

add to mob/living/living.dm

verbs += /mob/living/proc/insidePanel
	verbs += /mob/living/proc/escapeOOC

	//Creates at least the typical 'stomach' on every mob.
	spawn(20) //Wait a couple of seconds to make sure copy_to or whatever has gone
		if(!vore_organs.len)
			var/datum/belly/B = new /datum/belly(src)
			B.immutable = 1
			B.name = "Stomach"
			B.inside_flavor = "It appears to be rather warm and wet. Makes sense, considering it's inside \the [name]."
			vore_organs[B.name] = B
			vore_selected = B.name

			if(istype(src,/mob/living/simple_animal))
				B.emote_lists[DM_HOLD] = list(
					"The insides knead at you gently for a moment.",
					"The guts glorp wetly around you as some air shifts.",
					"Your predator takes a deep breath and sighs, shifting you somewhat.",
					"The stomach squeezes you tight for a moment, then relaxes.",
					"During a moment of quiet, breathing becomes the most audible thing.",
					"The warm slickness surrounds and kneads on you.")

				B.emote_lists[DM_DIGEST] = list(
					"The caustic acids eat away at your form.",
					"The acrid air burns at your lungs.",
					"Without a thought for you, the stomach grinds inwards painfully.",
					"The guts treat you like food, squeezing to press more acids against you.",
					"The onslaught against your body doesn't seem to be letting up; you're food now.",
					"The insides work on you like they would any other food.")

==============
Carbon/life.dm

/mob/living/carbon/proc/breathe()
+ if(ismob(loc))	return

carbon/human/life.dm
/mob/living/carbon/human/proc/get_cold_protection(temperature)

+ if(ismob(loc))
	return 1

=====================

voreconstants.dm needs to be in _DEFINES

*/


/proc/vore_admins(var/msg) //used  to ensure that
	msg = "<span class=\"admin\"><span class=\"prefix\">VORE LOG:</span> <span class=\"message\">[msg]</span></span>"
	admins << msg

/proc/readd_quotes(var/t)
	var/list/repl_chars = list("&#34;" = "\"","&#39;" = "'")
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+5)
			index = findtext(t, char)
	return t

/* to cloning.dm
	if(H.client.prefs)
		H.vore_organs = H.client.prefs.belly_prefs.Copy()
		for(var/I in H.vore_organs)
			var/datum/belly/B = H.vore_organs[I]
			B.owner = H
			B.internal_contents = list()
			B.digest_mode = DM_HOLD

	H.flavor_texts = R.flavor.Copy()
	*/