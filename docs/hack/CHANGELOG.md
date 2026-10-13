# Pokémon Crystal Interquel — Gameplay Changes

This is the master record of player-facing changes from the original Pokémon
Crystal ROM. It describes the current game, including changes that supersede
earlier behavior, rather than listing every development revision.

Last updated: October 13, 2026.

## Opening and starting location

- Oak shows a **Rhyhorn**, with its matching cry, during the introductory speech
  instead of Crystal's Wooper.
- After the speech, the player gains control upstairs in **Red's house in
  Pallet Town**, instead of starting in New Bark Town.
- The bedroom PC is usable as the player's home PC.
- A radio sits immediately to the right of the bedroom PC. In regular builds,
  it plays normal radio content; debug builds use it for the test setup below.
- Downstairs, Mom directs the player to Professor Oak. After receiving a
  starter, talking to her heals the party.
- The downstairs television has the Red/Blue-style movie reference: four boys
  walking along railroad tracks.
- The initial home return point is the Pallet Town bedroom, including a
  blackout before establishing another healing location.

### Meeting Oak and choosing a starter

1. Before the opening event, Oak and the rival are absent from the lab. Visiting
   it early does not begin starter selection, and its Poké Balls cannot be taken.
2. Trying to leave Pallet Town through the north exit triggers Oak's warning
   about wild Pokémon. This attempt is required to begin the sequence.
3. Oak escorts the player to his lab. The player walks to the doorway before
   entering, then approaches Oak inside.
4. Oak offers **Bulbasaur, Charmander, or Squirtle**. The balls on the table are
   arranged left to right as Charmander, Squirtle, and Bulbasaur.
5. Examining a ball shows the Pokémon's picture and plays its cry. The player
   can decline and inspect another choice.
6. The chosen starter is **level 5**, has no held item, and can be nicknamed.
   Only one starter can be received from Oak, and the player must choose before
   leaving the lab.
7. The rival walks to the table and takes the starter with the type advantage.
   He then returns to his waiting position.
8. The player walks directly in front of Oak, who gives the **Pokédex** with
   research dialogue adapted from Pokémon Yellow. This happens before the
   first rival battle and does not require a parcel delivery.

### The new rival and first battle

The opening rival is a new character, separate from canonical Blue. He currently
uses Blue's artwork and appears as **RIVAL ???**.

| Player's starter | Rival's starter |
|---|---|
| Bulbasaur | Charmander |
| Charmander | Squirtle |
| Squirtle | Bulbasaur |

- Approaching the lab exit after choosing a starter triggers the battle.
- The rival uses one **level-5 Pokémon**, with no held item, and has no usable
  battle items.
- The battle uses normal Kanto trainer battle music.
- Winning or losing completes the sequence. The player's party is healed,
  the rival leaves, and the battle does not repeat.
- The unchosen third starter remains with Oak.

The opening includes corrections to Oak's outdoor appearance, early lab
visibility, escort movement, rival visibility when nearby, and the rival facing
the player when issuing his challenge. Connected Pallet, Viridian, Pewter, and
Cinnabar maps retain the correct NPC graphics when walking between maps or
returning from battles. Surfing also preserves NPC graphics when the map reloads.

## Route 2 and Viridian Forest

- Route 2 uses Yellow's longer layout with Crystal artwork. Its main path now
  goes through two gatehouses and Viridian Forest between Viridian and Pewter.
- Rob, Ed and Doug retain their Crystal parties, levels and dialogue. They move
  to optional eastern areas and cannot force a battle on the main pre-Cut path.
- The PSNCureBerry tree moves to northern Route 2. Carbos remains near the
  northeast end and Elixer remains in the southeast. Dire Hit and Max Potion
  move to fit the new eastern bypass. Yellow's Moon Stone and HP Up are added.
- Crystal's four Route 2 hidden pickups are removed. The Nugget house, aide
  dialogue and Route 2 wild encounter table remain as before.
- Viridian Forest follows Yellow's maze, using Crystal forest art. It includes
  Yellow's four Bug Catchers, one Lass, two other NPCs, signs, two visible
  Potions, one visible Poké Ball, a hidden Potion and a hidden Antidote.
- The forest uses its original Yellow music, ported to Crystal's sound engine.
  This track plays only inside the forest. All six signs display sign artwork;
  decorative bushes use tree artwork.
- The forest stays dim throughout the day, like Ilex Forest. The northern exit
  retains its previous layout; the border-opening callback was reverted after
  playtesting found a crash when exiting north.
- Forest encounters approximate Yellow using Crystal's seven slots: Caterpie,
  Metapod, Pidgey and Pidgeotto, with base levels 3–9. The same table is used
  morning, day and night; the existing 0–4 level bonus still applies. Encounters
  occur in grass, and there are no wild Pikachu in this forest.

See [Route 2 and forest notes](route-2-viridian-forest.md) for placements,
encounter probabilities and playtesting details.

## Pewter City progression

Before Brock is defeated, Yellow's eastern-exit youngster stops the player from
leaving toward Route 3 and escorts them back to the Gym. Speaking to him also
starts the escort. He returns to his post afterward, so repeated attempts are
blocked. Defeating Brock removes him and opens the exit. The debug radio's
Brock victory flag also bypasses the event.

See [Pewter Gym blocker notes](pewter-gym-blocker.md) for implementation and
playtesting details.

## Pokémon pictures and icons

### Colored overworld pictures

Pokémon pictures shown during overworld interactions, including starter
previews, use the species' normal colors instead of monochrome. These previews
use normal colors rather than reflecting an individual Pokémon's shiny status.
Closing a picture also uses the updated redraw behavior to prevent visual
glitches.

### Unique animated icons

All **251 species, Bulbasaur through Celebi**, have individual two-frame icons
instead of sharing Crystal's small set of generic icons. The graphics come from
the LuigiTKO sprite sheet supplied for this project.

The shared icons appear in the party menu, naming and move screens, trades,
and Day-Care overworld displays. Held-item and Mail indicators continue to use
their existing overlays.

The original Egg icon is retained. All Unown forms currently share the main
Unown icon. Extra sprites beyond Celebi have not been added.

### Thrown Poké Ball colors

Each available ball type has its own palette when thrown in battle:

| Ball | Main color |
|---|---|
| Poké Ball | Red |
| Great Ball | Blue |
| Ultra Ball | Dark gray |
| Master Ball | Purple |
| Heavy Ball | Dark blue-gray |
| Level Ball | Yellow |
| Lure Ball | Bright blue |
| Fast Ball | Orange |
| Friend Ball | Green |
| Moon Ball | Cyan |
| Love Ball | Pink |
| Park Ball | Yellow-green |

These are appearance changes; the balls' existing capture effects are retained.

## Shiny Pokémon

- A Pokémon is shiny when its four independent DVs—**Attack, Defense, Speed,
  and Special—are each 14 or 15**. DVs are Crystal's innate stat values, ranging
  from 0 to 15. Special Attack and Special Defense share the Special DV.
- With uniformly random DVs, the rate is **1 in 4,096**, twice the original
  1-in-8,192 rate. Breeding and encounters with predetermined stats do not
  necessarily follow those odds.
- HP is derived separately from those four values and is not part of the shiny
  requirement. Shiny Pokémon are not guaranteed a high HP DV.
- The Lake of Rage red Gyarados receives **14/14/14/14 DVs**, guaranteeing that
  it is shiny during the encounter and after capture.
- Existing Pokémon are judged by the new rule. A Pokémon that qualified under
  the original shiny pattern loses its shiny appearance unless it also meets
  the new requirement. Previously caught red Gyarados are not automatically
  converted to the new stats.
- The **Odd Egg can no longer hatch a shiny** under its current preset
  outcomes: its original shiny variants do not meet the new requirement, and
  those outcomes have not been adjusted.

## Hidden Power

Hidden Power always has **60 base power**, replacing its original DV-dependent
power range of 30–70. Its type still depends on the user's DVs. Both the player
and opposing Pokémon use this rule.

## Wild encounter levels

Regular grass, cave, and Surf encounters can appear **0–4 levels above the
level listed for their encounter slot**. The listed level is the minimum, not
the center of the range.

| Level bonus | Approximate chance |
|---|---|
| +0 | 35% |
| +1 | 30% |
| +2 | 20% |
| +3 | 10% |
| +4 | 5% |

For example, a slot listed at level 5 can produce levels 5–9, with the lower
levels more common. Surf already had this variance in Crystal; the same
behavior now also applies on land. Species and encounter-slot probabilities
are retained.

Special encounters retain their existing level rules. This includes scripted
legendary encounters, roaming Pokémon, the red Gyarados, fishing, Headbutt,
Rock Smash, and the Bug-Catching Contest. Only normal encounter types receive
the added variance; Sweet Scent uses the normal encounter selection outside
the contest.

## Fishing while surfing

The Old Rod, Good Rod, and Super Rod can be used while surfing, as well as
from land. The player must face an unoccupied water tile in a fishing area.
Casting onto an NPC is blocked.

Both player characters now have surfing sprites showing the trainer riding
the Pokémon, with matching fishing poses. The normal surfing appearance is
restored after fishing or a fishing battle. Surfing Pikachu retains its
existing fishing restriction. Fishing species, levels, and bite chances use
their existing rod and area tables.

This feature uses the sprites and approach supplied by the pret
[fishing while surfing guide](https://github.com/pret/pokecrystal/wiki/Allow-fishing-while-surfing),
which credits The Void's contribution to Polished Crystal.

## Evolution changes

No Pokémon requires trading to evolve.

### Former trade evolutions

| Pokémon | Evolves into | New requirement |
|---|---|---|
| Kadabra | Alakazam | Level up to level 44 or higher |
| Haunter | Gengar | Level up to level 44 or higher |
| Machoke | Machamp | Level up to level 38 or higher |
| Graveler | Golem | Level up to level 38 or higher |

If evolution is postponed, another level-up at or above the required level
can trigger it.

### Former held-item trade evolutions

Use the corresponding item from the Bag directly on the Pokémon:

| Pokémon | Evolves into | Item |
|---|---|---|
| Poliwhirl | Politoed | King's Rock |
| Slowpoke | Slowking | King's Rock |
| Onix | Steelix | Metal Coat |
| Scyther | Scizor | Metal Coat |
| Seadra | Kingdra | Dragon Scale |
| Porygon | Porygon2 | Up-Grade |

**These four items are reusable:** a successful evolution does not consume
King's Rock, Metal Coat, Dragon Scale, or Up-Grade. There is no level or trade
requirement for these item evolutions. A Pokémon holding an Everstone cannot
be evolved with them.

The items retain their existing effects when held. Ordinary evolution stones
are still consumed. Poliwhirl can still evolve into Poliwrath with a Water
Stone, and Slowpoke can still evolve into Slowbro by leveling up to level 37.

## Cycling Road

Holding **A or B** while stationary on the downhill section brakes the bicycle
and stops automatic southward movement. Releasing both buttons resumes
coasting. Directional controls remain available, matching the original
Red/Blue/Yellow braking behavior.

## Current scope and playtesting

The Pallet opening is implemented, but the rest of Crystal's campaign has not
yet been converted into a complete Kanto-first adventure. Existing map layouts,
later trainer levels, and Johto story events remain in place. In particular,
later Elm starter events have not been rewritten around Oak's new opening.
The home PC still exposes Crystal's decoration system, which has not been
adapted to the Pallet bedroom.

The opening's general functionality has been verified through playtesting.
Later changes have passed ROM builds and source or data checks, but still
need in-game verification. Start a new game to test the complete Pallet opening;
older saves are not migrated into that opening sequence.

## Debug-build bedroom radio

In the debug ROM, interacting with the Pallet bedroom radio applies a
single-use testing package. The original New Bark bedroom radio provides the
same package. This feature is excluded from the regular ROM.

The package grants:

- A Pokédex and the full Pokégear, including phone, map, radio, and EXPN cards.
- 99 Max Repels and 99 Master Balls.
- All 16 badges, Gym Leader defeat flags, the Elite Four completion flag, and
  the credits-skip flag.
- All normal Fly destinations.
- A level-100 Mewtwo holding BrightPowder.
- A level-100 Mew holding Leftovers, with Fly, Surf, Strength, and Cut.
- A second level-100 Mew holding Leftovers, with Flash, Rock Smash, Headbutt,
  and Waterfall.

Existing party Pokémon are preserved. Three empty party slots and room in the
Bag are required. The party is healed and the new moves receive full PP.
Using the radio again after completion does not add duplicate rewards.

Debug builds reset the inherited battle-skip switch to off at startup, so
ordinary attacks deal normal damage even when the radio setup is skipped.

The setup also marks the Pallet opening complete, removes the lab's remaining
starter balls, and skips the guide's New Bark Mom and Vermilion introduction
scenes. These are testing shortcuts rather than a complete simulation of
every completed story event. Oak's speech, Elm's dialogue, and wall collision
are not changed by this debug package.

Build with `make crystal_debug` and open `pokecrystal_debug.gbc` to use it.
See [debug radio notes](debug-radio.md) for setup and playtesting details.

## Maintaining this document

Update this document whenever a change affects what players see, receive, can
do, or experience. Replace superseded descriptions with current behavior and
include relevant exceptions. Keep implementation details in the feature notes:

- [Pallet opening implementation notes](pallet-opening.md)
- [Party icon implementation notes and artwork source](party-icons.md)
- [Debug bedroom radio setup and testing](debug-radio.md)
- [Route 2 and Viridian Forest](route-2-viridian-forest.md)
- [Pewter City Gym guide and exit blocker](pewter-gym-blocker.md)
