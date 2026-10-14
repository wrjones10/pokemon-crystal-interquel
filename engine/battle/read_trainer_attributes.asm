GetTrainerClassName:
	ld hl, wRivalName
	ld a, c
	cp RIVAL1
	jr z, .rival

	ld [wCurSpecies], a
	ld a, TRAINER_NAME
	ld [wNamedObjectType], a
	call GetName
	ld de, wStringBuffer1
	ret

.rival
	ld de, wStringBuffer1
	push de
	ld bc, NAME_LENGTH
	call CopyBytes
	pop de
	ret

GetOTName:
	ld hl, wOTPlayerName
	ld a, [wLinkMode]
	and a
	jr nz, .ok

	ld hl, wRivalName
	ld a, c
	cp RIVAL1
	jr z, .ok

	ld [wCurSpecies], a
	ld a, TRAINER_NAME
	ld [wNamedObjectType], a
	call GetName
	ld hl, wStringBuffer1

.ok
	ld bc, TRAINER_CLASS_NAME_LENGTH
	ld de, wOTClassName
	push de
	call CopyBytes
	pop de
	ret

GetTrainerAttributes:
	ld a, [wTrainerClass]
	ld c, a
	call GetOTName
	ld a, [wTrainerClass]
	dec a
	ld hl, TrainerClassAttributes + TRNATTR_ITEM1
	ld bc, NUM_TRAINER_ATTRIBUTES
	call AddNTimes
	ld de, wEnemyTrainerItem1
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, [hl]
	ld [wEnemyTrainerBaseReward], a

; Brock's initial party has no Hyper Potion. Rematches keep the class items.
	ld a, [wTrainerClass]
	cp BROCK
	ret nz
	ld a, [wOtherTrainerID]
	cp BROCK1
	ret nz
	ld a, NO_ITEM
	ld [wEnemyTrainerItem1], a
	ret

GetTrainerAIMoveWeights:
; Return hl pointing to a move-AI bitfield in this bank.
; Preserve the original Battle Tower override: always use Falkner's class AI.
	ld hl, TrainerClassAttributes + TRNATTR_AI_MOVE_WEIGHTS
	ld a, [wInBattleTowerBattle]
	bit IN_BATTLE_TOWER_BATTLE_F, a
	ret nz
	ld a, [wTrainerClass]
	cp PALLET_RIVAL
	jr nz, .ClassDefaults
	ld a, [wOtherTrainerID]
	ld b, a
	ld hl, PalletRivalAIMoveWeights
.Lookup:
	ld a, [hli]
	and a
	jr z, .ClassDefaults
	cp b
	ret z
	inc hl
	inc hl
	jr .Lookup
.ClassDefaults:
	ld hl, TrainerClassAttributes + TRNATTR_AI_MOVE_WEIGHTS
	ld a, [wTrainerClass]
	dec a
	ld bc, NUM_TRAINER_ATTRIBUTES
	call AddNTimes
	ret

INCLUDE "data/trainers/attributes.asm"
INCLUDE "data/trainers/rival_ai.asm"
