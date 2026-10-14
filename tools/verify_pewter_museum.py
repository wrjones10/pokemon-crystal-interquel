#!/usr/bin/env python3
"""Build both ROMs, then check the restored museum's maps, admission and gift."""
from itertools import product
import re
from verify_route2 import Map, ROOT
from verify_route22_rival import Check

PAID = 'EVENT_BOUGHT_MUSEUM_TICKET'
AMBER = 'EVENT_GOT_OLD_AMBER'
SOURCE = (ROOT / 'maps/PewterMuseum1F.asm').read_text()


class MuseumMap(Map):
    def floor(self, position, cut=False):
        # Ledges are standable land tiles; the fence below blocks northward entry.
        return super().floor(position, cut) or (self.in_bounds(position)
                    and self.collision(position) in ('LADDER', 'HOP_DOWN'))


class Script:
    def __init__(self, rom):
        self.rom, self.labels, self.instructions = rom, {}, []
        scope = ''
        for line in SOURCE.splitlines():
            line = line.split(';')[0].strip()
            if not line:
                continue
            if line.endswith(':'):
                name = line[:-1]
                if name.startswith('.'):
                    name = scope + name
                else:
                    scope = name
                self.labels[name] = len(self.instructions)
            else:
                self.instructions.append((scope, line))

    def execute(self, label):
        pc, value = self.labels[label], False
        for _ in range(100):
            scope, line = self.instructions[pc]
            pc += 1
            cmd, _, parameters = line.partition(' ')
            args = [a.strip() for a in parameters.split(',')]
            target = lambda a: self.labels[scope + a if a.startswith('.') else a]
            if cmd == 'end':
                return
            if cmd == 'checkevent':
                value = self.flags.get(args[0], False)
            elif cmd == 'setevent':
                self.flags[args[0]] = True
            elif cmd in ('iftrue', 'iffalse'):
                if bool(value) == (cmd == 'iftrue'):
                    pc = target(args[0])
            elif cmd == 'ifequal':
                if value == args[0]:
                    pc = target(args[1])
            elif cmd == 'yesorno':
                value = self.accept
            elif cmd == 'checkmoney':
                value = 'HAVE_LESS' if self.money < int(args[1]) else 'HAVE_ENOUGH'
            elif cmd == 'takemoney':
                self.money -= int(args[1]); assert self.money >= 0
            elif cmd == 'verbosegiveitem':
                assert args == ['OLD_AMBER']
                value = self.room
                if self.room:
                    self.items += 1
            elif cmd == 'disappear':
                assert args == ['PEWTERMUSEUM1F_OLD_AMBER'] and self.items == 1
                self.visible = False
            elif cmd == 'applymovement':
                assert args == ['PLAYER', 'PewterMuseum1FStepBack']
                assert self.rom.data(args[1])[:2] == bytes((0x0c, 0x47))
                self.y += 1
            else:
                assert cmd in ('opentext', 'closetext', 'writetext', 'waitbutton',
                               'promptbutton', 'turnobject', 'playsound', 'special', 'faceplayer'), line
        raise AssertionError('script did not finish')


def main():
    city = MuseumMap('PewterCity', 20, 18, 'pewter', 'PEWTER_CITY')
    first = MuseumMap('PewterMuseum1F', 10, 4, 'museum', 'PEWTER_MUSEUM_1F')
    second = MuseumMap('PewterMuseum2F', 7, 4, 'museum', 'PEWTER_MUSEUM_2F')
    maps = {m.constant: m for m in (city, first, second)}
    # Crystal renders block 0 as the border and rejects its collision lookup.
    # Yellow's ordinary floor must use a nonzero block in the imported maps.
    metatiles = (ROOT / 'data/tilesets/museum_metatiles.bin').read_bytes()
    assert metatiles[0x7f * 16:0x80 * 16] == metatiles[:16], 'remapped floor artwork changed'
    for current in (first, second):
        assert 0 not in current.blocks, 'Yellow floor block 0 becomes black impassable padding'
        assert 0x7f in current.blocks
        assert current.collisions[0x7f] == ['FLOOR'] * 4
    assert first.collision((7, 7)) == second.collision((7, 7)) == 'LADDER'
    for current in (first, second):
        for position, tail in current.warps:
            assert current.collision(position) in ('LADDER', 'WARP_CARPET_DOWN')
            destination, index = [a.strip() for a in tail.split(',')]
            target = maps[destination]
            other_position, backlink = target.warps[int(index) - 1]
            assert backlink.split(',')[0] == current.constant
            if target == city:
                assert city.collision(other_position) == 'DOOR'
    triggers = {(9, 4), (10, 4)}
    assert (7, 7) not in first.reachable((10, 7), extra_blocked=triggers), 'unpaid gallery bypass'
    assert (7, 7) in first.reachable((10, 7)), 'paid gallery inaccessible'
    assert (15, 3) not in first.reachable((10, 7)), 'rear room bypasses Cut entrance'
    assert (15, 3) in first.reachable((16, 7)), 'Amber scientist inaccessible'
    assert (19, 5) not in city.reachable((14, 8)), 'rear entrance bypasses Cut tree'
    assert (19, 5) in city.reachable((14, 8), cut=True), 'rear entrance blocked after Cut'
    first.interactions_reachable(first.reachable((10, 7)) | first.reachable((16, 7)))
    second.interactions_reachable(second.reachable((7, 7)))
    assert len(first.objects) == len(second.objects) == 5
    assert first.objects[-1][1].endswith(AMBER)
    assert 'clearevent ' + PAID in (ROOT / 'maps/PewterCity.asm').read_text()
    assert 'clearevent ' + PAID not in SOURCE
    for stem in ('pokecrystal', 'pokecrystal_debug'):
        rom = Check(stem)
        for current in (first, second):
            compiled = rom.data(current.name + '_Blocks')[:len(current.blocks)]
            assert compiled == current.blocks and 0 not in compiled
        assert rom.data('TilesetMuseumColl')[0x7f * 4:0x80 * 4] == bytes(4)
        script = Script(rom)
        for paid, accept, money, x in product((False, True), (False, True), (0, 49, 50, 100), (9, 10)):
            script.flags = {PAID: paid}; script.accept = accept
            script.money, script.y = money, 4
            script.execute('PewterMuseum1FTicketGate')
            purchase = not paid and accept and money >= 50
            assert script.flags[PAID] == (paid or purchase)
            assert script.money == money - (50 if purchase else 0)
            assert script.y == (5 if not paid and not purchase else 4)
        for received, room in product((False, True), (False, True)):
            script.flags = {AMBER: received}; script.room = room
            script.items, script.visible = int(received), not received
            script.execute('PewterMuseum1FAmberScientist')
            assert script.items == int(received or room)
            assert script.flags[AMBER] == (received or room)
            assert script.visible == (not received and not room)
            if script.flags[AMBER]:
                script.execute('PewterMuseum1FAmberScientist')
                assert script.items == 1, 'repeat Amber gift'
        # Verify the actual compiled item record: protected, non-usable Key Item.
        item = rom.data('ItemAttributes')[(0x19 - 1) * 7:0x19 * 7]
        assert item == bytes((0, 0, 0, 0, 0xc0, 2, 0)), ('Old Amber attributes', item)
        assert rom.data('TilesetMuseumMeta')[:2048] == (ROOT / 'data/tilesets/museum_metatiles.bin').read_bytes()
        for name, size in (('Aerodactyl', 49), ('Kabutops', 36)):
            gfx = (ROOT / f'gfx/museum/{name.lower()}_fossil.2bpp').read_bytes()
            assert len(gfx) == size * 16
            assert rom.data(f'Museum{name}FossilGFX')[:size * 16] == gfx
        assert 'closepokepic' in SOURCE and 'call FarCopyWRAM' in SOURCE
        print(f'PASS {stem}: reciprocal warps, ticket gate/payment/refusal, Cut-only rear access,')
        print('      NPC/exhibit reachability, full-Bag gift retry, one-time Amber and item attributes.')


if __name__ == '__main__':
    main()
