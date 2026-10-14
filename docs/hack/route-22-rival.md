# Optional Route 22 rival battle

The event adapts the first Route 22 ambush from Red and Yellow. Their scripts use
trigger tiles (29, 4) and (29, 5), and their rival starts at (25, 5). These positions
also work with Crystal's existing Route 22 layout, so the layout is unchanged.
Red supplies the requested party: level-9 Pidgey followed by a level-8 starter.
Yellow instead uses Spearow and Eevee; that party and Yellow's starter-evolution
tracking are not ported. Dialogue is adapted from the first Red encounter, without
identifying the new rival as Blue.

## Availability and outcomes

Both coordinate triggers work without a new map scene variable. They require the
lab rival battle to be complete, the Boulder Badge to be absent, and
`EVENT_BATTLED_ROUTE_22_RIVAL` to be clear. The badge itself controls expiration,
independently of Brock's defeat flag. Debug radio users already have the badge,
so the event is unavailable after that setup.

The rival uses a separate visibility event flag, set by the object callback.
This keeps him hidden when Crystal rebuilds object masks after the callback.
He appears only when an eligible trigger fires; the script removes any existing
live instance before repositioning and revealing him.
He approaches the player from the west and faces them before challenging them.
The completion flag is set only after winning, so a loss leaves a retry available
until the player wins or earns the Boulder Badge.
Normal Crystal blackout handling applies to losses; wins resume the departure
scene. Neither outcome unlocks or blocks any progression. The completion and visibility flags
use two reserved event IDs, leaving `NUM_EVENTS` and existing IDs unchanged.

The trainer parties append to `PalletRivalGroup` as
`PALLET_RIVAL_ROUTE22_BULBASAUR`, `PALLET_RIVAL_ROUTE22_CHARMANDER`, and
`PALLET_RIVAL_ROUTE22_SQUIRTLE`. Lab party IDs remain unchanged. Selection uses the
same Oak starter flags as the lab battle, preserving the rival's chosen starter.
All six parties explicitly have no held items. The class already has no usable
battle items and uses standard Kanto trainer battle music.

## Graphics and movement

The shared Pallet/Viridian/Pewter/Cinnabar outdoor sprite list already contains
Blue's artwork, so its entries remain unchanged. Blue normally occupies the
second VRAM table, which lacks walking frames. A Route 22 sprite callback swaps
Blue's and Oak's allocated tile slots after the lab rival battle is complete.
Oak no longer walks outdoors at that point. Other sprites retain their existing
slots, and the callback is safe to repeat. It does nothing before the lab battle,
preserving Oak's early Pallet Town animation.

The event refreshes sprite graphics before revealing the rival. Normal walking
steps now animate both his approach and departure, and the sprite callback also
restores his walking slot during the post-battle map reload. This replaces the
initial standing-frame movement workaround. Connected maps keep consistent
sprite graphics and tile assignments until their next normal graphics reload.

After winning, the upper encounter walks east to (31, 5), then south to (31, 10).
The lower encounter passes above the player through row 4, then joins the same
southbound path. Both depart without crossing the player, walls, ledges or warps.

## Validation and playtesting

Build with `make -j4` and `make crystal_debug -j4`, then run
`python3 tools/verify_route22_rival.py`. It checks both compiled ROMs, all three
starter branches, both trigger tiles, both battle outcomes, completed/lab/badge
states, retries after losses, badge expiration after a loss, no repeats after a
win, facing and collision along the compiled movements.
It also checks visibility after the engine rebuilds object masks, prevents a
second live rival from being spawned, and executes the compiled slot-swap routine
for male/female walking, cycling and surfing sprites. Oak's early-game slot and
all other NPC slots are checked. It checks the six compiled rival parties,
including held-item bytes.

In an emulator, test each starter, both trigger rows, winning, losing, returning
afterward, and visiting after earning the Boulder Badge without doing the battle.
Check entry from Viridian City and from Victory Road Gate. Reboot the updated ROM
and use an in-game save or new game when testing changed map scripts.

## Move AI profiles

`data/trainers/rival_ai.asm` assigns move-AI flags by `PALLET_RIVAL` party ID.
The lab variants use `AI_BASIC`; Route 22 variants use `AI_BASIC | AI_SETUP`.
Add explicit entries for later rival parties as they are introduced. Unlisted
parties fall back to their class's default move AI. Item use, switching, other
trainer classes and Battle Tower's Falkner-AI override retain their behavior.
