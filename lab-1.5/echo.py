import ctypes
import sys

libc = ctypes.CDLL(None)

def echo(message):
    b = ctypes.ARRAY(ctypes.c_char, len(message))(*(ord(m) for m in message))
    f = libc.syscall
    f.argtypes = (
        ctypes.c_long,
        ctypes.c_long,
        ctypes.POINTER(ctypes.c_char),
        ctypes.c_long
    )
    f(64, 1, b, len(message))

args = sys.argv[1]
echo(args + "\n")