#define DM_HOLD "Hold"
#define DM_DIGEST "Digest"
#define DM_HEAL "Heal"
#define DM_ABSORB "Absorb"
#define DM_DIGESTF "Fast Digest"

#define VORE_STRUGGLE_EMOTE_CHANCE 40

var/global/list/player_sizes_list = list("Macro" = RESIZE_HUGE, "Big" = RESIZE_BIG, "Normal" = RESIZE_NORMAL, "Small" = RESIZE_SMALL, "Tiny" = RESIZE_TINY)


var/global/list/digestion_sounds = list(
		'sound/vore/digest1.ogg',
		'sound/vore/digest2.ogg',
		'sound/vore/digest3.ogg',
		'sound/vore/digest4.ogg',
		'sound/vore/digest5.ogg',
		'sound/vore/digest6.ogg',
		'sound/vore/digest7.ogg',
		'sound/vore/digest8.ogg',
		'sound/vore/digest9.ogg',
		'sound/vore/digest10.ogg',
		'sound/vore/digest11.ogg',
		'sound/vore/digest12.ogg')

var/global/list/death_sounds = list(
		'sound/vore/death1.ogg',
		'sound/vore/death2.ogg',
		'sound/vore/death3.ogg',
		'sound/vore/death4.ogg',
		'sound/vore/death5.ogg',
		'sound/vore/death6.ogg',
		'sound/vore/death7.ogg',
		'sound/vore/death8.ogg',
		'sound/vore/death9.ogg',
		'sound/vore/death10.ogg')

var/global/list/canine_species = list ()
var/global/list/feline_species = list ()
var/global/list/avian_species = list ()
var/global/list/tuar = list ()

/proc/log_debug(text)
	if (config.log_debug)
		diary << "\[[time_stamp()]]DEBUG: [text][log_end]"

	for(var/client/C in admins)
		if(C.prefs.toggles & CHAT_DEBUGLOGS)
			C << "DEBUG: [text]"