	object_const_def
	const PALLETTOWN_TEACHER
	const PALLETTOWN_FISHER
	const PALLETTOWN_OAK

PalletTown_MapScripts:
	def_scene_scripts
	scene_script PalletTownNoopScene, SCENE_PALLETTOWN_OAK_STOPS_PLAYER
	scene_script PalletTownNoopScene, SCENE_PALLETTOWN_NOOP

	def_callbacks
	callback MAPCALLBACK_NEWMAP, PalletTownFlypointCallback

PalletTownFlypointCallback:
	setflag ENGINE_FLYPOINT_PALLET
	endcallback

PalletTownNoopScene:
	end

PalletTownOakStopsPlayerLeft:
	moveobject PALLETTOWN_OAK, 8, 3
	scall PalletTownOakWarning
	follow PALLETTOWN_OAK, PLAYER
	applymovement PALLETTOWN_OAK, PalletTownOakEscortLeft
	sjump PalletTownFinishEscort

PalletTownOakStopsPlayerRight:
	moveobject PALLETTOWN_OAK, 9, 3
	scall PalletTownOakWarning
	follow PALLETTOWN_OAK, PLAYER
	applymovement PALLETTOWN_OAK, PalletTownOakEscortRight
PalletTownFinishEscort:
	stopfollow
	disappear PALLETTOWN_OAK
	applymovement PLAYER, PalletTownPlayerEntersLab
	setevent EVENT_FOLLOWED_OAK_TO_LAB
	setscene SCENE_PALLETTOWN_NOOP
	warp OAKS_LAB, 5, 10
	end

PalletTownOakWarning:
	playmusic MUSIC_PROF_OAK
	opentext
	writetext PalletTownOakWaitText
	waitbutton
	closetext
	showemote EMOTE_SHOCK, PLAYER, 15
	appear PALLETTOWN_OAK
	applymovement PALLETTOWN_OAK, PalletTownOakApproach
	turnobject PLAYER, DOWN
	opentext
	writetext PalletTownOakUnsafeText
	waitbutton
	closetext
	end

PalletTownOakApproach:
	step UP
	step_end

PalletTownPlayerEntersLab:
	step UP
	step_end

PalletTownOakEscortLeft:
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step RIGHT
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step RIGHT
	step RIGHT
	step RIGHT
	step UP
	step_end

PalletTownOakEscortRight:
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step RIGHT
	step RIGHT
	step RIGHT
	step UP
	step_end

PalletTownOakWaitText:
	text "OAK: Hey! Wait!"
	line "Don't go out!"
	done

PalletTownOakUnsafeText:
	text "OAK: It's unsafe!"
	line "Wild #MON live"
	cont "in tall grass!"

	para "You need your own"
	line "#MON for your"
	cont "protection."

	para "Here, come with"
	line "me!"
	done

PalletTownTeacherScript:
	jumptextfaceplayer PalletTownTeacherText

PalletTownFisherScript:
	jumptextfaceplayer PalletTownFisherText

PalletTownSign:
	jumptext PalletTownSignText

RedsHouseSign:
	jumptext RedsHouseSignText

OaksLabSign:
	jumptext OaksLabSignText

BluesHouseSign:
	jumptext BluesHouseSignText

PalletTownTeacherText:
	text "I'm raising #-"
	line "MON too."

	para "They serve as my"
	line "private guards."
	done

PalletTownFisherText:
	text "Technology is"
	line "incredible!"

	para "You can now trade"
	line "#MON across"
	cont "time like e-mail."
	done

PalletTownSignText:
	text "PALLET TOWN"

	para "A Tranquil Setting"
	line "of Peace & Purity"
	done

RedsHouseSignText:
	text "<PLAYER>'S HOUSE"
	done

OaksLabSignText:
	text "OAK #MON"
	line "RESEARCH LAB"
	done

BluesHouseSignText:
	text "BLUE'S HOUSE"
	done

PalletTown_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  5,  5, REDS_HOUSE_1F, 1
	warp_event 13,  5, BLUES_HOUSE, 1
	warp_event 12, 11, OAKS_LAB, 1

	def_coord_events
	coord_event 8, 1, SCENE_PALLETTOWN_OAK_STOPS_PLAYER, PalletTownOakStopsPlayerLeft
	coord_event 9, 1, SCENE_PALLETTOWN_OAK_STOPS_PLAYER, PalletTownOakStopsPlayerRight

	def_bg_events
	bg_event  7,  9, BGEVENT_READ, PalletTownSign
	bg_event  3,  5, BGEVENT_READ, RedsHouseSign
	bg_event 13, 13, BGEVENT_READ, OaksLabSign
	bg_event 11,  5, BGEVENT_READ, BluesHouseSign

	def_object_events
	object_event  3,  8, SPRITE_TEACHER, SPRITEMOVEDATA_WANDER, 2, 2, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PalletTownTeacherScript, -1
	object_event 12, 14, SPRITE_FISHER, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, PalletTownFisherScript, -1
	object_event 8, 3, SPRITE_OAK, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_PALLET_TOWN_OAK
