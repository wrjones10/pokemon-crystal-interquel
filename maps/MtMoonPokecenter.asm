	object_const_def
	const MTMOONPOKECENTER_NURSE
	const MTMOONPOKECENTER_YOUNGSTER
	const MTMOONPOKECENTER_GENTLEMAN
	const MTMOONPOKECENTER_SALESMAN
	const MTMOONPOKECENTER_CLIPBOARD
	const MTMOONPOKECENTER_LINK_RECEPTIONIST
	const MTMOONPOKECENTER_CHANSEY

MtMoonPokecenter_MapScripts:
	def_scene_scripts
	def_callbacks

MtMoonPokecenterNurse:
	jumpstd PokecenterNurseScript

MtMoonPokecenterYoungster:
	jumptextfaceplayer MtMoonPokecenterYoungsterText

MtMoonPokecenterGentleman:
	jumptextfaceplayer MtMoonPokecenterGentlemanText

MtMoonPokecenterClipboard:
	jumptext MtMoonPokecenterClipboardText

MtMoonPokecenterLinkReceptionist:
	jumptextfaceplayer MtMoonPokecenterLinkReceptionistText

MtMoonPokecenterChansey:
	faceplayer
	opentext
	writetext MtMoonPokecenterChanseyText
	cry CHANSEY
	waitbutton
	closetext
	end

MtMoonPokecenterMagikarpSalesman:
	faceplayer
	opentext
	checkevent EVENT_BOUGHT_MT_MOON_MAGIKARP
	iftrue .AlreadyBought
	special PlaceMoneyTopRight
	writetext MtMoonPokecenterMagikarpSalesmanIGotADealText
	yesorno
	iffalse .Refuse
	checkmoney YOUR_MONEY, 500
	ifequal HAVE_LESS, .NoMoney
	givepoke MAGIKARP, 5, NO_ITEM
	ifequal 2, .NoRoom
	takemoney YOUR_MONEY, 500
	special PlaceMoneyTopRight
	setevent EVENT_BOUGHT_MT_MOON_MAGIKARP
	closetext
	end
.AlreadyBought:
	writetext MtMoonPokecenterMagikarpSalesmanNoRefundsText
	sjump .Close
.Refuse:
	writetext MtMoonPokecenterMagikarpSalesmanNoText
	sjump .Close
.NoMoney:
	writetext MtMoonPokecenterMagikarpSalesmanNoMoneyText
	sjump .Close
.NoRoom:
	writetext MtMoonPokecenterNoRoomText
.Close:
	waitbutton
	closetext
	end

MtMoonPokecenterLinkReceptionistText:
	text "The CABLE CLUB is"
	line "upstairs."
	done

MtMoonPokecenterChanseyText:
	text "CHANSEY: Chanse!"
	done

MtMoonPokecenterNoRoomText:
	text "You have no room"
	line "for this #MON!"

	para "Make some room"
	line "and come back."
	done

MtMoonPokecenterYoungsterText:
	text "I've 6 # BALLs"
	line "set in my belt."

	para "At most, you can"
	line "carry 6 #MON."
	done

MtMoonPokecenterGentlemanText:
	text "TEAM ROCKET"
	line "attacks CERULEAN"
	cont "citizens..."

	para "TEAM ROCKET is"
	line "always in the"
	cont "news!"
	done

MtMoonPokecenterClipboardText:
	text ""
	done

MtMoonPokecenterMagikarpSalesmanIGotADealText:
	text "MAN: Hello, there!"
	line "Have I got a deal"
	cont "just for you!"

	para "I'll let you have"
	line "a swell MAGIKARP"
	cont "for just ¥500!"
	cont "What do you say?"
	done

MtMoonPokecenterMagikarpSalesmanNoText:
	text "No? I'm only"
	line "doing this as a"
	cont "favor to you!"
	done

MtMoonPokecenterMagikarpSalesmanNoMoneyText:
	text "You'll need more"
	line "money than that!"
	done

MtMoonPokecenterMagikarpSalesmanNoRefundsText:
	text "MAN: Well, I don't"
	line "give refunds!"
	done

MtMoonPokecenter_MapEvents:
	db 0, 0
	def_warp_events
	warp_event 3, 7, ROUTE_4, 1
	warp_event 4, 7, ROUTE_4, 1
	warp_event 0, 7, POKECENTER_2F, 1
	def_coord_events
	def_bg_events
	def_object_events
	object_event 3, 1, SPRITE_NURSE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, MtMoonPokecenterNurse, -1
	object_event 2, 3, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, MtMoonPokecenterYoungster, -1
	object_event 6, 3, SPRITE_GENTLEMAN, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, MtMoonPokecenterGentleman, -1
	object_event 5, 6, SPRITE_POKEFAN_M, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, PAL_NPC_BROWN, OBJECTTYPE_SCRIPT, 0, MtMoonPokecenterMagikarpSalesman, -1
	object_event 7, 2, SPRITE_PAPER, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, MtMoonPokecenterClipboard, -1
	object_event 9, 3, SPRITE_LINK_RECEPTIONIST, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, MtMoonPokecenterLinkReceptionist, -1
	object_event 4, 1, SPRITE_CHANSEY, SPRITEMOVEDATA_POKEMON, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, MtMoonPokecenterChansey, -1
