//
//	Definition for anal voring someone
//

/datum/voretype/unbirth
	name = "Unbirth"
	belly_target = "Womb"

/datum/voretype/unbirth/eat_held_mob(var/mob/user, var/mob/living/prey, var/mob/living/pred)
	var/attempt_msg = "<span class='danger'>[user] starts to push [prey] into [pred]'s pussy!</span>"
	var/success_msg = "<span class='danger'>The last of [prey] vanishes into [pred]'s vagina!</span>"

	return perform_the_nom(user, prey, pred, attempt_msg, success_msg, 'sound/vore/schlorp.ogg')

/datum/voretype/unbirth/feed_self_to_grabbed(var/mob/living/carbon/human/user, var/vore/pred_capable/pred)
	var/attempt_msg = "<span class='danger'>[user] is attempting to climb into [pred]'s pussy!</span>"
	var/success_msg = "<span class='danger'>[user] squelches into [pred]'s womb!</span>"

	return perform_the_nom(user, user, pred, attempt_msg, success_msg, 'sound/vore/schlorp.ogg')

/datum/voretype/unbirth/feed_grabbed_to_self(var/mob/living/carbon/human/user, var/mob/prey)
	var/attempt_msg = "<span class='danger'>[user] is attempting to unbirth [prey]!</span>"
	var/success_msg = "<span class='danger'>[user] squelches ["[prey]"] into \his womb!</span>"

	return perform_the_nom(user, prey, user, attempt_msg, success_msg, 'sound/vore/schlorp.ogg')

/datum/voretype/unbirth/feed_grabbed_to_other(var/mob/living/carbon/human/user, var/mob/prey, var/vore/pred_capable/pred)
	var/attempt_msg = "<span class='danger'>[user] is attempting to push [prey] into [pred]'s pussy!</span>"
	var/success_msg = "<span class='danger'>[prey] squelches into [pred]'s womb!</span>"

	return perform_the_nom(user, prey, pred, attempt_msg, success_msg, 'sound/vore/schlorp.ogg')
