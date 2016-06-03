// This file is a modified version of https://raw2.github.com/Baystation12/OldCode-BS12/master/code/TakePicture.dm

#define voreMAP_ICON_SIZE 4
#define voreMAP_MAX_ICON_DIMENSION 1024

#define voreMAP_TILES_PER_IMAGE (voreMAP_MAX_ICON_DIMENSION / voreMAP_ICON_SIZE)

#define voreMAP_TERMINALERR 5
#define voreMAP_INPROGRESS 2
#define voreMAP_BADOUTPUT 2
#define voreMAP_SUCCESS 1
#define voreMAP_WATCHDOGSUCCESS 4
#define voreMAP_WATCHDOGTERMINATE 3


//Call these procs to dump your world to a series of image files (!!)
//NOTE: Does not explicitly support non 32x32 icons or stuff with large pixel_* values, so don't blame me if it doesn't work perfectly

/client/proc/voremapgen_DumpImage()
	set name = "Generate VoreUI Map"
	set category = "Server"

	if(holder)
		voremapgen_DumpTile(1, 1, text2num(input(usr,"Enter the Z level to generate")))

/client/proc/voremapgen_DumpTile(var/startX = 1, var/startY = 1, var/currentZ = 1, var/endX = -1, var/endY = -1)

	if (endX < 0 || endX > world.maxx)
		endX = world.maxx

	if (endY < 0 || endY > world.maxy)
		endY = world.maxy

	if (currentZ < 0 || currentZ > world.maxz)
		usr << "voreMapGen: <B>ERROR: currentZ ([currentZ]) must be between 1 and [world.maxz]</B>"

		sleep(3)
		return voreMAP_TERMINALERR

	if (startX > endX)
		usr << "voreMapGen: <B>ERROR: startX ([startX]) cannot be greater than endX ([endX])</B>"

		sleep(3)
		return voreMAP_TERMINALERR

	if (startY > endX)
		usr << "voreMapGen: <B>ERROR: startY ([startY]) cannot be greater than endY ([endY])</B>"
		sleep(3)
		return voreMAP_TERMINALERR

	var/icon/Tile = icon(file("vore/mapbase1024.png"))
	if (Tile.Width() != voreMAP_MAX_ICON_DIMENSION || Tile.Height() != voreMAP_MAX_ICON_DIMENSION)
		world.log << "voreMapGen: <B>ERROR: BASE IMAGE DIMENSIONS ARE NOT [voreMAP_MAX_ICON_DIMENSION]x[voreMAP_MAX_ICON_DIMENSION]</B>"
		sleep(3)
		return voreMAP_TERMINALERR

	world.log << "voreMapGen: <B>GENERATE MAP ([startX],[startY],[currentZ]) to ([endX],[endY],[currentZ])</B>"
	usr << "voreMapGen: <B>GENERATE MAP ([startX],[startY],[currentZ]) to ([endX],[endY],[currentZ])</B>"

	var/count = 0;
	for(var/WorldX = startX, WorldX <= endX, WorldX++)
		for(var/WorldY = startY, WorldY <= endY, WorldY++)

			var/atom/Turf = locate(WorldX, WorldY, currentZ)

			var/icon/TurfIcon = new(Turf.icon, Turf.icon_state)
			TurfIcon.Scale(voreMAP_ICON_SIZE, voreMAP_ICON_SIZE)

			Tile.Blend(TurfIcon, ICON_OVERLAY, ((WorldX - 1) * voreMAP_ICON_SIZE), ((WorldY - 1) * voreMAP_ICON_SIZE))

			count++

			if (count % 8000 == 0)
				world.log << "voreMapGen: <B>[count] tiles done</B>"
				sleep(1)

	var/mapFilename = "voremap_z[currentZ]-new.png"

	world.log << "voreMapGen: <B>sending [mapFilename] to client</B>"

	usr << browse(Tile, "window=picture;file=[mapFilename];display=0")

	world.log << "voreMapGen: <B>Done.</B>"

	usr << "voreMapGen: <B>Done. File [mapFilename] uploaded to your cache.</B>"

	if (Tile.Width() != voreMAP_MAX_ICON_DIMENSION || Tile.Height() != voreMAP_MAX_ICON_DIMENSION)
		return voreMAP_BADOUTPUT

	return voreMAP_SUCCESS