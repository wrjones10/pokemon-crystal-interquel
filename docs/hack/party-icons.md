# Unique Pokémon party icons

Bulbasaur through Celebi use individual two-frame icons from the LuigiTKO
251-species sheet linked by the pret
[party icon guide](https://github.com/pret/pokecrystal/wiki/Add-a-new-party-menu-icon).
The supplied [source sheet](https://user-images.githubusercontent.com/64930003/220241272-8dcc220a-6eca-44eb-88f4-0a748f06f72b.png)
is 288 × 544 pixels, with 18 columns of 16 × 16 frames. Each pair of rows
contains both animation frames for 18 consecutive species in National Pokédex
order. For zero-based species index `i`, crop a 16 × 32 rectangle at
`x = (i % 18) * 16`, `y = (i / 18) * 32` using integer division.

The PNGs in `gfx/icons/` preserve the source pixels and four grayscale colors.
The existing Egg graphic is retained. Unown uses the sheet's main Unown icon
for every form; extra sprites after Celebi are not imported.

`constants/icon_constants.asm`, `data/icon_pointers.asm`, and
`data/pokemon/menu_icons.asm` define the species mapping. `gfx/icons.asm`
stores Bulbasaur through Tauros in `Mon Icons 1` (16,384 bytes), and Magikarp
through Celebi plus Egg in `Mon Icons 2` (15,872 bytes).
`GetIconBank` in `engine/gfx/mon_icons.asm` selects the bank at `ICON_MAGIKARP`
for both menu and overworld icon loading. These sections are placed by the
linker; the first completely fills its bank.

For playtesting, check the party menu with both Kanto and Johto Pokémon,
especially Tauros, Magikarp, Celebi, Unown, and Egg. Check animation, held-item
overlays, the naming and move screens, trades, and the Day-Care overworld icons,
which share the icon loader.
