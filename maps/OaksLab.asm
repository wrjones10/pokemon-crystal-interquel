	object_const_def
	const OAKSLAB_OAK
	const OAKSLAB_SCIENTIST1
	const OAKSLAB_SCIENTIST2
	const OAKSLAB_SCIENTIST3
	const OAKSLAB_CHARMANDER_BALL
	const OAKSLAB_SQUIRTLE_BALL
	const OAKSLAB_BULBASAUR_BALL
	const OAKSLAB_RIVAL

OaksLab_MapScripts:
	def_scene_scripts
	scene_script OaksLabOpeningScene, SCENE_OAKSLAB_WAITING_FOR_OAK
	scene_script OaksLabNoopScene, SCENE_OAKSLAB_CHOOSE_STARTER
	scene_script OaksLabNoopScene, SCENE_OAKSLAB_RIVAL_BATTLE
	scene_script OaksLabNoopScene, SCENE_OAKSLAB_NOOP

	def_callbacks
	callback MAPCALLBACK_OBJECTS, OaksLabOpeningCallback

OaksLabOpeningCallback:
	checkevent EVENT_FOLLOWED_OAK_TO_LAB
	iftrue .OakHere
	checkevent EVENT_BEAT_ELITE_FOUR
	iftrue .OakHere
	; LoadObjectMasks runs after this callback, so control visibility with flags.
	setevent EVENT_OAKS_LAB_OAK
	setevent EVENT_OAKS_LAB_RIVAL
	endcallback
.OakHere:
	clearevent EVENT_OAKS_LAB_OAK
	checkevent EVENT_FOLLOWED_OAK_TO_LAB
	iffalse .HideRival
	checkevent EVENT_BATTLED_RIVAL_IN_OAKS_LAB
	iftrue .HideRival
	clearevent EVENT_OAKS_LAB_RIVAL
	endcallback
.HideRival:
	setevent EVENT_OAKS_LAB_RIVAL
	endcallback

OaksLabOpeningScene:
	checkevent EVENT_FOLLOWED_OAK_TO_LAB
	iffalse .Done
	sdefer OaksLabIntroduceStarters
.Done:
	end

OaksLabNoopScene:
	end

OaksLabIntroduceStarters:
	applymovement PLAYER, OaksLabPlayerApproachesOak
	turnobject OAKSLAB_RIVAL, UP
	opentext
	writetext OaksLabRivalWaitingText
	promptbutton
	writetext OaksLabChooseStarterText
	waitbutton
	closetext
	setscene SCENE_OAKSLAB_CHOOSE_STARTER
	end

OaksLabPlayerApproachesOak:
	rept 6
	step UP
	endr
	step_end

OaksLabDontLeave:
	opentext
	writetext OaksLabDontLeaveText
	waitbutton
	closetext
	applymovement PLAYER, OaksLabStepBack
	end

OaksLabStepBack:
	step UP
	step_end

OaksLabRivalScript:
	faceplayer
	opentext
	checkevent EVENT_FOLLOWED_OAK_TO_LAB
	iftrue .Choose
	writetext OaksLabRivalOakAbsentText
	sjump .Done
.Choose:
	writetext OaksLabRivalChooseText
.Done:
	waitbutton
	closetext
	end

OaksLabCharmanderBallScript:
	checkevent EVENT_GOT_A_POKEMON_FROM_OAK
	iftrue OaksLabLastBallScript
	checkevent EVENT_FOLLOWED_OAK_TO_LAB
	iffalse OaksLabBeforeOakScript
	reanchormap
	pokepic CHARMANDER
	cry CHARMANDER
	waitbutton
	closepokepic
	opentext
	writetext OaksLabTakeCharmanderText
	yesorno
	iffalse OaksLabDeclineStarter
	readvar VAR_PARTYCOUNT
	ifequal PARTY_LENGTH, OaksLabPartyFullScript
	getmonname STRING_BUFFER_3, CHARMANDER
	writetext OaksLabReceivedStarterText
	playsound SFX_CAUGHT_MON
	waitsfx
	promptbutton
	givepoke CHARMANDER, 5, NO_ITEM
	disappear OAKSLAB_CHARMANDER_BALL
	setevent EVENT_GOT_CHARMANDER_FROM_OAK
	sjump OaksLabFinishChoosing

OaksLabSquirtleBallScript:
	checkevent EVENT_GOT_A_POKEMON_FROM_OAK
	iftrue OaksLabLastBallScript
	checkevent EVENT_FOLLOWED_OAK_TO_LAB
	iffalse OaksLabBeforeOakScript
	reanchormap
	pokepic SQUIRTLE
	cry SQUIRTLE
	waitbutton
	closepokepic
	opentext
	writetext OaksLabTakeSquirtleText
	yesorno
	iffalse OaksLabDeclineStarter
	readvar VAR_PARTYCOUNT
	ifequal PARTY_LENGTH, OaksLabPartyFullScript
	getmonname STRING_BUFFER_3, SQUIRTLE
	writetext OaksLabReceivedStarterText
	playsound SFX_CAUGHT_MON
	waitsfx
	promptbutton
	givepoke SQUIRTLE, 5, NO_ITEM
	disappear OAKSLAB_SQUIRTLE_BALL
	setevent EVENT_GOT_SQUIRTLE_FROM_OAK
	sjump OaksLabFinishChoosing

OaksLabBulbasaurBallScript:
	checkevent EVENT_GOT_A_POKEMON_FROM_OAK
	iftrue OaksLabLastBallScript
	checkevent EVENT_FOLLOWED_OAK_TO_LAB
	iffalse OaksLabBeforeOakScript
	reanchormap
	pokepic BULBASAUR
	cry BULBASAUR
	waitbutton
	closepokepic
	opentext
	writetext OaksLabTakeBulbasaurText
	yesorno
	iffalse OaksLabDeclineStarter
	readvar VAR_PARTYCOUNT
	ifequal PARTY_LENGTH, OaksLabPartyFullScript
	getmonname STRING_BUFFER_3, BULBASAUR
	writetext OaksLabReceivedStarterText
	playsound SFX_CAUGHT_MON
	waitsfx
	promptbutton
	givepoke BULBASAUR, 5, NO_ITEM
	disappear OAKSLAB_BULBASAUR_BALL
	setevent EVENT_GOT_BULBASAUR_FROM_OAK
	sjump OaksLabFinishChoosing

OaksLabFinishChoosing:
	setevent EVENT_GOT_A_POKEMON_FROM_OAK
	closetext
	checkevent EVENT_GOT_BULBASAUR_FROM_OAK
	iftrue .Charmander
	checkevent EVENT_GOT_CHARMANDER_FROM_OAK
	iftrue .Squirtle
	applymovement OAKSLAB_RIVAL, OaksLabRivalToBulbasaur
	turnobject OAKSLAB_RIVAL, UP
	disappear OAKSLAB_BULBASAUR_BALL
	getmonname STRING_BUFFER_3, BULBASAUR
	scall OaksLabRivalReceivesStarter
	applymovement OAKSLAB_RIVAL, OaksLabRivalFromBulbasaur
	sjump .Done
.Charmander:
	applymovement OAKSLAB_RIVAL, OaksLabRivalToCharmander
	turnobject OAKSLAB_RIVAL, UP
	disappear OAKSLAB_CHARMANDER_BALL
	getmonname STRING_BUFFER_3, CHARMANDER
	scall OaksLabRivalReceivesStarter
	applymovement OAKSLAB_RIVAL, OaksLabRivalFromCharmander
	sjump .Done
.Squirtle:
	applymovement OAKSLAB_RIVAL, OaksLabRivalToSquirtle
	turnobject OAKSLAB_RIVAL, UP
	disappear OAKSLAB_SQUIRTLE_BALL
	getmonname STRING_BUFFER_3, SQUIRTLE
	scall OaksLabRivalReceivesStarter
	applymovement OAKSLAB_RIVAL, OaksLabRivalFromSquirtle
	sjump .Done
.Done:
	scall OaksLabPlayerWalksToOak
	scall OaksLabGivePokedex
	setscene SCENE_OAKSLAB_RIVAL_BATTLE
	end

OaksLabRivalReceivesStarter:
	opentext
	writetext OaksLabRivalTakesStarterText
	promptbutton
	writetext OaksLabRivalReceivedStarterText
	playsound SFX_CAUGHT_MON
	waitsfx
	waitbutton
	closetext
	end

OaksLabPlayerWalksToOak:
	readvar VAR_YCOORD
	ifequal 2, .AboveTable
	ifequal 4, .BelowTable
	; The left-side selection tile is already directly in front of Oak.
	readvar VAR_XCOORD
	ifequal 5, .Done
	applymovement PLAYER, OaksLabPlayerDownOne
	sjump .BelowTable
.AboveTable:
	; Oak briefly steps back to clear the passage beside the table.
	applymovement OAKSLAB_OAK, OaksLabOakStepsBack
	readvar VAR_XCOORD
	ifequal 6, .AboveColumn6
	ifequal 7, .AboveColumn7
	applymovement PLAYER, OaksLabPlayerAboveColumn8ToOak
	sjump .OakReturns
.AboveColumn6:
	applymovement PLAYER, OaksLabPlayerAboveColumn6ToOak
	sjump .OakReturns
.AboveColumn7:
	applymovement PLAYER, OaksLabPlayerAboveColumn7ToOak
	sjump .OakReturns
.OakReturns:
	applymovement OAKSLAB_OAK, OaksLabPlayerDownOne
	sjump .Done
.BelowTable:
	readvar VAR_XCOORD
	ifequal 6, .FromColumn6
	ifequal 7, .FromColumn7
	ifequal 8, .FromColumn8
	applymovement PLAYER, OaksLabPlayerFromColumn9ToOak
	sjump .Done
.FromColumn6:
	applymovement PLAYER, OaksLabPlayerFromColumn6ToOak
	sjump .Done
.FromColumn7:
	applymovement PLAYER, OaksLabPlayerFromColumn7ToOak
	sjump .Done
.FromColumn8:
	applymovement PLAYER, OaksLabPlayerFromColumn8ToOak
.Done:
	turnobject PLAYER, UP
	end

OaksLabGivePokedex:
	checkflag ENGINE_POKEDEX
	iftrue .Done
	turnobject OAKSLAB_OAK, DOWN
	turnobject OAKSLAB_RIVAL, UP
	opentext
	writetext OaksLabPokedexRequestText
	promptbutton
	writetext OaksLabPokedexExplanationText
	promptbutton
	writetext OaksLabReceivedPokedexText
	playsound SFX_ITEM
	waitsfx
	setflag ENGINE_POKEDEX
	promptbutton
	writetext OaksLabPokedexDreamText
	waitbutton
	closetext
.Done:
	end

OaksLabDeclineStarter:
	writetext OaksLabTakeYourTimeText
	waitbutton
	closetext
	end

OaksLabPartyFullScript:
	writetext OaksLabPartyFullText
	waitbutton
	closetext
	end

OaksLabLastBallScript:
	jumptext OaksLabLastBallText

OaksLabBeforeOakScript:
	jumptext OaksLabBeforeOakText

OaksLabRivalBattleLeft:
	applymovement OAKSLAB_RIVAL, OaksLabRivalApproachesLeft
	sjump OaksLabRivalBattle

OaksLabRivalBattleRight:
	applymovement OAKSLAB_RIVAL, OaksLabRivalApproachesRight
OaksLabRivalBattle:
	turnobject OAKSLAB_RIVAL, DOWN
	turnobject PLAYER, UP
	playmusic MUSIC_RIVAL_ENCOUNTER
	opentext
	writetext OaksLabRivalChallengeText
	waitbutton
	closetext
	checkevent EVENT_GOT_BULBASAUR_FROM_OAK
	iftrue .Charmander
	checkevent EVENT_GOT_CHARMANDER_FROM_OAK
	iftrue .Squirtle
	loadtrainer PALLET_RIVAL, PALLET_RIVAL_BULBASAUR
	sjump .Battle
.Charmander:
	loadtrainer PALLET_RIVAL, PALLET_RIVAL_CHARMANDER
	sjump .Battle
.Squirtle:
	loadtrainer PALLET_RIVAL, PALLET_RIVAL_SQUIRTLE
.Battle:
	winlosstext OaksLabRivalWinText, OaksLabRivalLossText
	setlasttalked OAKSLAB_RIVAL
	loadvar VAR_BATTLETYPE, BATTLETYPE_CANLOSE
	startbattle
	reloadmap
	; Both outcomes finish the opening; losing never sends the player away.
	setscene SCENE_OAKSLAB_NOOP
	setevent EVENT_BATTLED_RIVAL_IN_OAKS_LAB
	special HealParty
	opentext
	writetext OaksLabRivalLeavingText
	waitbutton
	closetext
	readvar VAR_XCOORD
	ifequal 4, .LeaveRight
	applymovement OAKSLAB_RIVAL, OaksLabRivalLeavesLeft
	sjump .Gone
.LeaveRight:
	applymovement OAKSLAB_RIVAL, OaksLabRivalLeavesRight
.Gone:
	disappear OAKSLAB_RIVAL
	special RestartMapMusic
	end

OaksLabOakStepsBack:
	step UP
	step_end

OaksLabPlayerDownOne:
	step DOWN
	step_end

OaksLabPlayerFromColumn6ToOak:
	step LEFT
	step UP
	step_end

OaksLabPlayerFromColumn7ToOak:
	step LEFT
	step LEFT
	step UP
	step_end

OaksLabPlayerFromColumn8ToOak:
	step LEFT
	step LEFT
	step LEFT
	step UP
	step_end

OaksLabPlayerFromColumn9ToOak:
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step UP
	step_end

OaksLabPlayerAboveColumn6ToOak:
	step LEFT
	step DOWN
	step_end

OaksLabPlayerAboveColumn7ToOak:
	step LEFT
	step LEFT
	step DOWN
	step_end

OaksLabPlayerAboveColumn8ToOak:
	step LEFT
	step LEFT
	step LEFT
	step DOWN
	step_end

OaksLabRivalToCharmander:
	; Pass below the player rather than through the starter-selection tile.
	step DOWN
	step DOWN
	step RIGHT
	step RIGHT
	step UP
	step_end

OaksLabRivalFromCharmander:
	step DOWN
	step LEFT
	step LEFT
	step UP
	step UP
	step_end

OaksLabRivalToSquirtle:
	; Pass below the player rather than through the starter-selection tile.
	step DOWN
	step DOWN
	step RIGHT
	step RIGHT
	step RIGHT
	step UP
	step_end

OaksLabRivalFromSquirtle:
	step DOWN
	step LEFT
	step LEFT
	step LEFT
	step UP
	step UP
	step_end

OaksLabRivalToBulbasaur:
	; Pass below the player rather than through the starter-selection tile.
	step DOWN
	step DOWN
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step UP
	step_end

OaksLabRivalFromBulbasaur:
	step DOWN
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step UP
	step UP
	step_end

OaksLabRivalApproachesLeft:
	rept 4
	step DOWN
	endr
	step_end

OaksLabRivalApproachesRight:
	rept 4
	step DOWN
	endr
	step RIGHT
	step_end

OaksLabRivalLeavesLeft:
	step LEFT
	rept 4
	step DOWN
	endr
	step_end

OaksLabRivalLeavesRight:
	step RIGHT
	rept 4
	step DOWN
	endr
	step_end

Oak:
	faceplayer
	opentext
	checkevent EVENT_BEAT_ELITE_FOUR
	iftrue .KantoVisit
	checkevent EVENT_GOT_A_POKEMON_FROM_OAK
	iftrue .StarterAdvice
	writetext OaksLabChooseStarterText
	sjump .OpeningDone
.StarterAdvice:
	writetext OaksLabStarterAdviceText
.OpeningDone:
	waitbutton
	closetext
	end
.KantoVisit:
	checkevent EVENT_OPENED_MT_SILVER
	iftrue .CheckPokedex
	checkevent EVENT_TALKED_TO_OAK_IN_KANTO
	iftrue .CheckBadges
	writetext OakWelcomeKantoText
	promptbutton
	setevent EVENT_TALKED_TO_OAK_IN_KANTO
.CheckBadges:
	readvar VAR_BADGES
	ifequal NUM_BADGES, .OpenMtSilver
	ifequal NUM_JOHTO_BADGES, .Complain
	sjump .AhGood

.CheckPokedex:
	writetext OakLabDexCheckText
	waitbutton
	special ProfOaksPCBoot
	writetext OakLabGoodbyeText
	waitbutton
	closetext
	end

.OpenMtSilver:
	writetext OakOpenMtSilverText
	promptbutton
	setevent EVENT_OPENED_MT_SILVER
	sjump .CheckPokedex

.Complain:
	writetext OakNoKantoBadgesText
	promptbutton
	sjump .CheckPokedex

.AhGood:
	writetext OakYesKantoBadgesText
	promptbutton
	sjump .CheckPokedex

OaksAssistant1Script:
	jumptextfaceplayer OaksAssistant1Text

OaksAssistant2Script:
	jumptextfaceplayer OaksAssistant2Text

OaksAssistant3Script:
	jumptextfaceplayer OaksAssistant3Text

OaksLabBookshelf:
	jumpstd DifficultBookshelfScript

OaksLabPoster1:
	jumptext OaksLabPoster1Text

OaksLabPoster2:
	jumptext OaksLabPoster2Text

OaksLabTrashcan:
	jumptext OaksLabTrashcanText

OaksLabPC:
	jumptext OaksLabPCText

OaksLabRivalWaitingText:
	text "RIVAL: Hey, OAK!"
	line "I was waiting!"
	done

OaksLabChooseStarterText:
	text "OAK: These three"
	line "young #MON."

	para "Choose one to"
	line "be your partner,"
	cont "<PLAYER>!"
	done

OaksLabDontLeaveText:
	text "OAK: Wait! Choose"
	line "a #MON first!"
	done

OaksLabRivalOakAbsentText:
	text "RIVAL: OAK isn't"
	line "here right now."
	done

OaksLabRivalChooseText:
	text "RIVAL: Go ahead"
	line "and choose first!"
	done

OaksLabReceivedStarterText:
	text "<PLAYER> received"
	line "@"
	text_ram wStringBuffer3
	text "!"
	done

OaksLabRivalTakesStarterText:
	text "RIVAL: Then this"
	line "one is mine!"

	para "My #MON looks"
	line "stronger than"
	cont "yours!"
	done

OaksLabRivalReceivedStarterText:
	text "RIVAL received"
	line "@"
	text_ram wStringBuffer3
	text "!"
	done

OaksLabTakeYourTimeText:
	text "OAK: Take your"
	line "time choosing."
	done

OaksLabPartyFullText:
	text "Your party is full"
	line "Make room first!"
	done

OaksLabLastBallText:
	text "That's PROF.OAK's"
	line "last #MON!"
	done

OaksLabBeforeOakText:
	text "These # BALLS"
	line "contain #MON."

	para "Ask OAK before"
	line "taking one!"
	done

OaksLabRivalChallengeText:
	text "RIVAL: Wait,"
	line "<PLAYER>!"

	para "Come on! Let us"
	line "try out our new"
	cont "#MON!"
	done

OaksLabRivalWinText:
	text "RIVAL: What?"
	line "Unbelievable!"
	done

OaksLabRivalLossText:
	text "RIVAL: Yeah! Am I"
	line "great or what?"
	done

OaksLabRivalLeavingText:
	text "RIVAL: All right!"
	line "Smell you later!"
	done

OaksLabStarterAdviceText:
	text "OAK: Train your"
	line "partner in battles"
	cont "wild #MON."

	para "If it gets tired,"
	line "your mother can"
	cont "help it rest."
	done

OaksLabTakeCharmanderText:
	text "OAK: Do you want"
	line "CHARMANDER, the"
	cont "fire #MON?"
	done

OaksLabTakeSquirtleText:
	text "OAK: Do you want"
	line "SQUIRTLE, the"
	cont "water #MON?"
	done

OaksLabTakeBulbasaurText:
	text "OAK: Do you want"
	line "BULBASAUR, the"
	cont "grass #MON?"
	done

OaksLabPokedexRequestText:
	text "OAK: Now, I have"
	line "a request for"
	cont "both of you!"
	done

OaksLabPokedexExplanationText:
	text "This is my"
	line "invention,"
	cont "#DEX!"

	para "It automatically"
	line "records data on"
	cont "#MON you've"
	cont "seen or caught!"

	para "It's a hi-tech"
	line "encyclopedia!"
	done

OaksLabReceivedPokedexText:
	text "<PLAYER> received"
	line "#DEX from OAK!"
	done

OaksLabPokedexDreamText:
	text "To make a complete"
	line "guide on all the"
	cont "#MON in the"
	cont "world…"

	para "That was my dream!"

	para "But I'm too old!"
	line "I can't do it!"

	para "So, I want you two"
	line "to fulfill my"
	cont "dream for me!"
	done

OakWelcomeKantoText:
	text "OAK: Ah, <PLAY_G>!"
	line "It's good of you"


	para "to come all this"
	line "way to KANTO."


	para "What do you think"
	line "of the trainers"


	para "out here?"
	line "Pretty tough, huh?"
	done

OakLabDexCheckText:
	text "How is your #-"
	line "DEX coming?"


	para "Let's see…"
	done

OakLabGoodbyeText:
	text "If you're in the"
	line "area, I hope you"
	cont "come visit again."
	done

OakOpenMtSilverText:
	text "OAK: Wow! That's"
	line "excellent!"


	para "You collected the"
	line "BADGES of GYMS in"
	cont "KANTO. Well done!"


	para "I was right in my"
	line "assessment of you."


	para "Tell you what,"
	line "<PLAY_G>. I'll make"


	para "arrangements so"
	line "that you can go to"
	cont "MT.SILVER."


	para "MT.SILVER is a big"
	line "mountain that is"


	para "home to many wild"
	line "#MON."


	para "It's too dangerous"
	line "for your average"


	para "trainer, so it's"
	line "off limits. But"


	para "we can make an"
	line "exception in your"
	cont "case, <PLAY_G>."


	para "Go up to INDIGO"
	line "PLATEAU. You can"


	para "reach MT.SILVER"
	line "from there."
	done

OakNoKantoBadgesText:
	text "OAK: Hmm? You're"
	line "not collecting"
	cont "KANTO GYM BADGES?"


	para "The GYM LEADERS in"
	line "KANTO are as tough"


	para "as any you battled"
	line "in JOHTO."


	para "I recommend that"
	line "you challenge"
	cont "them."
	done

OakYesKantoBadgesText:
	text "OAK: Ah, you're"
	line "collecting KANTO"
	cont "GYM BADGES."


	para "I imagine that"
	line "it's hard, but the"


	para "experience is sure"
	line "to help you."


	para "Come see me when"
	line "you get them all."


	para "I'll have a gift"
	line "for you."


	para "Keep trying hard,"
	line "<PLAY_G>!"
	done

OaksAssistant1Text:
	text "The PROF's #MON"
	line "TALK radio program"


	para "isn't aired here"
	line "in KANTO."


	para "It's a shame--I'd"
	line "like to hear it."
	done

OaksAssistant2Text:
	text "Thanks to your"
	line "work on the #-"
	cont "DEX, the PROF's"


	para "research is coming"
	line "along great."
	done

OaksAssistant3Text:
	text "Don't tell anyone,"
	line "but PROF.OAK'S"


	para "#MON TALK isn't"
	line "a live broadcast."
	done

OaksLabPoster1Text:
	text "Press START to"
	line "open the MENU."
	done

OaksLabPoster2Text:
	text "The SAVE option is"
	line "on the MENU."


	para "Use it in a timely"
	line "manner."
	done

OaksLabTrashcanText:
	text "There's nothing in"
	line "here…"
	done

OaksLabPCText:
	text "There's an e-mail"
	line "message on the PC."


	para "…"


	para "PROF.OAK, how is"
	line "your research"
	cont "coming along?"


	para "I'm still plugging"
	line "away."


	para "I heard rumors"
	line "that <PLAY_G> is"


	para "getting quite a"
	line "reputation."


	para "I'm delighted to"
	line "hear that."


	para "ELM in NEW BARK"
	line "TOWN 8-)"
	done

OaksLab_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 11, PALLET_TOWN, 3
	warp_event  5, 11, PALLET_TOWN, 3

	def_coord_events
	coord_event 4, 8, SCENE_OAKSLAB_CHOOSE_STARTER, OaksLabDontLeave
	coord_event 5, 8, SCENE_OAKSLAB_CHOOSE_STARTER, OaksLabDontLeave
	coord_event 4, 8, SCENE_OAKSLAB_RIVAL_BATTLE, OaksLabRivalBattleLeft
	coord_event 5, 8, SCENE_OAKSLAB_RIVAL_BATTLE, OaksLabRivalBattleRight

	def_bg_events
	bg_event  6,  1, BGEVENT_READ, OaksLabBookshelf
	bg_event  7,  1, BGEVENT_READ, OaksLabBookshelf
	bg_event  8,  1, BGEVENT_READ, OaksLabBookshelf
	bg_event  9,  1, BGEVENT_READ, OaksLabBookshelf
	bg_event  0,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  1,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  2,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  3,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  6,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  7,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  8,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  9,  7, BGEVENT_READ, OaksLabBookshelf
	bg_event  4,  0, BGEVENT_READ, OaksLabPoster1
	bg_event  5,  0, BGEVENT_READ, OaksLabPoster2
	bg_event  9,  3, BGEVENT_READ, OaksLabTrashcan
	bg_event  0,  1, BGEVENT_READ, OaksLabPC

	def_object_events
	object_event  5,  2, SPRITE_OAK, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Oak, EVENT_OAKS_LAB_OAK
	object_event  1,  8, SPRITE_SCIENTIST, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, OaksAssistant1Script, -1
	object_event  8,  9, SPRITE_SCIENTIST, SPRITEMOVEDATA_WALK_UP_DOWN, 0, 1, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, OaksAssistant2Script, -1
	; Keep this assistant off the starter row to avoid scanline sprite overflow.
	object_event  1,  5, SPRITE_SCIENTIST, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, OaksAssistant3Script, -1
	object_event 6, 3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OaksLabCharmanderBallScript, EVENT_OAKS_LAB_CHARMANDER_BALL
	object_event 7, 3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OaksLabSquirtleBallScript, EVENT_OAKS_LAB_SQUIRTLE_BALL
	object_event 8, 3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, OaksLabBulbasaurBallScript, EVENT_OAKS_LAB_BULBASAUR_BALL
	object_event 4, 3, SPRITE_BLUE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, OaksLabRivalScript, EVENT_OAKS_LAB_RIVAL
