	object_const_def
	const ROUTE3_RESTING_NPC
	const ROUTE3_YELLOW_TRAINER_1
	const ROUTE3_YELLOW_TRAINER_2
	const ROUTE3_YELLOW_TRAINER_3
	const ROUTE3_YELLOW_TRAINER_4
	const ROUTE3_YELLOW_TRAINER_5
	const ROUTE3_YELLOW_TRAINER_6
	const ROUTE3_YELLOW_TRAINER_7
	const ROUTE3_YELLOW_TRAINER_8

Route3_MapScripts:
	def_scene_scripts
	def_callbacks
	callback MAPCALLBACK_OBJECTS, Route3RefreshSprites

Route3RefreshSprites:
	callasm Route3CheckSpriteGroup
	iffalse .Done
	special RefreshSprites
.Done:
	endcallback

Route3CheckSpriteGroup:
	ld c, SPRITE_FRUIT_TREE
	jp Route34NeedsSpriteRefresh

Route34NeedsSpriteRefresh:
; Warps/loads already refresh graphics. Connections retain the previous list.
	ldh a, [hMapEntryMethod]
	cp MAPSETUP_CONNECTION
	jr nz, .Ready
	ld hl, wUsedSprites
	ld b, SPRITE_GFX_LIST_CAPACITY
.FindGroupSprite:
	ld a, [hli]
	cp c
	jr z, .Ready
	inc hl
	dec b
	jr nz, .FindGroupSprite
	ld a, TRUE
	ld [wScriptVar], a
	ret
.Ready:
	xor a
	ld [wScriptVar], a
	ret

Route3RestingNPC:
	jumptextfaceplayer Route3Text1

Route3Sign:
	jumptext Route3SignText

Route3YellowTrainer1:
	trainer BUG_CATCHER, YELLOW_ROUTE3_BUG_CATCHER_1, EVENT_BEAT_YELLOW_ROUTE_3_TRAINER_1, Route3Youngster1BattleText, Route3Youngster1EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext Route3Youngster1AfterBattleText

Route3YellowTrainer2:
	trainer YOUNGSTER, YELLOW_ROUTE3_YOUNGSTER_1, EVENT_BEAT_YELLOW_ROUTE_3_TRAINER_2, Route3Youngster2BattleText, Route3Youngster2EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext Route3Youngster2AfterBattleText

Route3YellowTrainer3:
	trainer LASS, YELLOW_ROUTE3_LASS_1, EVENT_BEAT_YELLOW_ROUTE_3_TRAINER_3, Route3CooltrainerF1BattleText, Route3CooltrainerF1EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext Route3CooltrainerF1AfterBattleText

Route3YellowTrainer4:
	trainer BUG_CATCHER, YELLOW_ROUTE3_BUG_CATCHER_2, EVENT_BEAT_YELLOW_ROUTE_3_TRAINER_4, Route3Youngster3BattleText, Route3Youngster3EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext Route3Youngster3AfterBattleText

Route3YellowTrainer5:
	trainer LASS, YELLOW_ROUTE3_LASS_2, EVENT_BEAT_YELLOW_ROUTE_3_TRAINER_5, Route3CooltrainerF2BattleText, Route3CooltrainerF2EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext Route3CooltrainerF2AfterBattleText

Route3YellowTrainer6:
	trainer YOUNGSTER, YELLOW_ROUTE3_YOUNGSTER_2, EVENT_BEAT_YELLOW_ROUTE_3_TRAINER_6, Route3Youngster4BattleText, Route3Youngster4EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext Route3Youngster4AfterBattleText

Route3YellowTrainer7:
	trainer BUG_CATCHER, YELLOW_ROUTE3_BUG_CATCHER_3, EVENT_BEAT_YELLOW_ROUTE_3_TRAINER_7, Route3Youngster5BattleText, Route3Youngster5EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext Route3Youngster5AfterBattleText

Route3YellowTrainer8:
	trainer LASS, YELLOW_ROUTE3_LASS_3, EVENT_BEAT_YELLOW_ROUTE_3_TRAINER_8, Route3CooltrainerF3BattleText, Route3CooltrainerF3EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext Route3CooltrainerF3AfterBattleText

Route3Text1:
	text "Whew... I better"
	line "take a rest..."
	cont "Groan..."

	para "That tunnel from"
	line "CERULEAN takes a"
	cont "lot out of you!"
	done

Route3Youngster1BattleText:
	text "Hey! I met you in"
	line "VIRIDIAN FOREST!"
	done

Route3Youngster1EndBattleText:
	text "You"
	line "beat me again!"
	done

Route3Youngster1AfterBattleText:
	text "There are other"
	line "kinds of #MON"
	cont "than those found"
	cont "in the forest!"
	done

Route3Youngster2BattleText:
	text "Hi! I like shorts!"
	line "They're comfy and"
	cont "easy to wear!"
	done

Route3Youngster2EndBattleText:
	text "I don't"
	line "believe it!"
	done

Route3Youngster2AfterBattleText:
	text "Are you storing"
	line "your #MON on"
	cont "PC? Each BOX can"
	cont "hold 20 #MON!"
	done

Route3CooltrainerF1BattleText:
	text "You looked at me,"
	line "didn't you?"
	done

Route3CooltrainerF1EndBattleText:
	text "You're"
	line "mean!"
	done

Route3CooltrainerF1AfterBattleText:
	text "Quit staring if"
	line "you don't want to"
	cont "fight!"
	done

Route3Youngster3BattleText:
	text "Are you a trainer?"
	line "Let's fight!"
	done

Route3Youngster3EndBattleText:
	text "If I"
	line "had new #MON,"
	cont "I would've won!"
	done

Route3Youngster3AfterBattleText:
	text "If a #MON BOX"
	line "on the PC gets"
	cont "full, just switch"
	cont "to another BOX!"
	done

Route3CooltrainerF2BattleText:
	text "That look you"
	line "gave me, it's so"
	cont "intriguing!"
	done

Route3CooltrainerF2EndBattleText:
	text "Be nice!"
	done

Route3CooltrainerF2AfterBattleText:
	text "Avoid fights by"
	line "not letting"
	cont "people see you!"
	done

Route3Youngster4BattleText:
	text "Hey! You're not"
	line "wearing shorts!"
	done

Route3Youngster4EndBattleText:
	text "Lost!"
	line "Lost! Lost!"
	done

Route3Youngster4AfterBattleText:
	text "I always wear"
	line "shorts, even in"
	cont "winter!"
	done

Route3Youngster5BattleText:
	text "You can fight my"
	line "new #MON!"
	done

Route3Youngster5EndBattleText:
	text "Done"
	line "like dinner!"
	done

Route3Youngster5AfterBattleText:
	text "Trained #MON"
	line "are stronger than"
	cont "the wild ones!"
	done

Route3CooltrainerF3BattleText:
	text "Eek! Did you"
	line "touch me?"
	done

Route3CooltrainerF3EndBattleText:
	text "That's it?"
	done

Route3CooltrainerF3AfterBattleText:
	text "ROUTE 4 is at the"
	line "foot of MT.MOON."
	done

Route3SignText:
	text "ROUTE 3"
	line "MT.MOON AHEAD"
	done

Route3_MapEvents:
	db 0, 0
	def_warp_events
	def_coord_events
	def_bg_events
	bg_event 59, 9, BGEVENT_READ, Route3Sign
	def_object_events
	object_event 57, 11, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, Route3RestingNPC, -1
	object_event 10, 6, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 2, Route3YellowTrainer1, -1
	object_event 14, 4, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, Route3YellowTrainer2, -1
	object_event 16, 9, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 2, Route3YellowTrainer3, -1
	object_event 19, 5, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 1, Route3YellowTrainer4, -1
	object_event 23, 4, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 4, Route3YellowTrainer5, -1
	object_event 22, 9, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, Route3YellowTrainer6, -1
	object_event 24, 6, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, Route3YellowTrainer7, -1
	object_event 33, 10, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 2, Route3YellowTrainer8, -1
