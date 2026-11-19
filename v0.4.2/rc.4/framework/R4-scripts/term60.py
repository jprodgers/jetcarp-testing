"""R4-8 (#104): replay a typescript in a small terminal emulator WIDTH columns wide and report
whether any progress redraw wrapped (a redraw wider than the terminal leaves pieces behind).

usage: term60.py TYPESCRIPT [WIDTH]
Prints: the progress redraws (text a carriage return goes back over, escape sequences taken out):
how many, the widest, how many are wider than WIDTH - 1; then the screen as the terminal shows it at
the end (scrollback included), each line numbered.
"""
import re
import sys

path = sys.argv[1]
W = int(sys.argv[2]) if len(sys.argv) > 2 else 60
data = open(path, "rb").read().decode("utf-8", "replace")
# util-linux script writes a header and a trailer line in the file
lines = data.split("\n")
if lines and lines[0].startswith("Script started"):
    data = "\n".join(lines[1:])
data = re.sub(r"\n?Script done.*$", "", data, flags=re.S)

CSI = re.compile(r"\x1b\[([?0-9;]*)([@-~])")
plain = CSI.sub("", data)
plain = re.sub(r"\x1b[78()=>][0-9A-Za-z]?", "", plain)
# Redraws: the parts of a line that a carriage return sends the cursor back over (overwritten);
# the last part of each line stays.
redraws, kept = [], []
for ln in re.sub(r"\x1b[78()=>][0-9A-Za-z]?", "", CSI.sub("", data)).replace("\r\n", "\n").split("\n"):
    parts = ln.split("\r")
    redraws += [x for x in parts[:-1] if x]
    if parts[-1]:
        kept.append(parts[-1])
rw = [len(x) for x in redraws]
print(f"progress redraws (text a carriage return goes back over): {len(redraws)}, widest {max(rw) if rw else 0} columns, wider than {W - 1} (one short of the width): {sum(1 for x in rw if x > W - 1)}")
for x in [x for x in redraws if len(x) > W - 1][:5]:
    print(f"   redraw too wide ({len(x)}): {x!r}")
for x in redraws[-3:]:
    print(f"   a redraw ({len(x)} columns): {x!r}")
print(f"lines left standing: {len(kept)} (wider ones simply wrap; they are never redrawn)")
print(f"escape sequences used: {sorted(set(m.group(2) + ('(' + m.group(1) + ')' if m.group(1) else '') for m in CSI.finditer(data)))[:20]}")

# The emulator: deferred wrap as xterm does; \r, \n, \b; CSI K, A, B, C, D, G, J; others ignored.
screen = [[]]
r = c = 0
pending = False


def line(i):
    while len(screen) <= i:
        screen.append([])
    return screen[i]


def put(ch):
    global r, c, pending
    if pending:
        r += 1
        c = 0
        pending = False
    ln = line(r)
    while len(ln) < c:
        ln.append(" ")
    if c < len(ln):
        ln[c] = ch
    else:
        ln.append(ch)
    if c == W - 1:
        pending = True
    else:
        c += 1


i = 0
while i < len(data):
    ch = data[i]
    if ch == "\x1b":
        m = CSI.match(data, i)
        if m:
            args, op = m.group(1), m.group(2)
            n = int(args.split(";")[0]) if args and args[0].isdigit() else None
            ln = line(r)
            if op == "K":
                k = n or 0
                if k == 0:
                    del ln[c:]
                elif k == 1:
                    for j in range(min(c + 1, len(ln))):
                        ln[j] = " "
                else:
                    ln.clear()
            elif op == "A":
                r = max(0, r - (n or 1)); pending = False
            elif op == "B":
                r += n or 1; pending = False
            elif op == "C":
                c = min(W - 1, c + (n or 1)); pending = False
            elif op == "D":
                c = max(0, c - (n or 1)); pending = False
            elif op == "G":
                c = max(0, (n or 1) - 1); pending = False
            elif op == "J":
                del ln[c:]
                del screen[r + 1:]
            i = m.end()
            continue
        i += 2
        continue
    if ch == "\r":
        c = 0; pending = False
    elif ch == "\n":
        r += 1; pending = False; line(r)
    elif ch == "\b":
        c = max(0, c - 1); pending = False
    elif ch >= " ":
        put(ch)
    i += 1

text = ["".join(l).rstrip() for l in screen]
while text and not text[-1]:
    text.pop()
print(f"the terminal at the end ({len(text)} lines, {W} columns):")
for k, l in enumerate(text, 1):
    print(f"{k:4d} |{l}")
