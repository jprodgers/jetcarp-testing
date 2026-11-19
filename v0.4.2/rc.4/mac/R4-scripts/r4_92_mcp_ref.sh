#!/usr/bin/env bash
# R4 #92 (the book row's third bullet): the MCP reference shows <id> and L<level>. On the Mac: the page's source at
# the tag, and the same page served by rc.4's `jetcarp mcp` (resources/read and help). The rendered page (mdbook)
# was checked on the Framework (R4-9); mdbook isn't installed here.
set -u
D=$(cd "$(dirname "$0")" && pwd)
rm -rf ~/jetcarp-rc4/homes/docs
. "$D/lib.sh" docs
SRC=~/jetcarp-rc-042c/src
echo "R4 #92 the MCP reference's placeholders, the Mac, $(ts)"
echo "source: ~/jetcarp-rc-042c/src at $(git -C $SRC rev-parse --short HEAD) ($(git -C $SRC describe --tags 2>/dev/null)); test folder \$H = homes/docs"
echo
echo "#### The placeholders #92 named, in docs/src/reference/mcp.md"
run "grep -n -o -E '(L|find:|atlas:)?&lt;[A-Za-z. ]+>' $SRC/docs/src/reference/mcp.md | sed 's/^/  /'"
echo "#### Any bare '<' outside code spans and fences (HTML comments aside): only the page's own HTML expected"
run "python3 - $SRC/docs/src/reference/mcp.md <<'PY'
import re, sys
bad = []
infence = False
for n, line in enumerate(open(sys.argv[1], encoding='utf-8'), 1):
    if line.lstrip().startswith('\`\`\`'):
        infence = not infence
        continue
    if infence:
        continue
    s = re.sub(r'\`[^\`]*\`', '', line)
    s = re.sub(r'<!--.*?-->', '', s)
    for m in re.finditer(r'<[A-Za-z.]', s):
        bad.append((n, s[max(0, m.start()-30):m.start()+30].strip()))
print('bare < outside code:', len(bad))
for b in bad[:20]: print('  ', b)
PY"
echo "#### The same page served by jetcarp mcp: resources/read and help {page}"
run "python3 \$R/R4-scripts/mcall.py \$R/92-mcp.jsonl '[[\"help\",{\"page\":\"reference/mcp\"}]]' --resource jetcarp://docs/reference/mcp.md --maxlog 0 > \$H/served.txt; head -6 \$H/served.txt; grep -c . \$H/served.txt"
run "python3 - \$R/92-mcp.jsonl $SRC/docs/src/reference/mcp.md <<'PY'
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
    print('   the same text as the source page:', t.strip() == src.strip(), '| the source within it:', src.strip()[:2000] in t)
PY"
