//
//	The belly object is what holds onto a mob while they're inside a predator.
//	It takes care of altering the pred's decription, digesting the prey, relaying struggles etc.
//	It is not, however, for printing messages about entering/exiting the belly. That is done in voretype etc.
//

#define DM_HOLD "Hold"
#define DM_DIGEST "Digest"
#define DM_SDIGEST "Sdigest"
#define DM_FDIGEST "Fdigest"
#define DM_HEAL "Heal"
#define RELAY_STRUGGLE_COOLDOWN	5

#define VORE_STRUGGLE_EMOTE_CHANCE 40

/**
* Parent type of all the various "belly" varieties.
*/
/datum/belly
	// Instance Variables
	var/belly_type					// Stomach/Cock/Womb/Boob
	var/belly_name					// stomach/balls/womb/breast
	// TODO - Unify belly_type and belly_name shall we?
	var/mob/owner					// The mob whose belly this is.
	var/digest_mode = DM_HOLD		// Whether or not to digest. Default to not digest.
	var/list/digest_modes = list(DM_HOLD, DM_DIGEST)	// Possible digest modes
	var/is_full						// Flag for if digested remeans are present. (for disposal messages)
	var/inside_flavor				// Flavor text description of inside sight/sound/smells/feels.
	var/recent_struggle = 0			// Flag to prevent struggle emote spam
	var/milk_type=null
	var/list/milk_list=new()
	var/assoc_loc="chest"
	var/assoc_fluid="vomit"
	var/escape=1
	var/integrity=100
	var/exterior=0
	var/oxygen=1
	var/datum/vore_organ/transfer_target=null
	assume_air

	var/list/internal_contents = list();	// People/Things you've eaten into this belly!

	// These items are preserved when prey are digested.
	var/list/preserve_items = list(
		/obj/item/weapon/hand_tele,
		/obj/item/weapon/card/id/captains_spare,
		/obj/item/weapon/card/id/gold,
		/obj/item/weapon/card/id/syndicate,
		/obj/item/weapon/card/id/syndicate_command,
		/obj/item/weapon/card/id/centcom,
		/obj/item/weapon/card/id/ert,
		/obj/item/device/aicard,
		/obj/item/device/mmi,
		/obj/item/device/paicard,
		/obj/item/weapon/gun,
		/obj/item/weapon/pinpointer,
		/obj/item/clothing/suit,
		/obj/item/clothing/shoes/magboots,
		/obj/item/areaeditor/blueprints,
		/obj/item/clothing/head/helmet/space,
		/obj/item/weapon/storage/internal,
		/obj/item/weapon/reagent_containers/hypospray/CMO,
		/obj/item/clothing/tie/medal/gold/captain,
		/obj/item/nuke_core,
		/obj/item/documents,
		/obj/item/weapon/storage/backpack/holding)

// Constructor that sets the owning mob
// @Override
/datum/belly/New(var/mob/owning_mob)
	owner = owning_mob

// Toggle digestion on/off and notify user of the new setting.
// If multiple digestion modes are avaliable (i.e. unbirth) then user should be prompted.
/datum/belly/proc/toggle_digestion()
	return

// Checks if any mobs are present inside the belly
// @return True if the belly is empty.
/datum/belly/proc/is_empty()
	return internal_contents.len == 0


// Release all contents of this belly into the owning mob's location.
// If that location is another mob, contents are transferred into whichever of its bellies the owning mob is in.
// Returns the number of mobs so released.
/datum/belly/proc/release_all_contents()
	var/tick = 0 //easiest way to check if the list has anything
	for (var/atom/movable/M in internal_contents)
		M.loc = owner.loc  // Move the belly contents into the same location as belly's owner.
		src.internal_contents -= M  // Remove from the belly contents

		if (iscarbon(owner.loc)) // This makes sure that the mob behaves properly if released into another mob
			var/mob/living/carbon/loc_mob = owner.loc
			for (var/bellytype in loc_mob.internal_contents)
				var/datum/belly/belly = loc_mob.internal_contents[bellytype]
				if (owner in belly.internal_contents)
					belly.internal_contents += M
		tick++
	return tick

// Release a specific atom from the contents of this belly into the owning mob's location.
// If that location is another mob, the atom is transferred into whichever of its bellies the owning mob is in.
// Returns the number of atoms so released.
/datum/belly/proc/release_specific_contents(var/atom/movable/M)
	if (!(M in internal_contents))
		return 0 // They weren't in this belly anyway
	M.loc = owner.loc  // Move the belly contents into the same location as belly's owner.
	src.internal_contents -= M  // Remove from the belly contents

	if (iscarbon(owner.loc)) // This makes sure that the mob behaves properly if released into another mob
		var/mob/living/carbon/loc_mob = owner.loc
		for (var/bellytype in loc_mob.internal_contents)
			var/datum/belly/belly = loc_mob.internal_contents[bellytype]
			if (owner in belly.internal_contents)
				belly.internal_contents += M
	return 1

//
// Actually perform the mechanics of devouring the tasty prey.
// The purpose of this method is to avoid duplicate code, and ensure that all necessary
// steps are taken.
// @param prey Mob to be eaten
// @param user Optional: 3rd party is the one making this happen.
/datum/belly/proc/nom_mob(var/mob/prey, var/mob/user = null, var/mob/living/pred)
	// Unbuckle the mob
	if (prey.buckled)
		prey.buckled.unbuckle_mob()

	// Actually put the prey where they belong.
	prey.loc = owner
	internal_contents += prey
	vore_admins("[key_name(pred)]'s [belly_name] has added [key_name(prey)].")
	log_attack("[key_name(pred)]'s [belly_name] has added [key_name(prey)].")


// Process the predator's effects upon the contents of its belly (i.e digestion/transformation etc)
// Called from /mob/living/carbon/human/Life() proc.
// Default implementation does nothing!
/datum/belly/proc/process_Life()
	return

// Get the line that should show up in Examine message if the owner of this belly
// is eaxmined.   By making this a proc, we not only take advantage of polymorphism,
// but can easily make the message vary based on how many people are inside, etc.
// Returns a string which shoul be appended to the Examine output.
/datum/belly/proc/get_examine_msg(t_He, t_his, t_him, t_has, t_is)
	return

// Relay the sounds of someone struggling in a belly to those outside!
// Called from /mob/living/carbon/relaymove()
/datum/belly/proc/relay_struggle(var/mob/user, var/direction, var/mob/living/prey, var/atom/movable/M)
	if(istype(user,/mob/living))
		prey=user
	else
		return
	if(prey.vore_last_relay > world.time)
		return
	if(world.time < (prey.vore_last_relay + RELAY_STRUGGLE_COOLDOWN))
		return

	prey.vore_last_relay = world.time

	if(prey.a_intent=="help"&&!exterior)
	else
		integrity-=20
		if(prob(40)) owner.Stun(rand(1,2))
		playsound('sound/effects/attackblob.ogg', 50, 1)
		if(integrity<=0)
			M.loc = owner.loc
			src.internal_contents -= M
			integrity=0
			owner.Stun(rand(2,4))
	return

// Handle the death of a mob via digestion.
// Called from the process_Life() methods of bellies that digest prey.
// Default implementation calls M.death() and removes from internal contents.
// Indigestable items are removed, and M is deleted.
/datum/belly/proc/digestion_death(var/mob/living/M, var/mob/user, var/mob/living/prey, var/mob/living/pred)
	is_full = 1
	M.death(1)
	vore_admins("[key_name(pred)] has digested [key_name(prey)] in [belly_name]")
	log_attack("[key_name(pred)] has digested [key_name(prey)] in [belly_name]")
	internal_contents -= M


	// If digested prey is also a pred... anyone inside their bellies gets moved up.
	if (is_vore_predator(M))
		var/vore/pred_capable/P = M
		for (var/bellytype in P.internal_contents)
			var/datum/belly/belly = P.internal_contents[bellytype]
			for (var/obj/SubPrey in belly.internal_contents)
				SubPrey.loc = src.owner
				internal_contents += SubPrey
				if (istype(SubPrey, /mob))
					SubPrey << "As [M] melts away around you, you find yourself in [src.owner]'s [belly_name]"
					// TODO - If SubPrey is digestable, tell them its their turn to die horribly

	//Drop all items into the belly.
	if (preserve_items)
		for (var/obj/item/W in M)
			_handle_digested_item(W)

	// Delete the digested mob
	del(M)

// Recursive method - To recursively scan thru someone's inventory for digestable/indigestable.
/datum/belly/proc/_handle_digested_item(var/obj/item/W)
	// PDA's are handled specially in order to get the ID out of them.
	if (istype(W, /obj/item/device/pda))
		var/obj/item/device/pda/PDA = W
		if (PDA.id)
			W = PDA.id
			PDA.id = null
			del(PDA)

	if (istype(W, /obj/item/weapon/card/id))
		// Keep IDs around, but destroy them!
		var/obj/item/weapon/card/id/ID = W
		ID.desc = "A partially digested card that has seen better days.  Much of it's data has been destroyed."
		ID.icon_state = "digested"
		ID.access = list() // No access
		ID.loc = src.owner
		internal_contents += ID
	else if (!_is_digestable(W))
		W.loc = src.owner
		internal_contents += W
	else
		for (var/obj/item/SubItem in W)
			_handle_digested_item(SubItem)
		del(W)

/datum/belly/proc/_is_digestable(var/obj/item/I)
	for (var/T in preserve_items)
		if(istype(I, T))
			return 0
	return 1
/*
/mob/living/carbon/proc/ejaculate(var/stun = 1, var/distance = 0, var/message = 1, var/mob/owner, var/atom/movable/M)
	set name = "Ejaculate"
	set category = "Vore"

	if(prob(50))
		if(prob(55))
			visible_message("<span class='warning'>[src] groans and shivers!</span>", \
							"<span class='userdanger'>You feel the urge but not the need.</span>")
		if(prob(15))
			Stun(5)
	else
		if(message)
			visible_message("<span class='danger'>[src] suddenly orgasms!</span>", \
							"<span class='userdanger'>You orgasm!</span>")
		playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
		var/turf/T = get_turf(src)
		for(var/i=0 to distance)
			if("Womb" || owner.gender == "female")
				if(T)
					T.add_femjuice_floor(src)
					Stun(2)
					M.loc = owner.loc

			else
				T.add_femjuice_floor(src)

			if("Cock" || owner.gender == "male")
				if(T)
					T.add_semen_floor(src)
					Stun(2)
					M.loc = owner.loc

			else
				T.add_semen_floor(src)

			T = get_step(T, dir)
			if (is_blocked_turf(T))
				break
	return 1

	*/