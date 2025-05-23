/* strcat (dest, src) -- Append SRC on the end of DEST.
   For SPARC v9.
   Copyright (C) 1998-2025 Free Software Foundation, Inc.
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
#include <asm/asi.h>
#ifndef XCC
#define XCC xcc
#define USE_BPR
	.register	%g2, #scratch
	.register	%g3, #scratch
	.register	%g6, #scratch
#endif

	/* Normally, this uses
	   ((xword - 0x0101010101010101) & 0x8080808080808080) test
	   to find out if any byte in xword could be zero. This is fast, but
	   also gives false alarm for any byte in range 0x81-0xff. It does
	   not matter for correctness, as if this test tells us there could
	   be some zero byte, we check it byte by byte, but if bytes with
	   high bits set are common in the strings, then this will give poor
	   performance. You can #define EIGHTBIT_NOT_RARE and the algorithm
	   will use one tick slower, but more precise test
	   ((xword - 0x0101010101010101) & (~xword) & 0x8080808080808080),
	   which does not give any false alarms (but if some bits are set,
	   one cannot assume from it which bytes are zero and which are not).
	   It is yet to be measured, what is the correct default for glibc
	   in these days for an average user.
	 */

	.text
	.align		32
ENTRY(strcat)
	sethi		%hi(0x01010101), %g1		/* IEU0		Group		*/
	ldub		[%o0], %o3			/* Load				*/
	or		%g1, %lo(0x01010101), %g1	/* IEU0		Group		*/
	mov		%o0, %g6			/* IEU1				*/

	sllx		%g1, 32, %g2			/* IEU0		Group		*/
	andcc		%o0, 7, %g0			/* IEU1				*/
	or		%g1, %g2, %g1			/* IEU0		Group		*/
	bne,pn		%icc, 32f			/* CTI				*/

	 sllx		%g1, 7, %g2			/* IEU0		Group		*/
	brz,pn		%o3, 30f			/* CTI+IEU1			*/
	 ldx		[%o0], %o3			/* Load				*/
48:	add		%o0, 8, %o0			/* IEU0		Group		*/

49:	sub		%o3, %g1, %o2			/* IEU0		Group		*/
#ifdef EIGHTBIT_NOT_RARE
	andn		%o2, %o3, %g5			/* IEU0		Group		*/
	ldxa		[%o0] ASI_PNF, %o3		/* Load				*/
	andcc		%g5, %g2, %g0			/* IEU1		Group		*/
#else
	ldxa		[%o0] ASI_PNF, %o3		/* Load				*/
	andcc		%o2, %g2, %g0			/* IEU1		Group		*/
#endif
	be,pt		%xcc, 49b			/* CTI				*/

	 add		%o0, 8, %o0			/* IEU0				*/
 	addcc		%o2, %g1, %g3			/* IEU1		Group		*/
	srlx		%o2, 32, %o2			/* IEU0				*/
50:	andcc		%o2, %g2, %g0			/* IEU1		Group		*/

	be,pn		%xcc, 51f			/* CTI				*/
	 srlx		%g3, 56, %o2			/* IEU0				*/
	andcc		%o2, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 29f			/* CTI				*/

	 srlx		%g3, 48, %o2			/* IEU0				*/
	andcc		%o2, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 28f			/* CTI				*/
	 srlx		%g3, 40, %o2			/* IEU0				*/

	andcc		%o2, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 27f			/* CTI				*/
	 srlx		%g3, 32, %o2			/* IEU0				*/
	andcc		%o2, 0xff, %g0			/* IEU1		Group		*/

	be,pn		%icc, 26f			/* CTI				*/
51:	 srlx		%g3, 24, %o2			/* IEU0				*/
	andcc		%o2, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 25f			/* CTI				*/

	 srlx		%g3, 16, %o2			/* IEU0				*/
	andcc		%o2, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 24f			/* CTI				*/
	 srlx		%g3, 8, %o2			/* IEU0				*/

	andcc		%o2, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 23f			/* CTI				*/
	 sub		%o3, %g1, %o2			/* IEU0				*/
	andcc		%g3, 0xff, %g0			/* IEU1		Group		*/

	be,pn		%icc, 52f			/* CTI				*/
	 ldxa		[%o0] ASI_PNF, %o3		/* Load				*/
	andcc		%o2, %g2, %g0			/* IEU1		Group		*/
	be,pt		%xcc, 49b			/* CTI				*/

	 add		%o0, 8, %o0			/* IEU0				*/
	addcc		%o2, %g1, %g3			/* IEU1		Group		*/
	ba,pt		%xcc, 50b			/* CTI				*/
	 srlx		%o2, 32, %o2			/* IEU0				*/

	.align		16
52:	ba,pt		%xcc, 12f			/* CTI		Group		*/
	 add		%o0, -9, %o0			/* IEU0				*/
23:	ba,pt		%xcc, 12f			/* CTI		Group		*/
	 add		%o0, -10, %o0			/* IEU0				*/

24:	ba,pt		%xcc, 12f			/* CTI		Group		*/
	 add		%o0, -11, %o0			/* IEU0				*/
25:	ba,pt		%xcc, 12f			/* CTI		Group		*/
	 add		%o0, -12, %o0			/* IEU0				*/

26:	ba,pt		%xcc, 12f			/* CTI		Group		*/
	 add		%o0, -13, %o0			/* IEU0				*/
27:	ba,pt		%xcc, 12f			/* CTI		Group		*/
	 add		%o0, -14, %o0			/* IEU0				*/

28:	ba,pt		%xcc, 12f			/* CTI		Group		*/
	 add		%o0, -15, %o0			/* IEU0				*/
29:	add		%o0, -16, %o0			/* IEU0		Group		*/
30:	andcc		%o1, 7, %g3			/* IEU1				*/

31:	bne,pn		%icc, 14f			/* CTI				*/
	 orcc		%g0, 64, %g4			/* IEU1		Group		*/
1:	ldx		[%o1], %o3			/* Load				*/
	add		%o1, 8, %o1			/* IEU1				*/

2:	mov		%o3, %g3			/* IEU0		Group		*/
3:	sub		%o3, %g1, %o2			/* IEU1				*/
	ldxa		[%o1] ASI_PNF, %o3		/* Load				*/
#ifdef EIGHTBIT_NOT_RARE
	andn		%o2, %g3, %o2			/* IEU0		Group		*/
#endif
	add		%o0, 8, %o0			/* IEU0		Group		*/

	andcc		%o2, %g2, %g0			/* IEU1				*/
	add		%o1, 8, %o1			/* IEU0		Group		*/
	be,a,pt		%xcc, 2b			/* CTI				*/
	 stx		%g3, [%o0 - 8]			/* Store			*/

	srlx		%g3, 56, %g5			/* IEU0		Group		*/
	andcc		%g5, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 11f			/* CTI				*/
	 srlx		%g3, 48, %g4			/* IEU0				*/

	andcc		%g4, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 10f			/* CTI				*/
	 srlx		%g3, 40, %g5			/* IEU0				*/
	andcc		%g5, 0xff, %g0			/* IEU1		Group		*/

	be,pn		%icc, 9f			/* CTI				*/
	 srlx		%g3, 32, %g4			/* IEU0				*/
	andcc		%g4, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 8f			/* CTI				*/

	 srlx		%g3, 24, %g5			/* IEU0				*/
	andcc		%g5, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 7f			/* CTI				*/
	 srlx		%g3, 16, %g4			/* IEU0				*/

	andcc		%g4, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 6f			/* CTI				*/
	 srlx		%g3, 8, %g5			/* IEU0				*/
	andcc		%g5, 0xff, %g0			/* IEU1		Group		*/

	be,pn		%icc, 5f			/* CTI				*/
	 sub		%o3, %g1, %o2			/* IEU0				*/
	stx		%g3, [%o0 - 8]			/* Store	Group		*/
	andcc		%g3, 0xff, %g0			/* IEU1				*/

	bne,pt		%icc, 3b			/* CTI				*/
	 mov		%o3, %g3			/* IEU0		Group		*/
4:	retl						/* CTI+IEU1	Group		*/
	 mov		%g6, %o0			/* IEU0				*/

	.align		16
5:	stb		%g5, [%o0 - 2]			/* Store	Group		*/
	srlx		%g3, 16, %g4			/* IEU0				*/
6:	sth		%g4, [%o0 - 4]			/* Store	Group		*/
	srlx		%g3, 32, %g4			/* IEU0				*/

	stw		%g4, [%o0 - 8]			/* Store	Group		*/
	retl						/* CTI+IEU1	Group		*/
	 mov		%g6, %o0			/* IEU0				*/
7:	stb		%g5, [%o0 - 4]			/* Store	Group		*/

	srlx		%g3, 32, %g4			/* IEU0				*/
8:	stw		%g4, [%o0 - 8]			/* Store	Group		*/
	retl						/* CTI+IEU1	Group		*/
	 mov		%g6, %o0 			/* IEU0				*/

9:	stb		%g5, [%o0 - 6]			/* Store	Group		*/
	srlx		%g3, 48, %g4			/* IEU0				*/
10:	sth		%g4, [%o0 - 8]			/* Store	Group		*/
	retl						/* CTI+IEU1	Group		*/

	 mov		%g6, %o0			/* IEU0				*/
11:	stb		%g5, [%o0 - 8]			/* Store	Group		*/
	retl						/* CTI+IEU1	Group		*/
	 mov		%g6, %o0			/* IEU0				*/

	.align		16
32:	andcc		%o0, 7, %g0			/* IEU1		Group		*/
	be,a,pn		%icc, 48b			/* CTI				*/
	 ldx		[%o0], %o3			/* Load				*/
	add		%o0, 1, %o0			/* IEU0		Group		*/

	brnz,a,pt	%o3, 32b			/* CTI+IEU1			*/
	 lduba		[%o0] ASI_PNF, %o3		/* Load				*/
	add		%o0, -1, %o0			/* IEU0		Group		*/
	andcc		%o0, 7, %g0			/* IEU1		Group		*/

	be,a,pn		%icc, 31b			/* CTI				*/
	 andcc		%o1, 7, %g3			/* IEU1		Group		*/
12:	ldub		[%o1], %o3			/* Load				*/
	stb		%o3, [%o0]			/* Store	Group		*/

13:	add		%o0, 1, %o0			/* IEU0				*/
	add		%o1, 1, %o1			/* IEU1				*/
	andcc		%o3, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 4b			/* CTI				*/

	 lduba		[%o1] ASI_PNF, %o3		/* Load				*/
	andcc		%o0, 7, %g0			/* IEU1		Group		*/
	bne,a,pt	%icc, 13b			/* CTI				*/
	 stb		%o3, [%o0]			/* Store			*/

	andcc		%o1, 7, %g3			/* IEU1		Group		*/
	be,a,pt		%icc, 1b			/* CTI				*/
	 ldx		[%o1], %o3			/* Load				*/
	orcc		%g0, 64, %g4			/* IEU1		Group		*/

14:	sllx		%g3, 3, %g5			/* IEU0				*/
	sub		%o1, %g3, %o1			/* IEU0		Group		*/
	sub		%g4, %g5, %g4			/* IEU1				*/
							/* %g1 = 0101010101010101	*
							 * %g2 = 8080808080808080	*
							 * %g3 = source alignment	*
							 * %g5 = number of bits to shift left  *
							 * %g4 = number of bits to shift right */
	ldxa		[%o1] ASI_PNF, %o5		/* Load		Group		*/

	addcc		%o1, 8, %o1			/* IEU1				*/
15:	sllx		%o5, %g5, %o3			/* IEU0		Group		*/
	ldxa		[%o1] ASI_PNF, %o5		/* Load				*/
	srlx		%o5, %g4, %o4			/* IEU0		Group		*/

	add		%o0, 8, %o0			/* IEU1				*/
	or		%o3, %o4, %o3			/* IEU0		Group		*/
	add		%o1, 8, %o1			/* IEU1				*/
	sub		%o3, %g1, %o4			/* IEU0		Group		*/

#ifdef EIGHTBIT_NOT_RARE
	andn		%o4, %o3, %o4			/* IEU0		Group		*/
#endif
	andcc		%o4, %g2, %g0			/* IEU1		Group		*/
	be,a,pt		%xcc, 15b			/* CTI				*/
	 stx		%o3, [%o0 - 8]			/* Store			*/
	srlx		%o3, 56, %o4			/* IEU0		Group		*/

	andcc		%o4, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 22f			/* CTI				*/
	 srlx		%o3, 48, %o4			/* IEU0				*/
	andcc		%o4, 0xff, %g0			/* IEU1		Group		*/

	be,pn		%icc, 21f			/* CTI				*/
	 srlx		%o3, 40, %o4			/* IEU0				*/
	andcc		%o4, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 20f			/* CTI				*/

	 srlx		%o3, 32, %o4			/* IEU0				*/
	andcc		%o4, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 19f			/* CTI				*/
	 srlx		%o3, 24, %o4			/* IEU0				*/

	andcc		%o4, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 18f			/* CTI				*/
	 srlx		%o3, 16, %o4			/* IEU0				*/
	andcc		%o4, 0xff, %g0			/* IEU1		Group		*/

	be,pn		%icc, 17f			/* CTI				*/
	 srlx		%o3, 8, %o4			/* IEU0				*/
	andcc		%o4, 0xff, %g0			/* IEU1		Group		*/
	be,pn		%icc, 16f			/* CTI				*/

	 andcc		%o3, 0xff, %g0			/* IEU1		Group		*/
	bne,pn		%icc, 15b			/* CTI				*/
	 stx		%o3, [%o0 - 8]			/* Store			*/
	retl						/* CTI+IEU1	Group		*/

	 mov		%g6, %o0			/* IEU0				*/

	.align		16
16:	srlx		%o3, 8, %o4			/* IEU0		Group		*/
	stb		%o4, [%o0 - 2]			/* Store			*/
17:	srlx		%o3, 16, %o4			/* IEU0		Group		*/
	stb		%o4, [%o0 - 3]			/* Store			*/

18:	srlx		%o3, 24, %o4			/* IEU0		Group		*/
	stb		%o4, [%o0 - 4]			/* Store			*/
19:	srlx		%o3, 32, %o4			/* IEU0		Group		*/
	stw		%o4, [%o0 - 8]			/* Store			*/

	retl						/* CTI+IEU1	Group		*/
	 mov		%g6, %o0 			/* IEU0				*/
	nop
	nop

20:	srlx		%o3, 40, %o4			/* IEU0		Group		*/
	stb		%o4, [%o0 - 6]			/* Store			*/
21:	srlx		%o3, 48, %o4			/* IEU0		Group		*/
	stb		%o4, [%o0 - 7]			/* Store			*/

22:	srlx		%o3, 56, %o4			/* IEU0		Group		*/
	stb		%o4, [%o0 - 8]			/* Store			*/
	retl						/* CTI+IEU1	Group		*/
	 mov		%g6, %o0			/* IEU0				*/
END(strcat)
libc_hidden_builtin_def (strcat)
