/*
 * Copyright (c) 2011-2023 Columbia University, System Level Design Group
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * Baremetal device driver for DUMMY accelerator using Scatter-Gather DMA
 * and P2P multicast.
 *
 * Select Scatter-Gather in ESP configuration.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h> // Include for uintptr_t
#include <esp_accelerator.h> // Main ESP accelerator definitions
#include <esp_probe.h>       // ESP probe and helper functions (ioread32, etc.)
// #include "dummy_multicast_p2p.h" // Include local header if needed, otherwise define below

// --- Type Definitions ---
typedef long long unsigned u64;
typedef unsigned u32;
typedef u64 token_t; // Data type for transfer

// --- Accelerator Identification ---
// Define SLD_DUMMY and DEV_NAME only if not provided by headers/makefiles
#ifndef SLD_DUMMY
#define SLD_DUMMY   0x042
#endif
#ifndef DEV_NAME
#define DEV_NAME "sld,dummy_stratus"
#endif

// --- Accelerator Registers ---
// Define only if not provided by esp_accelerator.h or device-specific header
#ifndef TOKENS_REG
#define TOKENS_REG 0x50
#endif
#ifndef BATCH_REG
#define BATCH_REG 0x54
#endif
// Add other device-specific register definitions here if needed

// --- DMA and Cache Configuration ---
#define mask 0x0LL         // Mask applied during data init/validation
#define CACHELINE_SIZE 512 // System cache line size for alignment

/* Size definition for Scatter-Gather chunks */
#ifndef CHUNK_SHIFT
#define CHUNK_SHIFT 20     // Power of 2 for chunk size (e.g., 20 -> 1MB)
#endif
#ifndef BIT
#define BIT(n) (1ULL << (n)) // Macro to calculate 2^n
#endif
#define CHUNK_SIZE BIT(CHUNK_SHIFT)

// --- Static Memory Allocation (Baremetal Specific) ---
// IMPORTANT: These pointers and the allocation logic below are examples.
//            You MUST adapt this to your specific baremetal memory map
//            and available memory regions suitable for DMA.
static uintptr_t uncached_area_ptr_1 = 0x88000000;
static uintptr_t uncached_area_ptr_2 = 0x90000000;
static uintptr_t uncached_area_ptr_3 = 0xA0000000;
static uintptr_t uncached_area_ptr_4 = 0xB0000000; // Also used for placeholder aligned_malloc

// --- Aligned Memory Allocation ---
// IMPORTANT: Replace these placeholders with your actual baremetal
//            aligned memory allocation functions provided by your SDK/BSP.

// Function to allocate main data buffers from specific memory banks
// (Adapts the original function with minor safety checks)
void *aligned_malloc_mem(int size, int mem_n) {
    void *mem_base = NULL;
    uintptr_t start_ptr = 0;
    // Add size needed for alignment padding and storing original pointer
    size_t total_size_needed = size + CACHELINE_SIZE + sizeof(void*);

//    printf("aligned_malloc_mem: Requesting size %d from bank %d (Total needed: %zu)\n", size, mem_n, total_size_needed);

    // Select memory bank and advance pointer
    switch (mem_n) {
        case 1:
            start_ptr = uncached_area_ptr_1;
            // Check available space (example bounds)
            if (start_ptr + total_size_needed > 0x90000000) { // End of bank 1 example
                 printf("Error: Out of memory in bank 1!\n"); return NULL;
            }
            uncached_area_ptr_1 += total_size_needed;
            mem_base = (void *)start_ptr;
            break;
        case 2:
            start_ptr = uncached_area_ptr_2;
            if (start_ptr + total_size_needed > 0xA0000000) { // End of bank 2 example
                 printf("Error: Out of memory in bank 2!\n"); return NULL;
            }
            uncached_area_ptr_2 += total_size_needed;
            mem_base = (void *)start_ptr;
            break;
        case 3:
            start_ptr = uncached_area_ptr_3;
             if (start_ptr + total_size_needed > 0xB0000000) { // End of bank 3 example
                 printf("Error: Out of memory in bank 3!\n"); return NULL;
            }
            uncached_area_ptr_3 += total_size_needed;
            mem_base = (void *)start_ptr;
            break;
        case 4:
            start_ptr = uncached_area_ptr_4;
             if (start_ptr + total_size_needed > 0xC0000000) { // End of bank 4 example
                 printf("Error: Out of memory in bank 4!\n"); return NULL;
            }
            uncached_area_ptr_4 += total_size_needed;
            mem_base = (void *)start_ptr;
            break;
        default:
//             printf("Error: Invalid memory bank %d requested!\n", mem_n);
             return NULL; // Indicate error
    }

//    printf("  Allocated raw buffer for bank %d @ 0x%lx\n", mem_n, start_ptr);

    // Calculate the final aligned pointer, storing the original base pointer just before it
    // This allows a custom 'free' function to retrieve the original allocation start if needed.
    void **ptr = (void**)(((uintptr_t)mem_base + CACHELINE_SIZE + sizeof(void*)) & ~(uintptr_t)(CACHELINE_SIZE - 1));
    ptr[-1] = mem_base; // Store original pointer

//    printf("  Returning aligned ptr @ 0x%lx (Original base: 0x%lx)\n", (uintptr_t)ptr, (uintptr_t)mem_base);
    return (void *)ptr;
}

// --- Data Validation Function ---
static int validate_dummy(token_t *mem, int batch, int tokens, int offset)
{
    int i, j;
    int error_count = 0;
    token_t expected_value;
    printf("Validating buffer @ 0x%lx (Batch: %d, Tokens: %d, Offset: %d)...\n", (uintptr_t)mem, batch, tokens, offset);
    for (j = 0; j < batch; j++) {
        for (i = 0; i < tokens; i++) {
            expected_value = (mask | (token_t)(i + j * tokens + offset * batch * tokens));
            if (mem[i + j * tokens] != expected_value) {
//                if (error_count < 100) { // Print limited number of errors
                    printf("  ERROR [%d, %d]: Expected 0x%llx (%llu), Got 0x%llx (%llu)\n",
                           j, i, expected_value, expected_value,
                           mem[i + j * tokens], mem[i + j * tokens]);
//                } else if (error_count == 100) {
//                     printf("  ...suppressing further error messages.\n");
//                }
                error_count++;
            }
        }
    }
    if (error_count == 0) {
        printf("  Validation PASSED\n");
    } else {
        printf("  Validation FAILED with %d errors\n", error_count);
    }
    return error_count;
}

// --- Data Initialization Function ---
static void init_buf(token_t *mem, int batch, int tokens, int offset)
{
    int i, j;
//    printf("Initializing buffer @ 0x%lx (Batch: %d, Tokens: %d)\n", (uintptr_t)mem, batch, tokens);
    for (j = 0; j < batch; j++) {
        for (i = 0; i < tokens; i++) {
            mem[i + j * tokens] = (mask | (token_t)(i + j * tokens + offset * batch * tokens));
        }
    }
}

// --- P2P Configuration Wrapper ---
// (Assumes underlying esp_p2p_* functions are provided by headers)
void p2p_setup(struct esp_device* dev, int p2p_store, int mcast_ndests, int p2p_load, struct esp_device* p2p_src, int mcast_packet, int mcast_packet_size){
//    printf("Configuring P2P for device @ 0x%lx: store=%d, load=%d, ndests=%d, packet=%d, pkt_size=%d",
//           dev->addr, p2p_store, p2p_load, mcast_ndests, mcast_packet, mcast_packet_size);
//    if (p2p_load && p2p_src) {
        // Assuming esp_get_y/x work correctly via included headers
//        printf(", src=(%d,%d) @ 0x%lx\n", esp_get_y(p2p_src), esp_get_x(p2p_src), p2p_src->addr);
//    } else {
//        printf("\n");
//    }

//   printf("    P2P setup @ 0x%lx: reset\n", (uintptr_t)dev->addr);
    esp_p2p_reset(dev); // Reset P2P state
//   printf("    P2P setup @ 0x%lx: chip reset\n", (uintptr_t)dev->addr);
    esp_p2p_chip_reset(dev);
    if (p2p_store) { // Configure as destination/store point
//       printf("    P2P setup @ 0x%lx: enable dst\n", (uintptr_t)dev->addr);
        esp_p2p_enable_dst(dev);
    }

    if (p2p_load) { // Configure as source/load point
//       printf("    P2P setup @ 0x%lx: enable src\n", (uintptr_t)dev->addr);
        esp_p2p_enable_src(dev);
        if (p2p_src) { // Check if source pointer is valid
//         printf("    P2P setup @ 0x%lx: set src Y from 0x%lx\n", (uintptr_t)dev->addr, (uintptr_t)p2p_src->addr);
          esp_p2p_set_y(dev, 0, esp_get_y(p2p_src)); // Set source Y coordinate
//         printf("    P2P setup @ 0x%lx: set src X from 0x%lx\n", (uintptr_t)dev->addr, (uintptr_t)p2p_src->addr);
          esp_p2p_set_x(dev, 0, esp_get_x(p2p_src)); // Set source X coordinate
//         printf("    P2P setup @ 0x%lx: set src chip Y from 0x%lx\n", (uintptr_t)dev->addr, (uintptr_t)p2p_src->addr);
          esp_p2p_set_chip_y(dev, 0, esp_get_chip_y(p2p_src)); // Set source chip Y coordinate
//         printf("    P2P setup @ 0x%lx: set src chip X from 0x%lx\n", (uintptr_t)dev->addr, (uintptr_t)p2p_src->addr);
          esp_p2p_set_chip_x(dev, 0, esp_get_chip_x(p2p_src)); // Set source chip X coordinate
        } else {
//         printf("    P2P setup @ 0x%lx: default src Y/X/chip Y/X = 0\n", (uintptr_t)dev->addr);
          esp_p2p_set_y(dev, 0, 0); // Example default
          esp_p2p_set_x(dev, 0, 0); // Example default
          esp_p2p_set_chip_y(dev, 0, 0); // Example default
          esp_p2p_set_chip_x(dev, 0, 0); // Example default
        }
    }
}

// --- Cycle Counter Read (RISC-V Specific) ---
static inline uint64_t get_counter()
{
    // Reads the RISC-V machine cycle counter `mcycle`
    uint64_t counter;
    asm volatile (
        "csrr %0, mcycle"  // Read mcycle CSR into register designated by %0
        : "=r" (counter)   // Output: counter variable assigned from register
        :                  // No input operands
        :                  // No clobbered registers (apart from the destination)
    );
    return counter;
}

// --- Forward declaration for the test function ---
uint64_t test(int BATCH, int TOKENS, int MCAST_PACKET, int NUM_MULTICAST, unsigned COHERENCE);

// --- Main Function ---
int main()
{
    uint64_t count[2][5][6]; // Array to store cycle counts for different configs
    int k = 0, l = 0;         // Loop indices for the result array

    // Define ndev here to match the value assumed/used inside the 'test' function
    const int ndev = 4;      // Total number of devices available in the system

//    printf("\n--- Starting ESP Scatter-Gather Multicast Test Suite ---\n");
//    printf("System Configuration: ndev = %d\n", ndev);

    // Define test parameters
    int batches[] = {255};          // BATCH values to test
//    int batches[] = {64, 256};
    int multicasts[] = {1};     // NUM_MULTICAST values (Max = ndev-1)
//    int multicasts[] = {16};
//    int mcast_packets[] = {0, 1};                // MCAST_PACKET mode (0=disabled, 1=enabled)
    int mcast_packets[] = {0};
    int fixed_tokens = 512;                       // Fixed TOKENS value for these tests

    // Calculate array sizes safely
    int num_batch_vals = sizeof(batches) / sizeof(batches[0]);
    int num_mc_vals = sizeof(multicasts) / sizeof(multicasts[0]);
    int num_pkt_vals = sizeof(mcast_packets) / sizeof(mcast_packets[0]);

    // Check if result array dimensions match test parameters
    if (num_pkt_vals > 2 || num_batch_vals > 5 || num_mc_vals > 6) {
//        printf("Error: Test parameter array sizes exceed result array dimensions! Adjust 'count' array.\n");
        return 1; // Exit with error
    }

    // Iterate through test configurations
    for (int u_idx = 0; u_idx < num_pkt_vals; u_idx++) { // Loop MCAST_PACKET
        int current_mcast_packet = mcast_packets[u_idx];
        k = 0; // Reset batch index
        for (int i_idx = 0; i_idx < num_batch_vals; i_idx++) { // Loop BATCH
            int current_batch = batches[i_idx];
            l = 0; // Reset multicast index
            for (int j_idx = 0; j_idx < num_mc_vals; j_idx++) { // Loop NUM_MULTICAST
                int current_num_multicast = multicasts[j_idx];

                // Sanity check: Ensure NUM_MULTICAST doesn't exceed available devices
                if (current_num_multicast >= ndev) {
                     printf("Skipping test: NUM_MULTICAST (%d) >= ndev (%d). Invalid configuration.\n", current_num_multicast, ndev);
                     count[u_idx][k][l] = -1; // Store -1 to indicate skipped/invalid test
                     l++; // Increment 'l' to avoid overwriting next valid slot
                     continue; // Skip to the next multicast value
                }

                printf("\n====== Running test: BATCH=%d, TOKENS=%d, MCAST_PACKET=%d, NUM_MULTICAST=%d ======\n",
                       current_batch, fixed_tokens, current_mcast_packet, current_num_multicast);

                // Execute the test function with current parameters
                // Assuming ACC_COH_NONE coherence for this test suite run
                count[u_idx][k][l] = test(current_batch, fixed_tokens, current_mcast_packet, current_num_multicast, ACC_COH_RECALL);

//                printf("====== Test complete: Cycles = %lld ======\n", count[u_idx][k][l]);

                l++; // Move to next multicast result slot in the 'count' array
            }
            // Fill remaining slots in 'l' dimension if the inner loop exited early (due to skips)
            while (l < num_mc_vals) {
                 count[u_idx][k][l++] = -2; // Indicate not run due to prior skip
            }
            k++; // Move to next batch result slot
        }
         // Fill remaining slots in 'k' dimension if the batch loop exited early (unlikely with current structure)
         while (k < num_batch_vals) {
            for (l = 0; l < num_mc_vals; l++) {
                 count[u_idx][k][l] = -3; // Indicate not run
            }
            k++;
        }
    }

    // Print summary of results
    printf("\n--- Test Results Summary (Cycle Counts) ---\n");
    for (int u = 0; u < num_pkt_vals; u++) {
        printf("MCAST_PACKET = %d:\n", mcast_packets[u]);
        for (int i = 0; i < num_batch_vals; i++) {
            printf("  BATCH = %-3d: [", batches[i]);
            for (int j = 0; j < num_mc_vals; j++) {
                 printf("%lld", count[u][i][j]); // Print cycle count or error code
                 if (j < num_mc_vals - 1) printf(", ");
            }
            printf("] (NUM_MULTICAST = {");
            for(int mc_idx=0; mc_idx < num_mc_vals; ++mc_idx) {
                 printf("%d%s", multicasts[mc_idx], (mc_idx == num_mc_vals - 1) ? "" : ", ");
            }
            printf("}, TOKENS=%d)\n", fixed_tokens);
        }
    }

    printf("\n--- Test Suite Finished ---\n");
    return 0; // Indicate successful completion
}


// --- Test Function ---
// Executes a single test run with specified parameters
uint64_t test(int BATCH, int TOKENS, int MCAST_PACKET, int NUM_MULTICAST, unsigned COHERENCE)
{
    int errors = 0;
    int ndev = 4;
//    const int ndev = 4; // Total number of dummy devices assumed in the system
    int num_multicast = NUM_MULTICAST; // Number of consumers for this run
    uint64_t total_count = 0;
    uint64_t start_cycles, end_cycles;
//    struct esp_device *devs = NULL;
    int devices_0[] = {0, 3};
    int devices_1[] = {2, 1};
    //int devices_2[] = {2, 4};

    // --- Device Discovery/Setup (Baremetal: Assumed Addresses) ---
    printf("Setting up %d device structures...\n", ndev);
    struct esp_device devs[ndev]; // Array to hold device info
    for (int i = 0; i < ndev; i++) {
        devs[i].addr = 0x60010000 + i * 0x200;
    }

//    ndev = probe(&devs, VENDOR_SLD, SLD_DUMMY, DEV_NAME);
//    if (!ndev) {
//        printf("Error: %s device not found!\n", DEV_NAME);
//        exit(EXIT_FAILURE);
//    }
    
    printf("Device structure setup complete.\n");

    // --- Buffer Size Calculation ---
    int dummy_buf_size = TOKENS * BATCH * sizeof(token_t);
    if (dummy_buf_size <= 0) {
        printf("Error: Invalid buffer size calculation (size=%d). Check BATCH/TOKENS.\n", dummy_buf_size);
        return -10; // Error code for invalid size
    }
    // Calculate number of chunks needed for ONE device buffer
    int chunks_per_dev = (dummy_buf_size + CHUNK_SIZE - 1) / CHUNK_SIZE;
//    printf("Buffer size per device: %d bytes\n", dummy_buf_size);
//    printf("Chunk size (CHUNK_SIZE): %llu bytes (Shift: %d)\n", (unsigned long long)CHUNK_SIZE, CHUNK_SHIFT);
    if (chunks_per_dev == 0 && dummy_buf_size > 0) chunks_per_dev = 1; // Handle case where buf_size < CHUNK_SIZE
//    printf("Chunks per device required: %d\n", chunks_per_dev);


    // --- Memory Allocation for Data Buffers ---
    // Allocate array to hold pointers to each device's data buffer
//    printf("Before memtest setup\n");
    token_t **memtest = (token_t**)aligned_malloc(ndev * sizeof(token_t *));
    if (!memtest) {
    //    printf("Error: Failed to allocate memory for memtest pointer array!\n");
        return -11; // Error code for mem allocation failure
    }
//    printf("Allocated memtest pointer array @ 0x%lx\n", (uintptr_t)memtest);

    // Allocate the actual data buffers for all ndev devices
    // Using bank distribution from original code example
    int banks[] = {1,2,3,4};
    for (int i = 0; i < ndev; i++) {
        memtest[i] = (token_t *)aligned_malloc_mem(dummy_buf_size, banks[i % ndev]); // Use modulo for safety
        if (!memtest[i]) {
            printf("Error: Failed to allocate data buffer for device %d!\n", i);
            aligned_free(memtest); // Free the pointer array
            // TODO: Ideally, free previously allocated buffers if your free mechanism supports it
            return -12; // Error code for buffer allocation failure
        }
//        printf("Data buffer allocation loop %d complete.\n", i);

    }
//    printf("Data buffer allocation complete.\n");


    // --- Page Table Allocation & Population ---
    // Allocate array to hold pointers to each device's page table
    uintptr_t **ptables = (uintptr_t **)aligned_malloc(ndev * sizeof(uintptr_t *));
     if (!ptables) {
        printf("Error: Failed to allocate memory for page table pointer array!\n");
        // TODO: Free data buffers and memtest array
        aligned_free(memtest);
        return -13; // Error code for page table pointer allocation failure
    }
//    printf("Allocated page table pointer array @ 0x%lx\n", (uintptr_t)ptables);

    // Allocate and populate the actual page tables for each device
    for (int i = 0; i < ndev; i++) {
        // Allocate page table (array of physical addresses) for device i
        ptables[i] = (uintptr_t *)aligned_malloc(chunks_per_dev * sizeof(uintptr_t));
        if (!ptables[i]) {
            printf("Error: Failed to allocate page table for device %d\n", i);
            // TODO: Free previously allocated tables, data buffers, etc. before returning
            for(int k=0; k<i; ++k) aligned_free(ptables[k]); // Free previously allocated tables
            aligned_free(ptables); // Free the pointer array
            aligned_free(memtest); // Free the buffer pointer array
            return -14; // Error code for page table allocation failure
        }
//        printf("  Allocated page table for device %d @ 0x%lx (%d entries)\n", i, (uintptr_t)ptables[i], chunks_per_dev);

        // Populate the page table with physical addresses of chunks
        for (int j = 0; j < chunks_per_dev; j++) {
            ptables[i][j] = (uintptr_t)memtest[i] + (j * CHUNK_SIZE);
//              printf("    ptables[%d][%d] = 0x%lx\n", i, j, ptables[i][j]); // Uncomment for deep debug
        }
    }
//    printf("Page table allocation and population complete.\n");


    // --- Device Selection & Ordering ---
    // Using the balanced/shortest distance order from the original code example
    // devices[0] is the source, devices[1] to devices[num_multicast] are destinations
    int source_hw_index = 0; // Hardware index (0-29) of the source device

//    printf("Source device HW index: %d\n", source_hw_index);
//    printf("Number of multicast destinations: %d\n", num_multicast);
//    printf("List of participating device HW indices (Source + Destinations):\n ");
//    for (int i = 0; i < num_multicast + 1; i++) {
//        printf(" %d", devices[i]);
//    }
//    printf("\n");


    // --- Check Hardware Capabilities ---
    // Read max chunks capability from the source device
//    printf("Checking capabilities of source device %d @ 0x%lx\n", source_hw_index, devs[source_hw_index].addr);
    u32 max_chunks_hw = ioread32(&devs[devices_0[0]], PT_NCHUNK_MAX_REG);

//    printf(" Max chunks supported by hardware (PT_NCHUNK_MAX_REG): %u\n", max_chunks_hw);

    if (max_chunks_hw == 0) {
//        printf("  Error: Scatter-gather DMA is disabled by hardware (Max Chunks = 0). Abort.\n");
        // TODO: Free all allocated memory before returning
        return -20; // Error code for SG disabled
    }

    if (max_chunks_hw < chunks_per_dev) {
//        printf("  Error: Not enough hardware TLB entries available (%u) for required chunks per device (%d). Abort.\n", max_chunks_hw, chunks_per_dev);
        // TODO: Free all allocated memory before returning
        return -21; // Error code for insufficient TLB entries
    }
//    printf("Hardware capability check passed.\n");


    // --- Initialize Input Buffer ---
    // Initialize only the buffer for the source device
//    printf("Before init_buf\n");
    init_buf(memtest[devices_0[0]], BATCH, TOKENS, 0);
//    printf("After init_buf0\n");
    init_buf(memtest[devices_1[0]], BATCH, TOKENS, 1);
//    printf("After init_buf1\n");
    //init_buf(memtest[devices_2[0]], BATCH, TOKENS, 2);

    // --- Configure Participating Devices ---
    printf("Configuring %d participating devices...\n", 2*(num_multicast + 1));
    for (int i = 0; i < num_multicast + 1; i++) { // Loop through source (i=0) + destinations (i=1 to num_mustruct esp_device *current_dev = &devs[current_dev_hw_index]; // Pointer to the device struct
//      printf("Configuring ACC %d\n", devices_1[i]);
      struct esp_device *current_dev = &devs[devices_1[i]]; // Pointer to the device struct
//      printf("  devices_1[%d] -> dev[%d] @ 0x%lx: write COHERENCE\n",
//             i, devices_1[i], (uintptr_t) current_dev->addr);
        // 1. Coherence Setting
        iowrite32(current_dev, COHERENCE_REG, COHERENCE);
        // 2. P2P Setup
        if (i == 0) { // Source device configuration
//          printf("  devices_1[%d] -> dev[%d] @ 0x%lx: p2p source setup\n",
//                 i, devices_1[i], (uintptr_t) current_dev->addr);
          p2p_setup(current_dev, 1, num_multicast, 0, NULL, MCAST_PACKET, 4); // p2p_store=1, ndests=num_multicast
        } else { // Destination device configuration
//          printf("  devices_1[%d] -> dev[%d] @ 0x%lx: p2p destination setup from dev[%d] @ 0x%lx\n",
//                 i, devices_1[i], (uintptr_t) current_dev->addr,
//                 devices_1[0], (uintptr_t) devs[devices_1[0]].addr);
          p2p_setup(current_dev, 0, 0, 1, &devs[devices_1[0]], 0, 4); // p2p_load=1, src=&devs[source_hw_index]
        }

        // 3. Scatter-Gather DMA Configuration (Corrected)
//        printf("  devices_1[%d] -> dev[%d] @ 0x%lx: write PT_ADDRESS/PT_NCHUNK/PT_SHIFT\n",
//               i, devices_1[i], (uintptr_t) current_dev->addr);
        iowrite32(current_dev, PT_ADDRESS_REG, (u32)(uintptr_t)ptables[devices_1[i]]); // Address of this device's page table
        iowrite32(current_dev, PT_NCHUNK_REG, chunks_per_dev); // Number of chunks for THIS device's buffer
        iowrite32(current_dev, PT_SHIFT_REG, CHUNK_SHIFT);     // Log2 of chunk size
        // 4. DMA Offsets (Typically 0 for full buffer)
//        printf("  devices_1[%d] -> dev[%d] @ 0x%lx: write SRC/DST offsets\n",
//               i, devices_1[i], (uintptr_t) current_dev->addr);
        iowrite32(current_dev, SRC_OFFSET_REG, 0x0);
        iowrite32(current_dev, DST_OFFSET_REG, 0x0);
        // 5. Accelerator-Specific Registers
//        printf("  devices_1[%d] -> dev[%d] @ 0x%lx: write TOKENS/BATCH\n",
//               i, devices_1[i], (uintptr_t) current_dev->addr);
        iowrite32(current_dev, TOKENS_REG, TOKENS);
        iowrite32(current_dev, BATCH_REG, BATCH);
//        printf("  devices_1[%d] -> dev[%d] @ 0x%lx: configuration complete\n",
//               i, devices_1[i], (uintptr_t) current_dev->addr);
    }
//    printf("  devices_1 group complete\n");
    for (int i = 0; i < num_multicast + 1; i++) { // Loop through source (i=0) + destinations (i=1 to num_mustruct esp_device *current_dev = &devs[current_dev_hw_index]; // Pointer to the device struct
//        printf("Configuring ACC %d\n", devices_0[i]);
        struct esp_device *current_dev = &devs[devices_0[i]]; // Pointer to the device struct
//        printf("  devices_0[%d] -> dev[%d] @ 0x%lx: write COHERENCE\n",
//               i, devices_0[i], (uintptr_t) current_dev->addr);
        iowrite32(current_dev, COHERENCE_REG, COHERENCE);
        // 2. P2P Setup
        if (i == 0) { // Source device configuration
//            printf("  devices_0[%d] -> dev[%d] @ 0x%lx: p2p source setup\n",
//                   i, devices_0[i], (uintptr_t) current_dev->addr);
            p2p_setup(current_dev, 1, num_multicast, 0, NULL, MCAST_PACKET, 4); // p2p_store=1, ndests=num_multicast
        } else { // Destination device configuration
//            printf("  devices_0[%d] -> dev[%d] @ 0x%lx: p2p destination setup from dev[%d] @ 0x%lx\n",
//                   i, devices_0[i], (uintptr_t) current_dev->addr,
//                   devices_0[0], (uintptr_t) devs[devices_0[0]].addr);
            p2p_setup(current_dev, 0, 0, 1, &devs[devices_0[0]], 0, 4); // p2p_load=1, src=&devs[source_hw_index]
        }
        // 3. Scatter-Gather DMA Configuration (Corrected)
//        printf("  devices_0[%d] -> dev[%d] @ 0x%lx: write PT_ADDRESS/PT_NCHUNK/PT_SHIFT\n",
//               i, devices_0[i], (uintptr_t) current_dev->addr);
        iowrite32(current_dev, PT_ADDRESS_REG, (u32)(uintptr_t)ptables[devices_0[i]]); // Address of this device's page table
        iowrite32(current_dev, PT_NCHUNK_REG, chunks_per_dev); // Number of chunks for THIS device's buffer
        iowrite32(current_dev, PT_SHIFT_REG, CHUNK_SHIFT);     // Log2 of chunk size
        // 4. DMA Offsets (Typically 0 for full buffer)
//        printf("  devices_0[%d] -> dev[%d] @ 0x%lx: write SRC/DST offsets\n",
//               i, devices_0[i], (uintptr_t) current_dev->addr);
        iowrite32(current_dev, SRC_OFFSET_REG, 0x0);
        iowrite32(current_dev, DST_OFFSET_REG, 0x0);

        // 5. Accelerator-Specific Registers
//        printf("  devices_0[%d] -> dev[%d] @ 0x%lx: write TOKENS/BATCH\n",
//               i, devices_0[i], (uintptr_t) current_dev->addr);
        iowrite32(current_dev, TOKENS_REG, TOKENS);
        iowrite32(current_dev, BATCH_REG, BATCH);
//        printf("  devices_0[%d] -> dev[%d] @ 0x%lx: configuration complete\n",
//               i, devices_0[i], (uintptr_t) current_dev->addr);
    }
//    printf("  devices_0 group complete\n");
//    printf("Devices 0 configuration complete.\n");
//    for (int i = 0; i < num_multicast + 1; i++) { // Loop through source (i=0) + destinations (i=1 to num_mustruct esp_device *current_dev = &devs[current_dev_hw_index]; // Pointer to the device struct
////      printf("Configuring ACC %d\n", devices_1[i]);
//      struct esp_device *current_dev = &devs[devices_1[i]]; // Pointer to the device struct
////        printf("  Configuring device %d (HW Index %d @ 0x%lx)\n", i, current_dev_hw_index, current_dev->addr);
//
//        // 1. Coherence Setting
//        iowrite32(current_dev, COHERENCE_REG, COHERENCE);
//
//        // 2. P2P Setup
//        if (i == 0) { // Source device configuration
//             p2p_setup(current_dev, 1, num_multicast, 0, NULL, MCAST_PACKET, 4); // p2p_store=1, ndests=num_multicast
//        } else { // Destination device configuration
//             p2p_setup(current_dev, 0, 0, 1, &devs[devices_1[0]], 0, 4); // p2p_load=1, src=&devs[source_hw_index]
//        }
//
//        // 3. Scatter-Gather DMA Configuration (Corrected)
//        iowrite32(current_dev, PT_ADDRESS_REG, (u32)(uintptr_t)ptables[devices_1[i]]); // Address of this device's page table
//        iowrite32(current_dev, PT_NCHUNK_REG, chunks_per_dev); // Number of chunks for THIS device's buffer
//        iowrite32(current_dev, PT_SHIFT_REG, CHUNK_SHIFT);     // Log2 of chunk size
//
//        // 4. DMA Offsets (Typically 0 for full buffer)
//        iowrite32(current_dev, SRC_OFFSET_REG, 0x0);
//        iowrite32(current_dev, DST_OFFSET_REG, 0x0);
//
//        // 5. Accelerator-Specific Registers
//        iowrite32(current_dev, TOKENS_REG, TOKENS);
//        iowrite32(current_dev, BATCH_REG, BATCH);
//
////        printf("    PT_ADDRESS=0x%lx, PT_NCHUNK=%d, PT_SHIFT=%d\n", (uintptr_t)ptables[devices_1[i]], chunks_per_dev, CHUNK_SHIFT);
//    }
//    printf("Devices 1 configuration complete.\n");
//    for (int i = 0; i < num_multicast + 1; i++) { // Loop through source (i=0) + destinations (i=1 to num_mustruct esp_device *current_dev = &devs[current_dev_hw_index]; // Pointer to the device struct
//      struct esp_device *current_dev = &devs[devices_2[i]]; // Pointer to the device struct
////        printf("  Configuring device %d (HW Index %d @ 0x%lx)\n", i, current_dev_hw_index, current_dev->addr);
//
//        // 1. Coherence Setting
//        iowrite32(current_dev, COHERENCE_REG, COHERENCE);
//
//        // 2. P2P Setup
//        if (i == 0) { // Source device configuration
//             p2p_setup(current_dev, 1, num_multicast, 0, NULL, MCAST_PACKET, 4); // p2p_store=1, ndests=num_multicast
//        } else { // Destination device configuration
//             p2p_setup(current_dev, 0, 0, 1, &devs[devices_2[0]], 0, 4); // p2p_load=1, src=&devs[source_hw_index]
//        }
//
//        // 3. Scatter-Gather DMA Configuration (Corrected)
//        iowrite32(current_dev, PT_ADDRESS_REG, (u32)(uintptr_t)ptables[devices_2[i]]); // Address of this device's page table
//        iowrite32(current_dev, PT_NCHUNK_REG, chunks_per_dev); // Number of chunks for THIS device's buffer
//        iowrite32(current_dev, PT_SHIFT_REG, CHUNK_SHIFT);     // Log2 of chunk size
//
//        // 4. DMA Offsets (Typically 0 for full buffer)
//        iowrite32(current_dev, SRC_OFFSET_REG, 0x0);
//        iowrite32(current_dev, DST_OFFSET_REG, 0x0);
//
//        // 5. Accelerator-Specific Registers
//        iowrite32(current_dev, TOKENS_REG, TOKENS);
//        iowrite32(current_dev, BATCH_REG, BATCH);
//
////        printf("    PT_ADDRESS=0x%lx, PT_NCHUNK=%d, PT_SHIFT=%d\n", (uintptr_t)ptables[current_dev_hw_index], chunks_per_dev, CHUNK_SHIFT);
//    }
    if (COHERENCE == ACC_COH_NONE)
        esp_flush(COHERENCE); // Use the appropriate flush command for your platform

    // --- Start Accelerators & Measure Time ---
    printf("Starting accelerators...\n");
//    start_cycles = get_counter(); // Get start time
//    printf("Timer Started\n");

    for (int i = 0; i < (num_multicast + 1); i++) {
//    for (int i = 0; i < 2*(num_multicast + 1); i++) {
//      printf("Before iowrite i = %d\n", i);
      iowrite32(&devs[devices_0[i]], CMD_REG, CMD_MASK_START); // Send start command
      iowrite32(&devs[devices_1[i]], CMD_REG, CMD_MASK_START); // Send start command
      //      printf("After io write i = %d\n", i);
    }

    // --- Wait for Completion ---
//    printf("Waiting for completion status (STATUS_MASK_DONE=0x%x)...\n", STATUS_MASK_DONE);
//    int wait_loops = 0;
//    const int max_wait_loops = 10000000; // Add a basic timeout
//    while (wait_loops < max_wait_loops) {
    unsigned all_done = 0;
    while (!all_done) {
        all_done = STATUS_MASK_DONE; // Assume all done initially
        for (int i = 0; i < (num_multicast + 1); i++){
//        for (int i = 0; i < 2*(num_multicast + 1); i++){
             // Read status register and check ONLY the done bit
             all_done &= (ioread32(&devs[devices_0[i]], STATUS_REG) & STATUS_MASK_DONE);
             all_done &= (ioread32(&devs[devices_1[i]], STATUS_REG) & STATUS_MASK_DONE);
        }
    }

//    end_cycles = get_counter(); // Get end time
//    total_count = end_cycles - start_cycles; // Calculate duration

//    if (wait_loops >= max_wait_loops) {
//         printf("Error: Timeout waiting for device completion!\n");
//         // Attempt to read status anyway for debugging
//         for (int i = 0; i < num_multicast + 1; i++){
//             printf("  Device %d (HW %d) STATUS_REG = 0x%x\n", i, devices[i], ioread32(&devs[devices[i]], STATUS_REG));
//         }
//         total_count = -1; // Indicate timeout error
//    } else 
    {
//        printf("All accelerators finished\n");
//        printf("Total execution cycles = %lld\n", total_count);
    }


    // --- Reset Command Register (Good Practice) ---
    for (int i = 0; i < (num_multicast + 1); i++) {
//    for (int i = 0; i < 2*(num_multicast + 1); i++) {
      iowrite32(&devs[devices_0[i]], CMD_REG, 0x0);
      iowrite32(&devs[devices_1[i]], CMD_REG, 0x0);
    }


    // --- Validation ---
    printf("Starting validation for %d devices...\n", num_multicast + 1);
    errors = 0; // Reset error counter for this run
    for (int i = 1; i < num_multicast + 1; i++) {
        int current_dev_hw_index = devices_0[i];
        printf("  Validating device %d (HW Index %d)\n", devices_0[i], current_dev_hw_index);
        // Validate the buffer associated with the current device HW index
        errors += validate_dummy(memtest[current_dev_hw_index], BATCH, TOKENS, 0);
    }
    for (int i = 1; i < num_multicast + 1; i++) {
        int current_dev_hw_index = devices_1[i];
        printf("  Validating device %d (HW Index %d)\n", devices_1[i], current_dev_hw_index);
        // Validate the buffer associated with the current device HW index
        errors += validate_dummy(memtest[current_dev_hw_index], BATCH, TOKENS, 1);
    }
//    for (int i = 0; i < num_multicast + 1; i++) {
//        int current_dev_hw_index = devices_2[i];
//        printf("  Validating device %d (HW Index %d)\n", devices_2[i], current_dev_hw_index);
//        // Validate the buffer associated with the current device HW index
//        errors += validate_dummy(memtest[current_dev_hw_index], BATCH, TOKENS, 2);
//    }
    printf("Validation complete. Total Errors for this run: %d\n", errors);
    if (!errors) {
        printf("Source %d (HW Index %d) transfer: PASS\n", 0, source_hw_index);
    } else {
        printf("Source %d (HW Index %d) transfer: FAIL\n", 0, source_hw_index);
    }


    // --- Free Allocated Memory ---
    // Free in reverse order of allocation
//    printf("Freeing allocated memory...\n");
    if (ptables) {
        for (int i = 0; i < ndev; i++) {
            if (ptables[i]) {
                aligned_free(ptables[i]); // Free individual page table
            }
        }
        aligned_free(ptables); // Free the array of page table pointers
    }
    if (memtest) {
         // Freeing the actual data buffers depends heavily on how aligned_malloc_mem and
         // aligned_free work. The placeholder free does nothing.
         // If your allocator stored the original pointer like in the example,
         // you might iterate and retrieve/free based on that.
         // e.g., for(i=0; i<ndev; ++i) { free( ((void**)memtest[i])[-1] ); }
         // For now, just free the pointer array itself.
         aligned_free(memtest);
    }
//    printf("Memory freeing attempt complete (using placeholders).\n");


    // Return cycle count, or error code if something went wrong
    //if (total_count < 0) return -1; // Return -1 for errors like timeout
    //if (errors > 0) return -1; // Return -1 if validation failed
    return total_count;
}
