/datum/round_event_control/processor_overload
	name = "Processor Overload"
	typepath = /datum/round_event/processor_overload
	weight = 15

/datum/round_event/processor_overload
	announceWhen	= 1

/datum/round_event/processor_overload/announce()
	var/alert = pick(	"Exospheric bubble inbound. Processor overload is likely. Please contact you*%xp25)`6cq-BZZT", \
						"Exospheric bubble inbound. Processor overload is likel*1eta;c5;'1v�-BZZZT", \
						"Exospheric bubble inbound. Processor ov#MCi46:5.;@63-BZZZZT", \
						"Exospheric bubble inbo'Fz\\k55_@-BZZZZZT", \
						"Exospheri:%� QCbyj^j</.3-BZZZZZZT", \
						"!!hy%;f3l7e,<$^-BZZZZZZZT")

	for(var/mob/living/silicon/ai/A in ai_list)
	//AIs are always aware of processor overload
		A << "<br><span class='warning'><b>[alert]</b></span><br>"

	// Announce most of the time, but leave a little gap so people don't know
	// whether it's, say, a tesla zapping tcomms, or some selective
	// modification of the tcomms bus
	if(prob(80))
		priority_announce(alert)


/datum/round_event/processor_overload/start()
	for(var/obj/machinery/telecomms/T in telecomms_list)
		if(istype(T, /obj/machinery/telecomms/processor))
			var/obj/machinery/telecomms/processor/P = T
			if(prob(10))
				// Damage the surrounding area to indicate that it popped
				explosion(get_turf(P), 0, 0, 2)
				// Only a level 1 explosion actually damages the machine
				// at all
				P.ex_act(1)
			else
				P.emp_act(1)
