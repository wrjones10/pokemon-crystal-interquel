# Pewter City Gym guide

Before Brock is defeated, a youngster at (35, 16) stops the player from leaving
Pewter City toward Route 3. He uses Yellow's dialogue and escorts the player back
to the Gym. Talking to him directly also starts the escort.

The escort ends near the Gym sign, with the player at (11, 18), as in the original
sequence. The youngster encourages the player to challenge Brock, walks away,
and returns to his eastern post offscreen. Trying to leave again repeats the
event. The player is not forced into the Gym.

After `EVENT_BEAT_BROCK` is set, the youngster disappears and the eastern exit is
open. The debug radio already grants Brock's victory flag, so its setup skips
this blocker automatically. No trainer parties, levels or Gym rewards change.

## Translation and persistence

Read-only references:

- `pokeyellow/scripts/PewterCity.asm`
- `pokeyellow/data/maps/objects/PewterCity.asm`
- `pokeyellow/text/PewterCity.asm`
- `pokeyellow/engine/overworld/auto_movement.asm`
- `pokeyellow/engine/events/pewter_guys.asm`

Red has the same exit interception coordinates and basic escort. Yellow's text
is used here. Crystal's `follow`, `applymovement`, map callbacks and event flags
replace Gen I's simulated-input state machine and manual sprite repositioning.
The tour uses Crystal's existing `MUSIC_SHOW_ME_AROUND` theme.

Six all-scene coordinate events include Yellow's four interception points plus
the two remaining tiles needed to cover the eastern corridor at x=37. Every
handler checks Brock's defeat flag before starting dialogue or moving anyone.
No additional scene variable or WRAM allocation is needed.

`EVENT_PEWTER_CITY_GYM_BLOCKER` uses one reserved flag and controls visibility.
It is deliberately separate from `EVENT_BEAT_BROCK`: native `disappear` and
`appear` change an object's associated event flag. The object callback recomputes
visibility from Brock's actual defeat state before `LoadObjectMasks`, making it
safe to re-enter the map or continue an existing game. Existing event IDs and
save-data sizes are unchanged.

The walking route follows Yellow's route around the Gym's walls. Crystal's
wandering woman can occupy that corridor, so she is hidden while offscreen at
the beginning and restored at her original spawn when the escort finishes.
The youngster is hidden before his map position is reset, then restored to his
post offscreen. All other NPC placements and scripts remain as before.

## Validation

```sh
make
make crystal_debug
python3 tools/verify_pewter_blocker.py
python3 tools/verify_route2.py
git diff --check
```

The blocker check uses the compiled movement bytes from both ROMs. It verifies
all eight approaches (six automatic triggers and two direct-talk positions),
walkable paths, no player/guide overlap, possible wandering-NPC collisions,
repeatable reset behavior, visibility flags, and protection of Brock's defeat
flag. A map reachability check confirms that the east exit is inaccessible
without crossing a trigger, and accessible after the youngster is removed.

In-game checks still required:

- Enter Pewter before defeating Brock and attempt every eastern corridor lane.
- Talk to the youngster from both sides and from below; confirm the complete
  escort, dialogue, departure and return to his post.
- Attempt the exit again, then save/reload and repeat.
- Lose to Brock: the youngster must still stop the player afterward.
- Defeat Brock and leave the Gym: the youngster must be absent and Route 3 open.
- Use the debug radio before entering Pewter: the exit should already be open.

Re-enter Pewter after updating an existing save made in the city, so the map's
new object definition is loaded. Emulator save states can retain the old map.
