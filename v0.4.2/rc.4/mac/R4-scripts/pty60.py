"""R4 #104 on the Mac: run a command in a pseudo-terminal COLS x ROWS and keep everything it prints (a typescript).
macOS's `script` needs a terminal of its own, which this session hasn't, so this sets the size itself.

usage: pty60.py TYPESCRIPT COLS ROWS -- COMMAND...
"""
import fcntl, os, pty, struct, sys, termios

out, cols, rows = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
cmd = sys.argv[sys.argv.index("--") + 1:]
pid, fd = pty.fork()
if pid == 0:
    fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack("HHHH", rows, cols, 0, 0))
    os.execvp(cmd[0], cmd)
with open(out, "wb") as f:
    while True:
        try:
            b = os.read(fd, 65536)
        except OSError:
            break
        if not b:
            break
        f.write(b)
_, status = os.waitpid(pid, 0)
sys.exit(os.waitstatus_to_exitcode(status))
