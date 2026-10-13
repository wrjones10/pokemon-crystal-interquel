; Layout and content adapted from pret/pokeyellow.
	object_const_def
	const VIRIDIANFOREST_YOUNGSTER1
	const VIRIDIANFOREST_BUG_CATCHER1
	const VIRIDIANFOREST_BUG_CATCHER2
	const VIRIDIANFOREST_BUG_CATCHER3
	const VIRIDIANFOREST_LASS
	const VIRIDIANFOREST_BUG_CATCHER4
	const VIRIDIANFOREST_POTION1
	const VIRIDIANFOREST_POTION2
	const VIRIDIANFOREST_POKE_BALL
	const VIRIDIANFOREST_YOUNGSTER2

ViridianForest_MapScripts:
	def_scene_scripts

	def_callbacks

ViridianForestYoungster1Script:
	jumptextfaceplayer ViridianForestYoungster1Text

ViridianForestYoungster6Script:
	jumptextfaceplayer ViridianForestYoungster6Text

ViridianForestYoungster2Trainer:
	trainer BUG_CATCHER, VIRIDIAN_FOREST_BUG_CATCHER_1, EVENT_BEAT_VIRIDIAN_FOREST_TRAINER_1, ViridianForestYoungster2BattleText, ViridianForestYoungster2EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext ViridianForestYoungster2AfterBattleText

ViridianForestYoungster3Trainer:
	trainer BUG_CATCHER, VIRIDIAN_FOREST_BUG_CATCHER_2, EVENT_BEAT_VIRIDIAN_FOREST_TRAINER_2, ViridianForestYoungster3BattleText, ViridianForestYoungster3EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext ViridianForestYoungster3AfterBattleText

ViridianForestYoungster4Trainer:
	trainer BUG_CATCHER, VIRIDIAN_FOREST_BUG_CATCHER_3, EVENT_BEAT_VIRIDIAN_FOREST_TRAINER_3, ViridianForestYoungster4BattleText, ViridianForestYoungster4EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext ViridianForestYoungster4AfterBattleText

ViridianForestCooltrainerFTrainer:
	trainer LASS, VIRIDIAN_FOREST_LASS, EVENT_BEAT_VIRIDIAN_FOREST_TRAINER_4, ViridianForestCooltrainerFBattleText, ViridianForestCooltrainerFEndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext ViridianForestCooltrainerFAfterBattleText

ViridianForestYoungster5Trainer:
	trainer BUG_CATCHER, VIRIDIAN_FOREST_BUG_CATCHER_4, EVENT_BEAT_VIRIDIAN_FOREST_TRAINER_5, ViridianForestYoungster5BattleText, ViridianForestYoungster5EndBattleText, 0, .After
.After:
	endifjustbattled
	jumptext ViridianForestYoungster5AfterBattleText

ViridianForestPotion1:
	itemball POTION

ViridianForestPotion2:
	itemball POTION

ViridianForestPokeBall:
	itemball POKE_BALL

ViridianForestHiddenPotion:
	hiddenitem POTION, EVENT_VIRIDIAN_FOREST_HIDDEN_POTION

ViridianForestHiddenAntidote:
	hiddenitem ANTIDOTE, EVENT_VIRIDIAN_FOREST_HIDDEN_ANTIDOTE

ViridianForestTrainerTips1:
	jumptext ViridianForestTrainerTips1Text

ViridianForestUseAntidoteSign:
	jumptext ViridianForestUseAntidoteSignText

ViridianForestTrainerTips2:
	jumptext ViridianForestTrainerTips2Text

ViridianForestTrainerTips3:
	jumptext ViridianForestTrainerTips3Text

ViridianForestTrainerTips4:
	jumptext ViridianForestTrainerTips4Text

ViridianForestLeavingSign:
	jumptext ViridianForestLeavingSignText

ViridianForestYoungster1Text:
	text "I came here with"
	line "some friends!"

	para "They're out for"
	line "#MON fights!"
	done

ViridianForestYoungster2BattleText:
	text "Hey! You have"
	line "#MON! Come on!"
	cont "Let's battle 'em!"
	done

ViridianForestYoungster2EndBattleText:
	text "No!"
	line "CATERPIE can't"
	cont "cut it!"
	done

ViridianForestYoungster2AfterBattleText:
	text "Ssh! You'll scare"
	line "the bugs away!"
	done

ViridianForestYoungster3BattleText:
	text "Yo! You can't jam"
	line "out if you're a"
	cont "#MON trainer!"
	done

ViridianForestYoungster3EndBattleText:
	text "Huh?"
	line "I ran out of"
	cont "#MON!"
	done

ViridianForestYoungster3AfterBattleText:
	text "Darn! I'm going"
	line "to catch some"
	cont "stronger ones!"
	done

ViridianForestYoungster4BattleText:
	text "Hey, wait up!"
	line "What's the hurry?"
	done

ViridianForestYoungster4EndBattleText:
	text "I"
	line "give! You're good"
	cont "at this!"
	done

ViridianForestYoungster4AfterBattleText:
	text "Sometimes, you"
	line "can find stuff on"
	cont "the ground!"

	para "I'm looking for"
	line "the stuff I"
	cont "dropped!"
	done

ViridianForestCooltrainerFBattleText:
	text "Hi, do you have a"
	line "PIKACHU?"
	done

ViridianForestCooltrainerFEndBattleText:
	text "Oh no,"
	line "really?"
	done

ViridianForestCooltrainerFAfterBattleText:
	text "I looked forever,"
	line "but I never found"
	cont "a PIKACHU here!"
	done

ViridianForestYoungster5BattleText:
	text "I'm gonna be the"
	line "best. You just"
	cont "can't beat me!"
	done

ViridianForestYoungster5EndBattleText:
	text "After"
	line "all I did..."
	done

ViridianForestYoungster5AfterBattleText:
	text "A METAPOD is cool"
	line "because its"
	cont "attack is its"
	cont "defense!"
	done

ViridianForestYoungster6Text:
	text "I ran out of #"
	line "BALLs to catch"
	cont "#MON with!"

	para "You should carry"
	line "extras!"
	done

ViridianForestTrainerTips1Text:
	text "TRAINER TIPS"

	para "If you want to"
	line "avoid battles,"
	cont "stay away from"
	cont "grassy areas!"
	done

ViridianForestUseAntidoteSignText:
	text "For poison, use"
	line "ANTIDOTE! Get it"
	cont "at #MON MARTs!"
	done

ViridianForestTrainerTips2Text:
	text "TRAINER TIPS"

	para "Contact PROF.OAK"
	line "via PC to get"
	cont "your #DEX"
	cont "evaluated!"
	done

ViridianForestTrainerTips3Text:
	text "TRAINER TIPS"

	para "No stealing of"
	line "#MON from"
	cont "other trainers!"
	cont "Catch only wild"
	cont "#MON!"
	done

ViridianForestTrainerTips4Text:
	text "TRAINER TIPS"

	para "Weaken #MON"
	line "before attempting"
	cont "capture!"

	para "When healthy,"
	line "they may escape!"
	done

ViridianForestLeavingSignText:
	text "LEAVING"
	line "VIRIDIAN FOREST"
	cont "PEWTER CITY AHEAD"
	done

ViridianForest_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  1,  0, VIRIDIAN_FOREST_NORTH_GATE, 3
	warp_event  2,  0, VIRIDIAN_FOREST_NORTH_GATE, 3
	warp_event 15, 47, VIRIDIAN_FOREST_SOUTH_GATE, 1
	warp_event 16, 47, VIRIDIAN_FOREST_SOUTH_GATE, 1
	warp_event 17, 47, VIRIDIAN_FOREST_SOUTH_GATE, 1
	warp_event 18, 47, VIRIDIAN_FOREST_SOUTH_GATE, 1

	def_coord_events

	def_bg_events
	bg_event 24, 40, BGEVENT_READ, ViridianForestTrainerTips1
	bg_event 16, 32, BGEVENT_READ, ViridianForestUseAntidoteSign
	bg_event 26, 17, BGEVENT_READ, ViridianForestTrainerTips2
	bg_event  4, 24, BGEVENT_READ, ViridianForestTrainerTips3
	bg_event 18, 45, BGEVENT_READ, ViridianForestTrainerTips4
	bg_event  2,  1, BGEVENT_READ, ViridianForestLeavingSign
	bg_event  1, 18, BGEVENT_ITEM, ViridianForestHiddenPotion
	bg_event 16, 42, BGEVENT_ITEM, ViridianForestHiddenAntidote

	def_object_events
	object_event 16, 43, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ViridianForestYoungster1Script, -1
	object_event 30, 33, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 4, ViridianForestYoungster2Trainer, -1
	object_event 30, 19, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 4, ViridianForestYoungster3Trainer, -1
	object_event  2, 18, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 1, ViridianForestYoungster4Trainer, -1
	object_event  2, 41, SPRITE_LASS, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 0, ViridianForestCooltrainerFTrainer, -1
	object_event 13, 17, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_TRAINER, 4, ViridianForestYoungster5Trainer, -1
	object_event 25, 11, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, ViridianForestPotion1, EVENT_VIRIDIAN_FOREST_POTION_1
	object_event 12, 29, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, ViridianForestPotion2, EVENT_VIRIDIAN_FOREST_POTION_2
	object_event  1, 31, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_ITEMBALL, 0, ViridianForestPokeBall, EVENT_VIRIDIAN_FOREST_POKE_BALL
	object_event 27, 40, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ViridianForestYoungster6Script, -1
