ReinitBattleAnimFrameset:
	ld hl, BATTLEANIMSTRUCT_FRAMESET_ID
	add hl, bc
	ld [hl], a
	ld hl, BATTLEANIMSTRUCT_DURATION
	add hl, bc
	ld [hl], 0
	ld hl, BATTLEANIMSTRUCT_FRAME
	add hl, bc
	ld [hl], -1
	ret

GetBattleAnimFrame:
.loop
	ld hl, BATTLEANIMSTRUCT_DURATION
	add hl, bc
	ld a, [hl]
	and a
	jr z, .next_frame
	dec [hl]
	call .GetPointer
	ld a, [hli]
	push af
	jr .okay

.next_frame
	ld hl, BATTLEANIMSTRUCT_FRAME
	add hl, bc
	inc [hl]
	call .GetPointer
	ld a, [hli]
	cp oamrestart_command
	jr z, .restart
	cp oamend_command
	jr z, .repeat_last

	push af
	ld a, [hl]
	push hl
	and ~(OAM_YFLIP << 1 | OAM_XFLIP << 1)
	ld hl, BATTLEANIMSTRUCT_DURATION
	add hl, bc
	ld [hl], a
	pop hl
.okay
	ld a, [hl]
	and OAM_YFLIP << 1 | OAM_XFLIP << 1 ; The << 1 is compensated in the "oamframe" macro
	srl a
	ld [wBattleAnimTempFrameOAMFlags], a
	pop af
	ret

.repeat_last
	xor a
	ld hl, BATTLEANIMSTRUCT_DURATION
	add hl, bc
	ld [hl], a

	ld hl, BATTLEANIMSTRUCT_FRAME
	add hl, bc
	dec [hl]
	dec [hl]
	jr .loop

.restart
	xor a
	ld hl, BATTLEANIMSTRUCT_DURATION
	add hl, bc
	ld [hl], a

	dec a
	ld hl, BATTLEANIMSTRUCT_FRAME
	add hl, bc
	ld [hl], a
	jr .loop

.GetPointer:
	ld hl, BATTLEANIMSTRUCT_FRAMESET_ID
	add hl, bc
	ld e, [hl]
	ld d, 0
	ld hl, BattleAnimFrameData
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, BATTLEANIMSTRUCT_FRAME
	add hl, bc
	ld l, [hl]
	ld h, 0
	add hl, hl
	add hl, de
	ret

GetBattleAnimOAMPointer:
	ld l, a
	ld h, 0
	ld de, BattleAnimOAMData
	add hl, hl
	add hl, hl
	add hl, de
	ret

LoadBattleAnimGFX:
	push hl
	cp BATTLE_ANIM_GFX_POKE_BALL
	call z, .LoadBallPalette
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	ld de, AnimObjGFX
	add hl, de
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop de
	push bc
	call DecompressRequest2bpp
	pop bc
	ret

.LoadBallPalette:
	; Save the current WRAM bank and read the ball item.
	ldh a, [rWBK]
	push af
	ld a, BANK(wCurItem)
	ldh [rWBK], a
	ld a, [wCurItem]
	ld b, a
	ld hl, BallColors
.loop
	ld a, [hli]
	cp b
	jr z, .done
	cp -1
	jr z, .done
rept PAL_COLOR_SIZE * 2
	inc hl
endr
	jr .loop
.done
	; Replace the middle two colors of the ball's object palette.
	ld a, BANK(wOBPals2)
	ldh [rWBK], a
	ld de, wOBPals2 palette PAL_BATTLE_OB_RED color 1
rept PAL_COLOR_SIZE * 2 - 1
	ld a, [hli]
	ld [de], a
	inc de
endr
	ld a, [hl]
	ld [de], a
	ld a, $1
	ldh [hCGBPalUpdate], a
	pop af
	ldh [rWBK], a
	ld a, BATTLE_ANIM_GFX_POKE_BALL
	ret

INCLUDE "data/battle_anims/ball_colors.asm"

INCLUDE "data/battle_anims/framesets.asm"

INCLUDE "data/battle_anims/oam.asm"

INCLUDE "data/battle_anims/object_gfx.asm"
