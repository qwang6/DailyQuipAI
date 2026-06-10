"""Line-by-line Python port of DailyQuipAI/Features/PhysicsSandbox/SandboxEngine.swift.

Used to validate the cellular-automaton rules in an environment without a
Swift toolchain. Any change to the Swift engine must be mirrored here and
re-verified with sandbox_engine_tests.py.
"""

MASK64 = (1 << 64) - 1

EMPTY = 0
WALL = 1
SAND = 2
WATER = 3


class SandboxRNG:
    """SplitMix64, identical to the Swift SandboxRNG."""

    def __init__(self, seed):
        self.state = seed & MASK64

    def next(self):
        self.state = (self.state + 0x9E3779B97F4A7C15) & MASK64
        z = self.state
        z = ((z ^ (z >> 30)) * 0xBF58476D1CE4E5B9) & MASK64
        z = ((z ^ (z >> 27)) * 0x94D049BB133111EB) & MASK64
        return z ^ (z >> 31)

    def next_bool(self):
        return (self.next() & 1) == 1


class SandboxEngine:
    """Falling-sand cellular automaton.

    Coordinates: x in [0, width) left to right, y in [0, height) top to
    bottom. Gravity points toward larger y. Grid edges behave like walls.
    Each particle moves at most one cell per step.
    """

    def __init__(self, width, height, seed=0xDA11C0DE):
        assert width > 0 and height > 0
        self.width = width
        self.height = height
        self.cells = [EMPTY] * (width * height)
        self.moved = [False] * (width * height)
        self.rng = SandboxRNG(seed)
        self.step_count = 0

    def contains(self, x, y):
        return 0 <= x < self.width and 0 <= y < self.height

    def index(self, x, y):
        return y * self.width + x

    def cell(self, x, y):
        return self.cells[self.index(x, y)]

    def set(self, x, y, value):
        if self.contains(x, y):
            self.cells[self.index(x, y)] = value

    def count(self, cell_type):
        return sum(1 for c in self.cells if c == cell_type)

    def clear(self):
        self.cells = [EMPTY] * (self.width * self.height)
        self.step_count = 0

    def paint(self, center_x, center_y, radius, cell_type):
        for dy in range(-radius, radius + 1):
            for dx in range(-radius, radius + 1):
                if dx * dx + dy * dy <= radius * radius:
                    self.set(center_x + dx, center_y + dy, cell_type)

    def step(self):
        for i in range(len(self.moved)):
            self.moved[i] = False
        left_to_right = self.step_count % 2 == 0
        y = self.height - 1
        while y >= 0:
            for col in range(self.width):
                x = col if left_to_right else self.width - 1 - col
                i = self.index(x, y)
                if self.moved[i]:
                    continue
                c = self.cells[i]
                if c == SAND:
                    self._update_sand(x, y)
                elif c == WATER:
                    self._update_water(x, y)
            y -= 1
        self.step_count += 1

    def _update_sand(self, x, y):
        src = self.index(x, y)
        if y + 1 >= self.height:
            return  # resting on the floor
        below = self.index(x, y + 1)
        if self.cells[below] == EMPTY:
            self._move(src, below)
            return
        if self.cells[below] == WATER and not self.moved[below]:
            self._swap(src, below)
            return
        first = 1 if self.rng.next_bool() else -1
        for dx in (first, -first):
            nx = x + dx
            if 0 <= nx < self.width:
                diag = self.index(nx, y + 1)
                if self.cells[diag] == EMPTY:
                    self._move(src, diag)
                    return

    def _update_water(self, x, y):
        src = self.index(x, y)
        if y + 1 < self.height:
            below = self.index(x, y + 1)
            if self.cells[below] == EMPTY:
                self._move(src, below)
                return
            first = 1 if self.rng.next_bool() else -1
            for dx in (first, -first):
                nx = x + dx
                if 0 <= nx < self.width:
                    diag = self.index(nx, y + 1)
                    if self.cells[diag] == EMPTY:
                        self._move(src, diag)
                        return
        first = 1 if self.rng.next_bool() else -1
        for dx in (first, -first):
            nx = x + dx
            if 0 <= nx < self.width:
                side = self.index(nx, y)
                if self.cells[side] == EMPTY:
                    self._move(src, side)
                    return

    def _move(self, src, dst):
        self.cells[dst] = self.cells[src]
        self.cells[src] = EMPTY
        self.moved[dst] = True

    def _swap(self, a, b):
        self.cells[a], self.cells[b] = self.cells[b], self.cells[a]
        self.moved[a] = True
        self.moved[b] = True
