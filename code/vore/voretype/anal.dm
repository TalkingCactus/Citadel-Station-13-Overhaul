//
//	Definition for anal voring someone
//

/datum/voretype/anal
	name = "Anal Vore"
	belly_target = "Stomach"

/datum/voretype/anal/eat_held_mob(var/mob/user, var/mob/living/prey, var/mob/living/pred)
	var/attempt_msg = "<span class='danger'>[user] starts sliding [prey] up [pred]'s ass!</span>"
	var/success_msg = "<span class='danger'>[prey] fully slides into [pred]'s ass!</span>"

	return perform_the_nom(user, prey, pred, attempt_msg, success_msg, 'sound/vore/schlorp.ogg')

/datum/voretype/anal/feed_self_to_grabbed(var/mob/living/carbon/human/user, var/vore/pred_capable/pred)
	var/attempt_msg = "<span class='danger'>[user] is attempting to push themselves up [pred]'s rear!</span>"
	var/success_msg = "<span class='danger'>[user] disappears up [pred]'s ass!</span>"

	return perform_the_nom(user, user, pred, attempt_msg, success_msg, 'sound/vore/schlorp.ogg')

/datum/voretype/anal/feed_grabbed_to_self(var/mob/living/carbon/human/user, var/mob/prey)
	// Leshana; See docs for explanation of this wackohack.
	var/attempt_msg = "<span class='danger'>[user] is attempting to push ["[prey]"] up \his rear!</span>"
	var/success_msg = "<span class='danger'>[user] schlorps ["[prey]"] into \his rump!</span>"

	return perform_the_nom(user, prey, user, attempt_msg, success_msg, 'sound/vore/schlorp.ogg')

/datum/voretype/anal/feed_grabbed_to_other(var/mob/living/carbon/human/user, var/mob/prey, var/vore/pred_capable/pred)
	var/attempt_msg = "<span class='danger'>[user] is attempting to push [prey] up [pred]'s rear!</span>"
	var/success_msg = "<span class='danger'>[prey] disappears up [pred]'s ass!</span>"

	return perform_the_nom(user, prey, pred, attempt_msg, success_msg, 'sound/vore/schlorp.ogg')