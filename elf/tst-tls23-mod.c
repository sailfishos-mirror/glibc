/* DSO used by tst-tls23.
   Copyright (C) 2025 Free Software Foundation, Inc.
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

#include <tst-tls23.h>

__thread struct tls tls_var0 __attribute__ ((visibility ("hidden")));

struct tls *
apply_tls (struct tls *p)
{
  INIT_TLS_CALL ();
  BEFORE_TLS_CALL ();
  tls_var0 = *p;
  struct tls *ret = &tls_var0;
  AFTER_TLS_CALL ();
  return ret;
}
