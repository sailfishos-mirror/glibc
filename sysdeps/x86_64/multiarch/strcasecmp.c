/* Multiple versions of strcasecmp.
   All versions must be listed in ifunc-impl-list.c.
   Copyright (C) 2017-2025 Free Software Foundation, Inc.
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

/* Define multiple versions only for the definition in libc.  */
#if IS_IN (libc)
# define strcasecmp __redirect_strcasecmp
# define __strcasecmp __redirect___strcasecmp
# include <string.h>
# undef strcasecmp
# undef __strcasecmp

# define SYMBOL_NAME strcasecmp
# include "ifunc-strcasecmp.h"

libc_ifunc_redirected (__redirect_strcasecmp, __strcasecmp,
		       IFUNC_SELECTOR ());

weak_alias (__strcasecmp, strcasecmp)
# ifdef SHARED
__hidden_ver1 (__strcasecmp, __GI___strcasecmp, __redirect___strcasecmp)
  __attribute__ ((visibility ("hidden")));
# endif
#endif
