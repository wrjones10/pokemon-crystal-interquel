# Cerulean Gym and removal of the Machine Part quest

Cerulean Gym retains Crystal's 10×16 interior, warps, Misty, three gym trainers,
and gym guide. Their positions, facing, sight ranges, trainer IDs, parties,
and battle behavior are unchanged. Misty and the trainers are available
immediately and no longer depend on the Power Plant or Route 25. Misty's
initial party and rematch definition remain hand-editable in `parties.asm`.

The Cascade Badge remains a one-time reward. Defeating Misty marks the three
ordinary gym trainers defeated, as before. The Cascade Badge now also permits Cut outside battle and guarantees traded
Pokémon obedience through level 30, matching Yellow. Both party-menu Cut and
direct tree interactions accept it. Hive retains its existing benefits; Fog,
Storm, and Rising retain their higher obedience thresholds. Misty explains
the Cascade benefits after awarding the badge, then gives **TM52 (BubbleBeam)**.
The TM is awarded once; if it cannot be received, talking to Misty again retries.
BubbleBeam uses Yellow's compatibility for the original 151 Pokémon, extended
to Gen II Water types, Cleffa, Igglybuff, Smoochum, and Blissey. It is consumed
when taught, like other TMs. Existing TM numbers and moves are preserved.

Adding TM52 expands saved TM inventory and shifts HM item IDs. **Start a new
save with this build**; saves from before this addition are incompatible.

## Removed sequences

- The Rocket running into the player inside Cerulean Gym.
- The hidden Machine Part and empty-gym notices.
- The Route 24 Rocket encounter and its Machine Part clues.
- Misty's Route 25 date, boyfriend, movement scripts, and coordinate triggers.
  The remaining Route 25 trainers, item, and geometry are retained.
- The Power Plant's missing-part investigation, guard's phone call, and hand-in.
  The room and its NPC trade remain. Staff describe an operational facility.

Both legacy scene IDs in Cerulean Gym, Route 25, and the Power Plant remain valid
and do nothing, preventing existing saves from selecting a removed scene.
Old item and event IDs remain reserved rather than renumbering game data.

## Services and progression

The plant is operational from the beginning. The Magnet Train has no power-quest
requirement but still requires the Pass. Copycat's lost-doll quest remains the
way to receive the Pass; it no longer requires returning the Machine Part.
The Lavender Radio Tower gives the EXPN Card without the power quest, with
updated dialogue. The manager offers TM07 (Zap Cannon) as a one-time gift;
failed receipt leaves it available for another attempt.

The strongest Johto phone-rematch tiers that previously checked restored power
now check **the Earth Badge**, as requested. The other fight-count, Elite Four,
and progression checks in those scripts are unchanged. This changes 21 gates
across 15 maps; it does not alter the gym rematch definitions or their unlocks.

New-game initialization calls `KantoPowerAvailableScript`. Existing saves are
normalized when entering Cerulean City, Cerulean Gym, or the Power Plant:

- The legacy returned-part flag is set for compatibility.
- Gym visibility and old Rocket/date flags are normalized.
- The station populations and Route 5/6 underground entrances are available.
- An obsolete Machine Part in the Bag is removed silently.

Actual service and dialogue scripts no longer read the returned-part flag. The
old restored-power flag is no longer used for train service or phone rematches.
No badges or trainer victories are granted by this normalization.

## Verification

```sh
make -j4
make crystal_debug -j4
python3 tools/verify_cerulean_gym.py
python3 tools/verify_cascade_badge.py
python3 tools/verify_bubblebeam_tm.py
```

The checker validates the unchanged gym block hash, five unconditional gym NPCs,
old scene IDs, removed Rocket/date objects and coordinate events, new-game and
old-save callback linkage, 1,024 combinations of legacy flags and quest inventory,
Misty battle/badge outcomes, BubbleBeam and Zap Cannon gift retries, and all 21 compiled Earth
Badge rematch gates in both ROMs. Service source checks retain the Pass,
lost-item, Copycat-conversation, and one-time EXPN Card requirements. The Cascade
checker executes both compiled Cut gates and the obedience threshold selector
for every combination of Johto and Kanto badges.

Playtest entering the gym immediately on a new save, visiting the
Power Plant before and after Misty, walking through the former Route 25 trigger
positions, collecting the EXPN Card, completing Copycat's quest and using the
train, and returning to the manager with a full TM stack.
