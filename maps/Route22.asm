	object_const_def
	const ROUTE22_RIVAL

Route22_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_OBJECTS, Route22HideRivalCallback
	callback MAPCALLBACK_SPRITES, Route22RivalSpriteCallback

Route22HideRivalCallback:
; Reveal the rival only when an eligible player reaches the ambush tiles.
	disappear ROUTE22_RIVAL
	endcallback

Route22RivalSpriteCallback:
; Oak never walks outdoors again after the lab battle. Reuse his walking slot
; locally, keeping the shared outdoor list and every other NPC slot unchanged.
	checkevent EVENT_BATTLED_RIVAL_IN_OAKS_LAB
	iffalse .Done
	callasm Route22UseOakWalkingSlot
.Done:
	endcallback

Route22UseOakWalkingSlot:
	ld a, SPRITE_BLUE
	call .FindTile
	ret c
	bit 7, [hl]
	ret z ; already has walking frames
	push hl
	ld a, SPRITE_OAK
	call .FindTile
	jr c, .MissingOak
	bit 7, [hl]
	jr nz, .MissingOak
	ld d, [hl]
	pop bc
	ld a, [bc]
	ld [hl], a
	ld a, d
	ld [bc], a
	ret

.MissingOak:
	pop hl
	ret

.FindTile:
	ld hl, wUsedSprites + 2
	ld b, SPRITE_GFX_LIST_CAPACITY - 1
.FindLoop:
	cp [hl]
	jr z, .Found
	inc hl
	inc hl
	dec b
	jr nz, .FindLoop
	scf
	ret
.Found:
	inc hl
	and a
	ret

Route22RivalBattle:
	checkflag ENGINE_BOULDERBADGE
	iftrue .Done
	checkevent EVENT_BATTLED_ROUTE_22_RIVAL
	iftrue .Done
	checkevent EVENT_BATTLED_RIVAL_IN_OAKS_LAB
	iffalse .Done
	disappear ROUTE22_RIVAL
	moveobject ROUTE22_RIVAL, 25, 5
	special RefreshSprites
	appear ROUTE22_RIVAL
	showemote EMOTE_SHOCK, ROUTE22_RIVAL, 15
	playmusic MUSIC_RIVAL_ENCOUNTER
	readvar VAR_YCOORD
	ifequal 4, .UpperApproach
	applymovement ROUTE22_RIVAL, Route22RivalApproachLower
	turnobject PLAYER, LEFT
	turnobject ROUTE22_RIVAL, RIGHT
	sjump .Challenge
.UpperApproach:
	applymovement ROUTE22_RIVAL, Route22RivalApproachUpper
	turnobject PLAYER, DOWN
	turnobject ROUTE22_RIVAL, UP
.Challenge:
	opentext
	writetext Route22RivalChallengeText
	waitbutton
	closetext
	checkevent EVENT_GOT_BULBASAUR_FROM_OAK
	iftrue .Charmander
	checkevent EVENT_GOT_CHARMANDER_FROM_OAK
	iftrue .Squirtle
	loadtrainer PALLET_RIVAL, PALLET_RIVAL_ROUTE22_BULBASAUR
	sjump .Battle
.Charmander:
	loadtrainer PALLET_RIVAL, PALLET_RIVAL_ROUTE22_CHARMANDER
	sjump .Battle
.Squirtle:
	loadtrainer PALLET_RIVAL, PALLET_RIVAL_ROUTE22_SQUIRTLE
.Battle:
	winlosstext Route22RivalWinText, Route22RivalLossText
	setlasttalked ROUTE22_RIVAL
	startbattle
	reloadmapafterbattle
; Losses branch to blackout and do not return here, leaving a retry available.
	setevent EVENT_BATTLED_ROUTE_22_RIVAL
	opentext
	writetext Route22RivalLeavingText
	waitbutton
	closetext
	readvar VAR_YCOORD
	ifequal 4, .UpperExit
	applymovement ROUTE22_RIVAL, Route22RivalExitLower
	sjump .Leave
.UpperExit:
	applymovement ROUTE22_RIVAL, Route22RivalExitUpper
.Leave:
	disappear ROUTE22_RIVAL
	special RestartMapMusic
.Done:
	end

Route22RivalNoop:
	end

; The sprite callback gives BLUE full walking frames before these movements.
Route22RivalApproachUpper:
	step RIGHT
Route22RivalApproachLower:
	step RIGHT
	step RIGHT
	step RIGHT
	step_end

Route22RivalExitLower:
	step UP
	step RIGHT
	step RIGHT
	step RIGHT
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

Route22RivalExitUpper:
	step RIGHT
	step RIGHT
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step_end

Route22RivalChallengeText:
	text "Hey, <PLAYER>!"

	para "You're going to"
	line "#MON LEAGUE?"

	para "Forget it! You"
	line "probably don't"
	cont "have any BADGEs!"

	para "The guard won't"
	line "let you through!"

	para "By the way, did"
	line "your #MON"
	cont "get any stronger?"
	done

Route22RivalWinText:
	text "Awww! You just"
	line "lucked out!"
	done

Route22RivalLossText:
	text "You should catch"
	line "some more #MON"
	cont "too!"
	done

Route22RivalLeavingText:
	text "I heard #MON"
	line "LEAGUE has many"
	cont "tough trainers!"

	para "I have to figure"
	line "out how to get"
	cont "past them!"

	para "You should quit"
	line "dawdling and get"
	cont "a move on!"
	done

VictoryRoadEntranceSign:
	jumptext VictoryRoadEntranceSignText

VictoryRoadEntranceSignText:
	text "#MON LEAGUE"

	para "VICTORY ROAD"
	line "ENTRANCE"
	done

Route22_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 13,  5, VICTORY_ROAD_GATE, 1

	def_coord_events
	coord_event 29, 4, -1, Route22RivalBattle
	coord_event 29, 5, -1, Route22RivalBattle

	def_bg_events
	bg_event 15,  7, BGEVENT_READ, VictoryRoadEntranceSign

	def_object_events
	object_event 25, 5, SPRITE_BLUE, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, Route22RivalNoop, EVENT_ROUTE_22_RIVAL_HIDDEN
