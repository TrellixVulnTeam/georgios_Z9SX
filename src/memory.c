/* ============================================================================
 * System Wide Memory Management
 * ============================================================================
 * Interface for Managing System Memory
 */

#include <memory.h>

#include <platform.h> // FRAME_SIZE and FRAME_LEVELS
#include <kernel.h> // Location of the kernel
//#include <print.h> // Debug

/*
 * For x86_32
 *     FRAME_SIZE is 4096
 *     FRAME_LEVELS is 7
 *     1<<7 = 128
 *     128 * 4096 = 524288 B (1/2 MiB per Frame Block)
 */
#define FRAMES (1 << FRAME_LEVELS)
#define FRAME_BLOCK_SIZE (FRAMES * FRAME_SIZE)

mem_t memory_total = 0;
mem_t lost_total = 0;
mem_t blocks_total = 0;
mem_t memory_used = 0;

/* ============================================================================
 * Memory Map
 * ============================================================================
 * Represents contiguous physical memory sections that we can use
 */

typedef struct Memory_Range_struct Memory_Range;
struct Memory_Range_struct {
    mem_t start;
    mem_t size;
    mem_t blocks_start;
    mem_t blocks;
};

#define MEMORY_RANGE_MAX 64
Memory_Range memory_map[MEMORY_RANGE_MAX];
u1 memory_range_num = 0;

void memory_range_add(mem_t start, mem_t size) {
    if (memory_range_num < MEMORY_RANGE_MAX) {
        memory_map[memory_range_num].start = start;
        memory_map[memory_range_num].size = size;
        mem_t blocks = size / FRAME_BLOCK_SIZE;
        memory_map[memory_range_num].blocks_start = blocks_total;
        blocks_total += blocks;
        mem_t blocks_size = blocks * FRAME_BLOCK_SIZE;
        memory_map[memory_range_num].blocks = blocks;
        memory_total += blocks_size;
        lost_total += size - blocks_size;
        memory_range_num++;
    }
}

/* ============================================================================
 * Frame Allocation
 * ============================================================================
 * Allocate Frames of Physical Memory in groups called Frame Blocks.
 * Frame Blocks use Buddy System allocation to allocate frames.
 */

typedef struct Frame_Block_struct Frame_Block;
struct Frame_Block_struct {
    mem_t address;
    mem_t used, free;
    u1 frames[FRAMES];
};

Frame_Block * frame_blocks = (Frame_Block *) &KERNEL_HIGH_END;
mem_t frame_blocks_size = 0;

void memory_init() {
    // Calculate size of Frame Block Array
    mem_t lost = (mem_t) &KERNEL_SIZE;
    frame_blocks_size = ((memory_total - lost) * sizeof(Frame_Block)) /
        (FRAME_BLOCK_SIZE + sizeof(Frame_Block));
    lost += frame_blocks_size;
    lost_total += lost;
    memory_total -= lost;

    // Initialize Frame Blocks
    mem_t address;
    mem_t blocks;
    Frame_Block * b = frame_blocks;
    for (u1 m = 0; m < memory_range_num; m++) {
        address = memory_map[m].start;
        blocks = memory_map[m].blocks;
        if ( // If Kernel is in this range
            (address <= (mem_t) &KERNEL_LOW_START) &&
            (address + memory_map[m].size > (mem_t) &KERNEL_LOW_END)
        ) { // then account for the Kernel and Frame Blocks
            address += lost;
            blocks -= lost / FRAME_BLOCK_SIZE;
        }
        for (mem_t i = 0; i < blocks; i++) {
            b++;
            b->address = address;
            b->used = 0;
            b->free = FRAME_BLOCK_SIZE;
            for (u4 i = 0; i < FRAMES; i++) {
                b->frames[i] = 0;
            }
            address += FRAME_BLOCK_SIZE;
        }
    }
}

#define FRAME_IS_FREE(page) (!((page) & 1))
#define FRAME_LEVEL(page) ((page) >> 1)
#define FRAME_LEVEL_SIZE(level) (1 << (FRAME_LEVELS - level))
#define FRAME_MARK_FREE(page) (fb->frames[page] &= -2) // (-2 == 111..1110)
#define FRAME_MARK_USED(page) (fb->frames[page] |= 1)
#define FRAME_IS_RIGHT(page) (page) % (1 << (FRAME_LEVELS - PAGE_LEVEL(page)))

/* DEBUG FUNCTION
void print_frames(Frame_Block * fb) {
    for (u4 i = 0; i < FRAMES; i++) {
        u1 f = fb->frames[i];
        print_uint(FRAME_LEVEL(f));
        if (!FRAME_IS_FREE(f)) {
            print_string("*");
        }
    }
    print_char('\n');
}
*/

// Return true if an error occurred
bool Frame_Block_allocate(Frame_Block * fb, u2 frames, void ** address) {

    // Get Number of frames rounded to the next power of 2
    u4 level = 0;
    u4 rounded;
    while ((rounded = (1 << level)) < frames) {
        level++;
    }
    level = FRAME_LEVELS - level;
    //print_frames(fb);
    //print_format("Allocate:\n - Level is {d}\n - Find Exact Sized Free Buddy Block\n", level);

    // Find free Block Matching that rounded size exactly
    for (u4 i = 0; i < FRAMES; i += rounded) {
        u1 f = fb->frames[i];
        if (FRAME_IS_FREE(f) && FRAME_LEVEL(f) == level) {
            //print_format(" - Found at: {d}\n", i);
            FRAME_MARK_USED(i);
            *address = (void *) (fb->address + FRAME_SIZE * i);
            return false;
        }
    }

    //print_format(" - Did not find exact size, Find Larger Block\n");
    // Find Larger Block to split
    u4 l = level;
    bool block_found = false;
    u4 i;
    while (true) {
        //print_format("    Level: {d}\n", l);
        for (i = 0; i < FRAMES; i += FRAME_LEVEL_SIZE(l)) {
            u1 f = fb->frames[i];
            if (FRAME_IS_FREE(f) && FRAME_LEVEL(f) == l) {
                // We found a block to split
                block_found = true;
                break;
            }
        }
        if ((!l) || block_found)
            // We're at the top or we found a block to split
            break;
        l--;
    }
    if (!block_found) {
        //print_string("    Larger Block NOT Found, Error\n");
        return true;
    }
    //print_format("    Larger Block Found at: {d}\n - Split it\n", i);

    // Split first part of the block until it's the same size
    for (; l < level;) {
        l++;
        //print_format("        L{d} ", l);
        //print_frames(fb);
        fb->frames[i] = l << 1;
        fb->frames[i + FRAME_LEVEL_SIZE(l)] = l << 1;
    }
    FRAME_MARK_USED(i);
    //print_frames(fb);

    *address = (void *) (fb->address + FRAME_SIZE * i);
    return false;
}

// Return true if an error occurred
bool Frame_Block_deallocate(Frame_Block * fb, void * address) {
    u4 frame = (((u4) address) - ((u4) fb->address)) / FRAME_SIZE;
    FRAME_MARK_FREE(frame);

    // Merge buddy block with siblings until we find a used sibling or no more
    // siblings.
    u1 level = fb->frames[frame] >> 1;
    while (true) {
        u4 buddy_location = frame;
        u4 size = FRAME_LEVEL_SIZE(level);
        bool move_left;
        if (frame % (1 << (FRAME_LEVELS - level + 1))) {
            buddy_location -= size;
            move_left = true;
        } else {
            buddy_location += size;
            move_left = false;
        }
        u1 buddy = fb->frames[buddy_location];
        if (FRAME_IS_FREE(buddy) && (FRAME_LEVEL(buddy) == level)) {
            fb->frames[buddy_location] = 0;
            fb->frames[frame] = 0;
        } else {
            break;
        }
        if (move_left) {
            frame = buddy_location;
        }
        if (!level) { // No more siblings
            break;
        }
        level--;
    }
    fb->frames[frame] = level << 1;
    return false;
}

u1 apmem_range = 0;
mem_t apmem_block = 0;
bool allocate_pmem(mem_t amount, mem_t * got, void ** address) {
    u1 old_apmem_range = apmem_range;
    mem_t old_apmem_block = apmem_block++;
    if (apmem_block == memory_map[apmem_range].blocks) {
        apmem_block = 0;
        apmem_range = (apmem_range + 1) / memory_range_num;
    }
    while (
        (apmem_range != old_apmem_range) && (apmem_block != old_apmem_block)
    ) {
        if (Frame_Block_allocate(
            &frame_blocks[memory_map[apmem_range].blocks_start + apmem_block],
            (amount / FRAME_BLOCK_SIZE) + 1, address
        )) return false;
        apmem_block++;
        if (apmem_block == memory_map[apmem_range].blocks) {
            apmem_block = 0;
            apmem_range = (apmem_range + 1) / memory_range_num;
        }
    }
    return true;
}

bool deallocate_pmem(void * address) {
    mem_t base = 0;
    for (u1 m = 0; m < memory_range_num; m++) {
        if (
            (address >= memory_map[m].start) &&
            (address < memory_map[m].start + memory_map[m].size)
        ) {
            mem_t block =  ((mem_t) address - memory_map[m].start) / FRAME_BLOCK_SIZE;
            return Frame_Block_deallocate(&frame_blocks[base + block], address);
        }
        base += memory_map[m].blocks;
    }
    return true;
}