/* Copyright (C) 1996-2025 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published
   by the Free Software Foundation; version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see <https://www.gnu.org/licenses/>.  */

#include <netdb.h>


#define LOOKUP_TYPE		struct servent
#define FUNCTION_NAME		getservbyname
#define DATABASE_NAME		services
#define ADD_PARAMS		const char *name, const char *proto
#define ADD_VARIABLES		name, proto

/* We are nscd, so we don't want to be talking to ourselves.  */
#undef	USE_NSCD

#include "../nss/getXXbyYY_r.c"
