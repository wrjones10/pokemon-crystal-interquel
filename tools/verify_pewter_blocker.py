#!/usr/bin/env python3
"""Check Pewter's exit barrier and execute its scripted movement against the map.

Build both ROMs first, then run: python3 tools/verify_pewter_blocker.py
"""
from pathlib import Path
import re
from verify_route2 import Map, ROOT

BEAT = "EVENT_BEAT_BROCK"
HIDDEN = "EVENT_PEWTER_CITY_GYM_BLOCKER"
GUIDE = "PEWTERCITY_GYM_BLOCKER"
COOLTRAINER = "PEWTERCITY_COOLTRAINER_F"
DIRECTIONS = ((0, 1), (0, -1), (-1, 0), (1, 0))
SOURCE = (ROOT / "maps/PewterCity.asm").read_text()


def read_script():
    labels, instructions, scope = {}, [], ""
    for line in SOURCE.splitlines():
        line = line.split(";")[0].strip()
        if not line:
            continue
        if line.endswith(":"):
            label = line[:-1]
            if label.startswith("."):
                label = scope + label
            else:
                scope = label
            labels[label] = len(instructions)
        else:
            instructions.append((scope, line))
    return labels, instructions


class ScriptCheck:
    def __init__(self, stem, city):
        self.city = city
        self.labels, self.instructions = read_script()
        self.symbols = {}
        for line in (ROOT / f"{stem}.sym").read_text().splitlines():
            match = re.match(r"([\da-f]+):([\da-f]+) (.+)", line)
            if match:
                self.symbols[match[3]] = (int(match[1], 16), int(match[2], 16))
        self.rom = (ROOT / f"{stem}.gbc").read_bytes()

    def movement(self, name):
        bank, address = self.symbols[name]
        offset = bank * 0x4000 + address - 0x4000
        for command in self.rom[offset:offset + 100]:
            if command == 0x47:  # step_end
                return
            if command < 4:  # turn_head
                continue
            assert 0x0c <= command < 0x10, (name, "unexpected movement", command)
            yield DIRECTIONS[command & 3]
        raise AssertionError((name, "unterminated movement"))

    def execute(self, label):
        pc, value = self.labels[label], 0
        for _ in range(250):
            scope, line = self.instructions[pc]
            pc += 1
            command, _, parameters = line.partition(" ")
            args = [field.strip() for field in parameters.split(",")]
            target = lambda name: self.labels[scope + name if name.startswith(".") else name]
            if command in ("end", "endcallback"):
                return
            if command == "checkevent":
                value = self.flags.get(args[0], False)
            elif command in ("setevent", "clearevent"):
                self.flags[args[0]] = command == "setevent"
            elif command == "readvar":
                value = self.positions["PLAYER"][0 if args[0] == "VAR_XCOORD" else 1]
            elif command == "iftrue" and value:
                pc = target(args[0])
            elif command == "ifequal" and value == int(args[0]):
                pc = target(args[1])
            elif command == "sjump":
                pc = target(args[0])
            elif command in ("appear", "disappear"):
                self.visible[args[0]] = command == "appear"
                if args[0] == GUIDE:
                    self.flags[HIDDEN] = command == "disappear"
            elif command == "moveobject":
                assert not self.visible[args[0]], "Reset must happen offscreen, after hiding"
                self.positions[args[0]] = (int(args[1]), int(args[2]))
            elif command == "follow":
                assert args == [GUIDE, "PLAYER"]
                self.following = True
            elif command == "stopfollow":
                self.following = False
            elif command == "applymovement":
                actor, path = args
                assert actor == "PLAYER" or self.visible[actor], ("moving hidden actor", actor)
                for dx, dy in self.movement(path):
                    old = self.positions[actor]
                    new = (old[0] + dx, old[1] + dy)
                    assert self.city.collision(new) == "FLOOR", (path, "unsafe movement tile", new)
                    assert new != self.positions[GUIDE if actor == "PLAYER" else "PLAYER"], (
                        path, "player/guide overlap", new)
                    # Other wandering NPCs may occupy any point in their ranges.
                    occupied = {(x, 17) for x in range(27, 32)}
                    occupied |= {(x, y) for x in range(12, 17) for y in range(27, 32)}
                    occupied |= {(30, 3), (32, 3)}
                    if self.visible[COOLTRAINER]:
                        occupied |= {(x, y) for x in range(17, 22) for y in range(9, 14)}
                    assert new not in occupied, (path, "possible NPC collision", new)
                    if self.following and actor == GUIDE:
                        self.positions["PLAYER"] = old
                    self.positions[actor] = new
        raise AssertionError("Script did not end")

    def check(self, start, beaten, old_hidden):
        self.flags = {BEAT: beaten, HIDDEN: old_hidden}
        self.positions = {GUIDE: (35, 16), "PLAYER": start}
        self.visible = {GUIDE: True, COOLTRAINER: True}
        self.following = False
        self.execute("PewterCityGymBlockerCallback")
        assert self.flags[HIDDEN] == beaten
        self.visible[GUIDE] = not self.flags[HIDDEN]  # LoadObjectMasks
        self.execute("PewterCityGymBlockerScript")
        assert self.flags[BEAT] == beaten, "Escort must not defeat Brock"
        assert not self.following and self.visible[COOLTRAINER]
        assert self.visible[GUIDE] == (not beaten)
        assert self.positions[GUIDE] == (35, 16), "Guide must reset for repeat attempts"
        assert self.positions["PLAYER"] == (start if beaten else (11, 18))


def main():
    city = Map("PewterCity", 20, 18, "kanto", "PEWTER_CITY")
    triggers = {(int(x), int(y)) for x, y in re.findall(
        r"coord_event\s+(\d+),\s*(\d+), -1, PewterCityGymBlockerScript", SOURCE)}
    assert triggers >= {(35, 17), (36, 17)} | {(37, y) for y in range(16, 20)}
    starts = triggers | {(34, 16), (36, 16)}  # direct interactions from either side
    reachable = city.reachable((16, 18), extra_blocked=triggers)
    assert not any(x == 39 for x, _ in reachable), "Exit bypasses blocker"
    assert (16, 18) in reachable  # Gym approach remains available
    city.objects = [(p, tail) for p, tail in city.objects if "PewterCityGymBlockerScript" not in tail]
    assert (39, 18) in city.reachable((16, 18)), "Exit remains blocked after Brock"
    for stem in ("pokecrystal", "pokecrystal_debug"):
        script = ScriptCheck(stem, city)
        for start in starts:
            for beaten in (False, True):
                for old_hidden in (False, True):
                    script.check(start, beaten, old_hidden)
        print(f"PASS {stem}: exit coverage, 8 approaches, compiled movements, NPC collisions,")
        print("      visibility callbacks, repeat escort reset and Brock flag protection.")


if __name__ == "__main__":
    main()
