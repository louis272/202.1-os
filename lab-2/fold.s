.data
  mm:
    .quad 0 // start of heap
    .quad 0 // current break
  usage:
    .ascii "usage: fold [sum|sort] n...\n\0"
  sum_text:
    .ascii "sum\0"
  sort_text:
    .ascii "sort\0"

.text
.global _start
_start:
  // Read command line arguments and exit unless there are at least two, excluding the name of the
  // executable. The first argument will be read as the command and the remainder will be parsed
  // as input numbers.
  ldr   x0, [sp]
  mov   x19, sp
  sub   x20, x0, #2
  add   x21, sp, #24
  cmp   x20, #0
  ble   _usage

  // Initialize the heap.
  bl    _init_heap

  // Allocate enough memory to store each input argument on the stack. We're allocating an even
  // number of elements to make sure we satisfy the alignment requirement of the stack pointer.
  lsl   x0, x20, #3
  mov   x1, #4
  bl    _round_up_to_next_multiple_of_2n
  sub   sp, sp, x0

  // Parse input numbers to numbers and store write them to the stack.
  mov   x22, sp
  mov   x23, x20
_l0:
  cbz   x23, _l1
  sub   x23, x23, #1
  ldr   x0, [x21], #8
  bl    _atoi
  str   x0, [x22], #8
  b     _l0
_l1:

  // Determine which command should be executed.
  ldr   x0, =sum_text
  ldr   x1, [x19, #16]
  bl    _strcmp
  cbnz  x0, _l2
  ldr   x0, =sort_text
  ldr   x1, [x19, #16]
  cbnz  x0, _l3
  b     _usage
_l2:
  mov   x5, #1000
  b     _l4
_l3:
  mov   x5, #1001
_l4:

  // Allocate memory for the accumulator. For the "sum" command, this memory will hold the sum of
  // each input number. For the "sort" command, it will hold a pointer to a binary search tree.
  mov   x0, #0
  stp   x0, x0, [sp, #-16]!

  // Configure the arguments that are identical for both commands.
  add   x0, sp, #16
  mov   x1, #8
  mov   x2, x20
  mov   x3, sp

  cmp  x5, #1001
  beq   _sort

  // _foldright(0, (a, b) => *a += *b)
  adrp	x5, _add
	add	  x4, x5, :lo12:_add
  bl    _foldright

  // Load and print the result.
  ldr   x0, [x0]
  bl    _printn
  b     _success

_sort:
  // _foldright(0, (a, b) => *a.insert(*b))
  adrp  x5, _insert
  add   x4, x5, :lo12:_insert
  bl    _foldright

  // Load and print the result.
  ldr   x0, [x0]
  bl    _printt
  b     _success

// Exit with a status 0.
_success:
  mov   w0, #0
  mov   w8, #93
  svc   #0

// Show the executable's usage and exit with a status 1.
_usage:
  ldr   x0, =usage
  bl    _strlen
  mov   x2, x0
  ldr   x1, =usage
  mov   x0, #1
  mov   w8, #64
  svc   #0

// Exit with a failure status 1.
_failure:
  mov   w0, #1
  mov   w8, #93
  svc   #0

/// Combines the the elements a buffer into an accumulator by applying the given function on the
/// accumulator and each element, from right to left.
///
/// This function "folds" a sequence of elements from right to left into an accumulator using an
/// updating function provided by its caller. The updating function accepts the address of the
/// accumulator in `x0` and the address of an element in `x1`, combines the value at `x1` with the
/// value at `x0`, and writes the result in `x0`. The addresses of the `n`-th (with `n` less than
/// the number of elements in the buffer) is computed by offsetting the buffer's base address by
/// `n * s`, where `s` is the size of an element.
///
/// When the function returns, `x0` contains the address of the accumulator that was initially
/// passed in `x3`. The result of other argument registers is unspecified.
///
/// The following is a possible recursive implementation of `_foldright` in C:
///
///     void* foldright(void* xs, int s, int n, void* a, void(*f)(void*, void*)) {
///       if (n != 0) {
///         char* p = (char*)xs + s * --n;
///         f(a, p);
///         foldright(xs, s, n, a, f);
///       }
///       return a;
///     }
///
/// - Parameters:
///   - x0 The address of a buffer.
///   - x1 The size of each element in the buffer pointed to by `x0`, , which is less than 2^16
///   - x2 The number of elements in the buffer pointed to by `x0`, which is less than 2^48.
///   - x3 The address of the initial accumulator value.
///   - x4 The address of a function that combines an element with the accumulator.
///
/// - Complexity: O(n) where n is the number of elements in the buffer.
_foldright:
  // Store fp and lr on the stack.
  stp  x29, x30, [sp, #-64]!
  mov  x29, sp

_foldright.head:
  // Check if x2 (n) is zero.
  cbz  x2, _foldright.ret

  // Decrement x2 (n).
  sub  x2, x2, #1

  // Multiply x2 (n) by x1 (s) 
  mul  x5, x2, x1

  // Add x0 (xs) and x5 (n * s) to get the address of the n-th element.
  add  x6, x0, x5

  // Call the function at x4 (f) with the address of the accumulator (x3) and the address of the n-th element (x6).
  stp  x0, x1, [sp, #48]   // Store x0 and x1 on the stack to preserve their values.
  stp  x2, x4, [sp, #32]   // Store x2 and x4 on the stack to preserve their values.
  str  x3, [sp, #16]       // Store x3 on the stack to preserve its value.
  mov  x0, x3
  mov  x1, x6
  blr  x4
  ldr  x3, [sp, #16]       // Restore x3 from the stack.
  ldp  x2, x4, [sp, #32]   // Restore x2 and x4 from the stack.
  ldp  x0, x1, [sp, #48]   // Restore x0 and x1 from the stack.
  b    _foldright.head

_foldright.ret:
  mov  x0, x3
  ldp  x29, x30, [sp], #64   // Restore fp and lr from the stack.
  ret

/// Inserts the value of `x1` in the binary search tree rooted at `x0`.
///
/// If `x0` is null, a new node is allocated and its address is returned in `x0`. Otherwise, the
/// value in `x1` is inserted in either the left or right child of the node at `x0` and the value
/// of `x0` is preserved.
///
/// A node is a triple `(lhs, rhs, value)` where `lhs` and `rhs` are (possibly null) pointers to
/// the node's children and `value` is the value assigned to that node.
///
/// - Complexity: O(log n) where n is the number of elements in the tree.
_tree_insert:
  // Store fp and lr on the stack.
  stp  x29, x30, [sp, #-32]!
  mov  x29, sp
  stp  x0, x1, [sp, #16]  // Store x0 and x1 on the stack to preserve their values.

  // If x0 is null, allocate a new node.
  cbz  x0, _tree_insert.alloc

  // Otherwise
  ldr  x2, [x0, #16]   // Load the value of the current node.
  cmp  x1, x2
  blt  _tree_insert.left

_tree_insert.right:
  ldr  x0, [x0, #8]       // Load rhs in x0
  bl   _tree_insert
  mov  x3, x0
  ldp  x0, x1, [sp, #16]  // Restore x0 and x1 from the stack.
  str  x3 , [x0, #8]
  b    _tree_insert.ret

_tree_insert.left:
  ldr  x0, [x0]           // Load lhs in x0
  bl   _tree_insert
  mov  x3, x0
  ldp  x0, x1, [sp, #16]  // Restore x0 and x1 from the stack.
  str  x3 , [x0]
  b    _tree_insert.ret

_tree_insert.alloc:
  // Allocate memory for a new node.
  mov  x0, #24
  mov  x1, #3
  bl   _aalloc

  // Initialize the new node.
  ldr  x1, [sp, #24]   // Restore x1 from the stack.
  mov  x3, #0
  str  x3, [x0]        // lhs = null
  str  x3, [x0, #8]    // rhs = null
  str  x1, [x0, #16]   // value = x1


_tree_insert.ret:
  ldp  x29, x30, [sp], #32   // Restore fp and lr from the stack.
  ret


/// Computes the sum of the integers stored at the addresses contained in `x0` and `x1` and writes
/// the result at the address contained in `x0`.
_add:
  ldr   x2, [x0]
  ldr   x3, [x1]
  add   x4, x2, x3
  str   x4, [x0]
  ret

/// Inserts the number at the address in `x1` into the binary search tree whose address is stored
/// at the addess in `x2`.
_insert:
  stp   x29, x30, [sp, #-32]!
  mov   x29, sp
  str   x0, [sp, #16]
  ldr   x0, [x0]
  ldr   x1, [x1]
  bl    _tree_insert
  ldr   x1, [sp, #16]
  str   x0, [x1]
  ldp   x29, x30, [sp], #32
  ret

/// Computes the smallest multiple of 2^n greater than or equal to `x0`, where `n` is the value of
/// `x1`, and writes the results to `x0`.
///
/// For example:
/// - Given `x0 = 10` and `x1 = 4`, the result is 16.
/// - Given `x0 = 16` and `x1 = 4`, the result is 16.
_round_up_to_next_multiple_of_2n:
  mov   x2, #1
  lsl   x3, x2, x1
  sub   x4, x3, #1
  and   x5, x0, x4
  cbz   x5, _round_up_to_next_multiple_of_2n.ret
  add   x2, x0, x4
  lsr   x3, x2, x1
  lsl   x0, x3, x1
_round_up_to_next_multiple_of_2n.ret:
  ret

/// Converts the null-terminated string pointed to by `x0`, which encodes a non-negative integer in
/// base 10, and writes the result to `x0`.
///
/// - Parameters:
///   - x0 the address of a null-terminated string.
_atoi:
  mov   x1, #0
	mov   x2, #0
	mov   x3, #10
_atoi.head:
  ldrb	w5, [x0, x1]
	add   x1, x1, #1
	cbz   w5, _atoi.ret
	sub   w5, w5, #48
	mul   x2, x2, x3
  add   x2, x2, x5
	b     _atoi.head
_atoi.ret:
  mov   x0, x2
  ret

/// Converts the unsigned integer value in `x0` into a null-terminated string using the base in
/// `x2` and stores the result in the array to which `x1` points.
///
/// The value of `x1` is preserved. On success, `x0` is equal to `x1` and `x2` contains the number
/// of characters in the result. On failure, `x0` contains -1 and the value of `x2` is unspecified.
///
/// - Parameters:
///   - x0 the value to be converted.
///   - x1 the address of a buffer large enough to contains the output string.
///   - x2 the numerical base (between `2` and `36`) used to represent the converted value.
_itoa:
  stp   x29, x30, [sp, #-32]!
  mov   x29, sp

  // if x2 < 2 || x2 > 36 { goto _itoa.err }
  cmp   x2, #2
  blt   _itoa.err
  cmp   x2, #36
  bgt   _itoa.err

  // if x0 == 0 { goto _itoa.zero }
  cbz   x0, _itoa.zero

  // Converts into digits, from least to most significant, and then reverse them.
  mov   x3, #0
_itoa.head:
  cbz   x0, _itoa.ret
  udiv  x4, x0, x2			    // x4 = x0 / x2
	msub  x5, x4, x2, x0	    // x5 = x0 % x2
	mov   x0, x4
  cmp   w5, #10
  bge   _itoa.hex
	add   w5, w5, #48
  b     _itoa.tail
_itoa.hex:
  add   w5, w5, #87
_itoa.tail:
	strb  w5, [x1, x3]
  add   x3, x3, #1
	b 		_itoa.head
_itoa.zero:
  mov   w5, #48
  strb  w5, [x1]
  mov   x3, #1
_itoa.ret:
  mov   w5, #0
  strb  w5, [x1, x3]
  mov   x0, x1
  mov   x1, x3
  stp   x0, x1, [sp, #16]
  bl   _reverse
  ldp   x1, x2, [sp, #16]
  mov   x0, x1
  ldp   x29, x30, [sp], #32
  ret
_itoa.err:
  mov   x0, #-1
  ldp   x29, x30, [sp], #32
  ret

/// Reverses the bytes in the array that is pointed to by `x0` and whose length is `x1`.
_reverse:
  mov   x2, #0
_reverse.head:
  cmp   x1, x2
  ble   _reverse.ret
  sub   x1, x1, #1
  ldrb	w5, [x0, x1]
  ldrb	w6, [x0, x2]
  strb  w5, [x0, x2]
  strb  w6, [x0, x1]
  add   x2, x2, #1
  b     _reverse.head
_reverse.ret:
  ret

/// Computes the lenght of the null-terminated string at `x0` and writes the result to `x0`.
_strlen:
  mov   x1, x0
  mov   x0, #0
_strlen.head:
  ldrb	w5, [x1, x0]
  cbz   w5, _strlen.ret
  add   x0, x0, #1
  b     _strlen.head
_strlen.ret:
  ret

/// Tests whether the null-terminated strings at `x0` and `x1` are equal and writes the result to
/// `x0` (1 if they are equal or 0 otherwise).
_strcmp:
  ldrb  w5, [x0], #1
  ldrb  w6, [x1], #1
  cmp   w5, w6
  bne   _strcmp.ne
  cbz   w5, _strcmp.eq
  b     _strcmp
_strcmp.ne:
  mov   x0, 0
  ret
_strcmp.eq:
  mov   x0, 1
  ret

/// Prints the value of `x0`.
_printn:
  stp   x29, x30, [sp, #-32]!
  mov   x29, sp
  add   x1, sp, #16
  mov   x2, #10
  bl    _itoa
  mov   w5, #10
  strb  w5, [x0, x2]
  add   x2, x2, #14
  mov   x0, #1
  mov   w8, #64
  svc   #0
  ldp   x29, x30, [sp], #32
  ret

/// Prints the value of `x0` as an address (e.g., "0x1234").
_printa:
  stp   x29, x30, [sp, #-48]!
  mov   x29, sp
  mov   w5, #48
  strb  w5, [sp, #24]
  mov   w5, #120
  strb  w5, [sp, #25]
  add   x1, sp, #26
  mov   x2, #16
  bl    _itoa
  mov   w5, #10
  strb  w5, [x0, x2]
  add   x2, x2, #3
  add   x1, sp, #24
  mov   x0, #1
  mov   w8, #64
  svc   #0
  ldp   x29, x30, [sp], #48
  ret

/// Prints the contents of the binary tree rooted at `x0`, visiting its elements in in-order.
_printt:
  stp   x29, x30, [sp, #-272]!
  mov   x29, sp
  add   x1, sp, #16
  mov   w5, 91 // '['
  strb  w5, [x1], #1
  bl    _printt.inner
_printt.ret:
  ldrb  w0, [x1, #-1]
  cmp   w0, #32
  bne   _printt.svc
  sub   x1, x1, #2
_printt.svc:
  mov   w5, 93 // ']'
  strb  w5, [x1], #1
  mov   w5, 10 // '\n'
  strb  w5, [x1], #1
  add   x0, sp, #16
  sub   x2, x1, x0
  mov   x1, x0
  mov   x0, #1
  mov   w8, #64
  svc   #0
  ldp   x29, x30, [sp], #256
  ret
_printt.inner:
  // x0 the tree ; x1 the string
  stp   x29, x30, [sp, #-32]!
  mov   x29, sp
  cbz   x0, _printt.inner.ret
  str   x0, [sp, #16]
  ldr   x0, [x0]
  bl    _printt.inner
  ldr   x0, [sp, #16]
  ldr   x0, [x0, #16]
  mov   x2, #10
  bl    _itoa
  add   x1, x1, x2
  mov   w5, #44 // ','
  strb  w5, [x1], #1
  mov   w5, #32 // ' '
  strb  w5, [x1], #1
  ldr   x0, [sp, #16]
  ldr   x0, [x0, #8]
  bl    _printt.inner
_printt.inner.ret:
  ldp   x29, x30, [sp], #32
  ret

/// Initializes the heap.
///
/// This function reserves 2KB of heap memory and initializes `mm` with pointers to the start and
/// end of the heap memory region.
_init_heap:
  ldr   x2, =mm

  // Get the current program break.
  mov   x0, #0
  mov   w8, #214
  svc   #0
  str   x0, [x2]
  mov   x1, x0

  // Advance the program break by 2048 bytes.
  add   x0, x0, #2048
  svc   #0
  str   x0, [x2, #8]

  // Fail if we could not allocate memory.
  cmp   x0, x1
  beq   _failure

  // Store a pointer to the next free memory address at the start of the heap.
  add  x2, x1, #8
  str  x2, [x1]
  ret

/// Allocates on the heap as many bytes as the value of `x0` aligned at 2^n, where `n` is the value
/// of `x1`, and writes the address of to the allocation to `x0`.
///
/// This function assumes that heap memory has been initialized with `_init_heap`.
_aalloc:
  stp   x29, x30, [sp, #-48]!
  mov   x29, sp

  // Load the current configuration of the heap.
  ldr   x2, =mm
  ldr   x3, [x2]      // heap.start
  ldr   x4, [x3]      // heap.current
  ldr   x5, [x2, #8]  // heap.end

  stp   x0, x5, [sp, #16]
  stp   x3, x4, [sp, #32]

  // Adjust the start address.
  mov   x0, x4
  bl    _round_up_to_next_multiple_of_2n

  // Do we need more memory?
  ldp   x1, x5, [sp, #16]
  add   x3, x0, x1
  cmp   x3, x5
  ble   _aalloc.bump
  stp   x0, x3, [sp, #16]

  // Ask for more memory.
  mov   x0, x3
  mov   x1, #11
  bl    _round_up_to_next_multiple_of_2n
  mov   w8, #214
  svc   #0

  // Update the heap configuration.
  ldr   x2, =mm
  ldr   x5, [x2, #8]
  cmp   x0, x5
  beq   _aalloc.fail
  str   x0, [x2, #8]
  ldp   x0, x3, [sp, #16]

_aalloc.bump:
  ldr   x2, [sp, #32]
  str   x3, [x2]
  b     _aalloc.ret
_aalloc.fail:
  mov   x0, #0
_aalloc.ret:
  ldp   x29, x30, [sp], #48
  ret
