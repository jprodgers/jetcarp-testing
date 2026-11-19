"""A minimal MCP client over stdio for `jetcarp mcp` (JSON-RPC 2.0, one message per line).

F9 of the v0.4.2-rc.2 test wave. Every message sent and received is logged to a .jsonl file
(">> " sent, "<< " received), as the Acer's mcpclient.ps1 does.
"""
import json
import os
import queue
import subprocess
import sys
import threading
import time

HOME = os.path.expanduser("~")
W = f"{HOME}/Documents/jetcarp-dev/work/0.4.2-rc2/f9"
R = f"{HOME}/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.2/framework/F9"
J = f"{HOME}/Documents/jetcarp-dev/work/0.4.2-rc2/bin/jetcarp-0.4.2-rc.2-x86_64-unknown-linux-gnu/jetcarp"


def env():
    e = dict(os.environ)
    e.update(
        JETCARP_CONFIG_DIR=f"{W}/config",
        JETCARP_DATA_DIR=f"{W}/data",
        JETCARP_OUT=f"{W}/out",
        JETCARP_LIBRARY=f"{W}/library",
    )
    return e


class Mcp:
    def __init__(self, log, args=(), maxlog=4000, extra_env=None):
        self.logf = open(log, "w", encoding="utf-8")
        self.maxlog = maxlog
        self.p = subprocess.Popen(
            [J, "mcp", *args],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env={**env(), **(extra_env or {})},
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
        if len(text) > self.maxlog:
            text = text[: self.maxlog] + f" ...[{len(text) - self.maxlog} more chars cut in this log]"
        self.logf.write(f"{prefix} {text}\n")
        self.logf.flush()

    def note(self, text):
        self.logf.write(f"## {text}\n")
        self.logf.flush()

    def send(self, obj):
        line = json.dumps(obj, ensure_ascii=False)
        self.log(">>", line)
        self.p.stdin.write(line + "\n")
        self.p.stdin.flush()

    def send_raw(self, line):
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
            {"protocolVersion": "2025-06-18", "capabilities": {}, "clientInfo": {"name": "rc2-f9-test", "version": "1"}},
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
        return (bool(res.get("isError")), txt, r)

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
