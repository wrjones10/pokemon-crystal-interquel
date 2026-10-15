# Route 3 and Route 4 restoration

Route 3 and Route 4 use Pokémon Yellow's original block layouts: 70×18 and
90×18 walking tiles, respectively. A dedicated blockset uses Crystal Kanto
artwork with Yellow's cliff, tree, grass, water, and ledge geometry. No other
outdoor tileset is changed.

## Geography

Route 3 connects west to Pewter and north, at its eastern end, to western
Route 4. The Pokémon Center and western Mt. Moon entrance are on that western
part of Route 4. The eastern cave exit leads to the eastern part of Route 4,
which connects to Cerulean. Yellow's one-way ledges are retained.

The Pewter connection uses Yellow's four-block offset. The Cerulean connection
retains Crystal's five-block offset to meet the existing city's western road;
Cerulean's blocks are unchanged. The upper Route 4 bank can be reached later
from Cerulean's water. Its original Yellow Lass is level 31.

Mt. Moon's interior, map ID, NPCs, scenes, and internal warps are retained.
Only the two outdoor return destinations change: the western exit returns to
Route 4 warp 2 and the eastern exit to Route 4 warp 3. Restoring the Gen I cave
is separate work. Dig continues to use the actual cave entrance.

## NPCs and trainers

The seven Crystal trainers on these two routes are removed from their map
objects. Their party definitions, trainer IDs, and defeat flags are retained.
Yellow's positions, directions, sight ranges, and dialogue replace them.

| Route | Position | Class | Party |
|---|---|---|---|
| 3 | 10,6 | Bug Catcher | Caterpie 10, Weedle 10, Caterpie 10 |
| 3 | 14,4 | Youngster | Rattata 11, Ekans 11 |
| 3 | 16,9 | Lass | Pidgey 9, Pidgey 9 |
| 3 | 19,5 | Bug Catcher | Weedle 9, Kakuna 9, Caterpie 9, Metapod 9 |
| 3 | 23,4 | Lass | Rattata 10, Nidoran male 10 |
| 3 | 22,9 | Youngster | Spearow 14 |
| 3 | 24,6 | Bug Catcher | Caterpie 11, Metapod 11 |
| 3 | 33,10 | Lass | Jigglypuff 14 |
| 4 | 63,3 | Lass | Paras 31, Paras 31, Parasect 31 |

New parties append to the existing Bug Catcher, Youngster, and Lass groups.
They display `???`, following the unnamed Yellow trainers already restored in
Viridian Forest. They use Crystal's default moves and class AI, with no held
items. All nine victory flags are allocated from reserved event IDs.

Route 3's resting NPC remains at (57,11). Route 4's wandering NPC remains at
(9,8). Native Crystal sprite equivalents are used. Each route checks its loaded
outdoor sprite list before visible objects are initialized. Graphics are refreshed only for a connection with the other group's
list loaded; entering from the same group or through a door, Continue, or battle
reload avoids a redundant refresh. This removes the long reload pause when
entering Route 3 from Pewter while preserving graphics across the Route 3/4
group boundary. No shared sprite lists are changed.

## Items and encounters

Yellow's visible TM at (57,3) is restored as **TM05 (Roar)** by request, rather
than adding a Whirlwind TM. It has its own pickup flag. Crystal's Route 4 HP Up
and hidden Ultra Ball are removed; their old flags remain reserved. Route 3
has no visible item in Yellow. No hidden items are added.

Both routes retain the current hand-edited wild encounter tables, including
all morning/day/night species and levels, the revised seven-slot probabilities,
and normal level variance. Surf tables are unchanged.

## Mt. Moon Pokémon Center

A new map is appended to the Pewter map group without renumbering existing maps.
Its doorway is at Route 4 (11,5). The room uses Crystal's standard 10×8 Pokémon
Center layout, copied unchanged from `maps/Pokecenter1F.blk`. Yellow's seven NPCs are fitted to that room: nurse
(3,1), Youngster (2,3), Gentleman (6,3), Magikarp salesman (5,6), clipboard
(7,2), link receptionist (9,3), and Chansey (4,1). The clipboard retains its blank
Yellow text. Chansey uses its species party icon and cry; the sprite ID is appended to the Pokémon sprites.

The nurse uses the standard Crystal healing script and animation, and the PC
uses native PC collision behavior. Entering the Center establishes Route 4 as
the blackout return map. An appended spawn point places the player outside its
door at (11,6). This does not add a Fly destination. The standard stairway
connects to Crystal's shared upstairs Pokémon Center and its existing link services. The downstairs
link receptionist directs the player upstairs.

The salesman offers one level-5 Magikarp for ₽500. The player can decline or
return with more money. A full party sends it to the active PC Box when space
is available. If both party and Box are full, no money is charged and the
purchase flag remains clear. The money and flag are updated only after the
Pokémon is successfully received. Subsequent visits use Yellow's no-refunds
text.

## Storage and validation

The larger route blocks, scripts, and dedicated blockset use separate ROM
sections. The new Center attributes have a separate section because the
existing map-header/event bank is nearly full. Existing map, trainer, event,
and spawn IDs are preserved; no saved structure grows.

```sh
make -j4
make crystal_debug -j4
python3 tools/verify_route34.py
```

The verifier checks source layout hashes, object positions, connections,
reciprocal warps, the journey through the existing cave, one-way ledges, PC and
counter access, trainer sight through barriers, compiled map metadata, all nine
trainer parties, conditional sprite refreshes for every entry method, standard
Center layout and stair access, and salesman outcomes for refusal, insufficient funds, party
receipt, Box receipt, failed receipt, and repeat purchases.

Emulator playtesting should cover walking across each connection in both
available directions, entering and leaving both cave doors and the Center,
healing and blackout return, trainer approach animations, PC access, and a
Magikarp purchase with both an open and a full party.
