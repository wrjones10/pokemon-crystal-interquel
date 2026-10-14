#!/usr/bin/env python3
"""Build both ROMs, then verify Viridian's officer visibility and sprite data."""
from itertools import product
import re
from verify_route22_rival import Check
from verify_route2 import ROOT


def verify(stem):
    rom = Check(stem)
    source = (ROOT / 'maps/ViridianCity.asm').read_text()
    assert 'callback MAPCALLBACK_OBJECTS, ViridianCityGymOfficerCallback' in source
    # Read the compiled map events rather than assuming the object's flag ID.
    data = rom.data('ViridianCity_MapEvents')
    position = 2
    position += 1 + data[position] * 5  # warps
    assert data[position] == 0  # coordinate events
    position += 1
    position += 1 + data[position] * 5  # background events
    assert data[position] == 5
    position += 1
    objects = [data[position + i * 13:position + (i + 1) * 13] for i in range(5)]
    officer = objects[-1]
    assert officer[:3] == bytes((0x69, 8 + 4, 32 + 4)), 'wrong sprite/position'
    assert officer[3] == objects[1][3] and officer[4] == 0, 'officer must stand still'
    assert officer[5:7] == b'\xff\xff', 'officer must appear at all times'
    hidden = int.from_bytes(officer[11:13], 'little')
    assert 0 < hidden < 2048
    script = rom.data('ViridianCityGymOfficerCallback')[:50]
    engine_names = re.findall(r'^\s*const (ENGINE_\w+)', (ROOT / 'constants/engine_flags.asm').read_text(), re.M)
    badges = [engine_names.index(f'ENGINE_{name}BADGE') for name in
              ('BOULDER', 'CASCADE', 'THUNDER', 'RAINBOW', 'SOUL', 'MARSH', 'VOLCANO')]
    bank, start = rom.symbols['ViridianCityGymOfficerCallback']
    for bits, old_hidden, extra_badges in product(range(128), (False, True), (False, True)):
        flags = {flag: bool(bits & (1 << i)) for i, flag in enumerate(badges)}
        for name in ('EARTH', 'ZEPHYR', 'HIVE', 'PLAIN', 'FOG', 'MINERAL', 'STORM', 'GLACIER', 'RISING'):
            flags[engine_names.index(f'ENGINE_{name}BADGE')] = extra_badges
        original_flags = dict(flags)
        result, pc, value = old_hidden, 0, False
        for _ in range(20):
            opcode = script[pc]
            pc += 1
            if opcode == 0x90:  # endcallback
                break
            argument = int.from_bytes(script[pc:pc + 2], 'little')
            pc += 2
            if opcode == 0x34:  # checkflag
                assert argument in badges, 'must check only the seven other Kanto badges'
                value = flags[argument]
            elif opcode == 0x08:  # iffalse
                if not value:
                    pc = argument - start
            elif opcode in (0x32, 0x33):  # clear/setevent
                assert argument == hidden, 'callback must set the actual object visibility flag'
                result = opcode == 0x33
            else:
                raise AssertionError(('unexpected callback opcode', hex(opcode)))
        else:
            raise AssertionError('callback did not finish')
        assert result == (bits == 127), (bits, old_hidden, extra_badges)
        assert flags == original_flags, 'callback must not grant badges'
    sprites = rom.data('OverworldSprites')
    alias = sprites[(0x69 - 1) * 6:0x69 * 6]
    original = sprites[(0x43 - 1) * 6:0x43 * 6]
    assert alias[:4] == original[:4] and alias[4:] == bytes((2, 1)), 'wrong officer art/type/palette'
    for player in (1, 2, 0x60, 0x61, 0x67, 0x68, 0x34):
        tiles = rom.default_tiles(player)
        assert 0x69 in tiles and 0x1b not in tiles, 'replace unused Karen slot'
        # Type and length match the old Karen entry, preserving other allocations.
        assert sprites[(0x1b - 1) * 6 + 4] == alias[4]
    print(f'PASS {stem}: all 128 badge combinations, stale visibility flags, Earth/Johto independence,')
    print('      stationary object at (32, 8), persistent flag, and officer graphics allocation.')


def main():
    for stem in ('pokecrystal', 'pokecrystal_debug'):
        verify(stem)


if __name__ == '__main__':
    main()
