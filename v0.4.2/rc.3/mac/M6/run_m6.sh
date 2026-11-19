#!/usr/bin/env bash
# M-6 on the Mac (rc.3), the unattended part: Parts 4 and 5's MCP scripts and command-line steps (the Framework's R
# and F9 scripts, pointed at the Mac), then R's command-line rows. Everything under ~/jetcarp-rc-042c/m6 ($W).
R=$HOME/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/M6
. "$R/env.sh"
mkdir -p "$W"; cd "$R"
for t in t41_every_tool t42_folders t42b_symlink t43_bad_input t43b_followups t44_long_job t44b_in_server_job t53_mcp_limits t53b_mcp_over; do
  echo "$(date '+%H:%M:%S') $t"; timeout 900 python3 "$R/$t.py" > "$R/$t.stdout" 2>&1; echo "  exit $?"
done
mkdir -p "$W/ro-out-555"; chmod 555 "$W/ro-out-555"
echo "$(date '+%H:%M:%S') t55_readonly"; timeout 900 python3 "$R/t55_readonly.py" > "$R/t55_readonly.stdout" 2>&1; echo "  exit $?"
chmod 755 "$W/ro-out-555"
echo "$(date '+%H:%M:%S') t5_cli"; timeout 1800 bash "$R/t5_cli.sh" > "$R/t5_cli.stdout" 2>&1; echo "  exit $?"
echo "$(date "+%H:%M:%S") t51_mcp_odd (after t5_cli, which makes its files)"; timeout 900 python3 "$R/t51_mcp_odd.py" > "$R/t51_mcp_odd.stdout" 2>&1; echo "  exit $?"
echo "$(date '+%H:%M:%S') r_cli"; timeout 1200 bash "$R/r_cli.sh"; echo "  exit $?"
echo "$(date '+%H:%M:%S') r66"; timeout 600 bash "$R/r66.sh"; echo "  exit $?"
echo "$(date '+%H:%M:%S') done"
