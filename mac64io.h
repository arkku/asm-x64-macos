#ifndef MAC64IO_H
#define MAC64IO_H

#include <stdint.h>

/// Read character from stdin.
/// Returns the character read, or -1 on EOF/error.
int getchar();

/// Read a line of at most `size - 1` characters from stdin.
///
/// Reading stops (and includes) the first newline encountered,
/// or at the end of file, or when `buf` is full, whichever
/// occurs first.
char *getln(int RDI, char RSI[static RDI]);

/// Returns the length of the NUL-terminated string].
uint64_t strlen(const char *RDI);

/// Copies the NUL-terminated string from [RDI] to [RSI].
/// Returns a pointer to the start of the destination.
char *strcpy(char * restrict RDI, const char * restrict RSI);

/// Copies RDX bytes from [RSI] to [RDI].
/// Returns a pointer to the destination.
void *memcpy(void * restrict RDI, const void * restrict RSI, uint64_t RDX);

/// Sets RDX bytes in [RDI] to SIL.
/// Returns a pointer to the destination.
void *memset(void *RDI, char SIL, uint64_t RDX);

/// Compare two NUL-terminated strings.
/// Returns zero if the strings are equal, negative if the first is
/// in ordered before the second, and positive otherwise.
int strcmp(const char *RDI, const char *RSI);

/// Write character to stdout.
/// Returns non-zero on success.
int putchar(char DIL);

/// Write string to stdout.
/// Returns non-zero on success.
int print(const char *RDI);

/// Write string, followed by a newline to stdout.
/// Returns non-zero on success.
int puts(const char *RDI);

/// Write integer to stdout in decimal.
/// Returns non-zero on success.
int printi(int64_t RDI);

/// Parse signed integer from string as decimal.
/// Does not support leading whitespace or + sign.
/// Returns the integer and a pointer to one past its end in input.
int64_t parseint(const char *RDI);

/// Parse signed integer from string as decimal.
/// Skips any leading whitespace, and supports an optional + sign.
/// Returns the integer and a pointer to one past its end in input.
int atoi(const char *RDI);

/// Parse signed integer from string as decimal.
/// Skips any leading whitespace, and supports an optional + sign.
/// Returns the integer and a pointer to one past its end in input.
int64_t atol(const char *RDI);

/// Parse unsigned integer from string as decimal.
/// Does not support leading whitespace or sign.
/// Returns the integer and a pointer to one past its end in input.
uint64_t parseuint(const char *RDI);

/// Parse signed integer from string as decimal.
/// Skips any leading whitespace.
/// Returns the integer and a pointer to one past its end in input.
unsigned int atou(const char *RDI);

/// Parse signed integer from string as decimal.
/// Skips any leading whitespace.
/// Returns the integer and a pointer to one past its end in input.
uint64_t atoul(const char *RDI);

#endif
