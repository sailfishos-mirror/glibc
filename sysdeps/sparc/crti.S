/* Special .init and .fini section support for sparc.
   Copyright (C) 1995-2025 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   In addition to the permissions in the GNU Lesser General Public
   License, the Free Software Foundation gives you unlimited
   permission to link the compiled version of this file with other
   programs, and to distribute those programs without any restriction
   coming from the use of this file. (The GNU Lesser General Public
   License restrictions do apply in other respects; for example, they
   cover modification of the file, and distribution when not linked
   into another program.)

   Note that people who make modified versions of this file are not
   obligated to grant this special exception for their modified
   versions; it is their choice whether to do so. The GNU Lesser
   General Public License gives permission to release a modified
   version without this exception; this exception also makes it
   possible to release a modified version which carries forward this
   exception.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */

/* crti.S puts a function prologue at the beginning of the .init and
   .fini sections and defines global symbols for those addresses, so
   they can be called as functions.  The symbols _init and _fini are
   magic and cause the linker to emit DT_INIT and DT_FINI.  */

#include <libc-symbols.h>
#include <sysdep.h>

#ifndef PREINIT_FUNCTION
# define PREINIT_FUNCTION __gmon_start__
#endif

#ifndef PREINIT_FUNCTION_WEAK
# define PREINIT_FUNCTION_WEAK 1
#endif

#if PREINIT_FUNCTION_WEAK
	weak_extern (PREINIT_FUNCTION)
#else
	.hidden PREINIT_FUNCTION
#endif

#ifdef __arch64__
#define	STACKFRAME_SIZE	176
#define GOT_LOAD	ldx
#else
#define	STACKFRAME_SIZE	96
#define GOT_LOAD	ld
#endif

	.section	.init,"ax",@progbits
	.p2align	2
	.globl		_init
	.hidden		_init
	.type		_init, @function
_init:
	save		%sp, -STACKFRAME_SIZE, %sp
#if PREINIT_FUNCTION_WEAK
	SETUP_PIC_REG(l7)
	sethi		%gdop_hix22(PREINIT_FUNCTION), %g1
	xor		%g1, %gdop_lox10(PREINIT_FUNCTION), %g1
	GOT_LOAD	[%l7 + %g1], %g1, %gdop(PREINIT_FUNCTION)
	cmp		%g1, 0
	be		1f
	 nop
	call		PREINIT_FUNCTION
	 nop
1:
#else
	call		PREINIT_FUNCTION
	 nop
#endif

	.section	.fini,"ax",@progbits
	.p2align	2
	.globl		_fini
	.hidden		_fini
	.type		_fini, @function
_fini:
	save		%sp, -STACKFRAME_SIZE, %sp
