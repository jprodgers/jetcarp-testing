"""Run a command and print its exit status, wall time and peak memory (max RSS of the child)."""
import resource, subprocess, sys, time
t = time.time()
p = subprocess.run(sys.argv[1:])
ru = resource.getrusage(resource.RUSAGE_CHILDREN)
print(f"[exit {p.returncode}, wall {time.time() - t:.1f} s, max RSS {ru.ru_maxrss / 1024 / 1024:.2f} GB]")
