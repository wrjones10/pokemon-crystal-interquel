; Party-specific move AI for the new rival. Class defaults still control items
; and switching. Add later encounters here when their parties are introduced.
MACRO rival_ai
	assert \1 > 0 && \1 < 256
	db \1
	dw \2
ENDM

PalletRivalAIMoveWeights:
	rival_ai PALLET_RIVAL_BULBASAUR, AI_BASIC
	rival_ai PALLET_RIVAL_CHARMANDER, AI_BASIC
	rival_ai PALLET_RIVAL_SQUIRTLE, AI_BASIC
	rival_ai PALLET_RIVAL_ROUTE22_BULBASAUR, AI_BASIC | AI_SETUP
	rival_ai PALLET_RIVAL_ROUTE22_CHARMANDER, AI_BASIC | AI_SETUP
	rival_ai PALLET_RIVAL_ROUTE22_SQUIRTLE, AI_BASIC | AI_SETUP
	db 0 ; unlisted parties use their trainer class's default AI

; AIChooseMove reads both tables using BANK(TrainerClassAttributes).
	assert BANK(PalletRivalAIMoveWeights) == BANK(TrainerClassAttributes)
PURGE rival_ai
