/datum/species
	var/limbs_id = null	//this is used if you want to use a different species limb sprites. Mainly used for angels as they look like humans.


/datum/species/canine
	name = "Canine"
	id = "canine"
	default_color = "FFFFFF"
	specflags = list(EYECOLOR,HAIR,LIPS,MUTCOLORS)
	mutant_bodyparts = list("tail_human", "wings", "canine_species", "taur")
	default_features = list("mcolor" = "FFF", "tail_human" = "none", "wings" = "None", "canine_species" = "Fox", "taur" = "none", "special_color")
	skinned_type = /obj/item/stack/sheet/animalhide/human // will have to custom make hides.

//Add tails/wagging tails to reduce hooks into sprite_accessories.dm
// porting easier as this will be for ALL canines
/datum/sprite_accessory/tails/human/fox
	name = "Fox"
	icon_state = "fox"
	color_src = MUTCOLORS

/datum/sprite_accessory/tails_animated/human/fox
	name = "Fox"
	icon_state = "fox"
	color_src = MUTCOLORS


/datum/species/canine/qualifies_for_rank(rank, list/features)
	//These are needed to be 1 because TG is racist af
	if(rank in security_positions) //This list does not include lawyers.
		return 1
	if(rank in science_positions)
		return 1
	if(rank in medical_positions)
		return 1
	if(rank in engineering_positions)
		return 1
	if(rank == "Quartermaster") //QM is not contained in command_positions but we still want to bar mutants from it.
		return 1
	return ..()


/datum/species/canine/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H) //because slimes I guess
	if(chem.id == "mutationtoxin")
		H << "<span class='danger'>Your flesh rapidly mutates!</span>"
		H.set_species(/datum/species/jelly/slime)
		H.reagents.del_reagent(chem.type)
		H.faction |= "slime"
		return 1

//Curiosity killed the cat's wagging tail.
/datum/species/canine/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		H.endTailWag()


/datum/species/canine
	name = "Feline"
	id = "feline"
	default_color = "FFFFFF"
	specflags = list(EYECOLOR,HAIR,LIPS,MUTCOLORS)
	mutant_bodyparts = list("tail_human", "ears", "wings", "feline_species")
	default_features = list("mcolor" = "FFF", "tail_human" = "none", "ears" = "None", "wings" = "None", "feline_species" = "Tajaran")
	skinned_type = /obj/item/stack/sheet/animalhide/human // will have to custom make hides.
	tail=1 //legacy, tbib
	taur=1 //legacy

//Add tails/wagging tails to reduce hooks into sprite_accessories.dm
// make porting easier this will be for ALL felines
/datum/sprite_accessory/tails/human/tajaran
	name = "Tajaran"
	icon_state = "tajaran"
	color_src = MUTCOLORS

/datum/sprite_accessory/tails_animated/human/tajaran
	name = "Tajaran"
	icon_state = "tajaran"
	color_src = MUTCOLORS


/datum/species/feline/qualifies_for_rank(rank, list/features)
	//These are needed to be 1 because TG is racist af
	if(rank in security_positions) //This list does not include lawyers.
		return 1
	if(rank in science_positions)
		return 1
	if(rank in medical_positions)
		return 1
	if(rank in engineering_positions)
		return 1
	if(rank == "Quartermaster") //QM is not contained in command_positions but we still want to bar mutants from it.
		return 1
	return ..()


/datum/species/feline/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H) //because slimes I guess
	if(chem.id == "mutationtoxin")
		H << "<span class='danger'>Your flesh rapidly mutates!</span>"
		H.set_species(/datum/species/jelly/slime)
		H.reagents.del_reagent(chem.type)
		H.faction |= "slime"
		return 1

//Curiosity killed the cat's wagging tail.
/datum/species/feline/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		H.endTailWag()

/datum/species/canine
	name = "Avian"
	id = "avian"
	default_color = "FFFFFF"
	specflags = list(EYECOLOR,HAIR,LIPS,MUTCOLORS)
	mutant_bodyparts = list("tail_human", "ears", "wings", "avian_species")
	default_features = list("mcolor" = "FFF", "tail_human" = "none", "ears" = "None", "wings" = "None", "avian_species" = "bird")
	skinned_type = /obj/item/stack/sheet/animalhide/human // will have to custom make hides.
	tail=1 //legacy, tbib
	taur=1 //legacy

//Add tails/wagging tails to reduce hooks into sprite_accessories.dm
//Make porting easier as this will be for ALL avians
/datum/sprite_accessory/tails/human/bird
	name = "Bird"
	icon_state = "bird"
	color_src = MUTCOLORS

/* Not sure they have mobile sprites, but this is for it

/datum/sprite_accessory/tails_animated/human/fox
	name = "Fox"
	icon_state = "fox"
	color_src = MUTCOLORS
*/

/datum/species/avian/qualifies_for_rank(rank, list/features)
	//These are needed to be 1 because TG is racist af
	if(rank in security_positions) //This list does not include lawyers.
		return 1
	if(rank in science_positions)
		return 1
	if(rank in medical_positions)
		return 1
	if(rank in engineering_positions)
		return 1
	if(rank == "Quartermaster") //QM is not contained in command_positions but we still want to bar mutants from it.
		return 1
	return ..()


/datum/species/avian/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H) //because slimes I guess
	if(chem.id == "mutationtoxin")
		H << "<span class='danger'>Your flesh rapidly mutates!</span>"
		H.set_species(/datum/species/jelly/slime)
		H.reagents.del_reagent(chem.type)
		H.faction |= "slime"
		return 1

//Curiosity killed the cat's wagging tail.
/datum/species/canine/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		H.endTailWag()
/*


datum
	species
		var/generic="something"
		var/adjective="unknown"
		var/restricted=0 //Set to 1 to not allow anyone to choose it, 2 to hide it from the DNA scanner, and text to restrict it to one person
		var/tail=0
		var/taur=0
		human
			generic="human"
			adjective="ordinary"
			taur="horse"
		ailurus
			name="red panda"
			id="ailurus"
			generic="ailurus"
			adjective="cuddly"
			tail=1
		alien
			name="alien"
			id="alien"
			say_mod="hisses"
			generic="xeno"
			adjective="phallic"
			tail=1
		armadillo
			name="armadillo"
			id="armadillo"
			say_mod = "drawls"
			generic = "protected"
			adjective = "varmint on a halfshell" // that's not an adjective
			tail=1
			attack_verb = "noms"
			attack_sound = 'sound/weapons/bite.ogg'
		anubis
			name="anubis"
			id="anubis"
			say_mod = "intones"
			generic="jackal"
			adjective="cold"
			attack_verb = "claws"
		beaver
			name="beaver"
			id="beaver"
			say_mod = "chitters"
			generic="woody" // that's not a generic
			adjective="damnable"
			tail=1
			attack_verb = "tailslaps"
			attack_sound = 'sound/items/dodgeball.ogg'
		beholder
			name="beholder"
			id="beholder"
			say_mod = "jibbers"
			generic="body part"
			adjective="all-seeing"
			tail=0
			attack_verb = "visually assaults"
			attack_sound = 'sound/magic/MM_Hit.ogg' // MAGIC MISSILE! MAGIC MISSILE!
		boar
			name="boar"
			id="boar"
			generic="pig"
			adjective="wild and curly"
			tail=1
		capra
			name="caprine"
			id="capra"
			generic="goat"
			adjective="irritable"
		carp
			name="carp"
			id="carp"
			say_mod = "glubs"
			generic = "abomination"
			adjective = "violently fishy"
			tail=1
			eyes=0
			attack_verb = "noms"
			attack_sound = 'sound/weapons/bite.ogg'
		corgi
			name="corgi"
			id="corgi"
			say_mod ="yaps"
			generic="canine"
			adjective="corgalicious"
			tail=1
		corvid
			name="corvid"
			id="corvid"
			say_mod = "caws"
			generic="bird"
			adjective="mask-piercing"
			tail=1
			attack_verb = "whack"
		cow
			name="cow"
			id="cow"
			say_mod = "moos"
			generic="cow"
			adjective="wise"
			tail=1
			taur=1
		dalmatian
			name="dalmatian"
			id="dalmatian"
			say_mod = "ruffs"
			generic="canine"
			adjective="spotty"
			tail=1
		deer
			name="deer"
			id="deer"
			say_mod = "grunts"
			generic = "open season"
			adjective = "skittish"
			tail=1 // that's better
			attack_verb = "gores"
			attack_sound = 'sound/weapons/bladeslice.ogg'
		drake
			name="drake"
			id="drake"
			say_mod = "growls"
			generic = "reptile"
			adjective = "frilly"
			tail=1 // i'd use lizard tails but drakes have frills included on the icons
		drider
			name="drider"
			id="drider"
			generic="humanoid"
			adjective="big and hairy"
			taur=1
			tail=1
		fennec
			name="fennec"
			id="fennec"
			generic="vulpine"
			adjective="foxy"
			tail=1
		fox
			name="fox"
			id="fox"
			generic="vulpine"
			adjective="foxy" // open and shut with this one, huh
			tail=1
			taur=1
		glowfen
			name="glowfen"
			id="glowfen"
			generic="vulpine"
			adjective="glowing"
			tail=1
		gremlin
			name="gremlin"
			id="gremlin"
			generic="creature"
			tail=1
		hawk
			name="hawk"
			id="hawk"
			say_mod = "chirps"
			generic="bird"
			adjective="feathery"
			tail=1
			attack_verb = "whacks"
		hippo
			name="hippo"
			id="hippo"
			generic="hippo"
			adjective="buoyant"
			tail=1
		husky
			name="husky"
			id="husky"
			say_mod = "arfs"
			generic="canine"
			adjective="derpy"
			tail=1
			taur=1
		jackalope
			name="jackalope"
			id="jackalope"
			generic="leporid"
			adjective="hoppy and horny" //hue
			attack_verb = "kicks"
			tail=1
		jelly
			name="jelly"
			id="jelly"
			generic="jelly"
			adjective="jelly"
		kangaroo
			name="kangaroo"
			id="kangaroo"
			generic="kangaroo"
			adjective="bouncy"
			tail=1
		lab
			name="lab"
			id="lab"
			say_mod = "yaps"
			generic="canine"
			adjective="sleek"
			tail=1
			taur=1
		leporid
			name="leporid"
			id="leporid"
			generic="leporid"
			adjective="hoppy"
			tail=1
			attack_verb = "kicks"
		lizard
			name="lizard"
			id="lizard"
			generic="reptile"
			adjective="scaled"
			taur="naga"
			tail=1
		murid
			name="murid"
			id="murid"
			say_mod = "squeaks"
			generic="rodent"
			adjective="squeaky"
			tail=1
		moth
			name="moth"
			id="moth"
			generic="insect"
			adjective="fluttery"
			eyes="motheyes"
		naga
			name="naga"
			id="naga"
			generic="human"
			adjective="noodly"
			taur=1
			tail=1
		otter
			name="otter"
			id="otter"
			say_mod = "squeaks"
			generic="weasel"
			adjective="slim"
			tail=1
		otusian
			name="otusian"
			id="otie"
			say_mod ="growls"
			generic="something artificial"
			adjective="chunky"
			tail=1
		panther
			name="panther"
			id="panther"
			generic="feline"
			adjective="furry"
			tail=1
			taur=1
			attack_verb = "claw"
			attack_sound = 'sound/weapons/bladeslice.ogg'
		pig
			name="pig"
			id="pig"
			generic="pig"
			adjective="curly"
			tail=1
		plant
			generic="plant"
			adjective="leafy"
		porcupine
			name="porcupine"
			id="porcupine"
			say_mod = "snuffles"
			generic = "pointy"
			adjective = "quill-y"
			tail=1
			attack_verb = "quill whacks"
			attack_sound = 'sound/weapons/slash.ogg'
		possum
			name="possum"
			id="possum"
			say_mod = "chitters"
			generic = "rumager"
			adjective = "varmint"
			tail=1
			attack_verb = "viciously noms"
			attack_sound = 'sound/weapons/bite.ogg'
		raccoon
			name="raccoon"
			id="raccoon"
			say_mod="churrs"
			generic="raccoon"
			adjective="stripy"
			tail=1
		roorat
			name="kangaroo rat"
			id="roorat"
			generic="roorat"
			adjective="bouncy"
			tail=1
		seaslug
			name="sea slug"
			id="seaslug"
			generic="slug"
			adjective="salty"
			tail=1
		shark
			name="shark"
			id="shark"
			generic="fish"
			adjective="fishy"
			tail=1
		shepherd
			name="shepherd"
			id="shepherd"
			say_mod = "barks"
			generic="canine"
			adjective="happy"
			tail=1
			taur=1
		skunk
			name="skunk"
			id="skunk"
			say_mod = "snuffles"
			generic="mephit"
			adjective="stinky"
			tail=1
		slime
			name="slime"
			id="slime"
			generic="slime"
			adjective="slimy"
		smilodon
			name="smilodon"
			id="smilodon"
			generic="smilodon"
			adjective="toothy"
			tail=1
		snarby
			name="snarby"
			id="snarby"
			generic="beast"
			adjective="snippy and snarly"
			tail=1
			attack_verb = "chomps"
			attack_sound = 'sound/weapons/bite.ogg'
			eyes=0
			//restricted=2 // so that the choice is there whether you want it more snowflakey
		squirrel
			name="squirrel"
			id="squirrel"
			generic="rodent"
			adjective="nutty"
			tail=1
		tajaran
			name="tajaran"
			id="tajaran"
			generic="feline"
			adjective="furry"
			tail=1
			taur=1
			attack_verb = "claw"
			attack_sound = 'sound/weapons/bladeslice.ogg'
		turtle
			name="turtle"
			id="turtle"
			generic="turtle"
			adjective="hard-shelled"
			tail=1
		wolf
			name="wolf"
			id="wolf"
			say_mod = "howls"
			generic="canine"
			adjective="shaggy"
			tail=1
			taur=1


		//zigzagoon
			//name="zigzagoon"
			//id="zigzagoon"
			//generic="pokémon"
			//adjective="curious"
			//tail=1
			//restricted="kotetsuredwood"


		narky
			id="narky"
			say_mod="nyars"
			generic="abomination"
			adjective="fluffy"
			restricted=2
			tail=1
			taur=1
			attack_verb = "whack"
		fly
			generic="insect"
			adjective="buzzy"
			restricted=1
		pepsiman
			//name="PEPSI MAAAAAN"
			id="PEPSIMAAAN"
			generic="beverage"
			adjective="refreshing"
			restricted=2 // don't want half the station to be running around with soda cans on their heads
		cutebold
			name="cutebold"
			id="cutebold"
			say_mod = "yips"
			generic = "kobo"
			adjective = "cute"
			tail=1
			attack_verb = "noms"
			attack_sound = 'sound/weapons/bite.ogg'
		pony // of the "my little" variety
			name="pony"
			id="pony"
			generic="equine"
			adjective="little"
			tail=1
			attack_verb= "kicks"
		hylotl
			name="hylotl"
			id="hylotl"
			say_mod = "glubs"
			generic="amphibian"
			adjective="fishy"
			tail=0
			eyes="jelleyes"
var/list/kpcode_race_list

proc/kpcode_race_genlist()
	if(!kpcode_race_list)
		var/paths = typesof(/datum/species)
		kpcode_race_list = new/list()
		for(var/path in paths)
			var/datum/species/D = new path()
			if(D.name!="undefined")
				kpcode_race_list[D.name] = D

proc/kpcode_race_getlist(var/restrict=0)
	var/list/race_options = list()
	for(var/r_id in species_list)
		var/datum/species/R = kpcode_race_get(r_id)
		if(!R.restricted||R.restricted==restrict)
			race_options[r_id]=kpcode_race_get(r_id)
	return race_options

proc/kpcode_race_get(var/name="human")
	name=kpcode_race_san(name)
	if(!name||name=="") name="human"
	if(species_list[name])
		var/type_to_use=species_list[name]
		var/datum/species/return_this=new type_to_use()
		return return_this
	else
		return kpcode_race_get()

proc/kpcode_race_san(var/input)
	if(!input)input="human"
	if(istype(input,/datum/species))
		input=input:id
	return input

proc/kpcode_race_restricted(var/name="human")
	name=kpcode_race_san(name)
	if(kpcode_race_get(name))
		var/datum/species/D=kpcode_race_get(name)
		return D.restricted
	return 2

proc/kpcode_race_tail(var/name="human")
	name=kpcode_race_san(name)
	if(kpcode_race_get(name))
		var/datum/species/D=kpcode_race_get(name)
		return D.tail
	return 0

proc/kpcode_race_taur(var/name="human")
	name=kpcode_race_san(name)
	if(kpcode_race_get(name))
		var/datum/species/D=kpcode_race_get(name)
		if(D.taur==1)
			return D.id
		return D.taur
	return 0

proc/kpcode_race_generic(var/name="human")
	name=kpcode_race_san(name)
	if(kpcode_race_get(name))
		var/datum/species/D=kpcode_race_get(name)
		return D.generic
	return 0

proc/kpcode_race_adjective(var/name="human")
	name=kpcode_race_san(name)
	if(kpcode_race_get(name))
		var/datum/species/D=kpcode_race_get(name)
		return D.adjective
	return 0

proc/kpcode_get_generic(var/mob/living/M)
	if(istype(M,/mob/living/carbon/human))
		if(M:dna)
			return kpcode_race_generic(M:dna:mutantrace())
		else
			return kpcode_race_generic("human")
	if(istype(M,/mob/living/carbon/monkey))
		return "monkey"
	if(istype(M,/mob/living/carbon/alien))
		return "xeno"
	if(istype(M,/mob/living/simple_animal))
		return M.name
	return "something"

proc/kpcode_get_adjective(var/mob/living/M)
	if(istype(M,/mob/living/carbon/human))
		if(M:dna)
			return kpcode_race_adjective(M:dna:mutantrace())
		else
			return kpcode_race_adjective("human")
	if(istype(M,/mob/living/carbon/monkey))
		return "cranky"
	if(istype(M,/mob/living/carbon/alien))
		return "alien"
	if(istype(M,/mob/living/simple_animal))
		return "beastly"
	return "something"


/*var/list/mutant_races = list(
	"human",
	"fox",
	"fennec",
	"lizard",
	"tajaran",
	"panther",
	"husky",
	"squirrel",
	"otter",
	"murid",
	"leporid",
	"ailurus",
	"shark",
	"hawk",
	"jelly",
	"slime",
	"plant",
	)*/

var/list/mutant_tails = list(
	"none"=0,
	"tajaran"="tajaran",
	"neko"="neko",
	"dog"="lab",
	"wolf"="wolf",
	"fox"="fox",
	"mouse"="murid",
	"rabbit"="leporid",
	"panda"="ailurus",
	"pig"="pig",
	"cow"="cow",
	"kangaroo"="kangaroo",
	)

var/list/mutant_wings = list(
	"none"=0,
	"bat"="bat",
	"feathery"="feathery",
	"moth"="moth",
	"fairy"="fairy",
	"tentacle"="tentacle"
	)

var/list/cock_list = list(
	"human",
	"canine",
	"feline",
//	"murid",
//	"leporid",
	"reptilian",
	//"custom",
	)


proc/kpcode_hastail(var/S)
	if(kpcode_race_tail(S)==1)
		return S
	if(kpcode_race_tail(S))
		return kpcode_race_tail(S)
	if(S in mutant_tails)
		return mutant_tails[S]
	return 0

proc/kpcode_cantaur(var/S)
	return kpcode_race_taur(S)

/mob/living/proc/underwear_toggle()
	set name = "Force Update"
	set category = "Vore"
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/humz=src
		humz.underwear_active=!humz.underwear_active
		//updateappearance(src)
		src.update_body()
	else
		src<<"Humans only."

*/