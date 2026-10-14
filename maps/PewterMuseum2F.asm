PewterMuseum2F_MapScripts:
	def_scene_scripts
	def_callbacks

PewterMuseum2FYoungster:
	jumptextfaceplayer PewterMuseum2FYoungsterText

PewterMuseum2FGramps:
	jumptextfaceplayer PewterMuseum2FGrampsText

PewterMuseum2FScientist:
	jumptextfaceplayer PewterMuseum2FScientistText

PewterMuseum2FGirl:
	jumptextfaceplayer PewterMuseum2FBrunetteGirlText

PewterMuseum2FFather:
	jumptextfaceplayer PewterMuseum2FHikerText

PewterMuseum2FSpaceShuttleSign:
	jumptext PewterMuseum2FSpaceShuttleSignText

PewterMuseum2FMoonStoneSign:
	jumptext PewterMuseum2FMoonStoneSignText

PewterMuseum2FYoungsterText:
	text "MOON STONE?"

	para "What's so special"
	line "about it?"
	done

PewterMuseum2FGrampsText:
	text "July 20, 1969!"

	para "The 1st lunar"
	line "landing!"

	para "I bought a color"
	line "TV to watch it!"
	done

PewterMuseum2FScientistText:
	text "We have a space"
	line "exhibit now."
	done

PewterMuseum2FBrunetteGirlText:
	text "I want a PIKACHU!"
	line "It's so cute!"

	para "I asked my Daddy"
	line "to catch me one!"
	done

PewterMuseum2FHikerText:
	text "Yeah, a PIKACHU"
	line "soon, I promise!"
	done

PewterMuseum2FPikachuText1:
	text "Your PIKACHU looks"
	line "untamed."
	cont "May I have it for"
	cont "my daughter?"
	done

PewterMuseum2FPikachuText2:
	text "I'd like to get"
	line "that PIKACHU off"
	cont "you, but it's too"
	cont "attached to you."
	done

PewterMuseum2FSpaceShuttleSignText:
	text "SPACE SHUTTLE"
	line "COLUMBIA"
	done

PewterMuseum2FMoonStoneSignText:
	text "Meteorite that"
	line "fell on MT.MOON."
	cont "(MOON STONE?)"
	done

PewterMuseum2F_MapEvents:
	db 0, 0
	def_warp_events
	warp_event 7, 7, PEWTER_MUSEUM_1F, 5
	def_coord_events
	def_bg_events
	bg_event 11, 2, BGEVENT_READ, PewterMuseum2FSpaceShuttleSign
	bg_event 2, 5, BGEVENT_READ, PewterMuseum2FMoonStoneSign
	def_object_events
	object_event 1, 7, SPRITE_YOUNGSTER, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterMuseum2FYoungster, -1
	object_event 0, 5, SPRITE_GRAMPS, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterMuseum2FGramps, -1
	object_event 7, 5, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterMuseum2FScientist, -1
	object_event 11, 5, SPRITE_LASS, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterMuseum2FGirl, -1
	object_event 12, 5, SPRITE_POKEFAN_M, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterMuseum2FFather, -1
