#ifndef __MMI64_REGS_H__
#define __MMI64_REGS_H__

#define DDRS_NUM 4
#define MEMS_NUM 4
#define NOCS_NUM 2                    // mem -> dev, dev -> mem
#define CHIP_ROWS 2
#define CHIP_COLS 2
#define XLEN1 3
#define YLEN1 3
#define XLEN2 2
#define YLEN2 2
#define XLEN3 3
#define YLEN3 3
#define XLEN4 2
#define YLEN4 2
#define TILES_NUM ((XLEN1*YLEN1)+(XLEN2*YLEN2)+(XLEN3*YLEN3)+(XLEN4*YLEN4))
//#define TILES_NUM ((XLEN1*YLEN1)+(XLEN2*YLEN2)+(XLEN3*YLEN3)+(XLEN4*YLEN4)+(XLEN5*YLEN5)+(XLEN6*YLEN6))
//#define TILES_NUM ((XLEN1*YLEN1)+(XLEN2*YLEN2)+(XLEN3*YLEN3))
#define ACCS_NUM 17
#define VF_OP_POINTS 4                // DVFS-related
#define DIRECTIONS 5                  // N,S,W,E,Local
#define L2S_NUM 18                     // cpu + acc
#define LLCS_NUM 4                    // num mem tiles
#define MONITOR_REG_COUNT 0           // not sure
#define MONITOR_RESET_offset 0        // not sure
#define MONITOR_WINDOW_SIZE_offset 1  // not sure
#define MONITOR_WINDOW_LO_offset 2    // not sure
#define MONITOR_WINDOW_HI_offset 3    // not sure
#define TOTAL_REG_COUNT 4             // not sure

struct local_yx {
  unsigned y;
  unsigned x;
};

struct chip_yx {
  unsigned y;
  unsigned x;
};

struct span_u {
  unsigned w;
  unsigned h;
};

enum tile_type {
empty_tile,
cpu_tile,
accelerator_tile,
misc_tile,
memory_tile,
};

struct tile_info {
unsigned id;
int type;
struct chip_yx chip_position; // chiplet grid coordinate
struct local_yx position; // tile top-left inside chiplet
struct span_u span;   // tile size inside chiplet
char *name;
int has_pll; /* this tile's PLL drives all tiles in the domain */
int domain; /* if 0 then no DVFS */
int domain_master; /* ID of the tile where the PLL for this domain is located */
};

const struct tile_info tiles[TILES_NUM] = {   // needs change -- where does TILES_NUM come from?
  // chiplet 0
	{0, 4, {0, 0}, {0, 0}, {1, 1}, "mem", 0, 0, 0 },
	{1, 3, {0, 0}, {0, 1}, {1, 1}, "IO", 0, 0, 0 },
  {2, 4, {0, 0}, {0, 2}, {1, 1}, "mem", 0, 0, 0 },
  {3, 2, {0, 0}, {1, 0}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {4, 2, {0, 0}, {1, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {5, 2, {0, 0}, {1, 2}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
//  {4, 0, {0, 0}, {1, 1}, {1, 1}, "empty", 0, 0, 0 },
//  {5, 0, {0, 0}, {1, 2}, {1, 1}, "empty", 0, 0, 0 },
  {6, 4, {0, 0}, {2, 0}, {1, 1}, "mem", 0, 0, 0 },
  {7, 1, {0, 0}, {2, 1}, {1, 1}, "cpu", 0, 0, 0 },
  {8, 4, {0, 0}, {2, 2}, {1, 1}, "mem", 0, 0, 0 },
  // chiplet 1
  {9,  3, {0, 1}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
	{10, 2, {0, 1}, {0, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
//  {11, 0, {0, 1}, {1, 0}, {1, 1}, "empty", 0, 0, 0 },
  {11, 2, {0, 1}, {1, 0}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
	{12, 2, {0, 1}, {1, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  // chiplet 2
  {13, 3, {1, 0}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
	{14, 2, {1, 0}, {0, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {15, 2, {1, 0}, {0, 2}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
	{16, 2, {1, 0}, {1, 0}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
	{17, 2, {1, 0}, {1, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {18, 2, {1, 0}, {1, 2}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {19, 2, {1, 0}, {2, 0}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {20, 2, {1, 0}, {2, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {21, 2, {1, 0}, {2, 2}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  // chiplet 3
	{22, 3, {1, 1}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
	{23, 2, {1, 1}, {0, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {24, 2, {1, 1}, {1, 0}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {25, 2, {1, 1}, {1, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 }
};

#endif /*  __MMI64_REGS_H__ */
