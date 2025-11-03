import signal, sys
import ctypes

libc = ctypes.CDLL(None)

def cin(m=None):
  if m:
    print(m)
  b = ctypes.ARRAY(ctypes.c_char, 256)()
  f = libc.syscall
  f.argtypes = (
    ctypes.c_long,
    ctypes.c_long,
    ctypes.POINTER(ctypes.c_char),
    ctypes.c_long)
  n = f(63, 0, b, 256)
  return "".join([chr(b[i][0]) for i in range(n)])

def confirm(s, f):
  a = cin("Are you sure?")
  if a == "y\n":
    sys.exit(0)

def terminate(s, f):
  print("time's up")
  sys.exit(0)

signal.signal(signal.SIGINT, confirm)
signal.signal(signal.SIGALRM, terminate)
signal.alarm(60)

(m, n) = (1, 1)
while True:
  cin()
  (m, n) = (n, m + n)
  print(m)