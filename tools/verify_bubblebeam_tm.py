#!/usr/bin/env python3
"""Check TM52's compiled move mapping, compatibility, and inventory metadata."""
import re
from verify_route2 import ROOT
from verify_route22_rival import Check

YELLOW_COMPATIBLE = set('''seel nidorino tentacool gyarados lapras goldeen wartortle
mewtwo marowak dragonite rattata persian snorlax blastoise dratini poliwrath
nidoqueen nidoking starmie lickitung articuno dragonair rhydon wigglytuff cubone
seaking kabuto jynx horsea meowth tentacruel dewgong krabby clefairy squirtle
slowpoke mew kingler shellder cloyster omastar clefable kabutops poliwag vaporeon
slowbro staryu poliwhirl seadra nidorina jigglypuff raticate omanyte psyduck
golduck kangaskhan chansey'''.split())


def verify(stem):
    rom = Check(stem)
    constants = (ROOT / 'constants/item_constants.asm').read_text()
    tm = re.findall(r'^\s*add_tm (\w+)', constants, re.M)
    hm = re.findall(r'^\s*add_hm (\w+)', constants, re.M)
    tutors = re.findall(r'^\s*add_mt (\w+)', constants, re.M)
    assert len(tm) == 52 and tm[-2:] == ['ROCK_THROW', 'BUBBLEBEAM']
    assert hm == ['CUT', 'FLY', 'SURF', 'STRENGTH', 'FLASH', 'WHIRLPOOL', 'WATERFALL']
    assert tutors == ['FLAMETHROWER', 'THUNDERBOLT', 'ICE_BEAM']
    moves = tm + hm + tutors
    ids = {name: int(value, 16) for name, value in re.findall(
        r'^\s*const (\w+)\s*; ([0-9a-f]{2})\b',
        (ROOT / 'constants/move_constants.asm').read_text(), re.M)}
    assert rom.data('TMHMMoves')[:len(moves)+1] == bytes([ids[m] for m in moves] + [0])
    assert rom.symbols['wNumItems'][1] - rom.symbols['wTMsHMs'][1] == 59
    attributes = rom.data('ItemAttributes')
    assert attributes[(0xf4-1)*7:0xf4*7] == bytes([0xd0, 7, 0, 0, 0x40, 4, 0x50])
    for item in range(0xf5, 0xfc):
        assert attributes[(item-1)*7:item*7] == bytes([0, 0, 0, 0, 0xc0, 4, 0x50])
    assert len(YELLOW_COMPATIBLE) == 57
    eligible = YELLOW_COMPATIBLE | {'cleffa', 'igglybuff', 'smoochum', 'blissey'}
    base = rom.data('BaseData')
    count = learned = 0
    for path in (ROOT / 'data/pokemon/base_stats').glob('*.asm'):
        source = path.read_text()
        species = int(re.search(r'^\s*db \w+ ; (\d+)', source, re.M)[1])
        if species > 151 and re.search(r'^\s*db [^\n;]*\bWATER\b[^\n;]*; type', source, re.M):
            eligible.add(path.stem)
        listed = {m.strip() for m in re.search(r'^\s*tmhm\b([^\n]*)', source, re.M)[1].split(',') if m.strip()}
        assert listed <= set(moves), (path.name, 'unknown TM move')
        expected = sum(1 << moves.index(m) for m in listed)
        offset = (species - 1) * 32 + 24
        assert int.from_bytes(base[offset:offset+8], 'little') == expected, path.name
        assert ('BUBBLEBEAM' in listed) == (path.stem in eligible), path.name
        count += 1
        learned += 'BUBBLEBEAM' in listed
    assert count == 251 and learned == len(eligible) == 79
    print(f'{stem}: TM52, seven HMs, three tutors, inventory and all 251 learnsets passed (79 BubbleBeam users)')


if __name__ == '__main__':
    for stem in ('pokecrystal', 'pokecrystal_debug'):
        verify(stem)
