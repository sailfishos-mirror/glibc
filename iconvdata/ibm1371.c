/* Conversion from and to IBM1371.
   Copyright (C) 2005-2025 Free Software Foundation, Inc.
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

#define DATA_HEADER	"ibm1371.h"
#define CHARSET_NAME	"IBM1371//"
#define FROM_LOOP	from_ibm1371
#define TO_LOOP		to_ibm1371
#define SB_TO_UCS4	__ibm1371sb_to_ucs4
#define DB_TO_UCS4_IDX	__ibm1371db_to_ucs4_idx
#define DB_TO_UCS4	__ibm1371db_to_ucs4
#define UCS4_TO_SB_IDX	__ucs4_to_ibm1371sb_idx
#define UCS4_TO_SB	__ucs4_to_ibm1371sb
#define UCS4_TO_DB_IDX	__ucs4_to_ibm1371db_idx
#define UCS4_TO_DB	__ucs4_to_ibm1371db
#define UCS_LIMIT	0xffff

#include "ibm1364.c"
