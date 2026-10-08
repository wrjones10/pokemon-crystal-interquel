# Pokémon Crystal Interquel — Development Instructions

## Project Overview

This project is a Pokémon Crystal ROM hack using the `pret/pokecrystal` disassembly.

The game is set between Pokémon Generation 1 and Generation 2. Kanto is the main region, with Johto serving as postgame content.

## Reference Implementation

The `pret/pokeyellow` repository is available in the adjacent workspace directory.

Use Pokémon Yellow as the primary reference for Generation 1 map layouts, NPC placement, events, dialogue, progression, and game mechanics.

## Porting Guidelines

When asked to reproduce a feature from Pokémon Yellow:

1. Locate the relevant implementation in `pokeyellow`.
2. Identify the corresponding systems in `pokecrystal`.
3. Explain important architectural differences.
4. Propose a Crystal-native implementation that reproduces the desired behavior.
5. Prefer Crystal's existing engine systems rather than copying Yellow assembly directly.
6. Preserve Crystal's existing functionality unless explicitly instructed otherwise.
7. Make small, focused changes and test with `make`.

Do not modify the Yellow repository.

Do not assume Yellow and Crystal use identical map, event, graphics, or memory structures.

## Design Philosophy

The objective is to recreate and expand the experience of Pokémon Red/Blue/Yellow using Crystal's more advanced engine, not to recreate Generation 1's technical limitations.