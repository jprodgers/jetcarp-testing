#!/usr/bin/env bash
# R5-private (private, withheld from the public copy): files JETCARP names itself inside a checked folder.
# (a) rc.3's t42b_symlink.py again; (b) a symlink planted at an animation's poster.png (CLI media
# render --scene --out, and MCP media_render scene/out), plus the frames folder planted, and a link
# that stays inside as a control; (c) a symlink planted at a pack export's pack.json (CLI pack export
# and MCP pack export), plus the hidden store beside the export planted. Each must be refused, with
# nothing written where the link leads.
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc5/homes/t42b
. "$D/lib.sh" t42b
export J R H
O=$H/out
echo "R5-private (private) files JETCARP names itself inside a checked folder, Framework, $(ts)"
echo "fresh home \$H = homes/t42b; \$H/outside is outside the output folder (\$H/out) and the library's (\$H/library)"
echo
mkdir -p "$H/outside/frames-dir" "$H/outside/store-dir"
printf 'precious poster outside the output folder (CLI)\n' > "$H/outside/poster-victim-cli.png"
printf 'precious poster outside the output folder (MCP)\n' > "$H/outside/poster-victim-mcp.png"
printf '{"precious": "pack.json outside the export (CLI)"}\n' > "$H/outside/pack-victim-cli.json"
printf '{"precious": "pack.json outside the export (MCP)"}\n' > "$H/outside/pack-victim-mcp.json"
cat > "$O/life32.json" <<'EOF'
{"format":1,"name":"life32","tiling":{"family":"square","size":{"rect":{"w":32,"h":32}},"boundary":"wrap"},"rng_state":3,
 "cas":[{"id":1,"name":"Life","rule":"B3/S23","seed":{"random":{"density":0.3}}}]}
EOF
run "cd \$H/outside && find . -type f -print0 | sort -z | xargs -0 sha256sum | tee \$H/outside-before.sha256; ls -la \$H/outside"

echo "######## (a) rc.3's t42b_symlink.py, on rc.5"
run "python3 \$R/R5-scripts/t42b_symlink_rc5.py"

echo "######## (b) a link planted at an animation's poster.png"
echo "### (b1) CLI: media render --scene --out, poster.png planted"
mkdir -p "$O/anim-cli"; ln -s "$H/outside/poster-victim-cli.png" "$O/anim-cli/poster.png"
run "ls -la \$H/out/anim-cli"
run "\$J media render --scene \$H/out/life32.json --out \$H/out/anim-cli --gens 20"
run "ls -la \$H/out/anim-cli; cat \$H/outside/poster-victim-cli.png"
echo "### (b2) MCP: media_render {scene, out}, poster.png planted"
mkdir -p "$O/anim-mcp"; ln -s "$H/outside/poster-victim-mcp.png" "$O/anim-mcp/poster.png"
SCENE=$(python3 -c 'import json,sys; print(json.dumps(json.load(open(sys.argv[1]))))' "$O/life32.json")
run "python3 \$R/R5-scripts/mcall.py \$R/t42b-poster-mcp-rc5.jsonl '[[\"media_render\",{\"scene\":$SCENE,\"out\":\"anim-mcp\",\"gens\":20}],[\"media_render\",{\"scene\":$SCENE,\"out\":\"anim-mcp\",\"gens\":20,\"poster\":true}]]'"
run "ls -la \$H/out/anim-mcp; cat \$H/outside/poster-victim-mcp.png"
echo "### (b3) CLI: the frames folder planted (a folder on the way)"
mkdir -p "$O/anim-frames"; ln -s "$H/outside/frames-dir" "$O/anim-frames/frames"
run "\$J media render --scene \$H/out/life32.json --out \$H/out/anim-frames --gens 20"
run "ls -la \$H/out/anim-frames; ls -A \$H/outside/frames-dir | wc -l"
echo "### (b4) control: a poster.png link that stays inside the folder is followed"
mkdir -p "$O/anim-inside"; printf 'old\n' > "$O/anim-inside/real-poster.png"; ln -s "$O/anim-inside/real-poster.png" "$O/anim-inside/poster.png"
run "\$J media render --scene \$H/out/life32.json --out \$H/out/anim-inside --gens 20 | tail -3"
run "ls -la \$H/out/anim-inside; file \$H/out/anim-inside/real-poster.png"

echo "######## (c) a link planted at a pack export's pack.json"
cp -a /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc3/config/pack "$H/config/pack"
run "\$J search hunt --rules B3/S23 --tilings square --soups 300 --cpu --quiet | head -1"
echo "### (c1) CLI: pack export --to \$H/out/exp-cli, pack.json planted"
mkdir -p "$O/exp-cli"; ln -s "$H/outside/pack-victim-cli.json" "$O/exp-cli/pack.json"
run "ls -la \$H/out/exp-cli"
run "\$J pack export --to \$H/out/exp-cli --feed t42b-cli --no-media"
run "ls -la \$H/out/exp-cli; ls -a \$H/out; cat \$H/outside/pack-victim-cli.json"
echo "### (c2) MCP: pack {export: {to: exp-mcp, publish: {...}}}, pack.json planted"
mkdir -p "$O/exp-mcp"; ln -s "$H/outside/pack-victim-mcp.json" "$O/exp-mcp/pack.json"
run "python3 \$R/R5-scripts/mcall.py \$R/t42b-packjson-mcp-rc5.jsonl '[[\"pack\",{\"export\":{\"to\":\"exp-mcp\",\"publish\":{\"feed\":\"t42b-mcp\",\"no_media\":true}}}]]'"
run "ls -la \$H/out/exp-mcp; cat \$H/outside/pack-victim-mcp.json"
echo "### (c3) CLI: the hidden store beside the export planted (\$H/out/.exp-store.store -> \$H/outside/store-dir)"
ln -s "$H/outside/store-dir" "$O/.exp-store.store"
run "\$J pack export --to \$H/out/exp-store --feed t42b-store --no-media"
run "ls -la \$H/out | grep -E 'exp-store'; ls -A \$H/outside/store-dir | wc -l"

echo "######## Afterwards: every file outside, against its hash before"
run "cd \$H/outside && sha256sum -c \$H/outside-before.sha256; find \$H/outside -newer \$H/outside-before.sha256 | sed 's#^#changed since: #'; ls -laR \$H/outside"
