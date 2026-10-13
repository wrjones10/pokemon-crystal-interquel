	object_const_def
	const VIRIDIANFORESTSOUTHGATE_GIRL
	const VIRIDIANFORESTSOUTHGATE_LITTLEGIRL

ViridianForestSouthGate_MapScripts:
	def_scene_scripts

	def_callbacks

ViridianForestSouthGateGirlScript:
	jumptextfaceplayer ViridianForestSouthGateGirlText

ViridianForestSouthGateLittleGirlScript:
	jumptextfaceplayer ViridianForestSouthGateLittleGirlText

ViridianForestSouthGateGirlText:
	text "Are you going to"
	line "VIRIDIAN FOREST?"
	cont "Be careful, it's"
	cont "a natural maze!"
	done

ViridianForestSouthGateLittleGirlText:
	text "You have to roam"
	line "far to get new"
	cont "kinds of #MON."

	para "Look for other"
	line "types outside of"
	cont "VIRIDIAN FOREST."
	done

ViridianForestSouthGate_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 4, 0, VIRIDIAN_FOREST, 4
	warp_event 5, 0, VIRIDIAN_FOREST, 4
	warp_event 4, 7, ROUTE_2, 7
	warp_event 5, 7, ROUTE_2, 7

	def_coord_events

	def_bg_events

	def_object_events
	object_event 7, 4, SPRITE_LASS, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ViridianForestSouthGateGirlScript, -1
	object_event 2, 4, SPRITE_TWIN, SPRITEMOVEDATA_WALK_UP_DOWN, 0, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ViridianForestSouthGateLittleGirlScript, -1
