#!/usr/bin/env python3
"""Execute the compiled rival AI selector for every class and party ID."""
from pathlib import Path
from verify_route2 import ROOT
from verify_route22_rival import Check


def verify(stem):
    rom = Check(stem)
    bank, start = rom.symbols['GetTrainerAIMoveWeights']
    attr_bank, attributes = rom.symbols['TrainerClassAttributes']
    table_bank, table = rom.symbols['PalletRivalAIMoveWeights']
    assert bank == attr_bank == table_bank, 'AI bitfields must be in the attributes bank'
    memory = bytearray(65536)
    memory[:0x4000] = rom.rom[:0x4000]
    memory[0x4000:0x8000] = rom.rom[bank * 0x4000:(bank + 1) * 0x4000]
    # These are the six current PALLET_RIVAL party IDs, not trainer class IDs.
    overrides = {}
    offset = table
    while memory[offset]:
        party = memory[offset]
        assert party not in overrides, 'duplicate party AI entry'
        overrides[party] = memory[offset + 1] | (memory[offset + 2] << 8)
        offset += 3
    assert overrides == {1: 1, 2: 1, 3: 1, 4: 3, 5: 3, 6: 3}
    inputs = [rom.symbols[name][1] for name in
              ('wTrainerClass', 'wOtherTrainerID', 'wInBattleTowerBattle')]

    def run(trainer, party, tower):
        for address, value in zip(inputs, (trainer, party, tower)):
            memory[address] = value
        pc, hl, bc, a = start, 0, 0, 0
        zero, stack = False, []
        for _ in range(1000):
            op = memory[pc]
            pc += 1
            if op == 0x21:  # ld hl, immediate
                hl = memory[pc] | (memory[pc + 1] << 8); pc += 2
            elif op == 0x01:  # ld bc, immediate
                bc = memory[pc] | (memory[pc + 1] << 8); pc += 2
            elif op == 0xfa:  # ld a, [address]
                address = memory[pc] | (memory[pc + 1] << 8)
                pc += 2; a = memory[address]
            elif op == 0xcb:
                assert memory[pc] == 0x47  # bit 0, a
                pc += 1; zero = not (a & 1)
            elif op in (0xc9, 0xc0, 0xc8):
                condition = op == 0xc9 or (op == 0xc0 and not zero) or (op == 0xc8 and zero)
                if condition:
                    if stack:
                        pc = stack.pop()
                    else:
                        return hl
            elif op == 0xfe:  # cp immediate
                zero = a == memory[pc]; pc += 1
            elif op in (0x18, 0x20, 0x28):
                offset = memory[pc]; pc += 1
                if op == 0x18 or (op == 0x20 and not zero) or (op == 0x28 and zero):
                    pc += offset if offset < 128 else offset - 256
            elif op == 0x47:  # ld b, a
                bc = (a << 8) | (bc & 255)
            elif op == 0x2a:  # ld a, [hli]
                a = memory[hl]; hl += 1
            elif op == 0xa7:
                zero = a == 0
            elif op == 0xb8:  # cp b
                zero = a == (bc >> 8)
            elif op == 0x23:
                hl = (hl + 1) & 65535
            elif op == 0x3d:
                a = (a - 1) & 255; zero = a == 0
            elif op == 0xcd:
                target = memory[pc] | (memory[pc + 1] << 8)
                assert target == rom.symbols['AddNTimes'][1]
                stack.append(pc + 2); pc = target
            elif op == 0x09:  # add hl, bc (does not change zero)
                hl = (hl + bc) & 65535
            else:
                raise AssertionError(('unhandled compiled opcode', hex(op)))
        raise AssertionError('AI selector did not return')

    count = 0
    for trainer in range(1, 69):
        for party in range(256):
            for tower in (0, 1, 2, 3):
                pointer = run(trainer, party, tower)
                expected = attributes + 3 + (0 if tower & 1 else (trainer - 1) * 7)
                if not tower & 1 and trainer == 0x44 and party in overrides:
                    expected = table + (party - 1) * 3 + 1
                    assert memory[pointer] | (memory[pointer + 1] << 8) == overrides[party]
                assert pointer == expected, (trainer, party, tower, hex(pointer), hex(expected))
                count += 1
    print(f'PASS {stem}: {count} compiled selector cases; lab BASIC, Route 22 BASIC|SETUP,')
    print('      unlisted-party fallback, all other trainer classes and Battle Tower preserved.')


def main():
    for stem in ('pokecrystal', 'pokecrystal_debug'):
        verify(stem)


if __name__ == '__main__':
    main()
