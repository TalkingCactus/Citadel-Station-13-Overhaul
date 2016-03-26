//
//	Definition for oral voring someone
//

/datum/voretype/oral
	name = "Oral Vore"
	belly_target = "Stomach"

/datum/voretype/oral/eat_held_mob(var/mob/user, var/mob/living/prey, var/mob/living/pred)
	var/attempt_msg = "<span class='danger'>[user] is attempting to stuff [prey] down [pred]'s throat!</span>"
	var/success_msg = "<span class='danger'>[pred] swallows the last of [prey]!</span>"

	return perform_the_nom(user, prey, pred, attempt_msg, success_msg, 'sound/vore/gulp.ogg')

/datum/voretype/oral/feed_self_to_grabbed(var/mob/living/carbon/human/user, var/vore/pred_capable/pred)
	var/attempt_msg = "<span class='danger'>[user] is attempting to feed themselves to [pred]!</span>"
	var/success_msg = "<span class='danger'>[pred] swallows the last of [user]!</span>"

	return perform_the_nom(user, user, pred, attempt_msg, success_msg, 'sound/vore/gulp.ogg')

/datum/voretype/oral/feed_grabbed_to_self(var/mob/living/carbon/human/user, var/mob/prey)
	var/attempt_msg = "<span class='danger'>[user] is attempting to swallow down [prey]!</span>"
	var/success_msg = "<span class='danger'>[user] swallows the last of [prey]!</span>"

	return perform_the_nom(user, prey, user, attempt_msg, success_msg, 'sound/vore/gulp.ogg')

/datum/voretype/oral/feed_grabbed_to_other(var/mob/living/carbon/human/user, var/mob/prey, var/vore/pred_capable/pred)
	var/attempt_msg = "<span class='danger'>[user] is attempting to feed [prey] to [pred]!</span>"
	var/success_msg = "<span class='danger'>[pred] swallows the last of [prey]!</span>"

	return perform_the_nom(user, prey, pred, attempt_msg, success_msg, 'sound/vore/gulp.ogg')
