; Debug-build bedroom radio package, adapted from pret's Essential Debug Tools.
DebugPlayerRadioScript::
	opentext
	checkevent EVENT_DEBUG_RADIO_USED
	iftrue .AlreadyUsed
	readvar VAR_PARTYCOUNT
	ifgreater PARTY_LENGTH - 3, .PartyFull
	giveitem MAX_REPEL, 99
	iffalse .BagFull
	giveitem MASTER_BALL, 99
	iffalse .BagFull

	; Full Pokegear and Pokedex.
	setflag ENGINE_POKEGEAR
	setflag ENGINE_PHONE_CARD
	setflag ENGINE_MAP_CARD
	setflag ENGINE_RADIO_CARD
	setflag ENGINE_EXPN_CARD
	setflag ENGINE_POKEDEX

	; All badges and Gym Leader victories.
	setflag ENGINE_ZEPHYRBADGE
	setflag ENGINE_HIVEBADGE
	setflag ENGINE_PLAINBADGE
	setflag ENGINE_FOGBADGE
	setflag ENGINE_STORMBADGE
	setflag ENGINE_MINERALBADGE
	setflag ENGINE_GLACIERBADGE
	setflag ENGINE_RISINGBADGE
	setflag ENGINE_BOULDERBADGE
	setflag ENGINE_CASCADEBADGE
	setflag ENGINE_THUNDERBADGE
	setflag ENGINE_RAINBOWBADGE
	setflag ENGINE_MARSHBADGE
	setflag ENGINE_SOULBADGE
	setflag ENGINE_VOLCANOBADGE
	setflag ENGINE_EARTHBADGE
	setevent EVENT_BEAT_FALKNER
	setevent EVENT_BEAT_BUGSY
	setevent EVENT_BEAT_WHITNEY
	setevent EVENT_BEAT_MORTY
	setevent EVENT_BEAT_CHUCK
	setevent EVENT_BEAT_JASMINE
	setevent EVENT_BEAT_PRYCE
	setevent EVENT_BEAT_CLAIR
	setevent EVENT_BEAT_BROCK
	setevent EVENT_BEAT_MISTY
	setevent EVENT_BEAT_LTSURGE
	setevent EVENT_BEAT_ERIKA
	setevent EVENT_BEAT_JANINE
	setevent EVENT_BEAT_SABRINA
	setevent EVENT_BEAT_BLAINE
	setevent EVENT_BEAT_BLUE
	setevent EVENT_BEAT_ELITE_FOUR
	setflag ENGINE_CREDITS_SKIP

	; All normal Fly destinations.
	setflag ENGINE_FLYPOINT_NEW_BARK
	setflag ENGINE_FLYPOINT_CHERRYGROVE
	setflag ENGINE_FLYPOINT_VIOLET
	setflag ENGINE_FLYPOINT_AZALEA
	setflag ENGINE_FLYPOINT_GOLDENROD
	setflag ENGINE_FLYPOINT_ECRUTEAK
	setflag ENGINE_FLYPOINT_OLIVINE
	setflag ENGINE_FLYPOINT_CIANWOOD
	setflag ENGINE_FLYPOINT_MAHOGANY
	setflag ENGINE_FLYPOINT_LAKE_OF_RAGE
	setflag ENGINE_FLYPOINT_BLACKTHORN
	setflag ENGINE_FLYPOINT_SILVER_CAVE
	setflag ENGINE_FLYPOINT_INDIGO_PLATEAU
	setflag ENGINE_FLYPOINT_PALLET
	setflag ENGINE_FLYPOINT_VIRIDIAN
	setflag ENGINE_FLYPOINT_PEWTER
	setflag ENGINE_FLYPOINT_CERULEAN
	setflag ENGINE_FLYPOINT_VERMILION
	setflag ENGINE_FLYPOINT_CELADON
	setflag ENGINE_FLYPOINT_ROCK_TUNNEL
	setflag ENGINE_FLYPOINT_LAVENDER
	setflag ENGINE_FLYPOINT_FUCHSIA
	setflag ENGINE_FLYPOINT_SAFFRON
	setflag ENGINE_FLYPOINT_CINNABAR

	; Append the test party; never overwrite existing party slots.
	givepoke MEWTWO, 100, BRIGHTPOWDER
	givepoke MEW, 100, LEFTOVERS
	callasm DebugRadioSetFirstMewMoves
	givepoke MEW, 100, LEFTOVERS
	callasm DebugRadioSetSecondMewMoves
	special HealParty

	; Original guide's introductory event shortcuts.
	addcellnum PHONE_MOM
	setmapscene PLAYERS_HOUSE_1F, SCENE_PLAYERSHOUSE1F_NOOP
	setevent EVENT_PLAYERS_HOUSE_MOM_1
	clearevent EVENT_PLAYERS_HOUSE_MOM_2
	setmapscene VERMILION_CITY, $1

	; Complete the Pallet opening without replaying Oak's escort or rival battle.
	setevent EVENT_FOLLOWED_OAK_TO_LAB
	setevent EVENT_GOT_A_POKEMON_FROM_OAK
	setevent EVENT_BATTLED_RIVAL_IN_OAKS_LAB
	setevent EVENT_PALLET_TOWN_OAK
	setevent EVENT_OAKS_LAB_RIVAL
	clearevent EVENT_OAKS_LAB_OAK
	setevent EVENT_OAKS_LAB_CHARMANDER_BALL
	setevent EVENT_OAKS_LAB_SQUIRTLE_BALL
	setevent EVENT_OAKS_LAB_BULBASAUR_BALL
	setmapscene PALLET_TOWN, SCENE_PALLETTOWN_NOOP
	setmapscene OAKS_LAB, SCENE_OAKSLAB_NOOP
	setevent EVENT_DEBUG_RADIO_USED
	writetext DebugRadioReadyText
	waitbutton
	closetext
	end

.AlreadyUsed:
	writetext DebugRadioAlreadyUsedText
	sjump .Done
.PartyFull:
	writetext DebugRadioPartyFullText
	sjump .Done
.BagFull:
	writetext DebugRadioBagFullText
.Done:
	waitbutton
	closetext
	end

DebugRadioSetFirstMewMoves:
	ld hl, .Moves
	jr DebugRadioSetLastMonMoves
.Moves:
	db FLY, SURF, STRENGTH, CUT

DebugRadioSetSecondMewMoves:
	ld hl, .Moves
	jr DebugRadioSetLastMonMoves
.Moves:
	db FLASH, ROCK_SMASH, HEADBUTT, WATERFALL

DebugRadioSetLastMonMoves:
	push hl
	ld a, [wPartyCount]
	dec a
	ld [wCurPartyMon], a
	ld hl, wPartyMon1Moves
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	ld e, l
	ld d, h
	pop hl
	ld bc, NUM_MOVES
	call CopyBytes

	; Discard old moves' PP Up bits before HealParty fills the new moves' PP.
	ld a, [wCurPartyMon]
	ld hl, wPartyMon1PP
	ld bc, PARTYMON_STRUCT_LENGTH
	call AddNTimes
	xor a
	ld bc, NUM_MOVES
	jp ByteFill

DebugRadioReadyText:
	text "DEBUG setup ready!"
	para "Badges, FLY points"
	line "and test #MON"
	cont "have been added."
	done

DebugRadioAlreadyUsedText:
	text "DEBUG setup was"
	line "already applied."
	done

DebugRadioPartyFullText:
	text "Leave three empty"
	line "party slots for"
	cont "the DEBUG team."
	done

DebugRadioBagFullText:
	text "Make room for"
	line "MAX REPELS and"
	cont "MASTER BALLS."
	done
