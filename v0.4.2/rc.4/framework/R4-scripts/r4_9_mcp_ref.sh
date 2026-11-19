#!/usr/bin/env bash
# R4-9 (#92): the MCP reference shows <id> and L<level>: the book's page (source and as mdbook
# renders it) and the same page served by `jetcarp mcp` (resource and help).
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf /home/jimmie/Documents/jetcarp-dev/work/0.4.2-rc4/homes/docs
. "$D/lib.sh" docs
export J R H
SRC=/home/jimmie/Documents/GitHub/jetcarp
BK=$H/book   # a copy of docs/ built here, so nothing is written in the source repository
echo "R4-9 #92 the MCP reference's placeholders, Framework, $(ts)"
echo "source: \$SRC = the jetcarp repo at $(git -C $SRC rev-parse --short HEAD) ($(git -C $SRC describe --tags 2>/dev/null)); fresh home \$H = homes/docs"
echo
echo "#### The ten placeholders #92 named (7bccc8c), in docs/src/reference/mcp.md"
run "grep -n -o -E '(L|find:|atlas:)?&lt;[A-Za-z. ]+>' \$SRC/docs/src/reference/mcp.md | sed 's/^/  /'"
echo "#### Any '<' outside code spans left in the page (not HTML comments): none expected"
run "python3 - \$SRC/docs/src/reference/mcp.md <<'PY'
import re, sys
bad = []
infence = False
for n, line in enumerate(open(sys.argv[1], encoding='utf-8'), 1):
    if line.lstrip().startswith('\`\`\`'):
        infence = not infence
        continue
    if infence:
        continue
    s = re.sub(r'\`[^\`]*\`', '', line)          # code spans out
    s = re.sub(r'<!--.*?-->', '', s)            # comments out
    for m in re.finditer(r'<[A-Za-z.]', s):
        bad.append((n, s[max(0, m.start()-30):m.start()+30].strip()))
print('unescaped < outside code:', len(bad))
for b in bad[:20]: print('  ', b)
PY"
echo "(line 1041's <details><summary> is the page's own HTML, not a placeholder)"
echo "#### The page as mdbook renders it (docs copied to \$H/book and built there; mdbook 0.5 turns straight quotes into curly ones, so the placeholders are counted bare)"
mkdir -p "$BK" && cp -a "$SRC/docs/book.toml" "$SRC/docs/src" "$SRC/docs/theme" "$BK/" 2>/dev/null
run "cd \$H/book && mdbook build -d \$H/book/out 2>&1 | tail -5"
run "python3 - \$H/book/out/reference/mcp.html <<'PY'
import html, re, sys
raw = open(sys.argv[1], encoding='utf-8').read()
text = html.unescape(re.sub(r'<[^>]+>', '', raw))
for p in ['<Pictures>/JETCARP', '<id>', '<run id>', '<explore job>', '<sweep folder>', '<scene file>', 'L<level>', 'find:<id>', 'atlas:<...>']:
    print(f'  {text.count(p):3d} x  {p}')
PY"
echo "#### The same page served by jetcarp mcp: resources/read and help {page}"
run "python3 \$R/R4-scripts/mcall.py \$R/R4-9-mcp.jsonl '[[\"help\",{\"page\":\"reference/mcp\"}]]' --resource jetcarp://docs/reference/mcp.md --maxlog 0 > \$H/served.txt; head -12 \$H/served.txt; grep -c . \$H/served.txt"
run "python3 - \$R/R4-9-mcp.jsonl \$SRC/docs/src/reference/mcp.md <<'PY'
import json, re, sys
msgs = [json.loads(l[3:]) for l in open(sys.argv[1], encoding='utf-8') if l.startswith('<< ')]
src = open(sys.argv[2], encoding='utf-8').read()
pat = r'(?:L|find:|atlas:)?&lt;[A-Za-z. ]+>'
print('the book source:', len(re.findall(pat, src)), 'escaped placeholders')
for m in msgs:
    r = m.get('result', {})
    if 'contents' in r:
        t = ''.join(c.get('text', '') for c in r['contents']); what = 'resources/read jetcarp://docs/reference/mcp.md'
    elif 'content' in r:
        t = ''.join(c.get('text', '') for c in r['content']); what = 'help {page: reference/mcp}'
    else:
        continue
    found = re.findall(pat, t)
    print(f'{what}: {len(t)} chars, {len(found)} escaped placeholders: {sorted(set(found))}')
    print('   same text as docs/src/reference/mcp.md:', t.strip() == src.strip(), '| source contained in it:', src.strip()[:2000] in t)
PY"
