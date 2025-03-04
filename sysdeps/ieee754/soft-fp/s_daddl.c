/* Add long double (ldbl-128) values, narrowing the result to double,
   using soft-fp.
   Copyright (C) 2018-2025 Free Software Foundation, Inc.
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

#define f32xaddf64x __hide_f32xaddf64x
#define f32xaddf128 __hide_f32xaddf128
#define f64addf64x __hide_f64addf64x
#define f64addf128 __hide_f64addf128
#include <math.h>
#undef f32xaddf64x
#undef f32xaddf128
#undef f64addf64x
#undef f64addf128

#include <math-narrow.h>
#include <soft-fp.h>
#include <double.h>
#include <quad.h>

double
__daddl (_Float128 x, _Float128 y)
{
  FP_DECL_EX;
  FP_DECL_Q (X);
  FP_DECL_Q (Y);
  FP_DECL_Q (R);
  FP_DECL_D (RN);
  double ret;

  FP_INIT_ROUNDMODE;
  FP_UNPACK_SEMIRAW_Q (X, x);
  FP_UNPACK_SEMIRAW_Q (Y, y);
  FP_ADD_Q (R, X, Y);
#if _FP_W_TYPE_SIZE < 64
  FP_TRUNC (D, Q, 2, 4, RN, R);
#else
  FP_TRUNC (D, Q, 1, 2, RN, R);
#endif
  FP_PACK_SEMIRAW_D (ret, RN);
  FP_HANDLE_EXCEPTIONS;
  CHECK_NARROW_ADD (ret, x, y);
  return ret;
}
libm_alias_double_ldouble (add)
