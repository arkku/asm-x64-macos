#ifndef KK_ASM_H
#define KK_ASM_H

#include <stdint.h>

/// Read character from stdin.
/// Returns the character read, or -1 on EOF/error.
int getchar();

/// Read a line of at most `size - 1` characters from stdin.
///
/// Reading stops (and includes) the first newline encountered,
/// or at the end of file, or when `buf` is full, whichever
/// occurs first.
char *getln(int size, char buf[static size]);

/// Returns the length of the NUL-terminated string].
uint64_t strlen(const char *str);

/// Copy the NUL-terminated string from `src` to `dst`.
/// Returns a pointer to the start of the destination.
char *strcpy(char * restrict dst, const char * restrict src);

/// Copy `count` bytes from `src` to `dst`.
/// Returns a pointer to the destination.
void *memcpy(void * restrict dst, const void * restrict src, uint64_t count);

/// Set `count` bytes in `buf` to `c`.
/// Returns a pointer to the destination.
void *memset(void *buf, int c, uint64_t count);

/// Compare two NUL-terminated strings.
/// Returns zero if the strings are equal, negative if the first is
/// in ordered before the second, and positive otherwise.
int strcmp(const char *a, const char *b);

/// Write character `c` to stdout.
/// Returns non-zero on success.
int putchar(int c);

/// Write string to stdout.
/// Returns non-zero on success.
int print(const char *str);

/// Write string, followed by a newline to stdout.
/// Returns non-zero on success.
int puts(const char *str);

/// Write integer to stdout in decimal.
/// Returns non-zero on success.
int printi(int64_t i);

/// Parse signed integer from string as decimal.
/// Does not support leading whitespace or + sign.
/// Returns the integer and a pointer to one past its end in input.
int64_t parseint(const char *str);

/// Parse signed integer from string as decimal.
/// Skips any leading whitespace, and supports an optional + sign.
/// Returns the integer and a pointer to one past its end in input.
int atoi(const char *str);

/// Parse signed integer from string as decimal.
/// Skips any leading whitespace, and supports an optional + sign.
/// Returns the integer and a pointer to one past its end in input.
int64_t atol(const char *str);

/// Parse unsigned integer from string as decimal.
/// Does not support leading whitespace or sign.
/// Returns the integer and a pointer to one past its end in input.
uint64_t parseuint(const char *str);

/// Parse signed integer from string as decimal.
/// Skips any leading whitespace.
/// Returns the integer and a pointer to one past its end in input.
unsigned int atou(const char *str);

/// Parse signed integer from string as decimal.
/// Skips any leading whitespace.
/// Returns the integer and a pointer to one past its end in input.
uint64_t atoul(const char *str);

/// Generate a 64-bit random number.
uint64_t rand64(void);

/// The maximum number returned by `rand()`.
#define RAND_MAX 0x3fffffff

/// Generate a 30-bit random number.
int rand(void);

/// Seed the random number generator.
void srand(unsigned int seed);

/// Generate a random number uniformly in the range [0, `upper_bound`).
/// This is slower, but more uniform than `rand64() % upper_bound` in
/// the general case, but if `upper_bound` is known to be a power of 2,
/// it is better to just use `rand64()` and drop any unwanted bits.
uint64_t randuniform(uint64_t upper_bound);

#endif
