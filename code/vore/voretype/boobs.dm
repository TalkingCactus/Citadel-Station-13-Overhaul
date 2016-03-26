//
//	Definition for breast voring someone
//

/datum/voretype/boobs
	name = "Breast Vore"
	belly_target = "Boob"

/datum/voretype/boobs/eat_held_mob(var/mob/user, var/mob/living/prey, var/mob/living/pred)
	var/attempt_msg = "<span class='danger'>[user] is trying to force [prey] into [pred]'s breasts!</span>"
	var/success_msg = "<span class='danger'>[user] stuffs the last of [prey] into [pred]'s boobs!</span>"

	return perform_the_nom(user, prey, pred, attempt_msg, success_msg, 'sound/vore/insert.ogg')

/datum/voretype/boobs/feed_self_to_grabbed(var/mob/living/carbon/human/user, var/vore/pred_capable/pred)
	var/attempt_msg = "<span class='danger'>[user] is attempting to stuff themselves into [pred]'s breasts!</span>"
	var/success_msg = "<span class='danger'>[user] pushes themselves fully into [pred]'s tits!</span>"

	return perform_the_nom(user, user, pred, attempt_msg, success_msg, 'sound/vore/insert.ogg')

/datum/voretype/boobs/feed_grabbed_to_self(var/mob/living/carbon/human/user, var/mob/prey)
	var/attempt_msg = "<span class='danger'>[user] is attempting to stuff ["[prey]"] into \his breasts!</span>"
	var/success_msg = "<span class='danger'>[user] sucks ["[prey]"] into \his tits!</span>"

	return perform_the_nom(user, prey, user, attempt_msg, success_msg, 'sound/vore/insert.ogg')

/datum/voretype/boobs/feed_grabbed_to_other(var/mob/living/carbon/human/user, var/mob/prey, var/vore/pred_capable/pred)
	var/attempt_msg = "<span class='danger'>[user] is attempting to stuff [prey] into [pred]'s breasts!</span>"
	var/success_msg = "<span class='danger'>[pred] sucks [prey] into \his[pred] tits!</span>"

	return perform_the_nom(user, prey, pred, attempt_msg, success_msg, 'sound/vore/insert.ogg')
