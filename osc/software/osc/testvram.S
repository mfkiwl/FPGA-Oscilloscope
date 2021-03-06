################################################################################
#                                                                              #
#                                 VRAM Test Code                               #
#                 	            Test code for VRAM                             #
#                                   EE/CS 52                                   #
#                                                                              #
################################################################################


/*
 *  Albert Gural
 *  EE/CS 52
 *  TA: Dan Pipe-Mazo
 *
 *  File Description:	Tests VRAM (minimally)
 *
 *  Revision History:
 *      02/09/2012  Dan Pipe-Mazo	Initial Revision.
 *		05/14/2014	Albert Gural	Begain writing testcode assembly.
 *
 */

 /*  Local Include Files   */
#include "macros.m"
#include "../osc_bsp/system.h"

.section  .text         #start code section

/*
 *  test_vram
 *
 *  Description: Tests the VRAM in a couple different scenarios:
 *   - sequentially write/reading each value
 *   - sequentially writing all values then immediately reading all values
 *   - writing all values, waiting, then reading all values
 *
 *  Arguments: (none)
 *
 *  Return Value: (none)
 *
 */

.global test_vram
.type test_vram,@function

test_vram:
	SAVE

	movhi	r8, %hi(VRAM_CTRL_BASE)
	ori		r8, r8, %lo(VRAM_CTRL_BASE)
	movhi	r9, %hi(VRAM_CTRL_SPAN)
	ori		r9, r9, %lo(VRAM_CTRL_SPAN)
	add		r9, r8, r9
	movui	r12, 0x7000 # Test value to write to VRAM

	# Quick W/R test
	call	write_read_all

	# Slower W/R test
	call	write_all
	call	read_all

	# Place a breakpoint here and wait as long as necessary (1 minute or more).
	nop
	call	read_all # Verify there is no corrputed data.

# Failed tests
test_vram_fail:
	nop
	br 		test_vram_fail

# Succeeded tests
test_vram_done:
	RESTORE
	ret



write_all:
	mov		r10, r8
	mov		r11, r0

write_all_loop:
	# Write to each element sequentially
	sthio	r11, (r10)
	addi	r10, r10, 2
	addi	r11, r11, 1
	bgeu	r10, r9, write_all_done
	bgeu	r11, r12, write_all_reset_cnt
	br		write_all_loop

write_all_reset_cnt:
	mov		r11, r0
	br		write_all_loop

write_all_done:
	ret



read_all:
	mov		r10, r8
	mov		r11, r0

read_all_loop:
	# Read and verify each element sequentially
	ldhio	r13, (r10)
	bne		r13, r11, test_vram_fail
	addi	r10, r10, 2
	addi	r11, r11, 1
	bgeu	r10, r9, read_all_done
	bgeu	r11, r12, read_all_reset_cnt
	br		read_all_loop

read_all_reset_cnt:
	mov		r11, r0
	br		write_all_loop

read_all_done:
	ret

