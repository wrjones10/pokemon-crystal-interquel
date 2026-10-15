#!/usr/bin/env python3
"""Validate restored Route 3/4 geometry, events, and compiled purchase scripts.

Run after building regular and debug ROMs. No reference checkout is required.
"""
from collections import deque
from hashlib import sha256
from itertools import product
from pathlib import Path
import re
from verify_route2 import Map, ROOT


class RouteMap(Map):
    def floor(self, position, cut=False):
        return self.in_bounds(position) and (super().floor(position, cut)
                or self.collision(position).startswith('HOP_'))


MAPS = {
    'ROUTE_3': RouteMap('Route3', 35, 9, 'route_3_4', 'ROUTE_3'),
    'ROUTE_4': RouteMap('Route4', 45, 9, 'route_3_4', 'ROUTE_4'),
    'MT_MOON_POKECENTER': RouteMap('MtMoonPokecenter', 5, 4, 'pokecenter', 'MT_MOON_POKECENTER'),
    'MOUNT_MOON': RouteMap('MountMoon', 15, 9, 'cave', 'MOUNT_MOON'),
    'PEWTER_CITY': RouteMap('PewterCity', 20, 18, 'pewter', 'PEWTER_CITY'),
    'CERULEAN_CITY': RouteMap('CeruleanCity', 20, 18, 'kanto', 'CERULEAN_CITY'),
}


def connected(name, x, y):
    if name == 'ROUTE_3':
        if y == -1: return 'ROUTE_4', x - 50, 17
        if x == -1: return 'PEWTER_CITY', 39, y + 8
    elif name == 'ROUTE_4':
        if y == 18: return 'ROUTE_3', x + 50, 0
        if x == 90: return 'CERULEAN_CITY', 0, y + 10
    elif name == 'PEWTER_CITY' and x == 40:
        return 'ROUTE_3', 0, y - 8
    elif name == 'CERULEAN_CITY' and x == -1:
        return 'ROUTE_4', 89, y - 10
    return name, x, y


def reachable(start, use_cave=True, surf=False):
    seen, queue = {start}, deque([start])
    while queue:
        name, x, y = queue.popleft()
        current = MAPS[name]
        candidates = []
        for dx, dy, direction in [(0,-1,'UP'), (0,1,'DOWN'), (-1,0,'LEFT'), (1,0,'RIGHT')]:
            step = 2 if current.collision((x,y)).startswith('HOP_') and direction in current.collision((x,y)).split('_')[1:] else 1
            candidates.append(connected(name, x + dx * step, y + dy * step))
        for position, tail in current.warps:
            if position != (x,y): continue
            destination, index = tail.split(', ')
            if destination not in MAPS or (not use_cave and destination == 'MOUNT_MOON'): continue
            target = MAPS[destination]
            candidates.append((destination, *target.warps[int(index)-1][0]))
        for candidate in candidates:
            target, tx, ty = candidate
            m = MAPS[target]
            if not m.in_bounds((tx,ty)): continue
            if not (m.floor((tx,ty)) or (surf and m.collision((tx,ty))=='WATER')) or (tx,ty) in {p for p,_ in m.objects}: continue
            if candidate not in seen:
                seen.add(candidate);queue.append(candidate)
    return seen


def source_checks():
    route3, route4, center = [MAPS[n] for n in ('ROUTE_3','ROUTE_4','MT_MOON_POKECENTER')]
    # Original Yellow map bytes: retain the full geometry, not just connectivity.
    expected_hashes = {
        'Route3': '189694e837f01c7d22e06253ed49302ff666a744bd173119e4c01b5b2c781038',
        'Route4': '5a371bac8feaad260ba4d6e8891a7c82294ecef1a05f88cb702f9528b00777e3',
    }
    for name, expected in expected_hashes.items():
        assert sha256((ROOT/f'maps/{name}.blk').read_bytes()).hexdigest() == expected
    assert [p for p,_ in route3.objects] == [(57,11),(10,6),(14,4),(16,9),(19,5),(23,4),(22,9),(24,6),(33,10)]
    assert [p for p,_ in route4.objects] == [(9,8),(63,3),(57,3)]
    assert [p for p,_ in center.objects] == [(3,1),(2,3),(6,3),(5,6),(7,2),(9,3),(4,1)]
    for m in (route3, route4):
        assert 1 + len(m.objects) <= 13
        assert all(m.floor(p) for p,_ in m.objects)
    assert center.blocks == (ROOT/'maps/Pokecenter1F.blk').read_bytes()
    assert center.floor((9,3))
    assert any(center.collision((x,y)) == 'PC' for x in range(10) for y in range(8))
    assert center.collision((0,7)) == 'LADDER'
    assert center.warps[2] == ((0,7),'POKECENTER_2F, 1')
    for m in (route4, center):
        for p,tail in m.warps:
            assert m.collision(p) in ('DOOR','CAVE','WARP_CARPET_DOWN','LADDER')
            dest,index=tail.split(', ')
            if dest not in MAPS: continue
            target=MAPS[dest]
            assert target.warps[int(index)-1][1].split(', ')[0] == m.constant
    west = reachable(('ROUTE_3',0,8), use_cave=False)
    assert ('ROUTE_4',11,5) in west and ('ROUTE_4',18,5) in west
    assert ('ROUTE_4',24,5) not in west, 'outdoor shortcut bypasses Mt. Moon'
    all_reached = reachable(('ROUTE_3',0,8))
    # Yellow's level-31 Lass is on the upper bank, reached later from Cerulean's water.
    late_reached = reachable(('CERULEAN_CITY',0,14), surf=True) | all_reached
    assert ('ROUTE_4',24,5) in all_reached and ('CERULEAN_CITY',0,20) in all_reached
    assert ('PEWTER_CITY',39,17) in reachable(('MT_MOON_POKECENTER',3,7))
    for m in (route3, route4, center):
        for p,tail in m.objects + m.background:
            if 'MtMoonPokecenterClipboard,' in tail: continue # Yellow's blank clipboard
            x,y=p
            approaches=[(m.constant,x+dx,y+dy) for dx,dy in ((0,1),(0,-1),(-1,0),(1,0))]
            approaches += [(m.constant,x+2*dx,y+2*dy) for dx,dy in ((0,1),(0,-1),(-1,0),(1,0)) if m.in_bounds((x+dx,y+dy)) and m.collision((x+dx,y+dy))=='COUNTER']
            assert any(a in (late_reached if tail.endswith('Route4YellowLass, -1') else all_reached) for a in approaches), (m.name,'unreachable interaction',p)
    # Crystal trainer sight does not check walls. Every target tile in each ray must have a clear approach.
    for m in (route3, route4):
        for (x,y),tail in m.objects:
            fields=tail.split(', ')
            if fields[7] != 'OBJECTTYPE_TRAINER': continue
            direction=fields[1].removeprefix('SPRITEMOVEDATA_STANDING_')
            dx,dy={'UP':(0,-1),'DOWN':(0,1),'LEFT':(-1,0),'RIGHT':(1,0)}[direction]
            clear=True
            for n in range(1,int(fields[8])+1):
                p=(x+dx*n,y+dy*n)
                if m.floor(p): assert clear,(m.name,'sight through wall',(x,y),p)
                else: clear=False
    attributes=(ROOT/'data/maps/attributes.asm').read_text()
    for line in ('connection north, Route4, ROUTE_4, 25', 'connection south, Route3, ROUTE_3, -25',
                 'connection west, PewterCity, PEWTER_CITY, -4', 'connection east, Route3, ROUTE_3, 4',
                 'connection east, CeruleanCity, CERULEAN_CITY, -5', 'connection west, Route4, ROUTE_4, 5'):
        assert line in attributes
    for n in ('Route3','Route4'):
        assert f'callback MAPCALLBACK_OBJECTS, {n}RefreshSprites' in (ROOT/f'maps/{n}.asm').read_text()
    assert 'spawn ROUTE_4,                    11,  6' in (ROOT/'data/maps/spawn_points.asm').read_text()
    assert not MAPS['MOUNT_MOON'].objects
    print('Source geometry, connections, warps, NPC interactions and trainer sight passed')


def compiled_checks(stem):
    rom=(ROOT/f'{stem}.gbc').read_bytes()
    symbols={l.split()[1]:tuple(int(x,16) for x in l.split()[0].split(':')) for l in (ROOT/f'{stem}.sym').read_text().splitlines() if len(l.split())==2}
    def data(label):
        b,a=symbols[label];return rom[b*0x4000+a%0x4000:]
    for name in ('Route3','Route4','MtMoonPokecenter'):
        m=next(m for m in MAPS.values() if m.name==name)
        assert data(name+'_Blocks')[:len(m.blocks)]==m.blocks
        attrs=data(name+'_MapAttributes')
        assert tuple(attrs[1:3])==(m.height//2,m.width//2)
        assert tuple(attrs[3:6])==(symbols[name+'_Blocks'][0],symbols[name+'_Blocks'][1]&255,symbols[name+'_Blocks'][1]>>8)
        assert attrs[6]==symbols[name+'_MapScripts'][0]==symbols[name+'_MapEvents'][0]
    parties={
        'YellowRoute3BugCatcher1Party': [(10,10),(10,13),(10,10)],
        'YellowRoute3BugCatcher2Party': [(9,13),(9,14),(9,10),(9,11)],
        'YellowRoute3BugCatcher3Party': [(11,10),(11,11)],
        'YellowRoute3Youngster1Party': [(11,19),(11,23)],
        'YellowRoute3Youngster2Party': [(14,21)],
        'YellowRoute3Lass1Party': [(9,16),(9,16)],
        'YellowRoute3Lass2Party': [(10,19),(10,32)],
        'YellowRoute3Lass3Party': [(14,39)],
        'YellowRoute4LassParty': [(31,46),(31,46),(31,47)],
    }
    for label,party in parties.items():
        record=data(label)
        assert record[:5]==bytes([0xe6,0xe6,0xe6,0x50,0]) # "???@", TRAINERTYPE_NORMAL
        expected=bytes(v for pair in party for v in pair)+b'\xff'
        assert record[5:5+len(expected)]==expected,(stem,label)
    assert data('TilesetRoute34Meta')[:2048] == (ROOT/'data/tilesets/route_3_4_metatiles.bin').read_bytes()
    # Follow each actual map trainer's class/party IDs through TrainerGroups.
    trainer_labels=['YellowRoute3BugCatcher1Party','YellowRoute3Youngster1Party','YellowRoute3Lass1Party',
                    'YellowRoute3BugCatcher2Party','YellowRoute3Lass2Party','YellowRoute3Youngster2Party',
                    'YellowRoute3BugCatcher3Party','YellowRoute3Lass3Party']
    for name in ('Route3','Route4'):
        source=(ROOT/f'maps/{name}.asm').read_text()
        for match in re.finditer(r'^(\w+):\n\ttrainer ',source,re.M):
            label=match[1];record=data(label);cls,party_id=record[2:4]
            group_ptr=int.from_bytes(data('TrainerGroups')[(cls-1)*2:cls*2],'little')
            group_bank=symbols['TrainerGroups'][0]
            cursor=group_bank*0x4000+group_ptr%0x4000
            for _ in range(party_id-1):
                cursor=rom.index(0x50,cursor)+1
                cursor=rom.index(0xff,cursor)+1
            expected_record=rom[cursor:cursor+32]
            assert expected_record[:5]==bytes([0xe6,0xe6,0xe6,0x50,0])
            party_label=trainer_labels[int(label[-1])-1] if name=='Route3' else 'YellowRoute4LassParty'
            size=5+len(parties[party_label])*2+1
            assert expected_record[:size]==data(party_label)[:size], (stem,label,'incorrect party ID')
    # Execute the compiled salesman script. GivePoke returns 0=party, 1=box, 2=failure.
    bank,start=symbols['MtMoonPokecenterMagikarpSalesman'];mem=rom[bank*0x4000:(bank+1)*0x4000]
    flag=None;cases=0
    for bought,yes,money,gift_result in product((False,True),(False,True),(0,499,500,1000),(0,1,2)):
        pc=start%0x4000;value=0;initial=money;events=set();gifts=0;charged=0
        for _ in range(80):
            op=mem[pc];pc+=1
            if op==0x31:
                flag=int.from_bytes(mem[pc:pc+2],'little');pc+=2;value=bought
                if bought:events.add(flag)
            elif op in (0x08,0x09):
                dest=int.from_bytes(mem[pc:pc+2],'little');pc+=2
                if bool(value)==(op==0x09):pc=dest%0x4000
            elif op==0x06:
                match=mem[pc];dest=int.from_bytes(mem[pc+1:pc+3],'little');pc+=3
                if value==match:pc=dest%0x4000
            elif op==0x03:pc=int.from_bytes(mem[pc:pc+2],'little')%0x4000
            elif op==0x4c:pc+=2
            elif op==0x0f:pc+=2 # special
            elif op==0x4e:value=yes
            elif op in (0x23,0x24):
                who=mem[pc];amount=int.from_bytes(mem[pc+1:pc+4],'big');pc+=4
                assert who==0 and amount==500
                if op==0x24:value=2 if money<amount else 1 if money==amount else 0
                else:money-=amount;charged+=1
            elif op==0x2d:
                assert mem[pc:pc+4]==bytes([129,5,0,0]);pc+=4;value=gift_result
                gifts+=gift_result!=2
            elif op==0x33:events.add(int.from_bytes(mem[pc:pc+2],'little'));pc+=2
            elif op==0x91:break
            elif op in (0x47,0x49,0x54,0x6b):pass
            else:raise AssertionError((stem,'unknown script opcode',hex(op)))
        else:raise AssertionError('purchase script did not end')
        success=not bought and yes and initial>=500 and gift_result!=2
        assert money==initial-(500 if success else 0)
        assert gifts==charged==int(success)
        assert (flag in events)==(bought or success)
        cases+=1
    # Execute the compiled conditional refresh wrappers. Check all entry modes,
    # both outdoor lists, and markers at every possible list position.
    for label,current_group,other_group in [('Route3CheckSpriteGroup','PalletGroupSprites','CeruleanGroupSprites'),
                                            ('Route4CheckSpriteGroup','CeruleanGroupSprites','PalletGroupSprites')]:
        # Use the actual immediate sprite ID, avoiding assumptions about sprite numbering.
        marker=data(label)[1]
        assert marker in data(current_group)[:24] and marker not in data(other_group)[:24]
        code_bank,start=symbols[label]
        for entry,slot in product(range(0xf1,0xfd),range(-1,32)):
            memory=bytearray(65536)
            memory[:0x4000]=rom[:0x4000]
            memory[0x4000:0x8000]=rom[code_bank*0x4000:(code_bank+1)*0x4000]
            memory[symbols['hMapEntryMethod'][1]]=entry
            used=symbols['wUsedSprites'][1]
            if slot>=0:memory[used+slot*2]=marker
            previous=bytes(memory[used:used+64])
            pc=start;a=b=c=hl=0;z=False
            for _ in range(250):
                op=memory[pc];pc+=1
                if op==0x0e:c=memory[pc];pc+=1
                elif op==0xc3:pc=int.from_bytes(memory[pc:pc+2],'little')
                elif op==0xf0:a=memory[0xff00+memory[pc]];pc+=1
                elif op==0xfe:z=a==memory[pc];pc+=1
                elif op in (0x20,0x28):
                    n=memory[pc];pc+=1
                    if z==(op==0x28):pc+=n if n<128 else n-256
                elif op==0x21:hl=int.from_bytes(memory[pc:pc+2],'little');pc+=2
                elif op==0x06:b=memory[pc];pc+=1
                elif op==0x2a:a=memory[hl];hl+=1
                elif op==0xb9:z=a==c
                elif op==0x23:hl+=1
                elif op==0x05:b=(b-1)&255;z=b==0
                elif op==0x3e:a=memory[pc];pc+=1
                elif op==0xaf:a=0;z=True
                elif op==0xea:memory[int.from_bytes(memory[pc:pc+2],'little')]=a;pc+=2
                elif op==0xc9:break
                else:raise AssertionError(('refresh selector opcode',hex(op)))
            else:raise AssertionError('refresh selector loop')
            assert memory[symbols['wScriptVar'][1]]==int(entry==0xf7 and slot<0)
            assert bytes(memory[used:used+64])==previous
    # Both legacy Mt. Moon scene IDs must resolve to the same immediate end.
    moon=data('MountMoon_MapScripts')
    noop=symbols['MountMoonNoopScene'][1].to_bytes(2,'little')
    assert moon[:10]==bytes([2])+noop+bytes(2)+noop+bytes(2)+bytes([0])
    assert data('MountMoonNoopScene')[0]==0x91
    assert data('SpriteMons')[35]==113 # appended Chansey; previous sprite IDs retained
    print(f'{stem}: compiled map metadata, nine parties, {cases} salesman outcomes and 792 conditional-refresh cases passed')


if __name__=='__main__':
    source_checks()
    for stem in ('pokecrystal','pokecrystal_debug'):compiled_checks(stem)
