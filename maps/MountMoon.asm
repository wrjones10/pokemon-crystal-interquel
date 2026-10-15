MountMoon_MapScripts:
	def_scene_scripts
; Keep both scene IDs valid for existing saves; neither triggers an encounter.
	scene_script MountMoonNoopScene, SCENE_MOUNTMOON_RIVAL_BATTLE
	scene_script MountMoonNoopScene, SCENE_MOUNTMOON_NOOP

	def_callbacks

MountMoonNoopScene:
	end

MountMoon_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  3, ROUTE_4, 2
	warp_event 15, 15, ROUTE_4, 3
	warp_event 13,  3, MOUNT_MOON, 7
	warp_event 15, 11, MOUNT_MOON, 8
	warp_event 25,  5, MOUNT_MOON_SQUARE, 1
	warp_event 25, 15, MOUNT_MOON_SQUARE, 2
	warp_event 25,  3, MOUNT_MOON, 3
	warp_event 25, 13, MOUNT_MOON, 4

	def_coord_events

	def_bg_events

	def_object_events
