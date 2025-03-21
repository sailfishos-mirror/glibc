/* Data for vDSO support.  Linux version.
   Copyright (C) 2020-2025 Free Software Foundation, Inc.
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

/* This file is included in three different modes for both static (libc.a)
   and shared (rtld) modes:

   1. PROCINFO_DECL is defined, meaning we are only interested in
      declarations.  For static it requires use the extern keyword along with
      the attribute_relro while for shared it will be embedded in the
      rtld_global_ro.

   2. PROCINFO_DECL and SHARED are not defined.  Nothing to do, the default
      zero initializion is suffice.

   3. PROCINFO_DECL is not defined while SHARED is.  Similar to 2., the zero
      initialization of rtld_global_ro is suffice.  */

#ifndef PROCINFO_CLASS
# define PROCINFO_CLASS
#endif

#ifndef SHARED
# define RELRO attribute_relro
#else
# define RELRO
#endif

#if defined PROCINFO_DECL || !defined SHARED
# ifdef HAVE_CLOCK_GETTIME_VSYSCALL
PROCINFO_CLASS int (*_dl_vdso_clock_gettime) (clockid_t,
					      struct timespec *) RELRO;
#endif
# ifdef HAVE_CLOCK_GETTIME64_VSYSCALL
PROCINFO_CLASS int (*_dl_vdso_clock_gettime64) (clockid_t,
						struct __timespec64 *) RELRO;
#endif
# ifdef HAVE_GETTIMEOFDAY_VSYSCALL
PROCINFO_CLASS int (*_dl_vdso_gettimeofday) (struct timeval *, void *) RELRO;
#endif
# ifdef HAVE_TIME_VSYSCALL
PROCINFO_CLASS time_t (*_dl_vdso_time) (time_t *) RELRO;
# endif
# ifdef HAVE_GETCPU_VSYSCALL
PROCINFO_CLASS int (*_dl_vdso_getcpu) (unsigned *, unsigned *, void *) RELRO;
# endif
# ifdef HAVE_CLOCK_GETRES_VSYSCALL
PROCINFO_CLASS int (*_dl_vdso_clock_getres) (clockid_t,
					     struct timespec *) RELRO;
# endif
# ifdef HAVE_CLOCK_GETRES64_VSYSCALL
PROCINFO_CLASS int (*_dl_vdso_clock_getres_time64) (clockid_t,
						    struct __timespec64 *) RELRO;
# endif
# ifdef HAVE_GETRANDOM_VSYSCALL
PROCINFO_CLASS ssize_t (*_dl_vdso_getrandom) (void *buffer, size_t len,
                                              unsigned int flags, void *state,
                                              size_t state_len) RELRO;
# endif

/* PowerPC specific ones.  */
# ifdef HAVE_GET_TBFREQ
PROCINFO_CLASS uint64_t (*_dl_vdso_get_tbfreq)(void) RELRO;
# endif

/* RISC-V specific ones.  */
# ifdef HAVE_RISCV_HWPROBE
PROCINFO_CLASS int (*_dl_vdso_riscv_hwprobe)(void *,
                                             size_t,
                                             size_t,
                                             unsigned long *,
                                             unsigned int) RELRO;
# endif

#endif

#undef RELRO
#undef PROCINFO_DECL
#undef PROCINFO_CLASS
