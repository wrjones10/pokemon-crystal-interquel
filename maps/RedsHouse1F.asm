	object_const_def
	const REDSHOUSE1F_REDS_MOM

RedsHouse1F_MapScripts:
	def_scene_scripts
	scene_script RedHouse1FNoopScene ; unusable

	def_callbacks

RedHouse1FNoopScene:
	end

RedsMom:
	faceplayer
	opentext
	checkevent EVENT_GOT_A_POKEMON_FROM_OAK
	iftrue .Heal
	writetext RedsMomOpeningText
	waitbutton
	closetext
	end
.Heal:
	writetext RedsMomRestText
	waitbutton
	closetext
	special FadeOutToBlack
	special HealParty
	playmusic MUSIC_HEAL
	pause 60
	special FadeInFromBlack
	special RestartMapMusic
	jumptext RedsMomHealedText

RedsHouse1FTV:
	jumptext RedsHouse1FTVText

RedsHouse1FBookshelf:
	jumpstd PictureBookshelfScript

RedsMomOpeningText:
	text "MOM: Good morning,"
	line "<PLAYER>!"

	para "PROF.OAK was"
	line "looking for you."

	para "His lab is here"
	line "in PALLET TOWN."
	cont "Go see him!"
	done

RedsMomRestText:
	text "MOM: You and your"
	line "#MON should"
	cont "take a quick rest."
	done

RedsMomHealedText:
	text "MOM: Looking good!"
	line "Take care of"
	cont "yourself, honey!"
	done

RedsHouse1FTVText:
	text "A movie is on TV."

	para "Four boys are"
	line "walking along"
	cont "railroad tracks."

	para "I had better go!"
	done

RedsHouse1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  2,  7, PALLET_TOWN, 1
	warp_event  3,  7, PALLET_TOWN, 1
	warp_event  7,  0, REDS_HOUSE_2F, 1

	def_coord_events

	def_bg_events
	bg_event  0,  1, BGEVENT_READ, RedsHouse1FBookshelf
	bg_event  1,  1, BGEVENT_READ, RedsHouse1FBookshelf
	bg_event  2,  1, BGEVENT_READ, RedsHouse1FTV

	def_object_events
	object_event  5,  3, SPRITE_REDS_MOM, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, RedsMom, -1
