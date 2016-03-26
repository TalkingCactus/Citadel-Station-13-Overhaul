//
//	Definition for tail voring someone
//

/datum/voretype/tail
	name = "Tail Vore"
	belly_target = "Tail"

/datum/voretype/tail/eat_held_mob(var/mob/user, var/mob/living/prey, var/mob/living/pred)
	var/attempt_msg = "<span class='danger'>[user] is trying to force [prey] into [pred]'s tail!</span>"
	var/success_msg = "<span class='danger'>[user] stuffs the last of [prey] into [pred]'s tail!</span>"

	return perform_the_nom(user, prey, pred, attempt_msg, success_msg, 'sound/vore/insert.ogg')

/datum/voretype/tail/feed_self_to_grabbed(var/mob/living/carbon/human/user, var/vore/pred_capable/pred)
	var/attempt_msg = "<span class='danger'>[user] is attempting to stuff theif self into [pred]'s tail!</span>"
	var/success_msg = "<span class='danger'>[user] stuffs their self fully into [pred]'s tail!</span>"

	return perform_the_nom(user, user, pred, attempt_msg, success_msg, 'sound/vore/insert.ogg')

/datum/voretype/tail/feed_grabbed_to_self(var/mob/living/carbon/human/user, var/mob/prey)
	var/attempt_msg = "<span class='danger'>[user] is attempting to stuff ["[prey]"] into \his tail!</span>"
	var/success_msg = "<span class='danger'>[user] stuffs ["[prey]"] into \his tail!</span>"

	return perform_the_nom(user, prey, user, attempt_msg, success_msg, 'sound/vore/insert.ogg')

/datum/voretype/tail/feed_grabbed_to_other(var/mob/living/carbon/human/user, var/mob/prey, var/vore/pred_capable/pred)
	var/attempt_msg = "<span class='danger'>[user] is attempting to stuff [prey] into [pred]'s tail!</span>"
	var/success_msg = "<span class='danger'>[pred] sucks [prey] into \his[pred] tail!</span>"

	return perform_the_nom(user, prey, pred, attempt_msg, success_msg, 'sound/vore/insert.ogg')
