/* Add SIG to the calling process' signal mask.
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

#define __need_NULL
#include <stddef.h>
#include <signal.h>

int
sighold (int sig)
{
  sigset_t set;

  sigemptyset (&set);
  if (sigaddset (&set, sig) < 0)
    return -1;
  return __sigprocmask (SIG_BLOCK, &set, NULL);
}
