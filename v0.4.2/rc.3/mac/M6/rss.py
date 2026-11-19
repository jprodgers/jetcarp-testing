"""(Mac: ru_maxrss is in bytes there, in KB on Linux.) Run a command and print its exit status, wall time and peak memory (max RSS of the child)."""
import resource, subprocess, sys, time
t = time.time()
p = subprocess.run(sys.argv[1:])
ru = resource.getrusage(resource.RUSAGE_CHILDREN)
print(f"[exit {p.returncode}, wall {time.time() - t:.1f} s, max RSS {ru.ru_maxrss / (1024 ** 3 if sys.platform == 'darwin' else 1024 ** 2):.2f} GB]")
