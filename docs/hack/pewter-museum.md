# Pewter Museum of Science

Crystal retains unused block layouts for both museum floors, but no functioning
map headers, events or museum tileset. The beta blocks use different block IDs
from Yellow's gate/museum blockset. This restoration uses Yellow's 20-by-8 and
14-by-8 walking-tile maps with its original gate/museum artwork and Crystal's
unused museum palette assignments. The unused beta layouts remain intact.
Yellow's floor block $00 is remapped to $7f in both floors: Crystal reserves block
zero for map padding, rendering it as the border and rejecting its collision
lookup. Keeping the original zero IDs caused black, impassable floor patches.
The remapped block preserves Yellow's floor artwork and is walkable in all four
quadrants.

## Access and admission

Pewter City gains two appended warps, preserving its original five warp IDs:

- (14, 7): public entrance, leading to 1F warp 1 at (10, 7).
- (19, 5): rear entrance, leading to 1F warp 3 at (16, 7).

Crystal's sealed facade receives two door variants in a Pewter-only blockset
that shares Kanto graphics, palettes and animations. A Cut tree at (23, 6) gates
the rear walkway. Cutting it preserves the fence below. Other Kanto maps retain
the original shared blockset. Pewter's existing Cut rules remain available.

The public admission desk uses Yellow's triggers at (9, 4) and (10, 4). Paying
50 admits the player; refusing or having insufficient money moves them one tile
south. The paid flag persists between floors and resets when entering Pewter
City again. Repeated crossings do not charge again during the same visit.
The rear room remains separate from the public gallery.

## NPCs and exhibits

Both floors retain Yellow's NPC positions and dialogue. Crystal's scientist,
gentleman, youngster, gramps, lass and Pokefan artwork represent the original
characters. The downstairs scientist discusses amber with visitors behind his
counter. The upstairs father uses Yellow's ordinary Pikachu dialogue, since this
hack has no Yellow starter-Pikachu follower/happiness system.

Aerodactyl and Kabutops displays have their original tile artwork and readable
fossil descriptions. The upstairs Columbia and Moon Stone signs are readable.
Their picture popups use Yellow's original fossil illustrations and Crystal's
picture-box close/redraw routine.

The rear scientist at (15, 2) gives Old Amber. The table display at (16, 2) uses
Yellow's Old Amber sprite and disappears only after successful receipt. If the
Key Item pocket is full, neither the received flag nor display changes. The gift
cannot be collected again after saving, leaving the map or reentering.

## Storage and compatibility

- Museum maps append as IDs 9 and 10 in the Pewter group.
- Museum and Pewter tilesets append after existing tileset IDs.
- Two reserved event IDs store admission and Old Amber receipt; `NUM_EVENTS`
  remains 2048 and existing event IDs remain unchanged.
- Old Amber reuses unused item ID $19. `ITEM_19` remains an alias for the existing
  Gen 1 held-item conversion table; other item IDs and TM/HM IDs do not shift.
- Old Amber has a name and description, costs zero, and is a non-usable,
  non-discardable Key Item. It cannot be sold or given as a held item.
- Museum graphics, scripts, map blocks and the Amber sprite have separate ROM
  sections to avoid crowding existing banks.

No fossil revival system is included. Existing Cinnabar and museum-independent
story events remain as before.

## Validation

Build `make -j4` and `make crystal_debug -j4`, then run:

- `python3 tools/verify_pewter_museum.py`
- `python3 tools/verify_pewter_blocker.py`
- `python3 tools/verify_route22_rival.py`
- `python3 tools/verify_viridian_officer.py`

Checks cover reciprocal entrance/stair warps, gallery admission geometry,
separation of the rear room, Cut-only rear access, all NPC/exhibit interactions,
payment/refusal/repeated crossings, a full Key Item pocket and repeated gift
attempts, as well as the compiled Old Amber attribute record. Map previews have
also been inspected against Yellow's artwork.

In-game playtesting remains necessary: check both doors, stairs in both
directions, admission with 0/49/50 currency, repeat gallery entry, the Cut tree,
the rear NPC, a full Key Item pocket, item receipt and saving/reloading afterward.
Use an updated ROM boot and an ordinary in-game save instead of an old emulator
save state when testing changed map data.
