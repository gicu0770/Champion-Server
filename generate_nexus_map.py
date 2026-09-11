import os
import math
import struct

# Special OTBM byte tokens
NODE_START = 0xFE
NODE_END = 0xFF
ESCAPE = 0xFD

OTBM_ROOTV1 = 0
OTBM_MAP_DATA = 2
OTBM_TILE_AREA = 4
OTBM_TILE = 5
OTBM_ITEM = 6
OTBM_TOWNS = 12
OTBM_TOWN = 13

OTBM_ATTR_DESCRIPTION = 1
OTBM_ATTR_TILE_FLAGS = 3
OTBM_ATTR_ITEM = 9
OTBM_ATTR_EXT_SPAWN_FILE = 11
OTBM_ATTR_EXT_HOUSE_FILE = 13

OTBM_TILEFLAG_PROTECTIONZONE = 1

# ==============================================================================
# VERIFIED 10.98 PALETTE (Exact User-Specified IDs & Border 120)
# ==============================================================================

# User: "Uzyj tych borderów do grass wygladaja ladniej" (Image 1: 7653-7664)
# Ground brush: 'grass (alternate border)' uses items 9043-9058 and border 120!
def get_grass_tile(rnd):
    # 9043 is base clean grass (80%), 9044-9058 are natural variations (20%)
    if rnd < 0.80:
        return 9043
    else:
        return 9044 + int(((rnd - 0.80) / 0.20) * 15) % 15

# User Requested Grounds & Doodads
TILE_ROCK_SOIL = 4407     # Rock soil ground (Photo 1 & Photo 2)
TILE_WATER_POND = 4664    # Rivers and small scenic ponds
TILE_MOUNTAIN_GROUND = 919 # Mountain top ground
STONE_PEBBLE_3613 = 3613  # Photo 1 field stones / pebbles

# Desert / Lightning Grounds (User-Requested: 231, 25013, 11077, 708)
TILE_SAND_231 = 231       # Desert sand (thick border)
TILE_DRY_FLOOR = 25013    # Krailos dry cracked floor
TILE_MUD_SAND = 11077     # Mud sand
TILE_TAR = 708            # Desert TAR / Oil lake (hazard)

# Snow / Ice Grounds
TILE_SNOW = 670           # Snow floor
TILE_ICE = 671            # Ice floor (skating rinks / lakes)

# Earth / Poison Swamp Hazards (User-Requested: 4691 solid block)
TILE_POISON_SWAMP = 4691  # Deep poison swamp hazard (solid block)
TILE_DIRT = 103           # Standard dirt road (used for all visible highways)
TILE_EARTH = 101          # Classic earth (100% clean, NO doodads on 101!)
TILE_GRAVEL = 4595        # Natural gravel

# Volcanic / Fire Grounds & Hazards (User: 11561 ground & 23857 black lava border)
TILE_STONE_FLOOR = 413    # Ancient volcanic stone floor
TILE_BURNT_11561 = 11561  # Scorched / burnt earth ground (User: "W fire biom uzyj 11561 grounda bardziej spalonego niz skale")
TILE_LAVA = 23857         # Lava ground with black borders (Border ID 211 / items 15503-15514)
WALL_VOLCANO = 4468       # Mountain rock obstacle in volcano realm

# Void SideMap Grounds & Structures (Auto-bordering in RME)
TILE_DARK_SCALED = 25549      # Main Void ground: dark scaled ground (RME brush 'dark scaled ground', border 204)
TILE_VOID_PATCH = 25753       # Secondary Void patch: overgrown rift floor (RME brush 'unknown7', border 205)
VOID_OBSTACLE = 17854         # Inaccessible Void basalt mountain (RME brush 'basalt', border 61 / basalt walls)
VOID_CRYSTAL_OBSTACLE = 20724 # Inaccessible purple crystal mountain (RME brush 'purple crystal mountain', border 64)
CRYSTAL_BLACK_LARGE = 11753   # Large black crystal doodad
VOID_TREE_1 = 35854           # Void purple tree 1
VOID_TREE_2 = 35855           # Void purple tree 2
VOID_TREE_3 = 35882           # Void purple tree 3
TILE_WATER = 493          # Citadel pond

# Walls & Perimeter Structures
WALL_STONE = 9118
WALL_STONE_ALT = 3376
WALL_MOUNTAIN = 4468

# Trees & Flora
TREE_FIR = 2700
TREE_SYCAMORE = 2701
TREE_WILLOW = 2702
TREE_BEECH = 2707
TREE_POPLAR = 2708
TREE_PINE = 2705
TREE_DEAD_1 = 2709
TREE_DEAD_2 = 2710
TREE_DEAD_3 = 2717
TREE_SNOWY_ALIVE = 7023
TREE_SNOWY_2 = 2698
TREE_SNOWY_DEAD = 7020
TREE_STUMP_1 = 2711
TREE_STUMP_2 = 2712
TREE_MANGROVE_1 = 5393
TREE_MANGROVE_2 = 5397
TREE_BURNT = 2246

# Bushes & Shrubs
BUSH_GREEN_1 = 2767
BUSH_GREEN_2 = 2768
BUSH_BLUEBERRY_1 = 2785
BUSH_BLUEBERRY_2 = 2786
BUSH_DEAD_1 = 2770
BUSH_DEAD_2 = 2784
BUSH_VENOMOUS = 10870
FERN_JUNGLE_1 = 4009
FERN_JUNGLE_2 = 4010

# Biome Doodads
CACTUS_LARGE_1 = 2723
CACTUS_LARGE_2 = 2727
CACTUS_SMALL_1 = 2728
CACTUS_SMALL_2 = 2729
BONES_RIBCAGE = 2229
BONES_SMALL_1 = 2230
BONES_SMALL_2 = 2231

SNOW_DRIFT_1 = 6610
SNOW_DRIFT_2 = 6611
STALAGMITE = 387
CRYSTAL_BLUE_1 = 8634
CRYSTAL_BLUE_2 = 8638

MAGMA_STONE = 22142
LAVA_HOLE_1 = 388
LAVA_HOLE_2 = 389
CRYSTAL_RED_1 = 8635
CRYSTAL_RED_2 = 8639

CRYSTAL_PURPLE_1 = 11534
CRYSTAL_PURPLE_2 = 11536
CRYSTAL_PRISM_1 = 8633
CRYSTAL_PRISM_2 = 8637
JAGGED_STONE_WALKABLE = 8220
GARGOYLE_STONE = 9487

ROCK_BOULDER = 1304
ROCK_MOSSY = 1353
ROCK_SOLID = 1293
ROCK_SMOOTH = 1295
ROCK_BROWN_1 = 1290
ROCK_BROWN_2 = 1292
ROCK_SNOWY_1 = 7016
ROCK_SNOWY_2 = 7017
ROCK_DARK = 8020
ROCK_PILE = 1335
ROCK_PILE_SAND = 481
ROCK_PILE_ICE = 483
MUD_CAVE_ROCK = 5747

STONE_MED_1 = 3607
STONE_MED_2 = 3608
STONE_SMALL_1 = 3610
STONE_SMALL_2 = 3611
STONE_SMALL_3 = 3612
PEBBLE_1 = 1285
PEBBLE_2 = 1294
PEBBLE_3 = 3615
PEBBLE_4 = 3616

TUFT_GRASS_1 = 6218
TUFT_GRASS_2 = 6219
FLOWER_YELLOW_1 = 4152
FLOWER_WHITE_1 = 4156
MUSHROOM_1 = 4168
MUSHROOM_2 = 4169
SWAMP_KELP = 5421
WOOD_BRANCH_1 = 6222
WOOD_BRANCH_2 = 6223
TOMBSTONE_1 = 12950
TOMBSTONE_2 = 12956


class Node:
    def __init__(self, node_type, data=b""):
        self.node_type = node_type
        self.data = bytearray(data)
        self.children = []

    def add_child(self, child):
        self.children.append(child)
        return child

    def add_attr(self, attr_id, val_bytes):
        self.data.append(attr_id)
        self.data.extend(struct.pack("<H", len(val_bytes)))
        self.data.extend(val_bytes)

    def serialize(self):
        out = bytearray()
        out.append(NODE_START)
        out.append(self.node_type)
        for b in self.data:
            if b in (NODE_START, NODE_END, ESCAPE):
                out.append(ESCAPE)
            out.append(b)
        for child in self.children:
            out.extend(child.serialize())
        out.append(NODE_END)
        return out


def hash2d(x, y, seed=1337):
    n = (x * 374761393 + y * 668265263 + seed * 1274126177) & 0x7FFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0x7FFFFFFF
    return ((n ^ (n >> 16)) & 0xFFFFFF) / 16777215.0


def smooth_noise(x, y, scale=18.0, seed=1337):
    gx = x / scale
    gy = y / scale
    x0 = int(math.floor(gx))
    y0 = int(math.floor(gy))
    x1 = x0 + 1
    y1 = y0 + 1

    fx = gx - x0
    fy = gy - y0
    sx = fx * fx * (3.0 - 2.0 * fx)
    sy = fy * fy * (3.0 - 2.0 * fy)

    n00 = hash2d(x0, y0, seed)
    n10 = hash2d(x1, y0, seed)
    n01 = hash2d(x0, y1, seed)
    n11 = hash2d(x1, y1, seed)

    nx0 = n00 + sx * (n10 - n00)
    nx1 = n01 + sx * (n11 - n01)
    return nx0 + sy * (nx1 - nx0)


def generate_nexus():
    print("Generating Nexus Map with Organic Blending, Expanded Boss Realms & Alternate Grass Borders...")

    CENTER_X = 675
    CENTER_Y = 1040
    MAP_Z = 7

    WORLD_WIDTH = 4096
    WORLD_HEIGHT = 4096

    RADIUS_WORLD = 420
    MIN_X = CENTER_X - RADIUS_WORLD
    MAX_X = CENTER_X + RADIUS_WORLD
    MIN_Y = CENTER_Y - RADIUS_WORLD
    MAX_Y = CENTER_Y + RADIUS_WORLD

    # 4 Elemental Boss Arenas (Reduced by 25% from 30)
    PIT_NW_X, PIT_NW_Y = CENTER_X - 260, CENTER_Y - 260  # ICE
    PIT_NE_X, PIT_NE_Y = CENTER_X + 260, CENTER_Y - 260  # LIGHTNING (Sand)
    PIT_SW_X, PIT_SW_Y = CENTER_X - 260, CENTER_Y + 260  # EARTH / Poison Swamp
    PIT_SE_X, PIT_SE_Y = CENTER_X + 260, CENTER_Y + 260  # FIRE / Volcano Lava
    PIT_RADIUS = 23

    # 3 Entrance angles for each Boss Pit
    pit_gate_angles = {
        "NW": [0.785, -0.20, 1.77],    # ICE: SE (Citadel), East, South
        "NE": [2.356, 3.34, 1.37],     # LIGHTNING: SW (Citadel), West, South
        "SW": [-0.785, -1.77, 0.20],   # EARTH: NE (Citadel), North, East
        "SE": [-2.356, -1.37, -3.34]   # FIRE: NW (Citadel), North, West
    }

    # Citadel Shops (Open 3-tile doorways)
    houses = [
        (CENTER_X - 16, CENTER_Y - 16, 7, 6, WALL_STONE, TILE_STONE_FLOOR, "S"),
        (CENTER_X + 9, CENTER_Y - 16, 7, 6, WALL_STONE, TILE_STONE_FLOOR, "S"),
        (CENTER_X - 16, CENTER_Y + 10, 7, 6, WALL_STONE, TILE_STONE_FLOOR, "N"),
        (CENTER_X + 9, CENTER_Y + 10, 7, 6, WALL_STONE, TILE_STONE_FLOOR, "N"),
    ]

    house_tiles = {}
    for (hx, hy, hw, hh, wid, fid, door) in houses:
        for ry in range(hh):
            for rx in range(hw):
                tx = hx + rx
                ty = hy + ry
                is_wall = (rx == 0 or rx == hw - 1 or ry == 0 or ry == hh - 1)
                if door == "S" and ry == hh - 1 and abs(rx - hw // 2) <= 1: is_wall = False
                elif door == "N" and ry == 0 and abs(rx - hw // 2) <= 1: is_wall = False
                elif door == "E" and rx == hw - 1 and abs(ry - hh // 2) <= 1: is_wall = False
                elif door == "W" and rx == 0 and abs(ry - hh // 2) <= 1: is_wall = False

                house_tiles[(tx, ty)] = {
                    "ground": fid,
                    "wall": wid if is_wall else None
                }

    # =========================================================================
    # PRE-COMPUTE OBSTACLE CLUSTERS
    # =========================================================================
    print("Pre-computing natural obstacle clusters...")
    clusters = {}

    CELL_SIZE = 8
    min_cx = MIN_X // CELL_SIZE
    max_cx = MAX_X // CELL_SIZE
    min_cy = MIN_Y // CELL_SIZE
    max_cy = MAX_Y // CELL_SIZE

    for c_cy in range(min_cy, max_cy + 1):
        for c_cx in range(min_cx, max_cx + 1):
            jitter_x = int(hash2d(c_cx, c_cy, 11) * (CELL_SIZE - 2)) + 1
            jitter_y = int(hash2d(c_cx, c_cy, 22) * (CELL_SIZE - 2)) + 1
            ax = c_cx * CELL_SIZE + jitter_x
            ay = c_cy * CELL_SIZE + jitter_y

            dx = ax - CENTER_X
            dy = ay - CENTER_Y
            dist = math.sqrt(dx * dx + dy * dy)

            if dist > RADIUS_WORLD - 8 or dist <= 35:
                continue

            # Skip clusters inside boss pits
            if math.sqrt((ax - PIT_NW_X)**2 + (ay - PIT_NW_Y)**2) <= PIT_RADIUS + 2: continue
            if math.sqrt((ax - PIT_NE_X)**2 + (ay - PIT_NE_Y)**2) <= PIT_RADIUS + 2: continue
            if math.sqrt((ax - PIT_SW_X)**2 + (ay - PIT_SW_Y)**2) <= PIT_RADIUS + 2: continue
            if math.sqrt((ax - PIT_SE_X)**2 + (ay - PIT_SE_Y)**2) <= PIT_RADIUS + 2: continue

            spawn_prob = hash2d(c_cx, c_cy, 33)
            if spawn_prob > 0.48:
                continue

            # Multi-octave domain warping for cluster positioning
            warp_x = 32.0 * math.sin(ay * 0.035) + 18.0 * math.sin(ax * 0.07 + ay * 0.05)
            warp_y = 32.0 * math.sin(ax * 0.035) + 18.0 * math.cos(ax * 0.05 - ay * 0.07)
            w_ax = dx + warp_x
            w_ay = dy + warp_y
            w_dist = math.sqrt(w_ax * w_ax + w_ay * w_ay)

            cluster_type = hash2d(c_cx, c_cy, 44)
            shape_rnd = hash2d(c_cx, c_cy, 55)

            sat_offsets = [
                [(1, 0), (0, 1)],
                [(-1, 0), (0, -1)],
                [(1, 1), (1, 0)],
                [(-1, 1), (0, 1)],
                [(0, 1)],
                [(1, 0)]
            ][int(shape_rnd * 6) % 6]

            # 1. Ring 1: Breezy Meadows (w_dist <= 105)
            if w_dist <= 105:
                if cluster_type < 0.65:
                    tree_id = [TREE_SYCAMORE, TREE_BEECH, TREE_POPLAR, TREE_FIR][int(hash2d(ax, ay, 61) * 4)]
                    clusters[(ax, ay)] = tree_id
                    bush_id = [BUSH_GREEN_1, BUSH_GREEN_2, BUSH_BLUEBERRY_1, TREE_STUMP_1][int(hash2d(ax, ay, 62) * 4)]
                    ox1, oy1 = sat_offsets[0]
                    clusters[(ax + ox1, ay + oy1)] = bush_id
                    if len(sat_offsets) > 1:
                        ox2, oy2 = sat_offsets[1]
                        clusters[(ax + ox2, ay + oy2)] = [STONE_SMALL_1, STONE_SMALL_2, PEBBLE_1][int(hash2d(ax, ay, 63) * 3)]
                else:
                    boulder_id = [ROCK_BOULDER, ROCK_SMOOTH, ROCK_SOLID][int(hash2d(ax, ay, 71) * 3)]
                    clusters[(ax, ay)] = boulder_id
                    ox1, oy1 = sat_offsets[0]
                    clusters[(ax + ox1, ay + oy1)] = [STONE_MED_1, STONE_SMALL_2, ROCK_PILE][int(hash2d(ax, ay, 72) * 3)]

            # 2. Ring 2: Ancient Silverwood Forests (105 < w_dist <= 237)
            elif w_dist <= 237:
                if cluster_type < 0.55:
                    tree_id = [TREE_FIR, TREE_PINE, TREE_WILLOW, TREE_DEAD_1][int(hash2d(ax, ay, 81) * 4)]
                    clusters[(ax, ay)] = tree_id
                    ox1, oy1 = sat_offsets[0]
                    clusters[(ax + ox1, ay + oy1)] = [BUSH_GREEN_1, BUSH_DEAD_1, TREE_STUMP_2, FERN_JUNGLE_1][int(hash2d(ax, ay, 82) * 4)]
                    if len(sat_offsets) > 1:
                        ox2, oy2 = sat_offsets[1]
                        clusters[(ax + ox2, ay + oy2)] = [ROCK_MOSSY, TOMBSTONE_1, STONE_PEBBLE_3613][int(hash2d(ax, ay, 83) * 3)]
                else:
                    clusters[(ax, ay)] = [ROCK_MOSSY, ROCK_SOLID, ROCK_BOULDER][int(hash2d(ax, ay, 84) * 3)]
                    ox1, oy1 = sat_offsets[0]
                    clusters[(ax + ox1, ay + oy1)] = STONE_PEBBLE_3613

            # 3. Outer World: 4 Elemental Realms or Void SideMaps (w_dist > 237)
            else:
                # Check if cluster is in Void SideMaps
                side_noise_c = 30.0 * smooth_noise(ax, ay, 16.0, 333)
                d_boss_c = min(
                    math.sqrt((ax - PIT_NW_X)**2 + (ay - PIT_NW_Y)**2),
                    math.sqrt((ax - PIT_NE_X)**2 + (ay - PIT_NE_Y)**2),
                    math.sqrt((ax - PIT_SW_X)**2 + (ay - PIT_SW_Y)**2),
                    math.sqrt((ax - PIT_SE_X)**2 + (ay - PIT_SE_Y)**2)
                )
                is_void_c = False
                if d_boss_c > PIT_RADIUS + 38:
                    if w_ay < -275 + side_noise_c and abs(w_ax) <= 130 + side_noise_c: is_void_c = True
                    elif w_ay > 275 - side_noise_c and abs(w_ax) <= 130 + side_noise_c: is_void_c = True
                    elif w_ax < -275 + side_noise_c and abs(w_ay) <= 130 + side_noise_c: is_void_c = True
                    elif w_ax > 275 - side_noise_c and abs(w_ay) <= 130 + side_noise_c: is_void_c = True

                if is_void_c:
                    # Void flora & crystal clusters (doodads sitting on walkable ground)
                    if cluster_type < 0.55:
                        tree_void = [VOID_TREE_1, VOID_TREE_2, VOID_TREE_3][int(hash2d(ax, ay, 111) * 3)]
                        clusters[(ax, ay)] = tree_void
                        ox1, oy1 = sat_offsets[0]
                        clusters[(ax + ox1, ay + oy1)] = [CRYSTAL_PURPLE_1, CRYSTAL_PURPLE_2, JAGGED_STONE_WALKABLE][int(hash2d(ax, ay, 112) * 3)]
                    else:
                        clusters[(ax, ay)] = CRYSTAL_BLACK_LARGE
                        ox1, oy1 = sat_offsets[0]
                        clusters[(ax + ox1, ay + oy1)] = [CRYSTAL_PURPLE_1, CRYSTAL_PURPLE_2, JAGGED_STONE_WALKABLE][int(hash2d(ax, ay, 113) * 3)]

                # NW: ICE REALM
                elif w_ax < 0 and w_ay < 0:
                    if cluster_type < 0.50:
                        clusters[(ax, ay)] = [TREE_SNOWY_ALIVE, TREE_SNOWY_2, TREE_SNOWY_DEAD][int(hash2d(ax, ay, 91) * 3)]
                        ox1, oy1 = sat_offsets[0]
                        clusters[(ax + ox1, ay + oy1)] = [ROCK_SNOWY_1, STALAGMITE, SNOW_DRIFT_1][int(hash2d(ax, ay, 92) * 3)]
                    else:
                        clusters[(ax, ay)] = [ROCK_SNOWY_1, ROCK_SNOWY_2, ROCK_PILE_ICE][int(hash2d(ax, ay, 93) * 3)]
                        ox1, oy1 = sat_offsets[0]
                        clusters[(ax + ox1, ay + oy1)] = [STALAGMITE, CRYSTAL_BLUE_1, SNOW_DRIFT_2][int(hash2d(ax, ay, 94) * 3)]

                # NE: LIGHTNING DESERT REALM
                elif w_ax > 0 and w_ay < 0:
                    if cluster_type < 0.50:
                        clusters[(ax, ay)] = [CACTUS_LARGE_1, CACTUS_LARGE_2, TREE_DEAD_2][int(hash2d(ax, ay, 95) * 3)]
                        ox1, oy1 = sat_offsets[0]
                        clusters[(ax + ox1, ay + oy1)] = [CACTUS_SMALL_1, CACTUS_SMALL_2, BUSH_DEAD_1][int(hash2d(ax, ay, 96) * 3)]
                    else:
                        clusters[(ax, ay)] = [ROCK_BROWN_1, ROCK_BROWN_2, ROCK_PILE_SAND][int(hash2d(ax, ay, 97) * 3)]
                        ox1, oy1 = sat_offsets[0]
                        clusters[(ax + ox1, ay + oy1)] = [BONES_RIBCAGE, BONES_SMALL_1, STONE_PEBBLE_3613][int(hash2d(ax, ay, 98) * 3)]

                # SW: EARTH / POISON SWAMP REALM
                elif w_ax < 0 and w_ay > 0:
                    if cluster_type < 0.55:
                        clusters[(ax, ay)] = [TREE_MANGROVE_1, TREE_MANGROVE_2, TREE_WILLOW][int(hash2d(ax, ay, 99) * 3)]
                        ox1, oy1 = sat_offsets[0]
                        clusters[(ax + ox1, ay + oy1)] = [FERN_JUNGLE_1, FERN_JUNGLE_2, BUSH_VENOMOUS][int(hash2d(ax, ay, 100) * 3)]
                    else:
                        clusters[(ax, ay)] = [ROCK_MOSSY, MUD_CAVE_ROCK][int(hash2d(ax, ay, 101) * 2)]
                        ox1, oy1 = sat_offsets[0]
                        clusters[(ax + ox1, ay + oy1)] = [SWAMP_KELP, FERN_JUNGLE_1][int(hash2d(ax, ay, 102) * 2)]

                # SE: FIRE / VOLCANO REALM (Photo 2 style)
                else:
                    if cluster_type < 0.45:
                        clusters[(ax, ay)] = [TREE_BURNT, TREE_DEAD_1, TREE_PINE][int(hash2d(ax, ay, 103) * 3)]
                        ox1, oy1 = sat_offsets[0]
                        clusters[(ax + ox1, ay + oy1)] = [LAVA_HOLE_1, BUSH_DEAD_1][int(hash2d(ax, ay, 104) * 2)]
                    else:
                        clusters[(ax, ay)] = [MAGMA_STONE, ROCK_DARK, ROCK_BOULDER][int(hash2d(ax, ay, 105) * 3)]
                        ox1, oy1 = sat_offsets[0]
                        clusters[(ax + ox1, ay + oy1)] = [CRYSTAL_RED_1, STONE_MED_1][int(hash2d(ax, ay, 106) * 2)]

    print(f"Total cluster elements generated: {len(clusters)}")

    areas = {}

    def get_area_node(ax, ay):
        key = (ax, ay)
        if key not in areas:
            areas[key] = Node(OTBM_TILE_AREA, struct.pack("<HHB", ax, ay, MAP_Z))
        return areas[key]

    print("Building tiles with organic domain warping, grass 9043-9058, and irregular SideMaps...")
    tile_count = 0

    for y in range(MIN_Y, MAX_Y + 1):
        for x in range(MIN_X, MAX_X + 1):
            dx = x - CENTER_X
            dy = y - CENTER_Y
            dist = math.sqrt(dx * dx + dy * dy)

            if dist > RADIUS_WORLD:
                continue

            rnd = hash2d(x, y, 777)

            # =========================================================
            # MULTI-OCTAVE DOMAIN WARPING (Zero Straight Lines!)
            # =========================================================
            warp_x = 32.0 * math.sin(y * 0.035) + 18.0 * math.sin(x * 0.07 + y * 0.05) + 12.0 * math.cos(y * 0.12)
            warp_y = 32.0 * math.sin(x * 0.035) + 18.0 * math.cos(x * 0.05 - y * 0.07) + 12.0 * math.sin(x * 0.12)

            wx = dx + warp_x
            wy = dy + warp_y
            w_dist = math.sqrt(wx * wx + wy * wy)

            # Default: Alternate grass 9043-9058 (with thick border 120 from Image 1)
            ground_id = get_grass_tile(rnd)
            is_pz = False
            top_item = None
            is_path = False
            is_waypoint_marker = False

            # Distance to the 4 Boss Pits
            d_nw = math.sqrt((x - PIT_NW_X)**2 + (y - PIT_NW_Y)**2)
            d_ne = math.sqrt((x - PIT_NE_X)**2 + (y - PIT_NE_Y)**2)
            d_sw = math.sqrt((x - PIT_SW_X)**2 + (y - PIT_SW_Y)**2)
            d_se = math.sqrt((x - PIT_SE_X)**2 + (y - PIT_SE_Y)**2)

            in_pit = False

            # =========================================================
            # HIGHWAY SYSTEM: VISIBLE PROGRESSION PATHS
            # =========================================================
            # Cardinal Highways to Void SideMaps
            if y < CENTER_Y - 26 and y >= CENTER_Y - 370 and abs(dx) <= 20:
                dy_gate = (CENTER_Y - 26) - y
                curve_x = CENTER_X + 16.0 * math.sin(dy_gate * 0.035) + 7.0 * math.sin(dy_gate * 0.08)
                road_w = 2.4 + 0.6 * math.sin(dy_gate * 0.05)
                if abs(x - curve_x) <= road_w: is_path = True

            elif y > CENTER_Y + 26 and y <= CENTER_Y + 370 and abs(dx) <= 20:
                dy_gate = y - (CENTER_Y + 26)
                curve_x = CENTER_X - 16.0 * math.sin(dy_gate * 0.035) + 7.0 * math.cos(dy_gate * 0.075)
                road_w = 2.4 + 0.6 * math.cos(dy_gate * 0.05)
                if abs(x - curve_x) <= road_w: is_path = True

            elif x < CENTER_X - 26 and x >= CENTER_X - 370 and abs(dy) <= 20:
                dx_gate = (CENTER_X - 26) - x
                curve_y = CENTER_Y + 16.0 * math.sin(dx_gate * 0.035) + 7.0 * math.sin(dx_gate * 0.08)
                road_w = 2.4 + 0.6 * math.sin(dx_gate * 0.05)
                if abs(y - curve_y) <= road_w: is_path = True

            elif x > CENTER_X + 26 and x <= CENTER_X + 370 and abs(dy) <= 20:
                dx_gate = x - (CENTER_X + 26)
                curve_y = CENTER_Y - 16.0 * math.sin(dx_gate * 0.035) + 7.0 * math.cos(dx_gate * 0.075)
                road_w = 2.4 + 0.6 * math.cos(dx_gate * 0.05)
                if abs(y - curve_y) <= road_w: is_path = True

            # Diagonal Highways to the 4 Elemental Arenas
            if dx < -25 and dy < -25 and dist <= 380:
                t = min(1.0, max(0.0, (dist - 35) / 330))
                target_x = CENTER_X + (PIT_NW_X - CENTER_X) * t
                target_y = CENTER_Y + (PIT_NW_Y - CENTER_Y) * t
                curve_diag = 14.0 * math.sin(t * math.pi * 2.5)
                if math.sqrt((x - (target_x + curve_diag))**2 + (y - (target_y - curve_diag))**2) <= 2.4: is_path = True

            elif dx > 25 and dy < -25 and dist <= 380:
                t = min(1.0, max(0.0, (dist - 35) / 330))
                target_x = CENTER_X + (PIT_NE_X - CENTER_X) * t
                target_y = CENTER_Y + (PIT_NE_Y - CENTER_Y) * t
                curve_diag = 14.0 * math.sin(t * math.pi * 2.5)
                if math.sqrt((x - (target_x - curve_diag))**2 + (y - (target_y - curve_diag))**2) <= 2.4: is_path = True

            elif dx < -25 and dy > 25 and dist <= 380:
                t = min(1.0, max(0.0, (dist - 35) / 330))
                target_x = CENTER_X + (PIT_SW_X - CENTER_X) * t
                target_y = CENTER_Y + (PIT_SW_Y - CENTER_Y) * t
                curve_diag = 14.0 * math.sin(t * math.pi * 2.5)
                if math.sqrt((x - (target_x + curve_diag))**2 + (y - (target_y + curve_diag))**2) <= 2.4: is_path = True

            elif dx > 25 and dy > 25 and dist <= 380:
                t = min(1.0, max(0.0, (dist - 35) / 330))
                target_x = CENTER_X + (PIT_SE_X - CENTER_X) * t
                target_y = CENTER_Y + (PIT_SE_Y - CENTER_Y) * t
                curve_diag = 14.0 * math.sin(t * math.pi * 2.5)
                if math.sqrt((x - (target_x - curve_diag))**2 + (y - (target_y + curve_diag))**2) <= 2.4: is_path = True

            # Concentric Ring Crossroad Trails
            if 103 <= w_dist <= 107 and (abs(dx) <= 45 or abs(dy) <= 45): is_path = True
            if 173 <= w_dist <= 177 and (abs(dx) <= 70 or abs(dy) <= 70): is_path = True
            if 248 <= w_dist <= 252 and (abs(dx) <= 95 or abs(dy) <= 95): is_path = True

            for r_tr in (105, 175, 250):
                if abs(w_dist - r_tr) <= 1.5:
                    if abs(abs(dx) - abs(dy)) <= 3.0 or abs(dx) <= 3 or abs(dy) <= 3:
                        if 2.5 <= abs(x - CENTER_X) % 6 <= 3.5:
                            is_waypoint_marker = True

            # =========================================================
            # SCENIC RIVERS & SMALL PONDS 4664
            # =========================================================
            d_pond1 = math.sqrt((x - (CENTER_X - 45))**2 + (y - (CENTER_Y - 50))**2)
            d_pond2 = math.sqrt((x - (CENTER_X + 50))**2 + (y - (CENTER_Y + 45))**2)
            brook_x = (CENTER_X - 135) + 6.0 * math.sin((y - CENTER_Y) * 0.08)
            is_brook = (115 <= abs(y - CENTER_Y) <= 155 and abs(x - brook_x) <= 1.5 and dx < 0)
            is_pond = (d_pond1 <= 5.5 or d_pond2 <= 6.0 or is_brook)

            # =========================================================
            # BOSS PITS (Exact 3 Entrances)
            # =========================================================
            # NW ICE PIT
            if d_nw <= PIT_RADIUS:
                in_pit = True
                ang = math.atan2(y - PIT_NW_Y, x - PIT_NW_X)
                is_gate = any(abs((ang - ga + math.pi) % (2 * math.pi) - math.pi) <= 0.18 for ga in pit_gate_angles["NW"])
                if d_nw <= 16:
                    ground_id = TILE_ICE if smooth_noise(x, y, 10.0, 501) > 0.4 else TILE_SNOW
                    if rnd < 0.05: top_item = CRYSTAL_BLUE_1 if rnd < 0.025 else STALAGMITE
                elif 16 < d_nw <= PIT_RADIUS - 2:
                    ground_id = TILE_SNOW
                    if rnd < 0.04: top_item = SNOW_DRIFT_1
                else:
                    if is_gate:
                        ground_id = TILE_DIRT
                        is_path = True
                    else:
                        ground_id = TILE_SNOW
                        top_item = WALL_MOUNTAIN

            # NE LIGHTNING PIT
            elif d_ne <= PIT_RADIUS:
                in_pit = True
                ang = math.atan2(y - PIT_NE_Y, x - PIT_NE_X)
                is_gate = any(abs((ang - ga + math.pi) % (2 * math.pi) - math.pi) <= 0.18 for ga in pit_gate_angles["NE"])
                if d_ne <= 16:
                    ground_id = TILE_SAND_231
                    if rnd < 0.05: top_item = BONES_RIBCAGE if rnd < 0.025 else CACTUS_SMALL_1
                elif 16 < d_ne <= PIT_RADIUS - 2:
                    ground_id = TILE_DRY_FLOOR
                    if rnd < 0.03: top_item = ROCK_PILE_SAND
                else:
                    if is_gate:
                        ground_id = TILE_DIRT
                        is_path = True
                    else:
                        ground_id = TILE_STONE_FLOOR
                        top_item = WALL_STONE_ALT

            # SW EARTH PIT
            elif d_sw <= PIT_RADIUS:
                in_pit = True
                ang = math.atan2(y - PIT_SW_Y, x - PIT_SW_X)
                is_gate = any(abs((ang - ga + math.pi) % (2 * math.pi) - math.pi) <= 0.18 for ga in pit_gate_angles["SW"])
                if d_sw <= 16:
                    swamp_hazard = smooth_noise(x, y, 8.0, 801)
                    if swamp_hazard > 0.65:
                        ground_id = TILE_POISON_SWAMP
                    else:
                        ground_id = TILE_DIRT
                        if rnd < 0.05: top_item = FERN_JUNGLE_1 if rnd < 0.03 else MUD_CAVE_ROCK
                elif 16 < d_sw <= PIT_RADIUS - 2:
                    ground_id = TILE_DIRT
                else:
                    if is_gate:
                        ground_id = TILE_DIRT
                        is_path = True
                    else:
                        ground_id = TILE_DIRT
                        top_item = WALL_MOUNTAIN

            # SE FIRE PIT
            elif d_se <= PIT_RADIUS:
                in_pit = True
                ang = math.atan2(y - PIT_SE_Y, x - PIT_SE_X)
                is_gate = any(abs((ang - ga + math.pi) % (2 * math.pi) - math.pi) <= 0.18 for ga in pit_gate_angles["SE"])
                if d_se <= 12:
                    ground_id = TILE_LAVA
                elif 12 < d_se <= PIT_RADIUS - 2:
                    ground_id = TILE_BURNT_11561
                    if rnd < 0.06: top_item = MAGMA_STONE if rnd < 0.03 else CRYSTAL_RED_1
                else:
                    if is_gate:
                        ground_id = TILE_ROCK_SOIL
                        is_path = True
                    else:
                        ground_id = TILE_BURNT_11561
                        top_item = WALL_VOLCANO

            # =========================================================
            # NON-PIT GENERAL WORLD & ORGANIC BIOMES
            # =========================================================
            if not in_pit:
                # 1. House Overlay (Citadel only)
                if (x, y) in house_tiles:
                    ht = house_tiles[(x, y)]
                    ground_id = ht["ground"]
                    top_item = ht["wall"]
                    is_pz = True

                # 2. Outer World Mountain Border
                elif dist >= RADIUS_WORLD - 3:
                    ground_id = TILE_STONE_FLOOR
                    top_item = WALL_MOUNTAIN

                # 3. Central Citadel (PZ)
                elif max(abs(dx), abs(dy), (abs(dx) + abs(dy)) / 1.414) <= 28:
                    octo_r = max(abs(dx), abs(dy), (abs(dx) + abs(dy)) / 1.414)
                    is_pz = True
                    if 26.5 <= octo_r <= 28.5:
                        is_gate = (abs(dx) <= 3 and abs(dy) >= 25) or (abs(dy) <= 3 and abs(dx) >= 25)
                        if is_gate:
                            ground_id = TILE_DIRT
                        else:
                            ground_id = TILE_STONE_FLOOR
                            top_item = WALL_STONE
                    else:
                        if abs(dx) <= 3 and abs(dy) <= 3:
                            ground_id = TILE_WATER if (abs(dx) <= 1 and abs(dy) <= 1) else TILE_STONE_FLOOR
                        else:
                            ground_id = TILE_STONE_FLOOR

                # 4. Visible Paths / Highways (Walkable Dirt in green lands, Rock Soil in Fire realm)
                elif is_path:
                    if wx > 0 and wy > 0 and w_dist > 237:
                        # In Fire Biome: use rock soil 4407 so it naturally contrasts with 11561 burnt ground and blends cleanly
                        ground_id = TILE_ROCK_SOIL
                    else:
                        ground_id = TILE_DIRT
                    top_item = None
                    if is_waypoint_marker:
                        top_item = ROCK_PILE
                    elif rnd < 0.02:
                        top_item = [PEBBLE_1, PEBBLE_2, STONE_SMALL_3][int(rnd * 100) % 3]

                # 5. Scenic Rivers & Ponds 4664
                elif is_pond:
                    ground_id = TILE_WATER_POND
                    top_item = None

                # 6. Ring 1: Breezy Meadows (w_dist <= 105)
                elif w_dist <= 105:
                    soil_n = smooth_noise(x, y, 22.0, 1001)
                    if soil_n > 0.80:
                        ground_id = TILE_GRAVEL
                    elif soil_n > 0.74:
                        ground_id = TILE_DIRT
                    else:
                        ground_id = get_grass_tile(rnd)

                    if (x, y) in clusters:
                        top_item = clusters[(x, y)]
                    else:
                        if ground_id in range(9043, 9059):
                            if rnd < 0.045:
                                top_item = TUFT_GRASS_1 if rnd < 0.025 else TUFT_GRASS_2
                            elif rnd < 0.065:
                                top_item = FLOWER_YELLOW_1 if rnd < 0.055 else FLOWER_WHITE_1
                            elif rnd < 0.075:
                                top_item = MUSHROOM_1 if rnd < 0.070 else MUSHROOM_2
                            elif rnd < 0.090:
                                top_item = PEBBLE_1 if rnd < 0.082 else PEBBLE_2
                            elif rnd < 0.098:
                                top_item = WOOD_BRANCH_1

                # 7. Ring 2: Ancient Silverwood Forests (105 < w_dist <= 237)
                elif w_dist <= 237:
                    rock_pass_n = smooth_noise(x, y, 16.0, 2001)
                    forest_n = smooth_noise(x, y, 24.0, 2002)

                    # Photo 1 style: Rocky mountain pass with 4407 ground, 919 mountain, and 3613 pebbles
                    if rock_pass_n > 0.78:
                        ground_id = TILE_ROCK_SOIL
                        if rock_pass_n > 0.88 and rnd < 0.35:
                            top_item = WALL_MOUNTAIN
                        elif rnd < 0.12:
                            top_item = STONE_PEBBLE_3613
                    elif forest_n > 0.75:
                        ground_id = TILE_EARTH
                    elif forest_n > 0.68:
                        ground_id = TILE_DIRT
                    else:
                        ground_id = get_grass_tile(rnd)

                    if top_item is None:
                        if (x, y) in clusters:
                            top_item = clusters[(x, y)]
                        elif ground_id in range(9043, 9059):
                            if rnd < 0.04:
                                top_item = TUFT_GRASS_1
                            elif rnd < 0.06:
                                top_item = FERN_JUNGLE_1 if rnd < 0.05 else WOOD_BRANCH_1
                            elif rnd < 0.075:
                                top_item = MUSHROOM_1
                            elif rnd < 0.09:
                                top_item = PEBBLE_3

                # 8. OUTER WORLD ELEMENTAL REALMS (w_dist > 237)
                # Scaled to balance with the world (reduced by 25% to leave more room for forests & wilderness)
                else:
                    # Check if this tile falls into the Highly Irregular Expanded Void SideMaps
                    side_noise = 30.0 * smooth_noise(x, y, 16.0, 333)
                    d_boss = min(d_nw, d_ne, d_sw, d_se)

                    # Void SideMaps on North, South, West, East (Safely buffered from Boss Pits)
                    is_void = False
                    if d_boss > PIT_RADIUS + 38:
                        # North Void
                        if wy < -275 + side_noise and abs(wx) <= 130 + side_noise: is_void = True
                        # South Void
                        elif wy > 275 - side_noise and abs(wx) <= 130 + side_noise: is_void = True
                        # West Void
                        elif wx < -275 + side_noise and abs(wy) <= 130 + side_noise: is_void = True
                        # East Void
                        elif wx > 275 - side_noise and abs(wy) <= 130 + side_noise: is_void = True

                    if is_void:
                        # Void SideMaps with full RME Automagic border support
                        void_patch_n = smooth_noise(x, y, 9.0, 1102)
                        void_ridge_n = smooth_noise(x, y, 7.0, 1103)

                        # Primary ground: dark scaled ground (25549, 25704-25708, border 204)
                        # Secondary patches: overgrown rift floor (25753-25754, border 205)
                        if void_patch_n > 0.68:
                            ground_id = TILE_VOID_PATCH if (rnd < 0.5) else 25754
                        else:
                            ground_id = [25549, 25704, 25705, 25706, 25707, 25708][int(rnd * 100) % 6]

                        # Inaccessible areas & ridges (Basalt & Crystal Mountains - auto-bordered with 61 & 64)
                        if dist >= RADIUS_WORLD - 6:
                            ground_id = VOID_OBSTACLE
                        elif void_ridge_n > 0.81:
                            ground_id = VOID_CRYSTAL_OBSTACLE if rnd < 0.5 else VOID_OBSTACLE
                        elif (x, y) in clusters:
                            top_item = clusters[(x, y)]
                        elif rnd < 0.05:
                            top_item = [VOID_TREE_1, VOID_TREE_2, VOID_TREE_3, CRYSTAL_PURPLE_1, CRYSTAL_PURPLE_2, CRYSTAL_BLACK_LARGE][int(rnd * 100) % 6]

                    # -------------------------------------------------------------
                    # 4 EXPANDED ELEMENTAL BOSS BIOMES (Organic Quadrant Division)
                    # -------------------------------------------------------------
                    # NW: EXPANDED ICE BIOME
                    elif wx < 0 and wy < 0:
                        ice_lake = smooth_noise(x, y, 16.0, 601)
                        ground_id = TILE_ICE if ice_lake > 0.52 else TILE_SNOW
                        if (x, y) in clusters:
                            top_item = clusters[(x, y)]
                        elif rnd < 0.04:
                            top_item = [SNOW_DRIFT_1, STALAGMITE, CRYSTAL_BLUE_2, ROCK_SNOWY_1][int(rnd * 100) % 4]

                    # NE: EXPANDED LIGHTNING / SAND BIOME (231, 25013, 11077, 708)
                    elif wx > 0 and wy < 0:
                        desert_n = smooth_noise(x, y, 18.0, 701)
                        tar_n = smooth_noise(x, y, 12.0, 702)
                        if tar_n > 0.72:
                            ground_id = TILE_TAR
                        elif desert_n > 0.65:
                            ground_id = TILE_DRY_FLOOR
                        elif desert_n > 0.40:
                            ground_id = TILE_MUD_SAND
                        else:
                            ground_id = TILE_SAND_231

                        if ground_id != TILE_TAR:
                            if (x, y) in clusters:
                                top_item = clusters[(x, y)]
                            elif rnd < 0.04:
                                top_item = [CACTUS_SMALL_1, CACTUS_LARGE_1, BONES_RIBCAGE, ROCK_BROWN_1][int(rnd * 100) % 4]

                    # SW: EXPANDED EARTH & POISON SWAMP BIOME (101, 103, 4691)
                    elif wx < 0 and wy > 0:
                        swamp_hazard = smooth_noise(x, y, 14.0, 802)
                        if swamp_hazard > 0.72:
                            ground_id = TILE_POISON_SWAMP
                        elif swamp_hazard > 0.45:
                            ground_id = TILE_DIRT
                        else:
                            ground_id = TILE_EARTH

                        if ground_id not in (TILE_POISON_SWAMP, TILE_EARTH):
                            if (x, y) in clusters:
                                top_item = clusters[(x, y)]
                            elif rnd < 0.04:
                                top_item = [FERN_JUNGLE_1, BUSH_VENOMOUS, SWAMP_KELP, ROCK_MOSSY][int(rnd * 100) % 4]

                    # SE: EXPANDED FIRE / VOLCANO BIOME (User: 11561 burnt ground, black lava border)
                    else:
                        lava_lake_n = smooth_noise(x, y, 14.0, 901)
                        canyon_ridge_n = smooth_noise(x, y, 10.0, 902)

                        # Form cohesive lava lakes and pools (avoiding isolated 1-tile spurs)
                        if lava_lake_n > 0.73:
                            ground_id = TILE_LAVA
                        else:
                            # Primary ground is burnt / scorched earth 11561
                            ground_id = TILE_BURNT_11561

                        if ground_id != TILE_LAVA:
                            if canyon_ridge_n > 0.80:
                                top_item = WALL_VOLCANO
                            elif (x, y) in clusters:
                                top_item = clusters[(x, y)]
                            elif rnd < 0.06:
                                top_item = [MAGMA_STONE, CRYSTAL_RED_1, LAVA_HOLE_1, ROCK_DARK][int(rnd * 100) % 4]

            # =========================================================
            # CRITICAL USER RULE: NA ID 101 NIE STAWIAJ ŻADNYCH DODATKÓW!
            # =========================================================
            if ground_id == TILE_EARTH:
                top_item = None

            # Pack Tile into OTBM Node
            ax_node = (x // 256) * 256
            ay_node = (y // 256) * 256
            area = get_area_node(ax_node, ay_node)

            ox = x - ax_node
            oy = y - ay_node
            tile_data = bytearray([ox, oy])

            if is_pz:
                tile_data.append(OTBM_ATTR_TILE_FLAGS)
                tile_data.extend(struct.pack("<I", OTBM_TILEFLAG_PROTECTIONZONE))

            tile_data.append(OTBM_ATTR_ITEM)
            tile_data.extend(struct.pack("<H", ground_id))

            tile_node = Node(OTBM_TILE, tile_data)

            if top_item:
                item_data = struct.pack("<H", top_item)
                tile_node.add_child(Node(OTBM_ITEM, item_data))

            area.add_child(tile_node)
            tile_count += 1

    print(f"Total tiles generated: {tile_count}")
    print("Building OTBM node tree...")

    raw = bytearray(b"\x00\x00\x00\x00")
    root_header = struct.pack("<IHHII", 2, WORLD_WIDTH, WORLD_HEIGHT, 3, 57)
    root = Node(OTBM_ROOTV1, root_header)

    map_data = Node(OTBM_MAP_DATA)
    map_data.add_attr(OTBM_ATTR_DESCRIPTION, b"Nexus MMO Map - Remere's Map Editor 3.6")
    map_data.add_attr(OTBM_ATTR_EXT_SPAWN_FILE, b"nexus-spawn.xml")
    map_data.add_attr(OTBM_ATTR_EXT_HOUSE_FILE, b"nexus-house.xml")

    # Town: Nexus Citadel at (675, 1040, 7)
    towns = Node(OTBM_TOWNS)
    town_name = b"Nexus Citadel"
    town_data = struct.pack("<I", 1) + struct.pack("<H", len(town_name)) + town_name + struct.pack("<HHB", CENTER_X, CENTER_Y, MAP_Z)
    towns.add_child(Node(OTBM_TOWN, town_data))
    map_data.add_child(towns)

    for area_node in areas.values():
        map_data.add_child(area_node)

    root.add_child(map_data)
    raw.extend(root.serialize())

    otbm_path = r"c:\Users\GICU\Documents\GitHub\Champion-Server\data\world\nexus.otbm"
    with open(otbm_path, "wb") as f:
        f.write(raw)
    print(f"Saved {otbm_path} successfully ({len(raw)} bytes)!")


if __name__ == "__main__":
    generate_nexus()
