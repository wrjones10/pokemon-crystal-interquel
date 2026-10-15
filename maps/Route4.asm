	object_const_def
	const ROUTE4_WANDERING_NPC
	const ROUTE4_YELLOW_LASS
	const ROUTE4_ROAR_TM

Route4_MapScripts:
	def_scene_scripts
	def_callbacks
	callback MAPCALLBACK_OBJECTS, Route4RefreshSprites

Route4RefreshSprites:
	callasm Route4CheckSpriteGroup
	iffalse .Done
	special RefreshSprites
.Done:
	endcallback

Route4CheckSpriteGroup:
	ld c, SPRITE_MISTY
	jp Route34NeedsSpriteRefresh

Route4WanderingNPC:
	jumptextfaceplayer Route4CooltrainerF1Text

Route4RoarTM:
	itemball TM_ROAR

Route4PokecenterSign:
	jumptext Route4PokecenterSignText
Route4MtMoonSign:
	jumptext Route4MtMoonSignText
Route4Sign:
	jumptext Route4SignText

Route4YellowLass:
	trainer LASS, YELLOW_ROUTE4_LASS, EVENT_BEAT_YELLOW_ROUTE_4_LASS, Route4CooltrainerF2BattleText, Route4CooltrainerF2EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext Route4CooltrainerF2AfterBattleText

Route4CooltrainerF1Text:
	text "Ouch! I tripped"
	line "over a rocky"
	cont "#MON, GEODUDE!"
	done

Route4CooltrainerF2BattleText:
	text "I came to get my"
	line "mushroom #MON!"
	done

Route4CooltrainerF2EndBattleText:
	text "Oh! My cute"
	line "mushroom #MON!"
	done

Route4CooltrainerF2AfterBattleText:
	text "There might not"
	line "be any more"
	cont "mushrooms here."

	para "I think I got"
	line "them all."
	done

Route4MtMoonSignText:
	text "MT.MOON"
	line "Tunnel Entrance"
	done

Route4SignText:
	text "ROUTE 4"
	line "MT.MOON -"
	cont "CERULEAN CITY"
	done

Route4PokecenterSignText:
	text "Heal Your #MON!"
	line "#MON CENTER"
	done

Route4_MapEvents:
	db 0, 0
	def_warp_events
	warp_event 11, 5, MT_MOON_POKECENTER, 1
	warp_event 18, 5, MOUNT_MOON, 1
	warp_event 24, 5, MOUNT_MOON, 2
	def_coord_events
	def_bg_events
	bg_event 12, 5, BGEVENT_READ, Route4PokecenterSign
	bg_event 17, 7, BGEVENT_READ, Route4MtMoonSign
	bg_event 27, 7, BGEVENT_READ, Route4Sign
	def_object_events
	object_event 9, 8, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, Route4WanderingNPC, -1
	object_event 63, 3, SPRITE_COOLTRAINER_F, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_TRAINER, 3, Route4YellowLass, -1
	object_event 57, 3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, Route4RoarTM, EVENT_ROUTE_4_ROAR_TM
