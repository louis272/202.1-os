.global _start
_start:
  mov x0, #12

  bl _fib

  mov w8, #93
  svc #0

_fib:
  // Add your implementation here.
  // if n=0 or n=1
  cmp x0, #1
  blt _end
  
  mov x1, #0
  mov x2, #1
  mov x3, #2 // index

_loop:
  cmp x3, x0
  bgt _endLoop

  add x4, x1, x2
  mov x1, x2
  mov x2, x4

  add x3, x3, #1
  
  b _loop

_endLoop:
  mov x0, x4

_end:
  ret
