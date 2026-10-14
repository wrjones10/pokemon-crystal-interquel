#!/usr/bin/env python3
"""Check the optional Route 22 battle after building normal and debug ROMs."""
from itertools import product
from pathlib import Path
import re
from verify_route2 import Map, ROOT

SOURCE = (ROOT / 'maps/Route22.asm').read_text()
DONE = 'EVENT_BATTLED_ROUTE_22_RIVAL'
LAB = 'EVENT_BATTLED_RIVAL_IN_OAKS_LAB'
BADGE = 'ENGINE_BOULDERBADGE'
HIDDEN = 'EVENT_ROUTE_22_RIVAL_HIDDEN'
RIVAL = 'ROUTE22_RIVAL'
STARTERS = ('BULBASAUR', 'CHARMANDER', 'SQUIRTLE')


class Check:
    def __init__(self, stem):
        self.route = Map('Route22', 20, 9, 'kanto', 'ROUTE_22')
        self.rom = (ROOT / f'{stem}.gbc').read_bytes()
        self.symbols = {line.split()[1]: tuple(int(x, 16) for x in line.split()[0].split(':'))
                        for line in (ROOT / f'{stem}.sym').read_text().splitlines()
                        if len(line.split()) == 2}
        self.labels, self.instructions, scope = {}, [], ''
        for line in SOURCE.splitlines():
            line = line.split(';')[0].strip()
            if not line:
                continue
            if line.endswith(':'):
                label = line[:-1]
                if label.startswith('.'):
                    label = scope + label
                else:
                    scope = label
                self.labels[label] = len(self.instructions)
            else:
                self.instructions.append((scope, line))

    def data(self, label):
        bank, address = self.symbols[label]
        return self.rom[bank * 0x4000 + address % 0x4000:]

    def default_tiles(self, player=1):
        # Reproduce SortUsedSprites and ArrangeUsedSprites from compiled metadata.
        sprites = [player] + list(self.data('PalletGroupSprites')[:24])
        metadata = self.data('OverworldSprites')
        entries = [(sprite, metadata[(sprite - 1) * 6 + 4]) for sprite in sprites]
        for i in range(len(entries) - 1):
            for j in range(len(entries) - 1, i, -1):
                if entries[j][1] < entries[i][1]:
                    entries[i], entries[j] = entries[j], entries[i]
        tiles, cursor = {}, 0
        for sprite, kind in entries:
            length = 4 if kind == 3 else 12
            if cursor < 0x80 and cursor + length > 0x80:
                cursor = 0x80
            assert cursor + length <= 0x100
            tiles[sprite] = cursor
            cursor += length
        return tiles

    def refresh_graphics(self):
        self.tiles = self.default_tiles()
        self.execute('Route22RivalSpriteCallback')

    def walking_slot(self, tiles):
        # Execute the actual compiled slot-swap assembly, including stack/flags.
        bank, pc = self.symbols['Route22UseOakWalkingSlot']
        memory = bytearray(0x10000)
        memory[0x4000:0x8000] = self.rom[bank * 0x4000:(bank + 1) * 0x4000]
        base = self.symbols['wUsedSprites'][1]
        for i, (sprite, tile) in enumerate(tiles.items()):
            memory[base + i * 2:base + i * 2 + 2] = bytes((sprite, tile))
        a = b = c = d = h = l = 0
        zero = carry = False
        stack = []
        def word(at):
            return memory[at] | (memory[at + 1] << 8)
        for _ in range(1000):
            opcode = memory[pc]
            pc += 1
            hl, bc = h * 256 + l, b * 256 + c
            if opcode == 0x3e:  # ld a, immediate
                a = memory[pc]; pc += 1
            elif opcode == 0x06:
                b = memory[pc]; pc += 1
            elif opcode == 0x21:
                h, l = memory[pc + 1], memory[pc]; pc += 2
            elif opcode == 0xcd:
                stack.append(pc + 2); pc = word(pc)
            elif opcode in (0xc9, 0xd8, 0xc8):
                condition = opcode == 0xc9 or (opcode == 0xd8 and carry) or (opcode == 0xc8 and zero)
                if condition:
                    if not stack:
                        result = {memory[base + i * 2]: memory[base + i * 2 + 1]
                                  for i in range(len(tiles))}
                        return result
                    pc = stack.pop()
            elif opcode == 0xcb:
                assert memory[pc] == 0x7e  # bit 7, [hl]
                pc += 1; zero = not (memory[hl] & 0x80)
            elif opcode == 0xe5:
                stack.append(hl)
            elif opcode == 0xe1:
                value = stack.pop(); h, l = value >> 8, value & 255
            elif opcode == 0xc1:
                value = stack.pop(); b, c = value >> 8, value & 255
            elif opcode in (0x38, 0x20, 0x28):
                offset = memory[pc]; pc += 1
                condition = carry if opcode == 0x38 else (not zero if opcode == 0x20 else zero)
                if condition:
                    pc += offset if offset < 128 else offset - 256
            elif opcode == 0x56:
                d = memory[hl]
            elif opcode == 0x0a:
                a = memory[bc]
            elif opcode == 0x77:
                memory[hl] = a
            elif opcode == 0x7a:
                a = d
            elif opcode == 0x02:
                memory[bc] = a
            elif opcode == 0xbe:
                zero, carry = a == memory[hl], a < memory[hl]
            elif opcode == 0x23:
                value = (hl + 1) & 65535; h, l = value >> 8, value & 255
            elif opcode == 0x05:
                b = (b - 1) & 255; zero = b == 0
            elif opcode == 0x37:
                carry = True
            elif opcode == 0xa7:
                zero, carry = a == 0, False
            else:
                raise AssertionError(('unhandled assembly opcode', hex(opcode)))
        raise AssertionError('walking-slot routine did not return')

    def move(self, label):
        for opcode in self.data(label)[:100]:
            if opcode == 0x47:  # step_end
                return
            assert 0x0c <= opcode <= 0x0f, (label, 'must use animated walking movement', opcode)
            dx, dy = ((0, 1), (0, -1), (-1, 0), (1, 0))[opcode & 3]
            x, y = self.rival
            self.rival = (x + dx, y + dy)
            assert self.route.floor(self.rival), (label, 'blocked tile', self.rival)
            assert self.rival != self.player, (label, 'walked through player')
        raise AssertionError('unterminated movement')

    def execute(self, label):
        pc, value = self.labels[label], False
        for _ in range(200):
            scope, line = self.instructions[pc]
            pc += 1
            command, _, parameters = line.partition(' ')
            args = [x.strip() for x in parameters.split(',')]
            target = lambda name: self.labels[scope + name if name.startswith('.') else name]
            if command in ('end', 'endcallback'):
                return
            if command in ('checkflag', 'checkevent'):
                value = self.flags.get(args[0], False)
            elif command == 'setevent':
                self.flags[args[0]] = True
            elif command == 'iftrue':
                if value:
                    pc = target(args[0])
            elif command == 'iffalse':
                if not value:
                    pc = target(args[0])
            elif command == 'ifequal':
                if value == int(args[0]):
                    pc = target(args[1])
            elif command == 'sjump':
                pc = target(args[0])
            elif command == 'readvar':
                assert args == ['VAR_YCOORD']
                value = self.player[1]
            elif command == 'moveobject':
                assert not self.visible
                self.rival = tuple(map(int, args[1:]))
            elif command in ('appear', 'disappear'):
                assert args == [RIVAL]
                if command == 'appear':
                    assert self.active_objects == 0, 'appear duplicates an existing live object'
                    self.active_objects += 1
                    self.rival_tile = self.tiles[7]
                else:
                    self.active_objects = 0
                self.visible = command == 'appear'
                self.flags[HIDDEN] = not self.visible
            elif command == 'applymovement':
                assert args[0] == RIVAL and self.visible
                self.move(args[1])
            elif command == 'special' and args == ['RefreshSprites']:
                self.refresh_graphics()
            elif command == 'callasm':
                assert args == ['Route22UseOakWalkingSlot']
                self.tiles = self.walking_slot(self.tiles)
            elif command == 'turnobject':
                self.facing[args[0]] = args[1]
            elif command == 'loadtrainer':
                assert args[0] == 'PALLET_RIVAL'
                self.party = args[1]
            elif command == 'startbattle':
                assert not self.flags[DONE], 'encounter must remain available until a win'
                assert self.active_objects == 1 and self.rival_tile < 0x80
                delta = (self.player[0] - self.rival[0], self.player[1] - self.rival[1])
                expected = {(0, -1): ('UP', 'DOWN'), (1, 0): ('RIGHT', 'LEFT')}
                assert (self.facing[RIVAL], self.facing['PLAYER']) == expected[delta]
                self.battles += 1
            elif command == 'reloadmapafterbattle':
                if self.lose:
                    self.blacked_out = True
                    return
                self.refresh_graphics()
                assert self.rival_tile == self.tiles[7], 'battle reload changed the live rival slot'
            else:
                assert command in ('showemote', 'playmusic', 'opentext', 'writetext',
                                   'waitbutton', 'closetext', 'winlosstext', 'setlasttalked', 'special'), line
        raise AssertionError('script did not end')

    def run(self):
        assert self.route.objects[0][1].endswith(HIDDEN), 'visibility needs a persistent event flag'
        assert 'callback MAPCALLBACK_SPRITES, Route22RivalSpriteCallback' in SOURCE
        for player in (1, 2, 0x60, 0x61, 0x67, 0x68, 0x34):
            tiles = self.default_tiles(player)
            before = dict(tiles)
            after = self.walking_slot(tiles)
            assert after[7] < 0x80 and after[5] == before[7]
            assert all(after[key] == value for key, value in before.items() if key not in (5, 7))
            assert self.walking_slot(after) == after, 'callback must be safe to repeat'
            for missing in (5, 7):
                incomplete = {key: value for key, value in before.items() if key != missing}
                assert self.walking_slot(incomplete) == incomplete, 'missing sprite must not corrupt slots'
            # Guard early-game Oak's walking slot until the lab sequence is done.
            self.flags = {LAB: False}
            self.tiles = before
            self.execute('Route22RivalSpriteCallback')
            assert self.tiles == before
        triggers = re.findall(r'coord_event\s+(\d+),\s*(\d+), -1, Route22RivalBattle', SOURCE)
        assert set(triggers) == {('29', '4'), ('29', '5')}
        for badge, done, lab, starter, y, lose in product(
                (False, True), (False, True), (False, True), STARTERS, (4, 5), (False, True)):
            self.flags = {BADGE: badge, DONE: done, LAB: lab,
                          f'EVENT_GOT_{starter}_FROM_OAK': True}
            self.player, self.rival = (29, y), (25, 5)
            self.visible, self.battles, self.blacked_out = False, 0, False
            self.active_objects = 0
            self.facing, self.lose = {}, lose
            self.refresh_graphics()
            self.execute('Route22HideRivalCallback')
            # LoadMapObjects calls LoadObjectMasks AFTER the callback. It rebuilds
            # visibility from the event flag, discarding the callback's mask.
            self.visible = not self.flags.get(HIDDEN, False)
            self.active_objects = int(self.visible)
            assert not self.visible and self.active_objects == 0
            self.execute('Route22RivalBattle')
            eligible = lab and not badge and not done
            assert self.battles == int(eligible)
            assert self.flags[BADGE] == badge and self.flags[LAB] == lab
            assert self.flags[DONE] == (done or (eligible and not lose))
            assert self.blacked_out == (eligible and lose)
            if eligible:
                rival_starter = STARTERS[(STARTERS.index(starter) + 1) % 3]
                assert self.party == f'PALLET_RIVAL_ROUTE22_{rival_starter}'
                if not lose:
                    assert self.rival == (31, 10) and not self.visible
                else:
                    # Earning the badge after a loss must still expire the encounter.
                    self.flags[BADGE] = True
                    self.execute('Route22HideRivalCallback')
                    self.execute('Route22RivalBattle')
                    assert self.battles == 1 and not self.flags[DONE]
                    # Without the badge, return after blackout and win the retry.
                    self.flags[BADGE] = False
                    self.lose, self.blacked_out = False, False
                    self.execute('Route22HideRivalCallback')
                    self.execute('Route22RivalBattle')
                    assert self.battles == 2 and self.flags[DONE]
                    assert self.rival == (31, 10) and not self.visible
                self.execute('Route22HideRivalCallback')
                self.execute('Route22RivalBattle')
                assert self.battles == (2 if lose else 1), 'encounter repeated after victory'
            else:
                assert not self.visible and self.player == (29, y)
        # Check actual compiled trainer entries, including held-item fields.
        data = self.data('PalletRivalGroup')
        for index in range(6):
            name_end = data.index(0x50)  # @
            assert data[name_end + 1] == 2  # TRAINERTYPE_ITEM
            data = data[name_end + 2:]
            end = data.index(0xff)
            party, data = data[:end], data[end + 1:]
            starter = (1, 4, 7)[index % 3]
            expected = bytes((5, starter, 0)) if index < 3 else bytes((9, 16, 0, 8, starter, 0))
            assert party == expected, ('incorrect rival party', index, party)


def main():
    for stem in ('pokecrystal', 'pokecrystal_debug'):
        Check(stem).run()
        print(f'PASS {stem}: 96 eligibility/outcome/approach cases, loss retries, badge expiry,')
        print('      victory prevents repeats,')
        print('      persistent visibility, single live object, compiled walking-slot routine,')
        print('      animated movements, collision, facing, and all six rival parties.')


if __name__ == '__main__':
    main()
