#!/usr/bin/env python3
"""Check Route 2 / Viridian Forest collision, warps and reachability.

Run from any directory: python3 tools/verify_route2.py
Uses only the standard library; no emulator or Yellow checkout is required.
"""
from collections import deque
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
DIRECTIONS = ((0, -1), (0, 1), (-1, 0), (1, 0))
FLOORS = {"FLOOR", "TALL_GRASS", "DOOR", "CAVE",
          "WARP_CARPET_UP", "WARP_CARPET_DOWN"}
WARPS = {"DOOR", "CAVE", "WARP_CARPET_UP", "WARP_CARPET_DOWN"}


class Map:
    def __init__(self, name, width, height, tileset, constant):
        self.name, self.constant = name, constant
        self.width, self.height = width * 2, height * 2
        self.blocks = (ROOT / f"maps/{name}.blk").read_bytes()
        assert len(self.blocks) == width * height, (name, "block dimensions")
        self.collisions = []
        for line in (ROOT / f"data/tilesets/{tileset}_collision.asm").read_text().splitlines():
            if "tilecoll" in line:
                fields = line.split("tilecoll")[1].split(";")[0]
                self.collisions.append([field.strip() for field in fields.split(",")])
        metatiles = (ROOT / f"data/tilesets/{tileset}_metatiles.bin").read_bytes()
        assert len(metatiles) % 16 == 0
        assert max(self.blocks) < len(metatiles) // 16 <= 128
        assert max(self.blocks) < len(self.collisions)
        self.objects, self.warps, self.background = [], [], []
        for line in (ROOT / f"maps/{name}.asm").read_text().splitlines():
            match = re.search(r"(object_event|warp_event|bg_event)\s+(\d+),\s*(\d+), (.*)", line)
            if not match:
                continue
            kind, x, y, tail = match.groups()
            position = (int(x), int(y))
            assert self.in_bounds(position), (name, "event outside map", position)
            collection = {"object_event": self.objects, "warp_event": self.warps,
                          "bg_event": self.background}[kind]
            collection.append((position, tail))
        assert len({p for p, _ in self.objects}) == len(self.objects), (name, "overlapping objects")

    def in_bounds(self, position):
        x, y = position
        return 0 <= x < self.width and 0 <= y < self.height

    def collision(self, position):
        x, y = position
        block = self.blocks[y // 2 * (self.width // 2) + x // 2]
        return self.collisions[block][y % 2 * 2 + x % 2]

    def floor(self, position, cut=False):
        if not self.in_bounds(position):
            return False
        collision = self.collision(position)
        return collision in FLOORS or (cut and collision == "CUT_TREE")

    def reachable(self, start, cut=False, extra_blocked=()):
        blocked = {position for position, _ in self.objects} | set(extra_blocked)
        seen, queue = {start}, deque([start])
        while queue:
            x, y = queue.popleft()
            for dx, dy in DIRECTIONS:
                neighbor = (x + dx, y + dy)
                if neighbor in blocked or neighbor in seen:
                    continue
                if not self.floor(neighbor, cut):
                    # A southbound hop crosses the ledge tile and lands beyond it.
                    if (dy != 1 or not self.in_bounds(neighbor)
                            or self.collision(neighbor) != "HOP_DOWN"):
                        continue
                    neighbor = (neighbor[0], neighbor[1] + 1)
                    if neighbor in blocked or neighbor in seen or not self.floor(neighbor, cut):
                        continue
                seen.add(neighbor)
                queue.append(neighbor)
        return seen

    def interactions_reachable(self, reachable):
        for (x, y), tail in self.objects + self.background:
            assert any((x + dx, y + dy) in reachable for dx, dy in DIRECTIONS), (
                self.name, "unreachable interaction", (x, y), tail)


def main():
    route = Map("Route2", 10, 36, "route_2", "ROUTE_2")
    forest = Map("ViridianForest", 17, 24, "viridian_forest", "VIRIDIAN_FOREST")
    north = Map("ViridianForestNorthGate", 5, 4, "gate", "VIRIDIAN_FOREST_NORTH_GATE")
    south = Map("ViridianForestSouthGate", 5, 4, "gate", "VIRIDIAN_FOREST_SOUTH_GATE")
    maps = {m.constant: m for m in (route, forest, north, south)}
    for current in maps.values():
        for position, _ in current.objects:
            assert current.floor(position), (current.name, "object on impassable tile", position)
        for position, tail in current.warps:
            assert current.collision(position) in WARPS, (current.name, "non-warp collision", position)
            destination, index = [field.strip() for field in tail.split(",")]
            if destination in maps:
                target = maps[destination]
                assert 1 <= int(index) <= len(target.warps)
                _, backlink = target.warps[int(index) - 1]
                assert backlink.split(",")[0].strip() == current.constant, (
                    current.name, "warp does not return to originating map", position)

    # Main journey must work before Cut and before picking up any items.
    for current, start, goal in (
        (route, (8, 71), (3, 43)), (route, (3, 43), (8, 71)),
        (route, (3, 11), (8, 0)), (route, (8, 0), (3, 11)),
        (forest, (16, 47), (1, 0)), (forest, (1, 0), (16, 47)),
        (north, (4, 0), (4, 7)), (north, (4, 7), (4, 0)),
        (south, (4, 0), (4, 7)), (south, (4, 7), (4, 0)),
    ):
        assert goal in current.reachable(start), (current.name, "blocked journey", start, goal)

    route.interactions_reachable(route.reachable((8, 71), cut=True)
                                 | route.reachable((8, 0), cut=True))
    forest.interactions_reachable(forest.reachable((16, 47)))
    for gate in (north, south):
        gate.interactions_reachable(gate.reachable((4, 0)))

    # None of the retained level-30+ trainers may see the mandatory main path.
    main_path = route.reachable((8, 71)) | route.reachable((8, 0))
    vectors = {"LEFT": (-1, 0), "RIGHT": (1, 0), "DOWN": (0, 1)}
    for (x, y), tail in route.objects:
        if "OBJECTTYPE_TRAINER" not in tail:
            continue
        facing = re.search(r"SPRITEMOVEDATA_STANDING_(\w+)", tail)
        sight = int(tail.split(",")[8])
        facings = (vectors[facing[1]],) if facing else DIRECTIONS
        for dx, dy in facings:
            for distance in range(1, sight + 1):
                position = (x + dx * distance, y + dy * distance)
                if not route.floor(position):
                    break
                assert position not in main_path, ("mandatory high-level battle", tail)

    # Sign graphics must match the script positions, including after cutting grass.
    blocks = (ROOT / "data/tilesets/viridian_forest_metatiles.bin").read_bytes()
    sign = bytes((0x01, 0x06, 0x15, 0x16))
    def quadrant(block, x, y):
        base = block * 16 + (y % 2) * 8 + (x % 2) * 2
        return bytes(blocks[base + offset] for offset in (0, 1, 4, 5))

    map_entry = next(line for line in (ROOT / "data/maps/maps.asm").read_text().splitlines()
                     if line.strip().startswith("map ViridianForest,"))
    assert "PALETTE_NITE" in map_entry, "forest should stay dim during the day"

    drawn_signs = {(x, y) for y in range(forest.height) for x in range(forest.width)
                   if quadrant(forest.blocks[y // 2 * (forest.width // 2) + x // 2], x, y) == sign}
    readable_signs = {position for position, tail in forest.background if "BGEVENT_READ" in tail}
    assert drawn_signs == readable_signs, ("misplaced sign graphics", drawn_signs ^ readable_signs)
    replacements = (ROOT / "data/collision/field_move_blocks.asm").read_text()
    replacements = replacements.split(".viridian_forest:\n")[1].split(".forest:\n")[0]
    for old, new in re.findall(r"db \$(\w+), \$(\w+), 1", replacements):
        for x, y in readable_signs:
            source = forest.blocks[y // 2 * (forest.width // 2) + x // 2]
            if source == int(old, 16):
                assert quadrant(int(new, 16), x, y) == sign, "Cut changed a sign's appearance"

    assert not any("BGEVENT_ITEM" in tail for _, tail in route.background)
    assert len(forest.objects) == 10
    assert sum("OBJECTTYPE_TRAINER" in tail for _, tail in forest.objects) == 5
    assert sum("OBJECTTYPE_ITEMBALL" in tail for _, tail in forest.objects) == 3
    assert sum("BGEVENT_ITEM" in tail for _, tail in forest.background) == 2
    print("PASS: dimensions, collision, reciprocal forest warps, travel in both directions,")
    print("      reachable interactions, optional Crystal trainers, forest content counts,")
    print("      fixed forest palette.")


if __name__ == "__main__":
    main()
