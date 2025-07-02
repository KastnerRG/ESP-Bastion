// Copyright (c) 2011-2021 Columbia University, System Level Design Group
// SPDX-License-Identifier: Apache-2.0
/**
 * Baremetal device driver for DUMMY
 *
 * (point-to-point communication test)
 */

#include <stdio.h>
#ifndef __riscv
#include <stdlib.h>
#endif

#include <esp_accelerator.h>
#include <esp_probe.h>

typedef long long unsigned u64;
typedef unsigned u32;

typedef u64 token_t;
#define mask 0xFEED0BAC00000000LL

#define SLD_DUMMY   0x42
#define DEV_NAME "sld,dummy_stratus"

#define TOKENS 64
#define BATCH 4

#define SECURITY_ON 0

#define LEGAL_BATCH 4
#define ILLEGAL_RD_BATCH 2
#define ILLEGAL_WR_BATCH 2

// This is what illegal read data will be written to (this is a LEGAL addr to write to)!

// This is the region DMA will attempt to do illegal write, should be untouched

static unsigned out_offset;
static unsigned size;

/* Size of the contiguous chunks for scatter/gather */
#define CHUNK_SHIFT 10	// Set chunck size equal to 2 single batch	
#define CHUNK_SIZE BIT(CHUNK_SHIFT)
#define NCHUNK ((size % CHUNK_SIZE == 0) ?			\
			(size / CHUNK_SIZE) :		\
			(size / CHUNK_SIZE) + 1)

// User defined registers
#define TOKENS_REG	0x40
#define BATCH_REG	0x44

// here mem is set to the start of write addr already!
static int validate_dummy_legal(token_t *mem)
{
	int i, j;
	int rtn = 0;
	for (j = 0; j < LEGAL_BATCH; j++)
		for (i = 0; i < TOKENS; i++)
			if (mem[i + j * TOKENS] != (mask | (token_t) i)) {
				printf("[%d, %d]: legal r&w expecting %x, getting %x\n", j, i, (mask | (token_t) i), mem[i + j * TOKENS]);
				rtn++;
			}
	return rtn;
}

static int validate_dummy_illegal_read(token_t *mem){
	int i, j;
	int rtn = 0;
	for (j = 0; j < ILLEGAL_RD_BATCH; j++){
		for (i = 0; i < TOKENS; i++){
			if (SECURITY_ON){
				if (mem[i + j * TOKENS] != 0x0000000000000000LL) {
				printf("[%d, %d]: illegal read expecting all 0, getting %x\n", j, i, mem[i + j * TOKENS]);
				rtn++;
				}
			} else if (mem[i + j * TOKENS] != (mask | (token_t) i)) {
				printf("[%d, %d]: legal r&w expecting %x, getting %x\n", j, i, (mask | (token_t) i), mem[i + j * TOKENS]);
				rtn++;
			}
		}
	}		
	return rtn;
}

static int validate_dummy_illegal_write(token_t *mem){
	int i, j;
	int rtn = 0;
	for (j = 0; j < ILLEGAL_WR_BATCH; j++){
		for (i = 0; i < TOKENS; i++){
			if (SECURITY_ON){
				if (mem[i + j * TOKENS] != 0xFFFFFFFFFFFFFFFFLL) {
				printf("[%d, %d]: illegal write expecting all F, getting %x\n", j, i, mem[i + j * TOKENS]);
				rtn++;
				}
			} else if (mem[i + j * TOKENS] != (mask | (token_t) i)) {
				printf("[%d, %d]: legal r&w expecting %x, getting %x\n", j, i, (mask | (token_t) i), mem[i + j * TOKENS]);
				rtn++;
			}
		}
	}
	return rtn;
}

static void init_buf (token_t *mem)
{
	int i, j;
	// For legal read from
	for (j = 0; j < BATCH; j++)
		for (i = 0; i < TOKENS; i++)
			mem[i + j * TOKENS] = (mask | (token_t) i);
	// For legal write to
	for (i = 0; i < BATCH * TOKENS; i++)
		mem[i + BATCH * TOKENS] = 0xFFFFFFFFFFFFFFFFLL;

	// For illegal read from, this would result simulation to pass when security turned off
	for (j = 0; j < ILLEGAL_RD_BATCH; j++)
		for (i = 0; i < TOKENS; i++)
			mem[i + j * TOKENS + 2*BATCH * TOKENS] = (mask | (token_t) i);

	// For illegal write to
	for (i = 0; i < ILLEGAL_WR_BATCH * TOKENS; i++)
		mem[i + 2 * BATCH * TOKENS + ILLEGAL_RD_BATCH * TOKENS] = 0xFFFFFFFFFFFFFFFFLL; 

	
}


int main(int argc, char * argv[])
{
	int i;
	int n;
	int ndev;
	struct esp_device *espdevs;
	struct esp_device *dev;
	struct esp_device *srcs[4];
	unsigned all_done;
	unsigned **ptable = NULL;
	token_t *mem;
	unsigned errors = 0;

	out_offset = BATCH * TOKENS * sizeof(u64);
	size = 2 * out_offset;

	printf("Scanning device tree... \n");

	ndev = probe(&espdevs, SLD_DUMMY, DEV_NAME);
	if (ndev < 1) {
		printf("This test requires a dummy device!\n");
		return 0;
	}

	// Check DMA capabilities
	dev = &espdevs[0];

	if (ioread32(dev, PT_NCHUNK_MAX_REG) == 0) {
		printf("  -> scatter-gather DMA is disabled. Abort.\n");
		return 0;
	}

	// Maximum 4 page tables!
	if (ioread32(dev, PT_NCHUNK_MAX_REG) < NCHUNK) {
		printf("%x %x,  -> Not enough TLB entries available. Abort.\n", ioread32(dev, PT_NCHUNK_MAX_REG), NCHUNK);
		return 0;
	}

	// Allocate memory
	mem = aligned_malloc(size+out_offset);
	printf("  memory buffer base-address = %p\n", mem);

	//-----------------------------------------LEGAL---------------------------------------------//
	//Alocate and populate page table
	ptable = aligned_malloc(NCHUNK * sizeof(unsigned *));
	printf("  Legal R&W, read from chunk 1,2 and write to chunk 3,4");
	for (i = 0; i < NCHUNK; i++){
		ptable[i] = (unsigned *) &mem[i * (CHUNK_SIZE / sizeof(token_t))];
		printf("  Page number %d: %p\n", i, ptable[i]);
	}
	// mess up page table: 
	// Each read and write batch takes 0x200 bytes
	// Read addr of Batch 3: 0xa0100f30 -> 0xa0101b30 
	// Write addr of Batch 4: 0xa101930 -> 0xa0101d30
	printf("  ptable = %p\n", ptable);
	printf("  nchunk = %lu\n", NCHUNK);

	printf("  Generate random input... And populate the illegal areas\n");
	init_buf(mem);

	iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
	iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);
	iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
	iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
	iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
	iowrite32(dev, TOKENS_REG, TOKENS);
	iowrite32(dev, BATCH_REG, BATCH);
	iowrite32(dev, SRC_OFFSET_REG, 0x0);
	iowrite32(dev, DST_OFFSET_REG, out_offset);

	// Flush for non-coherent DMA
	esp_flush(ACC_COH_NONE);

	// Start accelerators
	printf("  Start...\n");
	iowrite32(dev, CMD_REG, CMD_MASK_START);

	// Wait for completion
	all_done = 0;
	while (!all_done) {
		all_done = ioread32(dev, STATUS_REG);
		all_done &= STATUS_MASK_DONE;
	}

	iowrite32(dev, CMD_REG, 0x0);

	printf("  Done\n");

	/* Validation */
	printf("  validating...\n");
	errors = validate_dummy_legal(&mem[BATCH * TOKENS]);

	if (errors)
		printf("  ...legal FAIL\n");
	else
		printf("  ...legal PASS\n");


	//---------------------------------ILLEGAL----------------------------------------//
	printf("  Illegal R&W, attempt to read from chunk [5], 2, write to chunk 3, [6]");
	ptable[0] = (unsigned *)0xA0101B30;
	ptable[3] = (unsigned *)0xA0101F30;
	for (i = 0; i < NCHUNK; i++){
		printf("  Page number %d: %p\n", i, ptable[i]);
	}
	iowrite32(dev, SELECT_REG, ioread32(dev, DEVID_REG));
	iowrite32(dev, COHERENCE_REG, ACC_COH_NONE);
	iowrite32(dev, PT_ADDRESS_REG, (unsigned long) ptable);
	iowrite32(dev, PT_NCHUNK_REG, NCHUNK);
	iowrite32(dev, PT_SHIFT_REG, CHUNK_SHIFT);
	iowrite32(dev, TOKENS_REG, TOKENS);
	iowrite32(dev, BATCH_REG, BATCH);
	iowrite32(dev, SRC_OFFSET_REG, 0x0);
	iowrite32(dev, DST_OFFSET_REG, out_offset);

	// Flush for non-coherent DMA
	esp_flush(ACC_COH_NONE);

	// Start accelerators
	printf("  Start...\n");
	iowrite32(dev, CMD_REG, CMD_MASK_START);

	// Wait for completion
	all_done = 0;
	while (!all_done) {
		all_done = ioread32(dev, STATUS_REG);
		all_done &= STATUS_MASK_DONE;
	}

	iowrite32(dev, CMD_REG, 0x0);

	printf("  Done\n");

	/* Validation */
	printf("  validating...\n");
	errors = validate_dummy_illegal_read(&mem[BATCH * TOKENS]);
	if (errors)
		printf("  ...illegal read test FAIL\n");
	else
		printf("  ...illegal read test PASS\n");

	errors = validate_dummy_illegal_write(&mem[2*BATCH * TOKENS + ILLEGAL_RD_BATCH * TOKENS]);
	if (errors)
		printf("  ...illegal write test FAIL\n");
	else
		printf("  ...illegal write test PASS\n");


	aligned_free(ptable);
	aligned_free(mem);

	return 0;
}

