	object_const_def
	const PEWTERCITY_COOLTRAINER_F
	const PEWTERCITY_BUG_CATCHER
	const PEWTERCITY_GRAMPS
	const PEWTERCITY_FRUIT_TREE1
	const PEWTERCITY_FRUIT_TREE2
	const PEWTERCITY_GYM_BLOCKER

PewterCity_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_NEWMAP, PewterCityFlypointCallback
	callback MAPCALLBACK_OBJECTS, PewterCityGymBlockerCallback

PewterCityFlypointCallback:
	setflag ENGINE_FLYPOINT_PEWTER
	endcallback

; LoadObjectMasks runs after this callback, so use a dedicated visibility flag.
; Never use EVENT_BEAT_BROCK as the object's flag: the escort hides/reappears it.
PewterCityGymBlockerCallback:
	checkevent EVENT_BEAT_BROCK
	iftrue .Gone
	clearevent EVENT_PEWTER_CITY_GYM_BLOCKER
	endcallback
.Gone:
	setevent EVENT_PEWTER_CITY_GYM_BLOCKER
	endcallback

; Yellow's east-exit youngster and Gym escort, using native Crystal movement.
; All-scene coord events avoid allocating another saved scene variable.
PewterCityGymBlockerScript:
	checkevent EVENT_BEAT_BROCK
	iftrue .Done
	setlasttalked PEWTERCITY_GYM_BLOCKER
	faceplayer
	opentext
	writetext PewterCityGymBlockerFollowMeText
	waitbutton
	closetext
	; Bring all exit approaches and direct interactions to (35, 19).
	readvar VAR_XCOORD
	ifequal 34, .FromWest
	ifequal 35, .FromSouth
	ifequal 36, .Column36
	readvar VAR_YCOORD
	ifequal 16, .FarNorth
	ifequal 17, .FarMiddle
	ifequal 18, .FarSouth
	applymovement PLAYER, PewterCityBlockerPlayerLeftTwo
	sjump .Ready
.FromWest:
	applymovement PLAYER, PewterCityBlockerPlayerFromWest
	sjump .Ready
.FromSouth:
	applymovement PLAYER, PewterCityBlockerPlayerDownTwo
	sjump .Ready
.Column36:
	readvar VAR_YCOORD
	ifequal 16, .FromEast
	applymovement PLAYER, PewterCityBlockerPlayerFromColumn36
	sjump .Ready
.FromEast:
	applymovement PLAYER, PewterCityBlockerPlayerFromEast
	sjump .Ready
.FarNorth:
	applymovement PLAYER, PewterCityBlockerPlayerFromFarNorth
	sjump .Ready
.FarMiddle:
	applymovement PLAYER, PewterCityBlockerPlayerFromFarMiddle
	sjump .Ready
.FarSouth:
	applymovement PLAYER, PewterCityBlockerPlayerFromFarSouth
.Ready:
	applymovement PEWTERCITY_GYM_BLOCKER, PewterCityBlockerDownTwo
	playmusic MUSIC_SHOW_ME_AROUND
	; Crystal's wandering NPC can occupy Yellow's original escort corridor.
	; She is outside the camera here; restore her when the escort is finished.
	disappear PEWTERCITY_COOLTRAINER_F
	follow PEWTERCITY_GYM_BLOCKER, PLAYER
	applymovement PEWTERCITY_GYM_BLOCKER, PewterCityBlockerWalkToGym
	stopfollow
	special RestartMapMusic
	turnobject PEWTERCITY_GYM_BLOCKER, LEFT
	turnobject PLAYER, RIGHT
	opentext
	writetext PewterCityGymBlockerTakeOnBrockText
	waitbutton
	closetext
	applymovement PEWTERCITY_GYM_BLOCKER, PewterCityBlockerLeaveGym
	disappear PEWTERCITY_GYM_BLOCKER
	moveobject PEWTERCITY_GYM_BLOCKER, 35, 16
	appear PEWTERCITY_GYM_BLOCKER
	appear PEWTERCITY_COOLTRAINER_F
.Done:
	end

PewterCityBlockerPlayerFromWest:
	rept 3
		step DOWN
	endr
	step RIGHT
	step_end

PewterCityBlockerPlayerFromEast:
	rept 3
		step DOWN
	endr
	step LEFT
	step_end

PewterCityBlockerPlayerDownTwo:
PewterCityBlockerDownTwo:
	step DOWN
	step DOWN
	step_end

PewterCityBlockerPlayerFromColumn36:
	step DOWN
	step DOWN
	step LEFT
	step_end

PewterCityBlockerPlayerFromFarNorth:
	step DOWN
PewterCityBlockerPlayerFromFarMiddle:
	step DOWN
PewterCityBlockerPlayerFromFarSouth:
	step DOWN
PewterCityBlockerPlayerLeftTwo:
	step LEFT
	step LEFT
	step_end

PewterCityBlockerWalkToGym:
	rept 15
		step LEFT
	endr
	rept 5
		step UP
	endr
	rept 11
		step LEFT
	endr
	rept 5
		step DOWN
	endr
	rept 3
		step RIGHT
	endr
	step_end

PewterCityBlockerLeaveGym:
	rept 5
		step RIGHT
	endr
	turn_head DOWN
	step_end

PewterCityGymBlockerFollowMeText:
	text "You're a trainer"
	line "right? BROCK's"
	cont "looking for new"
	cont "challengers!"
	cont "Follow me!"
	done

PewterCityGymBlockerTakeOnBrockText:
	text "If you have the"
	line "right stuff, go"
	cont "take on BROCK!"
	done

PewterCityCooltrainerFScript:
	jumptextfaceplayer PewterCityCooltrainerFText

PewterCityBugCatcherScript:
	jumptextfaceplayer PewterCityBugCatcherText

PewterCityGrampsScript:
	faceplayer
	opentext
	checkevent EVENT_GOT_SILVER_WING
	iftrue .GotSilverWing
	writetext PewterCityGrampsText
	promptbutton
	verbosegiveitem SILVER_WING
	setevent EVENT_GOT_SILVER_WING
	closetext
	end

.GotSilverWing:
	writetext PewterCityGrampsText_GotSilverWing
	waitbutton
	closetext
	end

PewterCitySign:
	jumptext PewterCitySignText

PewterGymSign:
	jumptext PewterGymSignText

PewterMuseumSign:
	jumptext PewterMuseumSignText

PewterCityMtMoonGiftShopSign:
	jumptext PewterCityMtMoonGiftShopSignText

PewterCityWelcomeSign:
	jumptext PewterCityWelcomeSignText

PewterCityPokecenterSign:
	jumpstd PokecenterSignScript

PewterCityMartSign:
	jumpstd MartSignScript

PewterCityFruitTree1:
	fruittree FRUITTREE_PEWTER_CITY_1

PewterCityFruitTree2:
	fruittree FRUITTREE_PEWTER_CITY_2

PewterCityCooltrainerFText:
	text "Have you visited"
	line "PEWTER GYM?"

	para "The LEADER uses"
	line "rock-type #MON."
	done

PewterCityBugCatcherText:
	text "At night, CLEFAIRY"
	line "come out to play"
	cont "at MT.MOON."

	para "But not every"
	line "night."
	done

PewterCityGrampsText:
	text "Ah, you came all"
	line "the way out here"
	cont "from JOHTO?"

	para "That brings back"
	line "memories. When I"

	para "was young, I went"
	line "to JOHTO to train."

	para "You remind me so"
	line "much of what I was"

	para "like as a young"
	line "man."

	para "Here. I want you"
	line "to have this item"
	cont "I found in JOHTO."
	done

PewterCityGrampsText_GotSilverWing:
	text "Going to new, un-"
	line "known places and"
	cont "seeing new people…"

	para "Those are the joys"
	line "of travel."
	done

PewterCitySignText:
	text "PEWTER CITY"
	line "A Stone Gray City"
	done

PewterGymSignText:
	text "PEWTER CITY"
	line "#MON GYM"
	cont "LEADER: BROCK"

	para "The Rock Solid"
	line "#MON Trainer"
	done

PewterMuseumSignText:
	text "There's a notice"
	line "here…"

	para "PEWTER MUSEUM OF"
	line "SCIENCE is closed"
	cont "for renovations…"
	done

PewterCityMtMoonGiftShopSignText:
	text "There's a notice"
	line "here…"

	para "MT.MOON GIFT SHOP"
	line "NOW OPEN!"
	done

PewterCityWelcomeSignText:
	text "WELCOME TO"
	line "PEWTER CITY!"
	done

PewterCity_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 29, 13, PEWTER_NIDORAN_SPEECH_HOUSE, 1
	warp_event 16, 17, PEWTER_GYM, 1
	warp_event 23, 17, PEWTER_MART, 2
	warp_event 13, 25, PEWTER_POKECENTER_1F, 1
	warp_event  7, 29, PEWTER_SNOOZE_SPEECH_HOUSE, 1

	def_coord_events
	; Yellow's interception points plus a complete eastern corridor boundary.
	coord_event 35, 17, -1, PewterCityGymBlockerScript
	coord_event 36, 17, -1, PewterCityGymBlockerScript
	coord_event 37, 16, -1, PewterCityGymBlockerScript
	coord_event 37, 17, -1, PewterCityGymBlockerScript
	coord_event 37, 18, -1, PewterCityGymBlockerScript
	coord_event 37, 19, -1, PewterCityGymBlockerScript

	def_bg_events
	bg_event 25, 23, BGEVENT_READ, PewterCitySign
	bg_event 11, 17, BGEVENT_READ, PewterGymSign
	bg_event 15,  9, BGEVENT_READ, PewterMuseumSign
	bg_event 33, 19, BGEVENT_READ, PewterCityMtMoonGiftShopSign
	bg_event 19, 29, BGEVENT_READ, PewterCityWelcomeSign
	bg_event 14, 25, BGEVENT_READ, PewterCityPokecenterSign
	bg_event 24, 17, BGEVENT_READ, PewterCityMartSign

	def_object_events
	object_event 19, 11, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_WANDER, 2, 2, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, PewterCityCooltrainerFScript, -1
	object_event 14, 29, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_WANDER, 2, 2, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, PewterCityBugCatcherScript, -1
	object_event 29, 17, SPRITE_GRAMPS, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, PewterCityGrampsScript, -1
	object_event 32,  3, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterCityFruitTree1, -1
	object_event 30,  3, SPRITE_FRUIT_TREE, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterCityFruitTree2, -1
	object_event 35, 16, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, PewterCityGymBlockerScript, EVENT_PEWTER_CITY_GYM_BLOCKER
