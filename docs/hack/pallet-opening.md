# Pallet Town opening

New games begin at (3, 3) upstairs in Red's house, using the existing
Crystal maps. The player has immediate control after the introductory
Oak speech. The Rhyhorn shown during that speech is retained.

## Sequence

1. Mom directs the player to Oak and heals the party after a starter is received.
2. Oak stops the player at either north-exit tile in Pallet Town, warns about
   wild Pokémon, and escorts the player around the lab to its entrance.
3. Before the escort, both Oak and the rival are absent from the lab.
   After the escort, Oak offers the three balls on the table. From left to right:
   Charmander, Squirtle, Bulbasaur, matching Red's table arrangement.
4. Each ball shows its Pokémon and cry, asks for confirmation, and grants
   a level-5 Pokémon with no held item and the normal nickname prompt.
   Declining permits another choice. Only one starter can be received.
5. The rival walks around the player to the starter with the type advantage,
   receives it with a message and sound, and returns to his waiting spot. The player walks directly in front of Oak before he gives the Pokédex,
   adapting Yellow's research speech.
   The player must choose before leaving, then battles the rival when approaching
   the lab exit.
6. Winning or losing completes the opening. The party is healed and the rival leaves.
   The remaining ball stays with Oak. Oak's original late-game dialogue is
   retained after the Elite Four.

## References and translation

Read-only references used:

- `pokered/scripts/PalletTown.asm` and `pokered/scripts/OaksLab.asm`
- `pokered/scripts/RedsHouse1F.asm` and `pokered/scripts/RedsHouse2F.asm`
- `pokered/data/maps/objects/OaksLab.asm`
- `pokeyellow/scripts/PalletTown.asm`

Red uses per-map assembly state machines and simulated input for movement.
This implementation uses Crystal scene scripts, coordinate events, movement
commands, event flags, and its native starter/nickname and trainer battle systems.
Yellow adds a wild Pikachu encounter and gives the player Pikachu; Red's three-ball
selection was chosen as requested. The rival uses a separate PALLET_RIVAL trainer class
and Blue's temporary graphics, with three level-5 parties. The rival is unnamed
(displayed as RIVAL ???), uses normal Kanto trainer battle music, carries no usable
battle items, and every starter explicitly has NO_ITEM as its held item. Canonical
Blue's Gym party and trainer class remain separate.

The existing Crystal map layouts, player graphics, later routes, trainer levels,
parcel progression and Johto story have not been ported from Red. This is
an opening-sequence change, not a complete Red progression conversion.

## Storage

Two scene variables replace two reserved WRAM bytes, preserving all subsequent
save-data offsets. Twelve event flags use previously reserved IDs without changing
`NUM_EVENTS`. The expanded Oak's Lab scripts share Pallet Town's script bank ($6b)
to avoid crowding bank $66. The trainer picture-pointer table lives in bank $0e
to make room for the new rival class; the actual graphics stay in their original banks. Test the new sequence with a fresh game; existing saves
are not migrated to its opening state.

Oak and the rival each have a persistent visibility flag. The lab's object
callback sets those flags before `LoadObjectMasks` rebuilds visibility; hiding
an unflagged object inside that callback alone is undone during map loading.
The flags are recomputed on entry, so early lab visits remain safe on existing
opening saves as well as fresh games.

## Validation

`make` and `git diff --check` are required. Static checks cover both escort paths,
the lab entry, both rival approach/exit paths, player collisions, north-exit coverage,
reserved-byte allocation, and opening text widths. In-game validation remains
necessary; no emulator is installed in the development environment.

Fresh-game playtest checklist:

- Begin upstairs, use the PC, descend, talk to Mom, and leave the house.
- Enter the lab before meeting Oak: both Oak and the rival are absent, and balls
  cannot be taken. Leave and approach each north-exit tile in separate runs.
- Check Oak's correct overworld sprite at both north-exit tiles, his full escort,
  and the automatic lab introduction with Oak and the rival present.
- Preview and decline each ball, then accept each starter in separate runs.
  Verify species, level, nickname, received sound, and removed balls.
  Confirm Oak awards the Pokédex before the rival battle, its menu opens, and
  the selected starter is marked caught. Declining a starter must not award it.
- Try leaving before choosing. Check both exit columns after choosing.
- Win and lose the rival's battle for each starter. Confirm the opposing starter,
  normal trainer battle music, no held or usable battle items, healing,
  the rival's departure, and that the battle never repeats.
- Save/reload before choosing, after choosing, and after the battle. Confirm
  scene state and ball visibility survive; leave/re-enter the lab as well.
- White out later before visiting a Pokémon Center: the home spawn should
  return to the Pallet bedroom. Verify Mom's healing after receiving a starter.
