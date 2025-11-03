import ctypes
import sys

libc = ctypes.CDLL(None)

def cat():
    b = ctypes.ARRAY(ctypes.c_char, 256)()
    f = libc.syscall
    f.argtypes = (
        ctypes.c_long,
        ctypes.c_long,
        ctypes.POINTER(ctypes.c_char),
        ctypes.c_long
    )

    while True:
        n = f(63, 0, b, 256)
        if n == 0:
            return
        f(64, 1, b, n)


try:
    cat()
except KeyboardInterrupt:
    pass