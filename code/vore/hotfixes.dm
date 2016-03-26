// ---------------------------------------------
// -!-!-!-!-!-!-!-!- READ ME -!-!-!-!-!-!-!-!-!-
// ---------------------------------------------

// Only put verbs in here that are intended as a TEMPORARY FIX
// to deal with a bug we haven't figured out how to prevent yet,
// such as taur sprites getting fucked up sometimes which admins
// can't fix on the fly.
//
//
// That way we can just turn off the whole file when we don't need it.

//////////////////////////////
/// NW's taur reset button ///
//////////////////////////////

// This is, of course, just intended as a quick fix so that people can repair their own tails and taur bodies without admins having to get involved.

mob/proc/fixtaur()
	set name = "Fix size scale issues"
	set category = "Resize"
	var/lastplayerscale = src.playerscale
	src.playerscale = 1
	src.regenerate_icons()
	src.resize(lastplayerscale)
