/* Atomic operations.  Sparc version.
   Copyright (C) 2019-2025 Free Software Foundation, Inc.
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

#ifndef _ATOMIC_MACHINE_H
#define _ATOMIC_MACHINE_H	1

#ifdef __arch64__
# define __HAVE_64B_ATOMICS          1
#else
# define __HAVE_64B_ATOMICS          0
#endif
#define USE_ATOMIC_COMPILER_BUILTINS 1

/* XXX Is this actually correct?  */
#define ATOMIC_EXCHANGE_USES_CAS     __HAVE_64B_ATOMICS

/* Compare and exchange.
   For all "bool" routines, we return FALSE if exchange successful.  */

#define __arch_compare_and_exchange_val_int(mem, newval, oldval, model) \
  ({									\
    typeof (*mem) __oldval = (oldval);					\
    __atomic_compare_exchange_n (mem, (void *) &__oldval, newval, 0,	\
				 model, __ATOMIC_RELAXED);		\
    __oldval;								\
  })

#define atomic_compare_and_exchange_val_acq(mem, new, old)		      \
  ({									      \
    __typeof ((__typeof (*(mem))) *(mem)) __result;			      \
    if (sizeof (*mem) == 4						      \
        || (__HAVE_64B_ATOMICS && sizeof (*mem) == 8))			      \
      __result = __arch_compare_and_exchange_val_int (mem, new, old,	      \
							 __ATOMIC_ACQUIRE);   \
    else								      \
      abort ();								      \
    __result;								      \
  })

#ifdef __sparc_v9__
# define atomic_full_barrier() \
  __asm __volatile ("membar #LoadLoad | #LoadStore"			      \
		    " | #StoreLoad | #StoreStore" : : : "memory")
# define atomic_read_barrier() \
  __asm __volatile ("membar #LoadLoad | #LoadStore" : : : "memory")
# define atomic_write_barrier() \
  __asm __volatile ("membar #LoadStore | #StoreStore" : : : "memory")

extern void __cpu_relax (void);
# define atomic_spin_nop() __cpu_relax ()
#endif

#endif /* _ATOMIC_MACHINE_H  */
