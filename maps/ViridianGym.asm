	object_const_def
	const VIRIDIANGYM_BERTHA
	const VIRIDIANGYM_GYM_GUIDE

ViridianGym_MapScripts:
	def_scene_scripts

	def_callbacks

ViridianGymBerthaScript:
	faceplayer
	opentext
	checkflag ENGINE_EARTHBADGE
	iftrue .FightDone
	writetext LeaderBerthaBeforeText
	waitbutton
	closetext
	winlosstext LeaderBerthaWinText, 0
	loadtrainer BERTHA, BERTHA1
	startbattle
	reloadmapafterbattle
	setevent EVENT_BEAT_BERTHA
	opentext
	writetext Text_ReceivedEarthBadge
	playsound SFX_GET_BADGE
	waitsfx
	setflag ENGINE_EARTHBADGE
	writetext LeaderBerthaAfterText
	waitbutton
	closetext
	end

.FightDone:
	writetext LeaderBerthaEpilogueText
	waitbutton
	closetext
	end

ViridianGymGuideScript:
	faceplayer
	opentext
	checkevent EVENT_BEAT_BERTHA
	iftrue .ViridianGymGuideWinScript
	writetext ViridianGymGuideText
	waitbutton
	closetext
	end

.ViridianGymGuideWinScript:
	writetext ViridianGymGuideWinText
	waitbutton
	closetext
	end

ViridianGymStatue:
	checkflag ENGINE_EARTHBADGE
	iftrue .Beaten
	jumpstd GymStatue1Script

.Beaten:
	gettrainername STRING_BUFFER_4, BERTHA, BERTHA1
	jumpstd GymStatue2Script

LeaderBerthaBeforeText:
	text "BERTHA: Welcome."

	para "I'm BERTHA, the"
	line "VIRIDIAN GYM"
	cont "LEADER."

	para "You've earned"
	line "seven KANTO"
	cont "BADGES already."

	para "Now, show me what"
	line "you and your"
	cont "#MON can do!"
	done

LeaderBerthaWinText:
	text "BERTHA: Well done!"

	para "You've earned"
	line "the EARTHBADGE."
	done

Text_ReceivedEarthBadge:
	text "<PLAYER> received"
	line "EARTHBADGE."
	done

LeaderBerthaAfterText:
	text "BERTHA: Your bond"
	line "with your #MON"
	cont "is impressive."

	para "Keep training"
	line "together. There's"
	cont "always more to"
	cont "learn!"
	done

LeaderBerthaEpilogueText:
	text "BERTHA: It's good"
	line "to see you again."

	para "Keep growing"
	line "alongside your"
	cont "#MON!"
	done

ViridianGymGuideText:
	text "Yo, CHAMP in"
	line "making!"

	para "BERTHA is the new"
	line "GYM LEADER here."

	para "She's no pushover."
	line "Give it everything"
	cont "you've got!"
	done

ViridianGymGuideWinText:
	text "Man, you are truly"
	line "tough…"

	para "That was a heck of"
	line "an inspirational"

	para "battle. It brought"
	line "tears to my eyes."
	done

ViridianGym_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4, 17, VIRIDIAN_CITY, 1
	warp_event  5, 17, VIRIDIAN_CITY, 1

	def_coord_events

	def_bg_events
	bg_event  3, 13, BGEVENT_READ, ViridianGymStatue
	bg_event  6, 13, BGEVENT_READ, ViridianGymStatue

	def_object_events
	object_event  5,  3, SPRITE_BLUE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ViridianGymBerthaScript, -1
	object_event  7, 13, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ViridianGymGuideScript, -1
