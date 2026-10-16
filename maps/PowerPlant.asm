	object_const_def
	const POWERPLANT_OFFICER1
	const POWERPLANT_GYM_GUIDE1
	const POWERPLANT_GYM_GUIDE2
	const POWERPLANT_OFFICER2
	const POWERPLANT_GYM_GUIDE3
	const POWERPLANT_MANAGER
	const POWERPLANT_FOREST

PowerPlant_MapScripts:
	def_scene_scripts
	scene_script PowerPlantNoopScene, SCENE_POWERPLANT_NOOP
	scene_script PowerPlantNoopScene, SCENE_POWERPLANT_GUARD_GETS_PHONE_CALL
	def_callbacks
	callback MAPCALLBACK_NEWMAP, PowerPlantAvailableCallback

PowerPlantNoopScene:
	end

PowerPlantAvailableCallback:
	farscall KantoPowerAvailableScript
	endcallback

KantoPowerAvailableScript::
; The old completion flag selects normal dialogue in existing Kanto scripts.
; Keep the old restored-power flag separate from Johto rematch progression.
	setevent EVENT_RETURNED_MACHINE_PART
	clearevent EVENT_TRAINERS_IN_CERULEAN_GYM
	setevent EVENT_CERULEAN_GYM_ROCKET
	setevent EVENT_FOUND_MACHINE_PART_IN_CERULEAN_GYM
	setevent EVENT_ROUTE_24_ROCKET
	setevent EVENT_ROUTE_25_MISTY_BOYFRIEND
	clearevent EVENT_SAFFRON_TRAIN_STATION_POPULATION
	clearevent EVENT_GOLDENROD_TRAIN_STATION_GENTLEMAN
	setevent EVENT_ROUTE_5_6_POKEFAN_M_BLOCKS_UNDERGROUND_PATH
; Remove obsolete quest inventory from existing saves, without item renumbering.
	takeitem MACHINE_PART
	end

PowerPlantOfficerScript:
	jumptextfaceplayer PowerPlantOfficerWorkingText

PowerPlantGymGuide1Script:
	jumptextfaceplayer PowerPlantGymGuide1GeneratorUpAndRunningText

PowerPlantGymGuide2Script:
	jumptextfaceplayer PowerPlantGymGuide2PowerPlantUpAndRunningText

PowerPlantOfficer2Script:
	jumptextfaceplayer PowerPlantOfficer2WorkingText

PowerPlantGymGuide4Script:
	jumptextfaceplayer PowerPlantGymGuide4WorkingText

PowerPlantManager:
	faceplayer
	opentext
	checkevent EVENT_GOT_TM07_ZAP_CANNON
	iftrue .GotZapCannon
	writetext PowerPlantManagerTakeThisTMText
	promptbutton
	verbosegiveitem TM_ZAP_CANNON
	iffalse .NoRoom
	setevent EVENT_GOT_TM07_ZAP_CANNON
	writetext PowerPlantManagerTM07IsZapCannonText
	waitbutton
.NoRoom:
	closetext
	end
.GotZapCannon:
	writetext PowerPlantManagerMyBelovedGeneratorText
	waitbutton
	closetext
	end

Forest:
	faceplayer
	opentext
	trade NPC_TRADE_FOREST
	waitbutton
	closetext
	end

PowerPlantBookshelf:
	jumpstd DifficultBookshelfScript

PowerPlantOfficerWorkingText:
	text "We keep a close"
	line "watch on this"
	cont "POWER PLANT."
	done

PowerPlantOfficer2WorkingText:
	text "The MANAGER takes"
	line "great pride in"
	cont "this generator."
	done

PowerPlantGymGuide4WorkingText:
	text "The MAGNET TRAIN"
	line "uses electricity"
	cont "from this plant."
	done

PowerPlantGymGuide1GeneratorUpAndRunningText:
	text "The generator's up"
	line "and running. It's"

	para "making electricity"
	line "to spare."
	done

PowerPlantGymGuide2PowerPlantUpAndRunningText:
	text "This POWER PLANT"
	line "had been abandoned"
	cont "in the past."

	para "We got it back up"
	line "and running to"

	para "provide power to"
	line "the MAGNET TRAIN."
	done

PowerPlantManagerTakeThisTMText:
	text "Wahah! Thanks!"

	para "Here! Take this TM"
	line "as a reward!"
	done

PowerPlantManagerTM07IsZapCannonText:
	text "MANAGER: TM07 is"
	line "my ZAP CANNON."

	para "It's a powerful"
	line "technique!"

	para "It's not what any-"
	line "one would consider"

	para "accurate, but it"
	line "packs a wallop!"
	done

PowerPlantManagerMyBelovedGeneratorText:
	text "MANAGER: My be-"
	line "loved generator!"

	para "Keep pumping the"
	line "electricity out!"
	done

PowerPlant_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2, 17, ROUTE_10_NORTH, 2
	warp_event  3, 17, ROUTE_10_NORTH, 2

	def_coord_events

	def_bg_events
	bg_event  0,  1, BGEVENT_READ, PowerPlantBookshelf
	bg_event  1,  1, BGEVENT_READ, PowerPlantBookshelf

	def_object_events
	object_event  4, 14, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, PowerPlantOfficerScript, -1
	object_event  2,  9, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, PowerPlantGymGuide1Script, -1
	object_event  6, 11, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, PowerPlantGymGuide2Script, -1
	object_event  9,  3, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, PowerPlantOfficer2Script, -1
	object_event  7,  2, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, PowerPlantGymGuide4Script, -1
	object_event 14, 10, SPRITE_FISHER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, PowerPlantManager, -1
	object_event  5,  5, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, Forest, -1
