// This is the window/UI manager for Nano UI
// There should only ever be one (global) instance of nanomanger
/datum/voremanager
	// a list of current open /voreui UIs, grouped by src_object and ui_vkey
	var/open_uis[0]
	// a list of current open /voreui UIs, not grouped, for use in processing
	var/list/processing_uis = list()
	// a list of asset filenames which are to be sent to the client on user logon
	var/list/asset_files = list()

 /**
  * Create a new voremanager instance.
  * This proc generates a list of assets which are to be sent to each client on connect
  *
  * @return /voremanager new voremanager object
  */
/datum/voremanager/New()
	var/list/nano_asset_dirs = list(\
		"nano/css/",\
		"nano/images/",\
		"nano/js/",\
		"nano/templates/"\
	)

	var/list/filenames = null
	for (var/path in nano_asset_dirs)
		filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // filenames which end in "/" are actually directories, which we want to ignore
				if(fexists(path + filename))
					asset_files.Add(fcopy_rsc(path + filename)) // add this file to asset_files for sending to clients when they connect

	return

 /**
  * Get an open /voreui ui for the current user, src_object and ui_vkey and try to update it with data
  *
  * @param user /mob The mob who opened/owns the ui
  * @param src_object /obj|/mob The obj or mob which the ui belongs to
  * @param ui_vkey string A string key used for the ui
  * @param ui /datum/voreui An existing instance of the ui (can be null)
  * @param data list The data to be passed to the ui, if it exists
  * @param force_open boolean The ui is being forced to (re)open, so close ui if it exists (instead of updating)
  *
  * @return /voreui Returns the found ui, for null if none exists
  */
/datum/voremanager/proc/try_update_ui(var/mob/user, src_object, ui_vkey, var/datum/voreui/ui, data, var/force_open = 0)
	if (isnull(ui)) // no ui has been passed, so we'll search for one
	{
		ui = get_open_ui(user, src_object, ui_vkey)
	}
	if (!isnull(ui))
		// The UI is already open
		if (!force_open)
			ui.push_data(data)
			return ui
		else
			//testing("voremanager/try_update_ui mob [user.name] [src_object:name] [ui_vkey] [force_open] - forcing opening of ui")
			ui.vclose()
	return null

 /**
  * Get an open /voreui ui for the current user, src_object and ui_vkey
  *
  * @param user /mob The mob who opened/owns the ui
  * @param src_object /obj|/mob The obj or mob which the ui belongs to
  * @param ui_vkey string A string key used for the ui
  *
  * @return /voreui Returns the found ui, or null if none exists
  */
/datum/voremanager/proc/get_open_ui(var/mob/user, src_object, ui_vkey)
	var/src_object_key = "\ref[src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		//testing("voremanager/get_open_ui mob [user.name] [src_object:name] [ui_vkey] - there are no uis open")
		return null
	else if (isnull(open_uis[src_object_key][ui_vkey]) || !istype(open_uis[src_object_key][ui_vkey], /list))
		//testing("voremanager/get_open_ui mob [user.name] [src_object:name] [ui_vkey] - there are no uis open for this object")
		return null

	for (var/datum/voreui/ui in open_uis[src_object_key][ui_vkey])
		if (ui.user == user)
			return ui

	//testing("voremanager/get_open_ui mob [user.name] [src_object:name] [ui_vkey] - ui not found")
	return null

 /**
  * Update all /voreui uis attached to src_object
  *
  * @param src_object /obj|/mob The obj or mob which the uis are attached to
  *
  * @return int The number of uis updated
  */
/datum/voremanager/proc/update_uis(src_object)
	var/src_object_key = "\ref[src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return 0

	var/update_count = 0
	for (var/ui_vkey in open_uis[src_object_key])
		for (var/datum/voreui/ui in open_uis[src_object_key][ui_vkey])
			if(ui && ui.src_object && ui.user && ui.src_object.vore_host())
				ui.process_vui(1)
				update_count++
	return update_count

 /**
  * Update /voreui uis belonging to user
  *
  * @param user /mob The mob who owns the uis
  * @param src_object /obj|/mob If src_object is provided, only update uis which are attached to src_object (optional)
  * @param ui_vkey string If ui_vkey is provided, only update uis with a matching ui_vkey (optional)
  *
  * @return int The number of uis updated
  */
/datum/voremanager/proc/update_user_uis(var/mob/user, src_object = null, ui_vkey = null)
	if (isnull(user.open_uis) || !istype(user.open_uis, /list) || open_uis.len == 0)
		return 0 // has no open uis

	var/update_count = 0
	for (var/datum/voreui/ui in user.open_uis)
		if ((isnull(src_object) || !isnull(src_object) && ui.src_object == src_object) && (isnull(ui_vkey) || !isnull(ui_vkey) && ui.ui_vkey == ui_vkey))
			ui.process_vui(1)
			update_count++

	return update_count

 /**
  * Close /voreui uis belonging to user
  *
  * @param user /mob The mob who owns the uis
  * @param src_object /obj|/mob If src_object is provided, only close uis which are attached to src_object (optional)
  * @param ui_vkey string If ui_vkey is provided, only close uis with a matching ui_vkey (optional)
  *
  * @return int The number of uis closed
  */
/datum/voremanager/proc/close_user_uis(var/mob/user, src_object = null, ui_vkey = null)
	if (isnull(user.open_uis) || !istype(user.open_uis, /list) || open_uis.len == 0)
		//testing("voremanager/close_user_uis mob [user.name] has no open uis")
		return 0 // has no open uis

	var/close_count = 0
	for (var/datum/voreui/ui in user.open_uis)
		if ((isnull(src_object) || !isnull(src_object) && ui.src_object == src_object) && (isnull(ui_vkey) || !isnull(ui_vkey) && ui.ui_vkey == ui_vkey))
			ui.vclose()
			close_count++

	//testing("voremanager/close_user_uis mob [user.name] closed [open_uis.len] of [close_count] uis")

	return close_count

 /**
  * Add a /voreui ui to the list of open uis
  * This is called by the /voreui open() proc
  *
  * @param ui /voreui The ui to add
  *
  * @return nothing
  */
/datum/voremanager/proc/ui_vopened(var/datum/voreui/ui)
	var/src_object_key = "\ref[ui.src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		open_uis[src_object_key] = list(ui.ui_vkey = list())
	else if (isnull(open_uis[src_object_key][ui.ui_vkey]) || !istype(open_uis[src_object_key][ui.ui_vkey], /list))
		open_uis[src_object_key][ui.ui_vkey] = list();

	ui.user.open_uis.Add(ui)
	var/list/uis = open_uis[src_object_key][ui.ui_vkey]
	uis.Add(ui)
	processing_uis.Add(ui)
	//testing("voremanager/ui_opened mob [ui.user.name] [ui.src_object:name] [ui.ui_vkey] - user.open_uis [ui.user.open_uis.len] | uis [uis.len] | processing_uis [processing_uis.len]")

 /**
  * Remove a /voreui ui from the list of open uis
  * This is called by the /voreui close() proc
  *
  * @param ui /voreui The ui to remove
  *
  * @return int 0 if no ui was removed, 1 if removed successfully
  */
/datum/voremanager/proc/ui_vclosed(var/datum/voreui/ui)
	var/src_object_key = "\ref[ui.src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return 0 // wasn't open
	else if (isnull(open_uis[src_object_key][ui.ui_vkey]) || !istype(open_uis[src_object_key][ui.ui_vkey], /list))
		return 0 // wasn't open

	processing_uis.Remove(ui)
	if(ui.user)	// Sanity check in case a user has been deleted (say a blown up borg watching the alarm interface)
		ui.user.open_uis.Remove(ui)
	var/list/uis = open_uis[src_object_key][ui.ui_vkey]
	uis.Remove(ui)

	//testing("voremanager/ui_closed mob [ui.user.name] [ui.src_object:name] [ui.ui_vkey] - user.open_uis [ui.user.open_uis.len] | uis [uis.len] | processing_uis [processing_uis.len]")

	return 1

 /**
  * This is called on user logout
  * Closes/clears all uis attached to the user's /mob
  *
  * @param user /mob The user's mob
  *
  * @return nothing
  */

//
/datum/voremanager/proc/user_logout(var/mob/user)
	//testing("voremanager/user_logout user [user.name]")
	return close_user_uis(user)

 /**
  * This is called when a player transfers from one mob to another
  * Transfers all open UIs to the new mob
  *
  * @param oldMob /mob The user's old mob
  * @param newMob /mob The user's new mob
  *
  * @return nothing
  */
/datum/voremanager/proc/user_transferred(var/mob/oldMob, var/mob/newMob)
	//testing("voremanager/user_transferred from mob [oldMob.name] to mob [newMob.name]")
	if (!oldMob || isnull(oldMob.open_uis) || !istype(oldMob.open_uis, /list) || open_uis.len == 0)
		//testing("voremanager/user_transferred mob [oldMob.name] has no open uis")
		return 0 // has no open uis

	if (isnull(newMob.open_uis) || !istype(newMob.open_uis, /list))
		newMob.open_uis = list()

	for (var/datum/voreui/ui in oldMob.open_uis)
		ui.user = newMob
		newMob.open_uis.Add(ui)

	oldMob.open_uis.Cut()

	return 1 // success

 /**
  * Sends all nano assets to the client
  * This is called on user login
  *
  * @param client /client The user's client
  *
  * @return nothing
  */

/datum/voremanager/proc/send_resources(client)
	for(var/file in asset_files)
		client << browse_rsc(file)	// send the file to the client
