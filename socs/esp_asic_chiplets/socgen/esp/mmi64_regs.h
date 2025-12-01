#ifndef __MMI64_REGS_H__
#define __MMI64_REGS_H__

#define DDRS_NUM 4
#define MEMS_NUM 4
#define NOCS_NUM 2                    // mem -> dev, dev -> mem
#define CHIP_ROWS 2
#define CHIP_COLS 3
#define XLEN1 2
#define YLEN1 2
#define XLEN2 3
#define YLEN2 3
#define XLEN3 2
#define YLEN3 2
#define XLEN4 3
#define YLEN4 3
#define XLEN5 2
#define YLEN5 2
#define XLEN6 3
#define YLEN6 3
#define XLEN7 2
#define YLEN7 2
#define XLEN8 3
#define YLEN8 3
#define XLEN9 2
#define YLEN9 2
#define TILES_NUM ((XLEN1*YLEN1)+(XLEN2*YLEN2)+(XLEN3*YLEN3)+(XLEN4*YLEN4)+(XLEN5*YLEN5)+(XLEN6*YLEN6)+(XLEN7*YLEN7)+(XLEN8*YLEN8)+(XLEN9*YLEN9))
//#define TILES_NUM ((XLEN1*YLEN1)+(XLEN2*YLEN2)+(XLEN3*YLEN3)+(XLEN4*YLEN4)+(XLEN5*YLEN5)+(XLEN6*YLEN6))
//#define TILES_NUM ((XLEN1*YLEN1)+(XLEN2*YLEN2)+(XLEN3*YLEN3))
#define ACCS_NUM 9
#define VF_OP_POINTS 4                // DVFS-related
#define DIRECTIONS 5                  // N,S,W,E,Local 
#define L2S_NUM 10                     // cpu + acc
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
  {0, 3, {0, 0}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
	{1, 0, {0, 0}, {0, 1}, {1, 1}, "empty", 0, 0, 0 },
	{2, 0, {0, 0}, {1, 0}, {1, 1}, "empty", 0, 0, 0 },
	{3, 2, {0, 0}, {1, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  // chiplet 1
	{4, 3, {0, 1}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
	{5, 0, {0, 1}, {0, 1}, {1, 1}, "empty", 0, 0, 0 },
  {6, 0, {0, 1}, {0, 2}, {1, 1}, "empty", 0, 0, 0 },
  {7, 4, {0, 1}, {1, 0}, {1, 1}, "mem", 0, 0, 0 },
  {8, 2, {0, 1}, {1, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {9, 0, {0, 1}, {1, 2}, {1, 1}, "empty", 0, 0, 0 },
  {10, 0, {0, 1}, {2, 0}, {1, 1}, "empty", 0, 0, 0 },
  {11, 0, {0, 1}, {2, 1}, {1, 1}, "empty", 0, 0, 0 },
  {12, 0, {0, 1}, {2, 2}, {1, 1}, "empty", 0, 0, 0 },
  // chiplet 2
  {13, 3, {0, 2}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
  {14, 0, {0, 2}, {0, 1}, {1, 1}, "empty", 0, 0, 0 },
  {15, 2, {0, 2}, {1, 0}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {16, 0, {0, 2}, {1, 1}, {1, 1}, "empty", 0, 0, 0 },
  // chiplet 3
 	{17, 3, {1, 0}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
	{18, 0, {1, 0}, {0, 1}, {1, 1}, "empty", 0, 0, 0 },
  {19, 0, {1, 0}, {0, 2}, {1, 1}, "empty", 0, 0, 0 },
  {20, 4, {1, 0}, {1, 0}, {1, 1}, "mem", 0, 0, 0 },
  {21, 2, {1, 0}, {1, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {22, 0, {1, 0}, {1, 2}, {1, 1}, "empty", 0, 0, 0 },
  {23, 0, {1, 0}, {2, 0}, {1, 1}, "empty", 0, 0, 0 },
  {24, 0, {1, 0}, {2, 1}, {1, 1}, "empty", 0, 0, 0 },
  {25, 0, {1, 0}, {2, 2}, {1, 1}, "empty", 0, 0, 0 },
  // chiplet 4
  {26, 3, {1, 1}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
  {27, 1, {1, 1}, {0, 1}, {1, 1}, "cpu", 0, 0, 0 },
  {28, 2, {1, 1}, {1, 0}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {29, 0, {1, 1}, {1, 1}, {1, 1}, "empty", 0, 0, 0 },
  // chiplet 5
 	{30, 3, {1, 2}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
	{31, 0, {1, 2}, {0, 1}, {1, 1}, "empty", 0, 0, 0 },
  {32, 0, {1, 2}, {0, 2}, {1, 1}, "empty", 0, 0, 0 },
  {33, 4, {1, 2}, {1, 0}, {1, 1}, "mem", 0, 0, 0 },
  {34, 2, {1, 2}, {1, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {35, 0, {1, 2}, {1, 2}, {1, 1}, "empty", 0, 0, 0 },
  {36, 0, {1, 2}, {2, 0}, {1, 1}, "empty", 0, 0, 0 },
  {37, 0, {1, 2}, {2, 1}, {1, 1}, "empty", 0, 0, 0 },
  {38, 0, {1, 2}, {2, 2}, {1, 1}, "empty", 0, 0, 0 },
//  // chiplet 6
  {39, 3, {2, 0}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
  {40, 0, {2, 0}, {0, 1}, {1, 1}, "empty", 0, 0, 0 },
  {41, 2, {2, 0}, {1, 0}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {42, 0, {2, 0}, {1, 1}, {1, 1}, "empty", 0, 0, 0 },
  // chiplet 7
 	{43, 3, {2, 1}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
	{44, 0, {2, 1}, {0, 1}, {1, 1}, "empty", 0, 0, 0 },
  {45, 0, {2, 1}, {0, 2}, {1, 1}, "empty", 0, 0, 0 },
  {46, 4, {2, 1}, {1, 0}, {1, 1}, "mem", 0, 0, 0 },
  {47, 2, {2, 1}, {1, 1}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {48, 0, {2, 1}, {1, 2}, {1, 1}, "empty", 0, 0, 0 },
  {49, 0, {2, 1}, {2, 0}, {1, 1}, "empty", 0, 0, 0 },
  {50, 0, {2, 1}, {2, 1}, {1, 1}, "empty", 0, 0, 0 },
  {51, 0, {2, 1}, {2, 2}, {1, 1}, "empty", 0, 0, 0 },
  // chiplet 8
  {52, 3, {2, 2}, {0, 0}, {1, 1}, "IO", 0, 0, 0 },
  {53, 0, {2, 2}, {0, 1}, {1, 1}, "empty", 0, 0, 0 },
  {54, 2, {2, 2}, {1, 0}, {1, 1}, "DUMMY_STRATUS", 0, 0, 0 },
  {55, 0, {2, 2}, {1, 1}, {1, 1}, "empty", 0, 0, 0 }
};

#endif /*  __MMI64_REGS_H__ */
