# rc2 Acer A4: a Claude Code session driving JETCARP over MCP

2026-11-12, 08:13-08:20 EST. Claude Code 2.1.317 in a separate PowerShell window, in a new empty
folder (`%USERPROFILE%\jetcarp-mcp-test`), so the session couldn't read this repository's notes.
Jimmie typed tutorial 6's prompts, one at a time. The session ran in Claude Code's auto mode, so no
permission prompts came up, and no call was blocked.

Setup (Jimmie): `claude mcp add jetcarp -- jetcarp mcp`, `claude mcp list` (connected), `claude`.
Afterwards `/exit` and `claude mcp remove jetcarp`; `claude mcp list` no longer shows it.

Tool calls are as made; results and answers are trimmed (`...`). `ToolSearch` is Claude Code
loading the JETCARP tools' definitions, not a JETCARP call. **All 9 JETCARP calls worked first
time; none returned an error.**

## 1. "What can the JETCARP tools do?"

```json
{"name": "help", "arguments": {"topic": "overview"}}
```

```text
JETCARP: a cellular-automaton (CA) research tool.

Concepts
- A world = a tiling (a grid of cells: squares, hexagons, triangles, Archimedean and k-uniform
  tilings, or the aperiodic Spectre, hat and Penrose tilings) + one or more CAs (rules) running on it.
...
The tools
- help, reference: these guides; rules, tilings, palettes, seed forms, commands.
- world_new, world_status, world_read, world_edit, world_step, world_render: ...
...
```

It then loaded the definitions of `app_display`, `host_control` and `use_app` (to describe them,
not to call them) and answered with the tools grouped by job: building and running a world, batch
runs (`run_script`), searches and the library, `media_render`, `pack` and `files_list`, the desktop
app (`use_app` needs *Tools → AI control… → Allow AI control*; `host_control` needs a running host),
and the docs. It offered four things to try. Accurate, and it called `help` first, as the tutorial
says a good assistant does.

## 2. "Run Brian's Brain on a 120 by 80 square grid for 200 generations and show me."

```json
{"name": "world_new", "arguments": {"tiling": "square", "width": 120, "height": 80,
  "boundary": "wrap", "cas": ["Brian's Brain"]}}
{"name": "world_step", "arguments": {"generations": 200}}
{"name": "world_render", "arguments": {"max_side": 960}}
```

```text
New world created.
{ "cas": [{"id": 1, "name": "Brian's Brain", "rule": "B2/S/C3", "palette": "Ember", ...}],
  "cells": 9600, "fields": [{"kind": "3-state", "population": 3048, ...}], "generation": 0,
  "hash": "3b9af0166f19ebf7",
  "host": {"kind": "headless", "note": "a private world inside this MCP server; the JETCARP app is not affected"}, ... }

Ran 200 generation(s) in 0.05s.
Generation 200. Status: Running. Hash c38568895709dcc6 (with generation and ages); cells hash 979f449932f65d92 (cell states only: equal when the cells repeat).
field 0 [Brian's Brain (id 1)]: 690 live

960 x 640 px picture of generation 200 (Square (parallelogram), 9600 cells; hash c38568895709dcc6).
[image]
```

**Hash `c38568895709dcc6` and 690 live cells: exactly the tutorial's**, as it says any computer
will give. The answer described the picture correctly (orange cells firing, purple dying, small
two-coloured spaceships, a long diagonal wavefront on the left, not settled).

**But Jimmie never saw the picture.** The model chose no `save_path` (the tutorial's session used
`"save_path": "brain.png"`), so nothing was written to the output folder, and Claude Code's
terminal doesn't show a tool's image to the user. The answer still began "the picture above shows
generation 200". The tutorial's "The picture comes back to the assistant, which shows it to you" is
true of Claude Desktop, not of Claude Code.

## 3. "Run 20,000 Life soups and tell me which spaceships turned up."

```json
{"name": "search_start", "arguments": {"hunt": {"rules": ["B3/S23"], "soups": 20000},
  "label": "life-20k-soups", "wait_s": 180}}
```

```text
Hunt job 30 started (background).
hunt 30: 20,000/20,000 soups, 1577 soups/s, 430,384 objects (ships 38,188, osc 124,582, still 267,614), 50 distinct, 8 new | newest: still life 12c #bf73c4 (B3/S23)
  status done, 13 s run, 19892 settled, 52 died, 56 exploded, 0 unsettled
  newest finds:
    bf73c46c186561ca3b75a3884d0b5ab5  still life 12c #bf73c4   B3/S23   Square soup 17973  (new to the catalog)
    ...
```

The call returned when the hunt ended (13 s; `wait_s` 180), so there was no polling. **Every count
matches the tutorial exactly** (430,384 objects; 38,188 / 124,582 / 267,614; 50 distinct; 19,892
settled, 52 died, 56 exploded), at 1,577 soups/s against the tutorial's 2,816. "8 new" instead of
"50 new" because this library already held rc1's and rc2's earlier finds; job 30 for the same
reason.

```json
{"name": "job_status", "arguments": {"job": 30, "report": true}}
{"name": "library_query", "arguments": {"class": "spaceship", "rule": "B3/S23", "order": "seen", "limit": 10}}
```

```text
# Hunt 30: life-20k-soups: B3/S23 on Square, 16x16 soups at 0.5
...
| 30 | Square | B3/S23 | 20000 | 50 (0) | c/4 diagonal 5c p4 x38120; c/2 orthogonal 9c p4 x51; c/2 orthogonal 11c p4 x13; c/2 orthogonal 13c p4 x4 |  |  | p3 48c; p2 3c |

{"catalog": "C:\\Users\\jimmi\\AppData\\Local\\jetcarp\\library.sqlite", "matching": 4, "patterns": [
  {"label": "glider", "speed": "c/4 diagonal", "cells": 5, "seen": 57076, "range": "B3/S23 to B3678/S0235678 (256 B/S rules)", "state": "new", ...},
  {"label": "LWSS", "speed": "c/2 orthogonal", "cells": 9, "seen": 75, "range": "B3/S23 to B3468/S2378 (32 B/S rules)", ...},
  {"label": "MWSS", "speed": "c/2 orthogonal", "cells": 11, ... "range": "B3/S23 to B3468/S238 (16 B/S rules)", ...},
  ...]}
```

The answer: a table of the four (glider 38,120, LWSS 51, MWSS 13, HWSS 4; 99.8% gliders), the
soup outcomes, and that the 8 "new" finds were still lifes new only to this library, not
discoveries. It took the hunt's numbers from the job report and not the library's `seen` totals
(which include earlier jobs), which is right.

## 4. "Tell me more about the LWSS it found."

```json
{"name": "library_query", "arguments": {"id": "LWSS", "phases": 4}}
```

```text
LWSS (6dd55e69689ba784aff448b7dbbc9328)
verified in: B3/S23
works in: B3/S23 to B3468/S2378 (32 B/S rules)
sightings: B3/S23 x24 (job 2), B3/S23 x51 (job 30)
moves per period by paste orientation: 0: (-2, 0), 1: (2, 0), 2: (2, 0), 3: (0, 2), 4: (0, -2), 5: (0, 2), 6: (0, -2), 7: (-2, 0)
phase 0:
OOOO.
O...O
O....
.O..O
...
{"format": 2, "id": "6dd55e69689ba784aff448b7dbbc9328", "name": "LWSS", ..., "period": 4,
 "speed": "c/2 orthogonal", "cells": 9, "min_cells": 9, "max_cells": 12, ...}
```

The answer showed the four phases side by side, explained the glide-reflection and c/2, worked out
why the range is 32 rules (birth on 4, 6, 8 and survival on 7, 8 never arise: 2^5), and said where
the record came from (job 2, which the library shows is rc1's 10,000-soup hunt on this laptop,
engine `0.4.0-rc.1`; then job 30). It read the record's `"state": "new"`
correctly as "not reviewed yet", though the hunt's "new to the catalog" uses the same word for
something else.

## Verdict

Every JETCARP call worked and nothing confused the model. Both of the tutorial's exact results
(the Brian's Brain hash and the 20,000-soup counts) came out identical on Windows. One gap, for the
tutorial or the server: in Claude Code the user can't see a picture unless the model saves it, and
here it didn't (Jimmie: "No, I saw no picture").
