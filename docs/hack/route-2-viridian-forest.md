# Route 2 and Viridian Forest

Route 2 follows Pokémon Yellow's 20-by-72 walking-tile layout, using Crystal's
Kanto artwork. Viridian Forest and its two gatehouses restore the main journey
between Viridian City and Pewter City. The eastern Cut bypass, Diglett's Cave
entrance, Nugget house, and Oak's aide gate remain available.

## Route 2 content

Crystal's trainers keep their parties, levels, dialogue, and defeat flags:

| Trainer | Position | Party |
|---|---|---|
| Rob | (14, 57) | Level 32 Beedrill and Butterfree |
| Ed | (18, 6) | Three level 30 Beedrill |
| Doug | (17, 29) | Level 34 Ariados |

They occupy optional eastern areas. Their sight lines cannot reach the mandatory
pre-Cut path to either forest entrance.
Rob faces left with a one-tile sight range, stopping before the wall. Ed faces
down with a three-tile sight range along the open path. Crystal's trainer sight
does not check intervening walls, so these settings prevent challenges through
barriers without changing trainer detection on other maps.

| Reward | Position | Source |
|---|---|---|
| PSNCureBerry tree | (9, 5) | Crystal; moved to the north end |
| Carbos | (19, 2) | Crystal; keeps its northeast location |
| Max Potion | (16, 24) | Crystal; relocated to the eastern bypass |
| HP Up | (13, 45) | Yellow |
| Dire Hit | (14, 51) | Crystal; relocated off the ledge and narrow passage |
| Moon Stone | (13, 54) | Yellow |
| Elixer | (14, 66) | Crystal; remains in the southeast section |

The four Crystal hidden pickups are removed from Route 2. Their event IDs remain
reserved so existing saves and subsequent flags do not shift. The Nugget house
and existing aide dialogue are retained; Yellow's house trade and Flash reward
are not part of this layout change. Route 2's original wild encounter table stays
unchanged.

## Forest content

The forest follows Yellow's 34-by-48 walking-tile maze. Its tree, sign, grass and
fence artwork is built from Crystal assets. It has a dedicated tileset, so Ilex
Forest and the shared Kanto graphics are unaffected. Small stumps and decorative
floor marks use Crystal equivalents. Sign blocks match the six readable sign
positions, including their grass-cleared variants; the original conversion had
confused the source sign and bush graphics.

The forest uses Crystal's fixed night palette, like Ilex Forest, to keep its
canopy dim even during the day. This does not change the clock or encounter time
period. The northern exit retains its original ported layout and tree border.
The attempted border-opening tile callback was removed after a north-exit crash
was reproduced during a new-game playtest.

Yellow's five trainers retain their positions, sight ranges, species and levels:

- (30, 33): two level 7 Caterpie.
- (30, 19): level 6 Metapod, Caterpie, and Metapod.
- (2, 18): level 10 Caterpie.
- (2, 41): a Lass with level 6 Nidoran female and Nidoran male.
- (13, 17): level 8 Caterpie and Metapod.

Yellow did not name these trainers; their Crystal name fields display `???`.
They use Crystal's battle mechanics, default moves and trainer AI. The two
non-battling NPCs and six signs retain Yellow's dialogue. The north exit sign
uses its intended leaving-forest text rather than Yellow's erroneous tips text.

Visible items are Potions at (25, 11) and (12, 29), and a Poké Ball at (1, 31).
Hidden items are a Potion at (1, 18) and an Antidote at (16, 42), matching Yellow.
The north and south gatehouses use Crystal's standard gate art and Yellow's NPC
dialogue. The south gate's stationary NPC moves one tile left to avoid Crystal's
counter geometry.

### Music

Only the forest uses `MUSIC_VIRIDIAN_FOREST`, a Crystal-native port of Yellow's
`audio/music/dungeon2.asm`. Route 2 and the gatehouses retain their existing music.
The port preserves the four-channel notes, tempo 144, envelopes, duty cycles,
vibrato and loop timing. Yellow's channel-1 perfect-pitch switch becomes Crystal's
`pitch_offset 1`. The wave-channel instrument is identical in both games, and
Yellow's percussion instruments 9–13 map to the identical envelope/noise sounds
at indices 2–6 in Crystal drumkit 1. Existing songs and drumkits are unchanged.
The track has a separate ROM section so it does not crowd the existing song banks.

### Encounters

Edit the `VIRIDIAN_FOREST` entry in `data/wild/kanto_grass.asm` to tune encounters.
All three time periods currently share this approximation:

| Chance | Base level | Species |
|---|---|---|
| 30% | 3 | Caterpie |
| 30% | 4 | Metapod |
| 20% | 5 | Caterpie |
| 10% | 4 | Pidgey |
| 5% | 6 | Caterpie |
| 4% | 8 | Pidgey |
| 1% | 9 | Pidgeotto |

The encounter rate is 10% for morning, day and night. There are no wild Pikachu.
The hack's existing 0–4 level bonus applies. Encounters occur only in grass;
clearings and paths are safe. There are no water or Headbutt encounter tables.

## Engine integration and storage

- Three map IDs are appended to the Viridian group, preserving existing IDs.
- Twelve reserved event flags hold five forest trainer victories, five forest
  item pickups, and the two new Route 2 item pickups. Existing flags are retained.
- New party entries append to the Bug Catcher and Lass groups, preserving all
  existing trainer IDs. The forest uses Crystal's ordinary map trainer scripts.
- A Route 2 blockset reuses Kanto graphics, palettes, animations and Cut rules.
  Two local block variants add downward warp carpets to Yellow's north-facing
  gate approach tiles. This preserves exit facing and avoids changing other maps.
- The taller Route 2 and new map blocks use a separate ROM section because the
  original block bank could not hold the expanded route. Forest scripts and
  tileset data also have dedicated sections.
- The forest uses Crystal's cave environment, as Ilex does, for its independent
  sprite list and field moves. A map-specific encounter check requires grass
  there while leaving encounters in existing caves and Ilex unchanged.
- The forest landmark is appended after existing landmarks. Region detection
  explicitly treats it as Kanto; map cursor navigation skips the intervening
  S.S. Aqua landmark. The original Pokégear progression restrictions remain.

## References and validation

Read-only references: `pokeyellow/maps/Route2.blk`, `maps/ViridianForest.blk`,
their map objects, forest and gate texts, forest trainer headers, trainer parties,
hidden events, and encounter tables. Red's Route 2 geometry agrees with Yellow;
Yellow's extra forest trainers and its second Potion are deliberately retained.
Gen I state machines and tile IDs are translated to Crystal's native systems.

Automated checks:

```sh
make
make crystal_debug
python3 tools/verify_route2.py
git diff --check
```

The verifier checks dimensions, collision, warp backlinks within the new area,
main-path traversal in both directions before Cut, object/sign/item reachability,
and separation of the high-level trainers from the mandatory path. It also checks
that the six readable signs have sign graphics and no decorative bushes look like
signs, including after cutting grass.

In-game validation is still required:

- Walk from Viridian to Pewter and back through both gates and the forest.
- Check entering and leaving both sides of every gate, house and cave doorway.
- Confirm all six forest signs look like signs, including the one near the south
  entrance. Listen through a complete forest music loop, verify battle return
  music, and check that Route 2 and both gates keep their previous tracks.
- Confirm grass encounters, safe clearings, the three time tables, and battle
  return graphics; inspect the forest entry name and Pokédex area marker.
- Fight each forest trainer, confirm the Lass must be spoken to, and check
  victory flags after save/reload. Visit Crystal's trainers through the bypass.
- Collect every visible and hidden item; verify flags persist and the berry tree
  regrows normally. Check that items do not obstruct paths.
- Use Cut on the route trees and forest grass. Check the bicycle and Escape Rope
  in the forest, and the Pokégear map after its normal progression unlocks.

Existing saves should enter from Viridian, Pewter, a gate or a house after the
update. A save made on old Route 2 may restore coordinates inside new terrain;
emulator save states also retain stale map and graphics data.
