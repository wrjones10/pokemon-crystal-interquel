# Cerulean bridge rival battle

The new Pallet rival challenges the player at the north end of Cerulean City,
before Route 24. This follows Yellow's encounter, which actually takes place
on the Cerulean City map rather than Route 24. Red uses the same trigger tiles
and movements; Yellow's dialogue is used here, without naming the rival Blue.

Stepping onto either bridge-approach tile, (20, 6) or (21, 6), reveals the rival
in that lane at y=2. He walks three tiles south, faces the player, and battles.
After a win he describes visiting Bill, steps into the other lane, walks six
tiles south, and disappears. Encounter/departure music surrounds the standard
trainer battle music. Losing causes the normal blackout and leaves the battle
available to retry. Winning clears it permanently. Neither Brock's badge nor
Misty's badge, nor the optional Route 22 result, controls its availability;
only the completed lab battle is required.

The three independently editable party definitions are at the end of
`data/trainers/parties.asm`:

- `PALLET_RIVAL_CERULEAN_BULBASAUR`
- `PALLET_RIVAL_CERULEAN_CHARMANDER`
- `PALLET_RIVAL_CERULEAN_SQUIRTLE`

They begin as copies of the current Route 22 parties: level 7 Nidoran♀ followed
by the rival's level 8 starter, with no held items. The starter remains the one
chosen in the lab. Editing these parties will not change the lab or Route 22
teams. Their move AI starts with `AI_BASIC | AI_SETUP`, matching Route 22;
future tuning can be done in `data/trainers/rival_ai.asm`.

Crystal-native coordinate events, movement streams and event flags replace
Yellow's per-frame map script state machine. Existing city NPCs, geometry,
warps, and services remain unchanged. The rival uses an appended object slot,
a reserved completion flag, and a separate reserved visibility flag. No saved
structures grow and existing trainer/event IDs remain stable.

The trainer-data ROM bank has 235 bytes free after this addition. Larger future
party edits may require moving trainer data to another bank.

The Cerulean outdoor sprite list replaces its unused quest Rocket entry with
Blue's artwork. Both sprites have the same graphics allocation type, retaining
the other NPC slots and giving Blue animated walking frames. The sequence hides
and positions the object before refreshing graphics and revealing it. Post-battle
reloads retain its position and visibility until the departure finishes.

## Verification

```sh
make -j4
make crystal_debug -j4
python3 tools/verify_cerulean_rival.py
python3 tools/verify_cerulean_gym.py
python3 tools/verify_route34.py
```

The rival checker executes compiled scripts for both lanes, all three starter
choices, wins/losses, completed/uncompleted encounters, and the lab prerequisite
(48 states per ROM), including subsequent retries and repeat visits. It checks
collision and player/NPC overlap throughout approach/departure, correct facing,
trainer selection, all nine rival party records, and walking-frame allocation
for six player forms. Existing city and Route 24 geometry are not modified.

Emulator playtesting remains necessary: approach from each lane, lose and return,
win and revisit, and check the rival's animation before and after battle.
