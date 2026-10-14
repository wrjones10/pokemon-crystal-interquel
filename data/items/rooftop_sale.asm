RooftopSaleMart1:
	db 5 + DEF(_DEBUG)
if DEF(_DEBUG)
	dbw RARE_CANDY, 100
endc
	dbw POKE_BALL,     150
	dbw GREAT_BALL,    500
	dbw SUPER_POTION,  500
	dbw FULL_HEAL,     500
	dbw REVIVE,       1200
	db -1

RooftopSaleMart2:
	db 5 + DEF(_DEBUG)
if DEF(_DEBUG)
	dbw RARE_CANDY, 100
endc
	dbw HYPER_POTION, 1000
	dbw FULL_RESTORE, 2000
	dbw FULL_HEAL,     500
	dbw ULTRA_BALL,   1000
	dbw PROTEIN,      7800
	db -1
