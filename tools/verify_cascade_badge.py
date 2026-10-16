#!/usr/bin/env python3
"""Execute the compiled Cut badge gates and traded-Pokemon obedience selector."""
from itertools import product
import re
from verify_route2 import ROOT
from verify_route22_rival import Check


def verify(stem):
    rom=Check(stem)
    names=re.findall(r'^\s*const (ENGINE_\w+)',(ROOT/'constants/engine_flags.asm').read_text(),re.M)
    cascade,hive=[names.index(n) for n in ('ENGINE_CASCADEBADGE','ENGINE_HIVEBADGE')]
    # Mock only unrelated engine calls; execute both actual Cut entry paths.
    for label in ('CutFunction.CheckAble','TryCutOW'):
        bank,start=rom.symbols[label];memory=bytearray(65536)
        memory[:0x4000]=rom.rom[:0x4000]
        memory[0x4000:0x8000]=rom.rom[bank*0x4000:(bank+1)*0x4000]
        for has_cascade,has_hive,has_move in product((False,True),repeat=3):
            flags=({cascade} if has_cascade else set())|({hive} if has_hive else set())
            pc=start;a=d=e=hl=0;carry=False;allowed=False
            for _ in range(35):
                op=memory[pc];pc+=1
                if op==0x11:e=memory[pc];d=memory[pc+1];pc+=2
                elif op==0x16:d=memory[pc];pc+=1
                elif op==0xcd:
                    target=int.from_bytes(memory[pc:pc+2],'little');pc+=2
                    if target in (rom.symbols['CheckEngineFlag'][1],rom.symbols['CheckBadge'][1]):
                        carry=((d<<8)|e) not in flags
                    elif target==rom.symbols['CheckPartyMove'][1]:carry=not has_move
                    elif target==rom.symbols['CheckMapForSomethingToCut'][1]:allowed=True;break
                    elif target==rom.symbols['CallScript'][1]:allowed=hl==rom.symbols['AskCutScript'][1];break
                    else:raise AssertionError(('unknown Cut call',hex(target)))
                elif op in (0x30,0x38):
                    n=memory[pc];pc+=1
                    if carry==(op==0x38):pc+=n if n<128 else n-256
                elif op==0x3e:a=memory[pc];pc+=1
                elif op==0x21:hl=int.from_bytes(memory[pc:pc+2],'little');pc+=2
                elif op==0xc9:break
                else:raise AssertionError(('unknown Cut opcode',hex(op)))
            else:raise AssertionError('Cut loop')
            expected=(has_cascade or has_hive) and (has_move or label=='CutFunction.CheckAble')
            assert allowed==expected,(label,has_cascade,has_hive,has_move)
    bank,start=rom.symbols['BattleCommand_CheckObedience.obeylevel']
    _,end=rom.symbols['BattleCommand_CheckObedience.getlevel']
    memory=bytearray(65536)
    memory[0x4000:0x8000]=rom.rom[bank*0x4000:(bank+1)*0x4000]
    johto_addr=rom.symbols['wJohtoBadges'][1];kanto_addr=rom.symbols['wKantoBadges'][1]
    for johto,kanto in product(range(256),repeat=2):
        memory[johto_addr]=johto;memory[kanto_addr]=kanto
        pc=start;a=hl=0;zero=False
        for _ in range(25):
            if pc==end:break
            op=memory[pc];pc+=1
            if op==0x21:hl=int.from_bytes(memory[pc:pc+2],'little');pc+=2
            elif op==0xcb:
                sub=memory[pc];pc+=1;assert sub&0xc7==0x46
                zero=not bool(memory[hl]&(1<<((sub-0x46)//8)))
            elif op==0x3e:a=memory[pc];pc+=1
            elif op==0x20:
                n=memory[pc];pc+=1
                if not zero:pc+=n if n<128 else n-256
            else:raise AssertionError(('obedience opcode',hex(op)))
        else:raise AssertionError('obedience loop')
        expected=101 if johto&128 else 70 if johto&32 else 50 if johto&8 else 30 if (johto&2 or kanto&2) else 10
        assert a==expected,(johto,kanto,a,expected)
    print(f'{stem}: both Cut gates and all 65,536 badge combinations for obedience passed')


if __name__=='__main__':
    for stem in ('pokecrystal','pokecrystal_debug'):verify(stem)
