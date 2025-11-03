.data
  // A 12-bytes buffer.
  buffer:
    .word 0
    .word 0
    .word 0

.text

.global _start
_start:
  // Obtains the process ID of the program and prints it.
  mov   w8, #172
  svc   #0
  bl    _print_nat

  // Exit with status 0.
  mov   w0, #0
  mov   w8, #93
  svc   #0

// Prints the natural number stored in `x0` followed by a newline.
_print_nat:

  // Writes `\n` at the end of the buffer.
  ldr   x3, =buffer
  mov   w4, #10
  strb  w4, [x3, #11]

  // Is `x0` equal to 0?
  cbz   x0, _print_nat_0
  
  // Check if the number is larger than an uint32 integer
  mov   x9, #1
  lsl   x9, x9, #32
  cmp   x0, x9
  bge   _too_large

  // Otherwise, write each digit from right to left in a buffer, using `w1` to track the index of
  // the leftmost digit written in the buffer referred to by `x3`.
  mov   w1, #11
  mov   w2, #10

_print_nat_head:

  // Are we done?
  cbz   x0, _print_nat_n

  // Otherwise, write the next digit in the buffer.
  udiv  x4, x0, x2      // x4 = x0 / x2
  msub  x5, x4, x2, x0  // x5 = x0 % x2
  mov   x0, x4
  add   x5, x5, #48
  sub   x1, x1, #1
  strb  w5, [x3, x1]
  b     _print_nat_head

_print_nat_0:
  mov   x4, #48
  strb  w4, [x3, #10]
  mov   x1, #10

_print_nat_n:
  // Print the contents of the buffer referred to by `x3` starting from `w2`.
  add   x4, x3, x1
  mov   w3, #12
  sub   w2, w3, w1
  mov   x1, x4
  mov   x0, #1
  mov   w8, #64
  svc   #0
  ret

_too_large:
  // Exit with status 1.
  mov   w0, #1
  mov   w8, #93
  svc   #0
