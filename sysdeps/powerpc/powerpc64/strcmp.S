/* Optimized strcmp implementation for PowerPC64.
   Copyright (C) 1997-2025 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */

#include <sysdep.h>

/* See strlen.s for comments on how the end-of-string testing works.  */

/* int [r3] strcmp (const char *s1 [r3], const char *s2 [r4])  */

#ifndef STRCMP
# define STRCMP strcmp
#endif

ENTRY_TOCLESS (STRCMP, 4)
	CALL_MCOUNT 2

#define rTMP2	r0
#define rRTN	r3
#define rSTR1	r3	/* first string arg */
#define rSTR2	r4	/* second string arg */
#define rWORD1	r5	/* current word in s1 */
#define rWORD2	r6	/* current word in s2 */
#define rFEFE	r7	/* constant 0xfefefefefefefeff (-0x0101010101010101) */
#define r7F7F	r8	/* constant 0x7f7f7f7f7f7f7f7f */
#define rNEG	r9	/* ~(word in s1 | 0x7f7f7f7f7f7f7f7f) */
#define rBITDIF	r10	/* bits that differ in s1 & s2 words */
#define rTMP	r11

	dcbt	0,rSTR1
	or	rTMP, rSTR2, rSTR1
	dcbt	0,rSTR2
	clrldi.	rTMP, rTMP, 61
	lis	rFEFE, -0x101
	bne	L(unaligned)

	ld	rWORD1, 0(rSTR1)
	ld	rWORD2, 0(rSTR2)
	lis	r7F7F, 0x7f7f
	addi	rFEFE, rFEFE, -0x101
	addi	r7F7F, r7F7F, 0x7f7f
	sldi	rTMP, rFEFE, 32
	insrdi	r7F7F, r7F7F, 32, 0
	add	rFEFE, rFEFE, rTMP
	b	L(g1)

L(g0):	ldu	rWORD1, 8(rSTR1)
	bne	cr1, L(different)
	ldu	rWORD2, 8(rSTR2)
L(g1):	add	rTMP, rFEFE, rWORD1
	nor	rNEG, r7F7F, rWORD1
	and.	rTMP, rTMP, rNEG
	cmpd	cr1, rWORD1, rWORD2
	beq+	L(g0)

/* OK. We've hit the end of the string. We need to be careful that
   we don't compare two strings as different because of gunk beyond
   the end of the strings...  */
#ifdef __LITTLE_ENDIAN__
L(endstring):
	addi    rTMP2, rTMP, -1
	beq	cr1, L(equal)
	andc    rTMP2, rTMP2, rTMP
	rldimi	rTMP2, rTMP2, 1, 0
	and	rWORD2, rWORD2, rTMP2	/* Mask off gunk.  */
	and	rWORD1, rWORD1, rTMP2
	cmpd	cr1, rWORD1, rWORD2
	beq	cr1, L(equal)
	xor	rBITDIF, rWORD1, rWORD2	/* rBITDIF has bits that differ.  */
	neg	rNEG, rBITDIF
	and	rNEG, rNEG, rBITDIF	/* rNEG has LS bit that differs.  */
	cntlzd	rNEG, rNEG		/* bitcount of the bit.  */
	andi.	rNEG, rNEG, 56		/* bitcount to LS byte that differs. */
	sld	rWORD1, rWORD1, rNEG	/* shift left to clear MS bytes.  */
	sld	rWORD2, rWORD2, rNEG
	xor.	rBITDIF, rWORD1, rWORD2
	sub	rRTN, rWORD1, rWORD2
	blt-	L(highbit)
	sradi	rRTN, rRTN, 63		/* must return an int.  */
	ori	rRTN, rRTN, 1
	blr
L(equal):
	li	rRTN, 0
	blr

L(different):
	ld	rWORD1, -8(rSTR1)
	xor	rBITDIF, rWORD1, rWORD2	/* rBITDIF has bits that differ.  */
	neg	rNEG, rBITDIF
	and	rNEG, rNEG, rBITDIF	/* rNEG has LS bit that differs.  */
	cntlzd	rNEG, rNEG		/* bitcount of the bit.  */
	andi.	rNEG, rNEG, 56		/* bitcount to LS byte that differs. */
	sld	rWORD1, rWORD1, rNEG	/* shift left to clear MS bytes.  */
	sld	rWORD2, rWORD2, rNEG
	xor.	rBITDIF, rWORD1, rWORD2
	sub	rRTN, rWORD1, rWORD2
	blt-	L(highbit)
	sradi	rRTN, rRTN, 63
	ori	rRTN, rRTN, 1
	blr
L(highbit):
	sradi	rRTN, rWORD2, 63
	ori	rRTN, rRTN, 1
	blr

#else
L(endstring):
	and	rTMP, r7F7F, rWORD1
	beq	cr1, L(equal)
	add	rTMP, rTMP, r7F7F
	xor.	rBITDIF, rWORD1, rWORD2
	andc	rNEG, rNEG, rTMP
	blt-	L(highbit)
	cntlzd	rBITDIF, rBITDIF
	cntlzd	rNEG, rNEG
	addi	rNEG, rNEG, 7
	cmpd	cr1, rNEG, rBITDIF
	sub	rRTN, rWORD1, rWORD2
	blt-	cr1, L(equal)
	sradi	rRTN, rRTN, 63		/* must return an int.  */
	ori	rRTN, rRTN, 1
	blr
L(equal):
	li	rRTN, 0
	blr

L(different):
	ld	rWORD1, -8(rSTR1)
	xor.	rBITDIF, rWORD1, rWORD2
	sub	rRTN, rWORD1, rWORD2
	blt-	L(highbit)
	sradi	rRTN, rRTN, 63
	ori	rRTN, rRTN, 1
	blr
L(highbit):
	sradi	rRTN, rWORD2, 63
	ori	rRTN, rRTN, 1
	blr
#endif

/* Oh well.  In this case, we just do a byte-by-byte comparison.  */
	.align 4
L(unaligned):
	lbz	rWORD1, 0(rSTR1)
	lbz	rWORD2, 0(rSTR2)
	b	L(u1)

L(u0):	lbzu	rWORD1, 1(rSTR1)
	bne-	L(u4)
	lbzu	rWORD2, 1(rSTR2)
L(u1):	cmpwi	cr1, rWORD1, 0
	beq-	cr1, L(u3)
	cmpd	rWORD1, rWORD2
	bne-	L(u3)
	lbzu	rWORD1, 1(rSTR1)
	lbzu	rWORD2, 1(rSTR2)
	cmpdi	cr1, rWORD1, 0
	cmpd	rWORD1, rWORD2
	bne+	cr1, L(u0)
L(u3):	sub	rRTN, rWORD1, rWORD2
	blr
L(u4):	lbz	rWORD1, -1(rSTR1)
	sub	rRTN, rWORD1, rWORD2
	blr
END (STRCMP)
libc_hidden_builtin_def (strcmp)
