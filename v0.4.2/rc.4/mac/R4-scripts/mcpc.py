"""A minimal MCP client over stdio for `jetcarp mcp` (JSON-RPC 2.0, one message per line).

R4 (rc.4) on the Mac, adapted from the Framework's R4-scripts/mcpc.py. The caller must
have sourced R4-scripts/lib.sh (which exports J, R and H), so the server runs with every JETCARP
folder in that test folder (HOME stays the real one on the Mac): this module refuses to start
otherwise. Every message sent and received is logged to a .jsonl file (">> " sent, "<< " received).
"""
import json
import os
import queue
import subprocess
import threading
import time

HOME = os.path.expanduser("~")
W4 = f"{HOME}/jetcarp-rc4/homes"
J = os.environ["J"]
R = os.environ["R"]
H = os.environ["H"]
for k in ("JETCARP_CONFIG_DIR", "JETCARP_DATA_DIR", "JETCARP_OUT", "JETCARP_LIBRARY", "JETCARP_RUNTIME_DIR"):
    v = os.environ.get(k, "")
    if not v.startswith(f"{W4}/"):
        raise SystemExit(f"ABORT: {k} is not under a scratch home: {v!r}")


def sub(text):
    """Paths written as $J, $H, $R and ~."""
    return text.replace(J, "$J").replace(H, "$H").replace(R, "$R").replace(HOME, "~")


class Mcp:
    def __init__(self, log, args=(), maxlog=4000, extra_env=None):
        self.logf = open(log, "w", encoding="utf-8")
        self.maxlog = maxlog
        self.p = subprocess.Popen(
            [J, "mcp", *args],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env={**os.environ, **(extra_env or {})},
            text=True,
            encoding="utf-8",
            bufsize=1,
        )
        self.q = queue.Queue()
        self.stderr = []
        self.next_id = 1
        threading.Thread(target=self._read_out, daemon=True).start()
        threading.Thread(target=self._read_err, daemon=True).start()

    def _read_out(self):
        for line in self.p.stdout:
            self.q.put(line.rstrip("\n"))
        self.q.put(None)

    def _read_err(self):
        for line in self.p.stderr:
            self.stderr.append(line.rstrip("\n"))

    def log(self, prefix, text):
        text = sub(text)
        if self.maxlog and len(text) > self.maxlog:
            text = text[: self.maxlog] + f" ...[{len(text) - self.maxlog} more chars cut in this log]"
        self.logf.write(f"{prefix} {text}\n")
        self.logf.flush()

    def note(self, text):
        self.logf.write(f"## {sub(text)}\n")
        self.logf.flush()

    def send(self, obj):
        line = json.dumps(obj, ensure_ascii=False)
        self.log(">>", line)
        self.p.stdin.write(line + "\n")
        self.p.stdin.flush()

    def recv(self, want_id, timeout=120):
        deadline = time.time() + timeout
        while time.time() < deadline:
            try:
                line = self.q.get(timeout=max(0.1, deadline - time.time()))
            except queue.Empty:
                break
            if line is None:
                self.note("server closed stdout")
                return None
            self.log("<<", line)
            try:
                m = json.loads(line)
            except json.JSONDecodeError:
                self.note("line is not JSON")
                continue
            if m.get("id") == want_id:
                return m
        self.note(f"no answer to id {want_id} within {timeout}s")
        return None

    def request(self, method, params=None, timeout=120):
        i = self.next_id
        self.next_id += 1
        msg = {"jsonrpc": "2.0", "id": i, "method": method}
        if params is not None:
            msg["params"] = params
        self.send(msg)
        return self.recv(i, timeout)

    def notify(self, method, params=None):
        msg = {"jsonrpc": "2.0", "method": method}
        if params is not None:
            msg["params"] = params
        self.send(msg)

    def init(self):
        r = self.request(
            "initialize",
            {"protocolVersion": "2025-06-18", "capabilities": {}, "clientInfo": {"name": "rc4-r4-test", "version": "1"}},
        )
        self.notify("notifications/initialized")
        return r

    def call(self, name, arguments, timeout=180):
        """tools/call; returns (isError, text, raw message)."""
        r = self.request("tools/call", {"name": name, "arguments": arguments}, timeout)
        if r is None:
            return (None, "<no answer>", None)
        if "error" in r:
            return ("rpc-error", json.dumps(r["error"]), r)
        res = r.get("result", {})
        txt = "\n".join(c.get("text", "") for c in res.get("content", []) if c.get("type") == "text")
        kinds = [c.get("type") for c in res.get("content", [])]
        if any(k != "text" for k in kinds):
            txt += f"\n[content types: {kinds}]"
        return (bool(res.get("isError")), sub(txt), r)

    def close(self, timeout=15):
        try:
            self.p.stdin.close()
        except Exception:
            pass
        try:
            self.p.wait(timeout)
        except subprocess.TimeoutExpired:
            self.note("server did not exit within the timeout; killed")
            self.p.kill()
            self.p.wait()
        time.sleep(0.2)
        self.note(f"server exit {self.p.returncode}; stderr: {' | '.join(self.stderr)[:4000]}")
        self.logf.close()
        return self.p.returncode
