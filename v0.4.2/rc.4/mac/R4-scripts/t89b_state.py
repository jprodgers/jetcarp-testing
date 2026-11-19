"""R4 #89, a follow-up: app_display's whole state, before, with and after keep_awake, and pmset's JETCARP line each
time. The same test folder as t87_89_app.py (homes/app87); the app opened with --control, then closed."""
import json, os, re, subprocess, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mcpc  # noqa: E402
out = open(os.path.join(mcpc.R, "89b-state.txt"), "w")
def say(s):
    s = mcpc.sub(s); print(s, flush=True); out.write(s + "\n")
os.makedirs(os.path.join(mcpc.H, "cwd"), exist_ok=True)
app = subprocess.Popen([mcpc.J, "--control"], cwd=os.path.join(mcpc.H, "cwd"), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(8)
m = mcpc.Mcp(os.path.join(mcpc.R, "89b-state.jsonl"), args=["--app"], maxlog=0)
m.init()
def state(label):
    err, txt, _ = m.call("app_display", {})
    keys = [mm.group(0) for mm in re.finditer(r'"?keep[_ ]awake"?\s*[:=]?\s*\S{0,12}', txt, re.I)]
    pm = [l.strip() for l in subprocess.run(["pmset", "-g", "assertions"], capture_output=True, text=True).stdout.splitlines() if "jetcarp" in l.lower()]
    say(f"{label}: app_display {{}} -> isError={err}; keep_awake in the reply: {keys}; pmset: {pm or 'none'}")
    return txt
say(f"R4 #89b, the Mac, {time.strftime('%Y-%m-%d %I:%M:%S %p %Z')}; app pid {app.pid}")
t = state("just opened")
say("  the reply's first 1,500 characters: " + t[:1500].replace("\n", " | "))
for v in (True, False, True, False):
    err, txt, _ = m.call("app_display", {"keep_awake": v})
    say(f"app_display keep_awake {v} -> isError={err}: {txt[:300].replace(chr(10), ' | ')}")
    time.sleep(3)
    state(f"  3 s later")
m.close(); app.terminate(); app.wait(15)
say(f"the app closed (exit {app.returncode}); app.json's keep-awake now: {[l.strip() for l in open(os.path.join(os.environ['JETCARP_CONFIG_DIR'], 'app.json')) if 'awake' in l.lower()]}")
