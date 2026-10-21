#!/usr/bin/env python3
"""Check the compiled Cerulean bridge rival sequence and its walking paths."""
from itertools import product
from verify_route2 import Map, ROOT
from verify_route22_rival import Check


def verify(stem):
    rom = Check(stem)
    city = Map('CeruleanCity', 20, 18, 'kanto', 'CERULEAN_CITY')
    source = (ROOT / 'maps/CeruleanCity.asm').read_text()
    assert 'coord_event 20, 6, -1, CeruleanCityRivalBattle' in source
    assert 'coord_event 21, 6, -1, CeruleanCityRivalBattle' in source
    data = rom.data('CeruleanCity_MapEvents')
    pos = 2
    count = data[pos]; pos += 1 + count * 5
    assert data[pos] == 2; pos += 1
    assert [(data[pos+i*8+2], data[pos+i*8+1]) for i in range(2)] == [(20, 6), (21, 6)]
    pos += 16
    count = data[pos]; pos += 1 + count * 5
    assert data[pos] == 7; pos += 1
    obj = data[pos+6*13:pos+7*13]
    assert (obj[0], obj[2]-4, obj[1]-4) == (7, 20, 2)
    hidden = int.from_bytes(obj[11:13], 'little')
    assert rom.data('CeruleanCityHideRivalCallback')[:3] == bytes([0x6e, 8, 0x90])
    start = rom.data('CeruleanCityRivalBattle')
    done = int.from_bytes(start[1:3], 'little')
    lab = int.from_bytes(start[7:9], 'little')
    assert done != hidden and max(done, hidden) < 2048
    # Three independent encounter groups, with stable old IDs and three new IDs.
    parties = rom.data('PalletRivalGroup'); pos = 0
    for index in range(9):
        pos = parties.index(0x50, pos) + 1
        kind = parties[pos]; pos += 1
        assert kind in range(4)
        team = []
        while parties[pos] != 255:
            level, species = parties[pos:pos+2]; pos += 2
            assert 1 <= level <= 100 and 1 <= species <= 251
            if kind & 2: pos += 1
            if kind & 1: pos += 4
            team.append((level, species))
        pos += 1
        assert 1 <= len(team) <= 6
    ai = rom.data('PalletRivalAIMoveWeights')
    assert [ai[i] for i in range(0, 27, 3)] == list(range(1, 10))
    assert all(int.from_bytes(ai[i+1:i+3], 'little') == 3 for i in (18, 21, 24))
    # Reproduce the engine's sprite sort and VRAM allocation for six player forms.
    sprites = rom.data('CeruleanGroupSprites')[:23]
    assert list(sprites).count(7) == 1
    metadata = rom.data('OverworldSprites')
    for player in (1, 2, 0x60, 0x61, 0x67, 0x68):
        entries = [(s, metadata[(s-1)*6+4]) for s in [player] + list(sprites)]
        for i in range(len(entries)-1):
            for j in range(len(entries)-1, i, -1):
                if entries[j][1] < entries[i][1]: entries[i], entries[j] = entries[j], entries[i]
        tiles = {}; cursor = 0
        for sprite, kind in entries:
            length = 4 if kind == 3 else 12
            if cursor < 128 and cursor+length > 128: cursor = 128
            tiles[sprite] = cursor; cursor += length
        assert cursor <= 256 and tiles[7] + 12 <= 128, (player, 'rival needs walking frames')
    # Execute the actual compiled script, resolving pointers and movement streams.
    bank, address = rom.symbols['CeruleanCityRivalBattle']
    mem = rom.rom[bank*0x4000:(bank+1)*0x4000]
    def run(lane, starter, won, completed=False, lab_done=True):
        flags = {done} if completed else set()
        if lab_done: flags.add(lab)
        # Read the starter flag operands directly from the compiled script.
        checks = []
        # These offsets are identified by the dedicated loadtrainer branches below.
        branch = rom.symbols['CeruleanCityRivalBattle.Charmander'][1] % 0x4000
        before = mem[address%0x4000:branch]
        for at in range(len(before)-5):
            if before[at] == 0x31 and before[at+3] == 0x09:
                checks.append(int.from_bytes(before[at+1:at+3], 'little'))
        assert len(checks) == 3
        checks = checks[1:]
        if starter == 'BULBASAUR': flags.add(checks[0])
        if starter == 'CHARMANDER': flags.add(checks[1])
        pc = address % 0x4000; value = 0; rival = (20, 2)
        visible = False; trainer = None; battles = 0; facing = {}; refreshed = False
        player = (lane, 6)
        def word(at): return int.from_bytes(mem[at:at+2], 'little')
        for _ in range(100):
            op = mem[pc]; pc += 1
            if op == 0x31:
                value = word(pc) in flags; pc += 2
            elif op in (0x08, 0x09):
                target = word(pc); pc += 2
                if bool(value) == (op == 9): pc = target % 0x4000
            elif op == 0x06:
                expected = mem[pc]; target = word(pc+1); pc += 3
                if value == expected: pc = target % 0x4000
            elif op == 0x03: pc = word(pc) % 0x4000
            elif op == 0x1c:
                assert mem[pc] == 0x12; pc += 1; value = lane
            elif op == 0x72:
                assert mem[pc] == 8 and not visible
                rival = tuple(mem[pc+1:pc+3]); pc += 3
            elif op in (0x6e, 0x6f):
                assert mem[pc] == 8; pc += 1; visible = op == 0x6f
                if visible: assert refreshed
            elif op == 0x0f: pc += 2; refreshed = True
            elif op == 0x69:
                assert mem[pc] == 8 and visible
                movement = word(pc+1) % 0x4000; pc += 3
                for _ in range(12):
                    step = mem[movement]; movement += 1
                    if step == 0x47: break
                    assert step in range(0x0c, 0x10), hex(step)
                    dx, dy = ((0,1),(0,-1),(-1,0),(1,0))[step-0x0c]
                    rival = (rival[0]+dx, rival[1]+dy)
                    assert rival != player and rival not in {p for p,_ in city.objects[:-1]}
                    assert city.collision(rival) in ('FLOOR', 'LADDER'), rival
                else: raise AssertionError('unterminated movement')
            elif op == 0x76:
                facing[mem[pc]] = mem[pc+1]; pc += 2
            elif op == 0x5e: trainer = tuple(mem[pc:pc+2]); pc += 2
            elif op == 0x5f:
                assert rival == (lane, 5) and visible
                assert facing[0] == 1 and facing[8] == 0
                battles += 1
            elif op == 0x60:
                if not won: return flags, battles, trainer, False, rival
            elif op == 0x33: flags.add(word(pc)); pc += 2
            elif op == 0x68: assert mem[pc] == 8; pc += 1
            elif op in (0x4c, 0x7f): pc += 2
            elif op == 0x64: pc += 4
            elif op in (0x47, 0x49, 0x54): pass
            elif op == 0x91: return flags, battles, trainer, visible, rival
            else: raise AssertionError(hex(op))
        raise AssertionError('script loop')
    for lane, starter, won, completed, lab_done in product(
            (20,21), ('BULBASAUR','CHARMANDER','SQUIRTLE'), (False,True), (False,True), (False,True)):
        flags, battles, trainer, visible, rival = run(lane, starter, won, completed, lab_done)
        eligible = lab_done and not completed
        assert battles == int(eligible)
        assert (done in flags) == (completed or eligible and won)
        assert not visible
        if eligible:
            assert trainer == (0x44, {'SQUIRTLE':7,'BULBASAUR':8,'CHARMANDER':9}[starter])
            if won: assert rival == (41-lane, 11)
            retry = run(lane, starter, True, completed=won)
            assert retry[1] == int(not won)
    print(f'{stem}: 48 encounter states, retry/repeat behavior, both movement paths, nine parties and six sprite forms passed')


if __name__ == '__main__':
    for stem in ('pokecrystal', 'pokecrystal_debug'):
        verify(stem)
