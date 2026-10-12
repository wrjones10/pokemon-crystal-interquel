# Bedroom debug radio

Implements only the [Player's Radio section of Essential Debug Tools](https://github.com/pret/pokecrystal/wiki/Essential-Debug-Tools#players-radio),
adapted to the Pallet opening. The guide credits vulcandth.

## Access

Build using `make crystal_debug`, then run `pokecrystal_debug.gbc`.
The regular `make` target builds `pokecrystal.gbc` without this package.
`make DEBUG=1` only changes symbol-export options; it does not select the
debug ROM target.

The Pallet bedroom originally had no radio interaction or radio furnishing.
Its upper-left room block now uses the existing PC-and-radio block. The PC
stays at `(0, 1)` and the radio is at `(1, 1)`; stand below the radio and face up.
The regular ROM uses `Radio1Script`. In debug builds, both this radio and the
original New Bark bedroom radio jump to the shared debug package.

## Adaptations

- The package is single-use per save, tracked in a formerly unused event flag.
  No existing event IDs or save-data offsets change.
- It requires at most three existing party members before granting Pokémon.
  The test Pokémon are appended, and each Mew's moves are assigned using its
  actual party slot rather than overwriting fixed slots 2 and 3.
- Move PP and PP Up bits are refreshed before healing the party.
- Item grants are checked for success. If an item cannot fit, the script stops
  without marking setup complete; make space and try again. A failed attempt
  may already have added the Max Repels.
- Pallet and Oak's Lab scenes are set to their completed states. Oak remains
  available, the rival and all starter balls are hidden, and the north-exit
  escort cannot restart. No Kanto starter-choice flag is fabricated.
- The original guide's badge, Fly, Pokégear, Pokédex, Mom, Vermilion, and
  Elite Four shortcuts are retained. Other story prerequisites are not
  automatically completed.
- The debug script has its own ROM section to avoid crowding map script banks.
  It and its helper routines are included only when `_DEBUG` is defined.
- The inherited debug-room battle-skip switch resets to off at startup, including
  when continuing existing saves. Uninitialized SRAM previously could enable
  instant knockouts even without using the radio. The radio does not enable it.

## Playtesting

Check the regular ROM's radio and PC, and verify that no debug rewards appear.
In the debug ROM, test setup on a fresh game and with one to three party
members. Confirm existing moves and held items are preserved, the new Mew
have the intended moves and PP, the Pokégear tabs and badges are available,
and Fly offers the destinations after leaving the house.

Also test four or more party members, full Bag pockets, repeated interaction,
and save/reload after completion. Leave Pallet northward and visit Oak's Lab
to confirm the opening cannot restart. Check the original New Bark radio
uses the same single-use state.

Start a debug game without using the radio and fight the lab rival. Ordinary
attacks should deal normal damage. Fully restart the ROM when checking the fix
with an existing save; emulator save states can bypass startup initialization.
