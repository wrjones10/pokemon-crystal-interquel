#!/usr/bin/env python3
"""Check Cerulean availability, removed quest scenes, and replacement progression."""
from hashlib import sha256
from itertools import product
from pathlib import Path
import re
from verify_route2 import ROOT
from verify_route22_rival import Check


def source_checks():
    gym=(ROOT/'maps/CeruleanGym.asm').read_text()
    assert sha256((ROOT/'maps/CeruleanGym.blk').read_bytes()).hexdigest()=='3819b792c35d7b8bd666c41e649b133ed08d86b39250cd7a93659d89ebc2c964'
    assert 'hiddenitem MACHINE_PART' not in gym
    assert 'SPRITE_ROCKET' not in gym
    assert 'EVENT_TRAINERS_IN_CERULEAN_GYM' not in gym
    assert 'loadtrainer MISTY, MISTY1' in gym
    for trainer in ('TrainerSwimmerfDiana','TrainerSwimmerfBriana','TrainerSwimmermParker'):
        assert trainer in gym
    for name in ('Route24','Route25','PowerPlant'):
        source=(ROOT/f'maps/{name}.asm').read_text()
        assert not re.search(r'^\s*coord_event ',source,re.M)
    assert 'SPRITE_ROCKET' not in (ROOT/'maps/Route24.asm').read_text()
    route25=(ROOT/'maps/Route25.asm').read_text()
    assert 'SPRITE_MISTY' not in route25 and 'EVENT_ROUTE_25_MISTY_BOYFRIEND' not in route25
    # The replacement rematch milestone must cover all former restored-power gates.
    gates=0
    for p in (ROOT/'maps').glob('*.asm'):
        source=p.read_text()
        assert 'checkevent EVENT_RESTORED_POWER_TO_KANTO' not in source,p.name
        assert 'checkevent EVENT_RETURNED_MACHINE_PART' not in source,p.name
        if p.name.startswith('Route') or p.stem in ('NationalPark','OlivineLighthouse2F'):
            gates+=source.count('checkflag ENGINE_EARTHBADGE')
    assert gates==21,gates
    for name in ('GoldenrodMagnetTrainStation','SaffronMagnetTrainStation'):
        assert 'checkitem PASS' in (ROOT/f'maps/{name}.asm').read_text()
    assert 'checkflag ENGINE_EXPN_CARD' in (ROOT/'maps/LavRadioTower1F.asm').read_text()
    assert 'checkevent EVENT_MET_COPYCAT_FOUND_OUT_ABOUT_LOST_ITEM' in (ROOT/'maps/PokemonFanClub.asm').read_text()
    assert 'checkitem LOST_ITEM' in (ROOT/'maps/CopycatsHouse2F.asm').read_text()


def verify(stem):
    rom=Check(stem)
    def events(name):
        data=rom.data(name+'_MapEvents');p=2
        warp_count=data[p];p+=1+warp_count*5
        coord_count=data[p];p+=1+coord_count*8
        bg_count=data[p];p+=1+bg_count*5
        count=data[p];p+=1
        return coord_count,bg_count,[data[p+i*13:p+(i+1)*13] for i in range(count)]
    coord,bg,objects=events('CeruleanGym')
    assert coord==0 and bg==2 and len(objects)==5
    assert [(o[2]-4,o[1]-4) for o in objects]==[(5,3),(4,6),(1,9),(8,9),(7,13)]
    assert all(o[11:13]==b'\xff\xff' for o in objects), 'gym visibility must ignore stale quest flags'
    assert len(events('Route24')[2])==0
    assert len(events('Route25')[2])==9
    assert events('Route25')[0]==events('PowerPlant')[0]==0
    for name in ('CeruleanGym','Route25','PowerPlant'):
        script=rom.data(name+'_MapScripts');assert script[0]==2
        bank=rom.symbols[name+'_MapScripts'][0]
        for offset in (1,5):
            ptr=int.from_bytes(script[offset:offset+2],'little')
            assert rom.rom[bank*0x4000+ptr%0x4000]==0x91, (name,'old scene must be a no-op')
    common=rom.data('KantoPowerAvailableScript');p=0;actions=[]
    while common[p] in (0x32,0x33):
        actions.append((common[p],int.from_bytes(common[p+1:p+3],'little')));p+=3
    assert [op for op,_ in actions]==[0x33,0x32,0x33,0x33,0x33,0x33,0x32,0x32,0x33]
    assert len({flag for _,flag in actions})==9 and all(0<flag<2048 for _,flag in actions)
    assert common[p:p+4]==bytes([0x20,0x80,1,0x91]) # remove legacy Machine Part, return
    for bits,has_part in product(range(512),(False,True)):
        flags={flag for i,(_,flag) in enumerate(actions) if bits&(1<<i)}|{0,2047}
        bag={7:1,0x80:1} if has_part else {7:1}
        for repeat in range(2):
            for op,flag in actions:
                if op==0x33:flags.add(flag)
                else:flags.discard(flag)
            bag.pop(0x80,None)
            assert flags=={flag for op,flag in actions if op==0x33}|{0,2047}
            assert bag=={7:1}
    # All availability callbacks call the same script, including new-game setup.
    address=rom.symbols['KantoPowerAvailableScript']
    farcall=bytes([1,address[0],address[1]&255,address[1]>>8])
    for label in ('CeruleanGymAvailableCallback','PowerPlantAvailableCallback'):
        assert rom.data(label)[:5]==farcall+b'\x90'
    assert farcall in rom.data('InitializeEventsScript')[:1100]
    assert farcall in rom.data('CeruleanCityFlypointCallback')[:12]
    engine_names=re.findall(r'^\s*const (ENGINE_\w+)',(ROOT/'constants/engine_flags.asm').read_text(),re.M)
    cascade=engine_names.index('ENGINE_CASCADEBADGE')
    earth=engine_names.index('ENGINE_EARTHBADGE')
    def run(label,flags=None,owned=None,won=True,room=True,reward=0xc6):
        bank,start=rom.symbols[label];mem=rom.rom[bank*0x4000:(bank+1)*0x4000]
        pc=start%0x4000;value=0;flags=set(flags or []);owned=set(owned or []);battles=gifts=0
        for _ in range(100):
            op=mem[pc];pc+=1
            if op in (0x31,0x34):
                arg=int.from_bytes(mem[pc:pc+2],'little');pc+=2;value=arg in (owned if op==0x31 else flags)
            elif op in (0x08,0x09):
                target=int.from_bytes(mem[pc:pc+2],'little');pc+=2
                if bool(value)==(op==9):pc=target%0x4000
            elif op in (0x33,0x36):
                arg=int.from_bytes(mem[pc:pc+2],'little');pc+=2
                (owned if op==0x33 else flags).add(arg)
            elif op==0x4c:pc+=2
            elif op==0x64:pc+=4
            elif op==0x5e:pc+=2
            elif op==0x5f:
                battles+=1
                if not won:break # normal lost battle whites out; no reward continuation
            elif op==0x85:pc+=2
            elif op==0x9e:
                assert mem[pc:pc+2]==bytes([reward,1]);pc+=2;value=room;gifts+=bool(room)
            elif op==0x91:break
            elif op in (0x47,0x49,0x54,0x55,0x60,0x6b,0x86):pass
            else:raise AssertionError((label,'opcode',hex(op)))
        else:raise AssertionError('script loop')
        return flags,owned,battles,gifts
    tm_flag=int.from_bytes(rom.data('CeruleanGymMistyScript.FightDone')[1:3],'little')
    for badge,won,got,room in product((False,True),repeat=4):
        flags,owned,battles,gifts=run('CeruleanGymMistyScript',
            flags={cascade} if badge else set(),owned={tm_flag} if got else set(),
            won=won,room=room,reward=0xf4)
        eligible=badge or won
        received=eligible and not got and room
        assert battles==int(not badge)
        assert (cascade in flags)==eligible
        assert gifts==int(received)
        assert (tm_flag in owned)==(got or received)
        assert len(owned-{tm_flag})==(4 if not badge and won else 0), 'Misty plus three gym victory flags'
        if eligible:
            _,retry_owned,retry_battles,retry_gifts=run('CeruleanGymMistyScript',
                flags=flags,owned=owned,room=True,reward=0xf4)
            assert retry_battles==0 and tm_flag in retry_owned
            assert retry_gifts==int(tm_flag not in owned)
    gift=rom.data('PowerPlantManager');reward_flag=None
    for i in range(60):
        if gift[i]==0x31:reward_flag=int.from_bytes(gift[i+1:i+3],'little');break
    assert reward_flag is not None
    for got,room in product((False,True),(False,True)):
        _,owned,_,gifts=run('PowerPlantManager',owned={reward_flag} if got else set(),room=room)
        assert gifts==int(not got and room)
        assert (reward_flag in owned)==(got or room)
    # Check every compiled rematch gate actually reads Earth, not the legacy event.
    check=bytes([0x34,earth&255,earth>>8]);gate_count=0
    for p in (ROOT/'maps').glob('*.asm'):
        source=p.read_text()
        count=source.count('checkflag ENGINE_EARTHBADGE')
        if not count:continue
        # First and last map labels bound the assembled map's scripts and events.
        if p.stem.startswith('Route') or p.stem in ('NationalPark','OlivineLighthouse2F'):
            bank,start=rom.symbols[p.stem+'_MapScripts'];event_address=rom.symbols[p.stem+'_MapEvents'][1]
            code=rom.rom[bank*0x4000+start%0x4000:bank*0x4000+event_address%0x4000]
            assert code.count(check)==count,(p.name,'compiled Earth gates')
            gate_count+=count
    assert gate_count==21
    print(f'{stem}: gym visibility/scenes, 1024 legacy states, badge outcomes, TM retry and 21 Earth rematch gates passed')


if __name__=='__main__':
    source_checks()
    for stem in ('pokecrystal','pokecrystal_debug'):verify(stem)
