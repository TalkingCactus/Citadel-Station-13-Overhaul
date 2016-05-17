 // This file contains all Nano procs/definitions for external classes/objects

 /**
  * Called when a Nano UI window is closed
  * This is how Nano handles closed windows
  * It must be a verb so that it can be called using winset
  *
  * @return nothing
  */
/client/verb/voreclose(var/vuiref as text)
	set hidden = 1	// hide this verb from the user's panel
	set name = "voreclose"

	var/datum/voreui/vui = locate(vuiref)

	if (istype(vui))
	//	ui.vclose

		if(vui.ref)
			var/href = "close=1"
			src.Topic(href, params2list(href), vui.ref)	// this will direct to the atom's Topic() proc via client.Topic()
		else if (vui.on_close_logic)
			// no atomref specified (or not found)
			// so just reset the user mob's machine var
			if(src && src.mob)
				src.mob.unset_machine()

 /**
  * The vui_interact proc is used to open and update Nano UIs
  * If vui_interact is not used then the UI will not update correctly
  * vui_interact is currently defined for /atom/movable
  *
  * @param user /mob The mob who is interacting with this vui
  * @param ui_vkey string A string key to use for this vui. Allows for multiple unique vuis on one obj/mob (defaut value "main")
  * @param vui /datum/voreui This parameter is passed by the voreui process() proc when updating an open vui
  * @param force_open boolean Force the UI to (re)open, even if it's already open
  *
  * @return nothing
  */
/atom/movable/proc/vui_interact(mob/user, ui_vkey = "main", var/datum/voreui/vui = null, var/force_open = 1, var/datum/vore_vui/master_vui = null, var/datum/topic_state/custom_state = null)
	return

// Used by the Nano UI Manager (/datum/voremanager) to track UIs opened by this mob
/mob/var/list/open_vuis = list()
