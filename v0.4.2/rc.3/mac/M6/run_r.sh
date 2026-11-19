#!/usr/bin/env bash
# Run R's unattended rows on the Framework, one after another.
R=$HOME/Documents/GitHub/jetcarp-rc/results/v0.4.2-rc.3/mac/M6
cd "$R"
for t in t41_every_tool t42_folders t42b_symlink t43_bad_input t43b_followups t44b_in_server_job t53b_mcp_over t55_readonly; do
  echo "$(date '+%H:%M:%S') $t"; timeout 900 python3 "$R/$t.py" > "$R/$t.stdout" 2>&1; echo "  exit $?"
done
echo "$(date '+%H:%M:%S') r_cli"; timeout 1200 bash "$R/r_cli.sh"; echo "  exit $?"
echo "$(date '+%H:%M:%S') done"
