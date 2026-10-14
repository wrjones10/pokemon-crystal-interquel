	object_const_def
	const PEWTERMUSEUM1F_TICKET_SCIENTIST
	const PEWTERMUSEUM1F_GENTLEMAN
	const PEWTERMUSEUM1F_AMBER_SCIENTIST
	const PEWTERMUSEUM1F_FOSSIL_SCIENTIST
	const PEWTERMUSEUM1F_OLD_AMBER

PewterMuseum1F_MapScripts:
	def_scene_scripts
	def_callbacks

PewterMuseum1FTicketGate:
	checkevent EVENT_BOUGHT_MUSEUM_TICKET
	iftrue .Done
	turnobject PEWTERMUSEUM1F_TICKET_SCIENTIST, LEFT
	opentext
	special PlaceMoneyTopRight
	writetext PewterMuseum1FScientist1WouldYouLikeToComeInText
	yesorno
	iffalse .Refuse
	checkmoney YOUR_MONEY, 50
	ifequal HAVE_LESS, .NoMoney
	takemoney YOUR_MONEY, 50
	special PlaceMoneyTopRight
	setevent EVENT_BOUGHT_MUSEUM_TICKET
	playsound SFX_TRANSACTION
	writetext PewterMuseum1FScientist1ThankYouText
	waitbutton
	closetext
	end
.NoMoney:
	writetext PewterMuseum1FScientist1DontHaveEnoughMoneyText
	waitbutton
.Refuse:
	writetext PewterMuseum1FScientist1ComeAgainText
	waitbutton
	closetext
	applymovement PLAYER, PewterMuseum1FStepBack
.Done:
	end

PewterMuseum1FStepBack:
	step DOWN
	step_end

PewterMuseum1FTicketScientist:
	faceplayer
	opentext
	readvar VAR_XCOORD
	ifequal 13, .Amber
	readvar VAR_YCOORD
	ifequal 3, .Amber
	checkevent EVENT_BOUGHT_MUSEUM_TICKET
	iftrue .Paid
	writetext PewterMuseum1FScientist1GoToOtherSideText
	waitbutton
	closetext
	end
.Paid:
	writetext PewterMuseum1FScientist1TakePlentyOfTimeText
	waitbutton
	closetext
	end
.Amber:
	writetext PewterMuseum1FScientist1DoYouKnowWhatAmberIsText
	yesorno
	iffalse .Explain
	writetext PewterMuseum1FScientist1TheresALabSomewhereText
	sjump .Close
.Explain:
	writetext PewterMuseum1FScientist1AmberIsFossilizedTreeSapText
.Close:
	waitbutton
	closetext
	end

PewterMuseum1FAmberScientist:
	faceplayer
	opentext
	checkevent EVENT_GOT_OLD_AMBER
	iftrue .Received
	writetext PewterMuseum1FScientist2TakeThisToAPokemonLabText
	promptbutton
	verbosegiveitem OLD_AMBER
	iffalse .NoSpace
	setevent EVENT_GOT_OLD_AMBER
	disappear PEWTERMUSEUM1F_OLD_AMBER
.Received:
	writetext PewterMuseum1FScientist2GetTheOldAmberCheckText
	waitbutton
	closetext
	end
.NoSpace:
	writetext PewterMuseum1FScientist2YouDontHaveSpaceText
	waitbutton
	closetext
	end

PewterMuseum1FGentleman:
	jumptextfaceplayer PewterMuseum1FGamblerText

PewterMuseum1FFossilScientist:
	jumptextfaceplayer PewterMuseum1FScientist3Text

PewterMuseum1FOldAmber:
	jumptext PewterMuseum1FOldAmberText

PewterMuseum1FAerodactylFossil:
	opentext
	setval 0
	callasm PewterMuseum1FShowFossilPicture
	waitbutton
	closepokepic
	writetext PewterMuseum1FAerodactylFossilText
	waitbutton
	closetext
	end

PewterMuseum1FKabutopsFossil:
	opentext
	setval 1
	callasm PewterMuseum1FShowFossilPicture
	waitbutton
	closepokepic
	writetext PewterMuseum1FKabutopsFossilText
	waitbutton
	closetext
	end

; Use the native Pokepic box/close routine, loading Yellow's fossil art rather
; than a living Pokemon. These uncompressed pictures use row-major tile order.
PewterMuseum1FShowFossilPicture:
	ld a, [wScriptVar]
	push af
	ld hl, .MenuHeader
	call CopyMenuHeader
	call MenuBox
	call UpdateSprites
	call ApplyTilemap
	ld hl, .FossilPalette
	ld de, wBGPals1 palette PAL_BG_TEXT color 1
	ld bc, PAL_COLOR_SIZE * 2
	ld a, BANK(wBGPals1)
	call FarCopyWRAM
	call UpdateTimePals
	xor a
	ldh [hBGMapMode], a
	pop af
	and a
	jr nz, .Kabutops
	ld de, MuseumAerodactylFossilGFX
	ld b, BANK(MuseumAerodactylFossilGFX)
	ld c, 49
	ld a, 7
	jr .Load
.Kabutops:
	ld de, MuseumKabutopsFossilGFX
	ld b, BANK(MuseumKabutopsFossilGFX)
	ld c, 36
	ld a, 6
.Load:
	push af
	ld hl, vTiles1
	call Get2bpp
	pop af
	ld b, a
	ld c, a
	hlcoord 7, 5
	cp 7
	jr z, .Place
	hlcoord 8, 6 ; align the smaller Kabutops picture within the same 7x7 box
.Place:
	ld a, $80
.Row:
	push bc
	push hl
.Column:
	ld [hli], a
	inc a
	dec c
	jr nz, .Column
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
	pop bc
	dec b
	jr nz, .Row
	call WaitBGMap
	ret
.MenuHeader:
	db MENU_BACKUP_TILES
	menu_coords 6, 4, 14, 13
	dw NULL
	db 1
.FossilPalette:
	RGB 21, 21, 21, 10, 10, 10

PewterMuseum1FAerodactylFossilText:
	text "AERODACTYL Fossil"
	line "A primitive and"
	cont "rare #MON."
	done

PewterMuseum1FKabutopsFossilText:
	text "KABUTOPS Fossil"
	line "A primitive and"
	cont "rare #MON."
	done

PewterMuseum1FScientist1ComeAgainText:
	text "Come again!"
	done

PewterMuseum1FScientist1WouldYouLikeToComeInText:
	text "It's ¥50 for a"
	line "child's ticket."

	para "Would you like to"
	line "come in?"
	done

PewterMuseum1FScientist1ThankYouText:
	text "Right, ¥50!"
	line "Thank you!"
	done

PewterMuseum1FScientist1DontHaveEnoughMoneyText:
	text "You don't have"
	line "enough money."
	done

PewterMuseum1FScientist1DoYouKnowWhatAmberIsText:
	text "You can't sneak"
	line "in the back way!"

	para "Oh, whatever!"
	line "Do you know what"
	cont "AMBER is?"
	done

PewterMuseum1FScientist1TheresALabSomewhereText:
	text "There's a lab"
	line "somewhere trying"
	cont "to resurrect"
	cont "ancient #MON"
	cont "from AMBER."
	done

PewterMuseum1FScientist1AmberIsFossilizedTreeSapText:
	text "AMBER is fossil-"
	line "ized tree sap."
	done

PewterMuseum1FScientist1GoToOtherSideText:
	text "Please go to the"
	line "other side!"
	done

PewterMuseum1FScientist1TakePlentyOfTimeText:
	text "Take plenty of"
	line "time to look!"
	done

PewterMuseum1FGamblerText:
	text "That is one"
	line "magnificent"
	cont "fossil!"
	done

PewterMuseum1FScientist2TakeThisToAPokemonLabText:
	text "Ssh! I think that"
	line "this chunk of"
	cont "AMBER contains"
	cont "#MON DNA!"

	para "It would be great"
	line "if #MON could"
	cont "be resurrected"
	cont "from it!"

	para "But, my colleagues"
	line "just ignore me!"

	para "So, I have a favor"
	line "to ask!"

	para "Take this to a"
	line "#MON LAB and"
	cont "get it examined!"
	done

PewterMuseum1FScientist2GetTheOldAmberCheckText:
	text "Ssh! Get the OLD"
	line "AMBER checked!"
	done

PewterMuseum1FScientist2YouDontHaveSpaceText:
	text "You don't have"
	line "space for this!"
	done

PewterMuseum1FScientist3Text:
	text "We are proud of 2"
	line "fossils of very"
	cont "rare, prehistoric"
	cont "#MON!"
	done

PewterMuseum1FOldAmberText:
	text "The AMBER is"
	line "clear and gold!"
	done

PewterMuseum1F_MapEvents:
	db 0, 0
	def_warp_events
	warp_event 10, 7, PEWTER_CITY, 6
	warp_event 11, 7, PEWTER_CITY, 6
	warp_event 16, 7, PEWTER_CITY, 7
	warp_event 17, 7, PEWTER_CITY, 7
	warp_event 7, 7, PEWTER_MUSEUM_2F, 1
	def_coord_events
	coord_event 9, 4, -1, PewterMuseum1FTicketGate
	coord_event 10, 4, -1, PewterMuseum1FTicketGate
	def_bg_events
	bg_event 2, 3, BGEVENT_READ, PewterMuseum1FAerodactylFossil
	bg_event 2, 6, BGEVENT_READ, PewterMuseum1FKabutopsFossil
	def_object_events
	object_event 12, 4, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterMuseum1FTicketScientist, -1
	object_event 1, 4, SPRITE_GENTLEMAN, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterMuseum1FGentleman, -1
	object_event 15, 2, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterMuseum1FAmberScientist, -1
	object_event 17, 4, SPRITE_SCIENTIST, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterMuseum1FFossilScientist, -1
	object_event 16, 2, SPRITE_OLD_AMBER, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PewterMuseum1FOldAmber, EVENT_GOT_OLD_AMBER
