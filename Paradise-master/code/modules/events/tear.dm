/datum/event/tear
	startWhen = 3
	announceWhen = 20
	endWhen = 50
	var/obj/effect/tear/TE

/datum/event/tear/announce()
	command_alert("A tear in the fabric of space and time has opened. Expected location: [impact_area.name].", "Anomaly Alert")


/datum/event/tear/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		TE = new /obj/effect/tear(T.loc)


/datum/event/tear/setup()
	impact_area = findEventArea()

/datum/event/tear/end()
	if(TE)
		del(TE)

/obj/effect/tear
	name="Dimensional Tear"
	desc="A tear in the dimensional fabric of space and time."
	icon='icons/effects/tear.dmi'
	icon_state="tear"
	unacidable = 1
	density = 0
	anchored = 1
	luminosity = 3

/obj/effect/tear/New()
	..()
	var/atom/movable/overlay/animation = null
	animation = new(loc)
	animation.icon_state = "newtear"
	animation.icon = 'icons/effects/tear.dmi'
	animation.master = src
//	flick("newtear",usr)
	spawn(15)
		if(animation)	del(animation)


	spawn(rand(30,120))
		var/blocked = list(/mob/living/simple_animal/hostile,

		)//exclusion list for things you don't want the reaction to create.
		var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

		for(var/i = 1, i <= 5, i++)
			var/chosen = pick(critters)
			var/mob/living/simple_animal/hostile/C = new chosen
			C.faction = "slimesummon"
			C.loc = src.loc
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(C, pick(NORTH,SOUTH,EAST,WEST))
