/* Copyright (C) 2002-2025 Free Software Foundation, Inc.
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

#include <errno.h>
#include "semaphoreP.h"
#include <sem_routines.h>

int
__sem_close (sem_t *sem)
{
  if (!__sem_remove_mapping (sem))
    {
      __set_errno (EINVAL);
      return -1;
    }

  return 0;
}
#if PTHREAD_IN_LIBC
versioned_symbol (libc, __sem_close, sem_close, GLIBC_2_34);
# if OTHER_SHLIB_COMPAT (libpthread, GLIBC_2_1_1, GLIBC_2_34)
compat_symbol (libpthread, __sem_close, sem_close, GLIBC_2_1_1);
# endif
#else /* !PTHREAD_IN_LIBC */
strong_alias (__sem_close, sem_close)
#endif
