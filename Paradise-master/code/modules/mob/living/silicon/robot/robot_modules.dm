/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 100.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS | CONDUCT

	var/list/modules = list()
	var/obj/item/emag = null
	var/obj/item/borg/upgrade/jetpack = null


	emp_act(severity)
		if(modules)
			for(var/obj/O in modules)
				O.emp_act(severity)
		if(emag)
			emag.emp_act(severity)
		..()
		return


	New()
		src.modules += new /obj/item/device/flashlight(src)
		src.modules += new /obj/item/device/flash(src)
		src.emag = new /obj/item/toy/sword(src)
		src.emag.name = "Placeholder Emag Item"
//		src.jetpack = new /obj/item/toy/sword(src)
//		src.jetpack.name = "Placeholder Upgrade Item"
		return


/obj/item/weapon/robot_module/proc/respawn_consumable(var/mob/living/silicon/robot/R)
	return

/obj/item/weapon/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O

/obj/item/weapon/robot_module/standard
	name = "standard robot module"


	New()
		..()
		modules += new /obj/item/weapon/melee/baton/loaded(src)
		modules += new /obj/item/weapon/extinguisher(src)
		modules += new /obj/item/weapon/wrench(src)
		modules += new /obj/item/weapon/crowbar(src)
		modules += new /obj/item/device/healthanalyzer(src)
		emag = new /obj/item/weapon/melee/energy/sword(src)



/obj/item/weapon/robot_module/medical
	name = "medical robot module"


	New()
		..()
		src.modules += new /obj/item/borg/sight/hud/med(src)
		src.modules += new /obj/item/device/healthanalyzer(src)
		src.modules += new /obj/item/device/reagent_scanner/adv(src)
		src.modules += new /obj/item/weapon/reagent_containers/borghypo(src)
		src.modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
		src.modules += new /obj/item/weapon/reagent_containers/robodropper(src)
		src.modules += new /obj/item/weapon/reagent_containers/syringe(src)
		src.modules += new /obj/item/weapon/extinguisher/mini(src)
		src.emag = new /obj/item/weapon/reagent_containers/spray(src)

		src.emag.reagents.add_reagent("pacid", 250)
		src.emag.name = "Polyacid spray"
		return



/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"


	New()
		..()
		modules += new /obj/item/borg/sight/meson(src)
		emag = new /obj/item/borg/stun(src)
		modules += new /obj/item/weapon/rcd/borg(src)
		modules += new /obj/item/weapon/extinguisher(src)
		modules += new /obj/item/weapon/weldingtool/largetank(src)
		modules += new /obj/item/weapon/screwdriver(src)
		modules += new /obj/item/weapon/wrench(src)
		modules += new /obj/item/weapon/crowbar(src)
		modules += new /obj/item/weapon/wirecutters(src)
		modules += new /obj/item/device/multitool(src)
		modules += new /obj/item/device/t_scanner(src)
		modules += new /obj/item/device/analyzer(src)
		modules += new /obj/item/taperoll/engineering(src)

		var/obj/item/stack/sheet/metal/cyborg/M = new /obj/item/stack/sheet/metal/cyborg(src)
		M.amount = 50
		src.modules += M

		var/obj/item/stack/sheet/rglass/cyborg/G = new /obj/item/stack/sheet/rglass/cyborg(src)
		G.amount = 50
		src.modules += G

		var/obj/item/stack/cable_coil/W = new /obj/item/stack/cable_coil(src)
		W.amount = 50
		src.modules += W

		return


	respawn_consumable(var/mob/living/silicon/robot/R)
		var/list/what = list (
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/rglass,
			/obj/item/stack/cable_coil,
		)
		for (var/T in what)
			if (!(locate(T) in src.modules))
				src.modules -= null
				var/O = new T(src)
				src.modules += O
				O:amount = 1
		return



/obj/item/weapon/robot_module/security
	name = "security robot module"


	New()
		..()
		modules += new /obj/item/borg/sight/hud/sec(src)
		modules += new /obj/item/weapon/handcuffs/cyborg(src)
		modules += new /obj/item/weapon/melee/baton/loaded(src)
		modules += new /obj/item/weapon/gun/energy/taser/cyborg(src)
		modules += new /obj/item/taperoll/police(src)
		emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)



/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"


	New()
		..()
		src.modules += new /obj/item/weapon/soap/nanotrasen(src)
		src.modules += new /obj/item/weapon/storage/bag/trash(src)
		src.modules += new /obj/item/weapon/mop(src)
		src.modules += new /obj/item/device/lightreplacer(src)
		src.emag = new /obj/item/weapon/reagent_containers/spray(src)

		src.emag.reagents.add_reagent("lube", 250)
		src.emag.name = "Lube spray"
		return



/obj/item/weapon/robot_module/butler
	name = "service robot module"


	New()
		..()
		src.modules += new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
		src.modules += new /obj/item/weapon/reagent_containers/food/condiment/enzyme(src)
		src.modules += new /obj/item/weapon/pen/robopen(src)
		src.modules += new /obj/item/weapon/razor(src)
		var/obj/item/weapon/rsf/M = new /obj/item/weapon/rsf(src)
		M.matter = 30
		src.modules += M

		src.modules += new /obj/item/weapon/reagent_containers/robodropper(src)

		var/obj/item/weapon/lighter/zippo/L = new /obj/item/weapon/lighter/zippo(src)
		L.lit = 1
		src.modules += L

		src.modules += new /obj/item/weapon/tray/robotray(src)
		src.modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)
		src.emag = new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)

		var/datum/reagents/R = new/datum/reagents(50)
		src.emag.reagents = R
		R.my_atom = src.emag
		R.add_reagent("beer2", 50)
		src.emag.name = "Mickey Finn's Special Brew"
		return



/obj/item/weapon/robot_module/miner
	name = "miner robot module"


	New()
		..()
		modules += new /obj/item/borg/sight/meson(src)
		emag = new /obj/item/borg/stun(src)
		modules += new /obj/item/weapon/storage/bag/ore(src)
		modules += new /obj/item/weapon/pickaxe/borgdrill(src)
		modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
		modules += new /obj/item/weapon/wrench(src)
		modules += new /obj/item/weapon/pickaxe/robotic(src)
		modules += new /obj/item/device/depth_scanner(src)

/obj/item/weapon/robot_module/syndicate
	name = "syndicate robot module"


	New()
		src.modules += new /obj/item/weapon/melee/energy/sword(src)
		src.modules += new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(src)
		src.modules += new /obj/item/weapon/card/emag(src)
		return

/obj/item/weapon/robot_module/combat
	name = "combat robot module"

	New()
		src.modules += new /obj/item/borg/sight/thermal(src)
		src.modules += new /obj/item/weapon/gun/energy/laser/cyborg(src)
		src.modules += new /obj/item/weapon/pickaxe/plasmacutter(src)
		src.modules += new /obj/item/borg/combat/shield(src)
		src.modules += new /obj/item/borg/combat/mobility(src)
		src.modules += new /obj/item/weapon/wrench(src) //Is a combat android really going to be stopped by a chair?
		src.emag = new /obj/item/weapon/gun/energy/lasercannon/cyborg(src)
		return

/obj/item/weapon/robot_module/alien/hunter
	name = "alien hunter module"

	New()
		src.modules += new /obj/item/weapon/melee/energy/alien/claws(src)
		src.modules += new /obj/item/device/flash/alien(src)
		src.modules += new /obj/item/borg/sight/thermal/alien(src)
		var/obj/item/weapon/reagent_containers/spray/alien/stun/S = new /obj/item/weapon/reagent_containers/spray/alien/stun(src)
		S.reagents.add_reagent("stoxin",250) //nerfed to sleeptoxin to make it less instant drop.
		src.modules += S
		var/obj/item/weapon/reagent_containers/spray/alien/smoke/A = new /obj/item/weapon/reagent_containers/spray/alien/smoke(src)
		S.reagents.add_reagent("water",50) //Water is used as a dummy reagent for the smoke bombs. More of an ammo counter.
		src.modules += A
		src.emag = new /obj/item/weapon/reagent_containers/spray/alien/acid(src)
		src.emag.reagents.add_reagent("pacid", 125)
		src.emag.reagents.add_reagent("sacid", 125)

/obj/item/weapon/robot_module/drone
	name = "drone module"
	var/list/stacktypes = list(
		/obj/item/stack/sheet/wood/cyborg = 1,
		/obj/item/stack/sheet/mineral/plastic/cyborg = 1,
		/obj/item/stack/sheet/rglass/cyborg = 5,
		/obj/item/stack/tile/wood = 5,
		/obj/item/stack/rods = 15,
		/obj/item/stack/tile/plasteel = 15,
		/obj/item/stack/sheet/metal/cyborg = 20,
		/obj/item/stack/sheet/glass/cyborg = 20,
		/obj/item/stack/cable_coil = 30
		)

	New()
		//TODO: Replace with shittier flashlight and work out why we can't remove the flash. ~Z
		..()
		src.modules += new /obj/item/weapon/weldingtool(src)
		src.modules += new /obj/item/weapon/screwdriver(src)
		src.modules += new /obj/item/weapon/wrench(src)
		src.modules += new /obj/item/weapon/crowbar(src)
		src.modules += new /obj/item/weapon/wirecutters(src)
		src.modules += new /obj/item/device/multitool(src)
		src.modules += new /obj/item/device/lightreplacer(src)
		src.modules += new /obj/item/weapon/reagent_containers/spray/cleaner(src)
		src.modules += new /obj/item/weapon/gripper(src)
		src.modules += new /obj/item/weapon/matter_decompiler(src)

		src.emag = new /obj/item/weapon/card/emag(src)
		src.emag.name = "Cryptographic Sequencer"

		for(var/T in stacktypes)
			var/obj/item/stack/sheet/W = new T(src)
			W.amount = stacktypes[T]
			src.modules += W

		return

/obj/item/weapon/robot_module/drone/respawn_consumable(var/mob/living/silicon/robot/R)
	var/obj/item/weapon/reagent_containers/spray/cleaner/C = locate() in src.modules
	C.reagents.add_reagent("cleaner", 10)

	for(var/T in stacktypes)
		var/O = locate(T) in src.modules
		var/obj/item/stack/sheet/S = O

		if(!S)
			src.modules -= null
			S = new T(src)
			src.modules += S
			S.amount = 1

		if(S && S.amount < stacktypes[T])
			S.amount++

	var/obj/item/device/lightreplacer/LR = locate() in src.modules
	LR.Charge(R)

	return
