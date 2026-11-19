#!/usr/bin/env bash
# R5-private (c4), private: (c3)'s planted hidden store again, through MCP's pack export (folder rules on).
set -u
D=$(cd "$(dirname "$0")" && pwd)
. "$D/lib.sh" t42b
export J R H
O=$H/out
echo
echo "### (c4) MCP: the hidden store beside the export planted (\$H/out/.exp-store-mcp.store -> \$H/outside/store-dir-mcp)"
mkdir -p "$H/outside/store-dir-mcp"; ln -s "$H/outside/store-dir-mcp" "$O/.exp-store-mcp.store"
run "ls -la \$H/out | grep exp-store-mcp; ls -A \$H/outside/store-dir-mcp | wc -l"
run "python3 \$R/R5-scripts/mcall.py \$R/t42b-hiddenstore-mcp-rc5.jsonl '[[\"pack\",{\"export\":{\"to\":\"exp-store-mcp\",\"publish\":{\"feed\":\"t42b-store-mcp\",\"no_media\":true}}}]]'"
run "ls -la \$H/out | grep exp-store-mcp; ls -A \$H/outside/store-dir-mcp | wc -l; ls -A \$H/outside/store-dir-mcp"
echo "### (c5) MCP: pack publish into a store folder that is itself such a link (\$H/out/pub-link -> \$H/outside/pub-dir)"
mkdir -p "$H/outside/pub-dir"; ln -s "$H/outside/pub-dir" "$O/pub-link"
run "python3 \$R/R5-scripts/mcall.py \$R/t42b-publish-mcp-rc5.jsonl '[[\"pack\",{\"publish\":{\"feed\":\"t42b-pub\",\"to\":\"pub-link\",\"no_media\":true}}]]'"
run "ls -A \$H/outside/pub-dir | wc -l"
