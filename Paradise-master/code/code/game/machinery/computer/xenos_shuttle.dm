#define XENOS_SHUTTLE_MOVE_TIME 240
#define XENOS_SHUTTLE_COOLDOWN 200

/obj/machinery/computer/xenos_station
	name = "xenos shuttle terminal"
	icon = 'icons/obj/computer.dmi'
	icon_state = "xenocontrol"
	req_access = list()
	var/area/curr_location
	var/moving = 0
	var/lastMove = 0


/obj/machinery/computer/xenos_station/New()
	curr_location= locate(/area/xenos_station/start)


/obj/machinery/computer/xenos_station/proc/xenos_move_to(area/destination as area)
	if(moving)	return
	if(lastMove + XENOS_SHUTTLE_COOLDOWN > world.time)	return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)	return

	moving = 1
	lastMove = world.time

	if(curr_location.z != dest_location.z)
		var/area/transit_location = locate(/area/xenos_station/transit)
		curr_location.move_contents_to(transit_location)
		curr_location = transit_location
		sleep(XENOS_SHUTTLE_MOVE_TIME)

	curr_location.move_contents_to(dest_location)
	curr_location = dest_location
	moving = 0
	return 1


/obj/machinery/computer/xenos_station/attackby(obj/item/I as obj, mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/xenos_station/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/xenos_station/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/xenos_station/attack_hand(mob/user as mob)
	if(!allowed(user))
		user << "\red Access Denied"
		return

	user.set_machine(src)

	var/dat = {"Location: [curr_location]<br>
	Ready to move[max(lastMove + XENOS_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + XENOS_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
	<a href='?src=\ref[src];xenos=1'>Xenos Space</a><br>
	<a href='?src=\ref[src];station_nw=1'>North West of SS13</a> |
	<a href='?src=\ref[src];station_n=1'>North of SS13</a> |
	<a href='?src=\ref[src];station_ne=1'>North East of SS13</a><br>
	<a href='?src=\ref[src];station_sw=1'>South West of SS13</a> |
	<a href='?src=\ref[src];station_s=1'>South of SS13</a> |
	<a href='?src=\ref[src];station_se=1'>South East of SS13</a><br>
	<a href='?src=\ref[user];mach_close=computer'>Close</a>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return


/obj/machinery/computer/xenos_station/Topic(href, href_list)
	if(!isliving(usr))	return
	var/mob/living/user = usr

	if(in_range(src, user) || istype(user, /mob/living/silicon))
		user.set_machine(src)

	if(href_list["xenos"])
		xenos_move_to(/area/xenos_station/start)
	else if(href_list["station_nw"])
		xenos_move_to(/area/xenos_station/northwest)
	else if(href_list["station_n"])
		xenos_move_to(/area/xenos_station/north)
	else if(href_list["station_ne"])
		xenos_move_to(/area/xenos_station/northeast)
	else if(href_list["station_sw"])
		xenos_move_to(/area/xenos_station/southwest)
	else if(href_list["station_s"])
		xenos_move_to(/area/xenos_station/south)
	else if(href_list["station_se"])
		xenos_move_to(/area/xenos_station/southeast)


	add_fingerprint(usr)
	updateUsrDialog()
	return

/obj/machinery/computer/xenos_station/bullet_act(var/obj/item/projectile/Proj)
	visible_message("[Proj] ricochets off [src]!")	//let's not let them fuck themselves in the rear