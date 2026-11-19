# rc3 Mac M5: MCP with Claude Desktop (trimmed transcript)

Claude Desktop 5.1231.2 on macOS 27.0.1, JETCARP 0.4.0-rc.3, 2026-11-13 00:24-00:36.
Jimmie typed the prompts; Claude Desktop's model chose the tool calls. Claude Desktop's logs record
only the connection (`Connected to jetcarp (21 tools)`), not the calls, so this is from the chat as
Jimmie copied it, trimmed. The Researcher data folder (`~/Documents/jetcarp-data`) is the library.

## Connecting

Claude Code added the tutorial's entry to `claude_desktop_config.json` while Claude Desktop was
closed (`"jetcarp": {"command": "jetcarp", "args": ["mcp"]}`, beside the existing another server).
Claude Desktop found the bare `jetcarp`: it started `/Users/Jimmie/.local/bin/jetcarp mcp` (it
passes the login shell's PATH, which has `~/.local/bin`), and its log says *Server started and
connected successfully*, then `initialize`, `tools/list`, `resources/list`. The tutorial's
*Settings → Developer → Edit Config* isn't where this version lists servers: Jimmie found JETCARP
under *Settings → Customize*.

## 1. The tutorial's prompt, as written: no tools used

> Run Brian's Brain on a 120 by 80 square grid for 200 generations and show me.

The model **wrote its own simulation as an artifact** instead of using JETCARP; the server's log
has no `tools/call`. Jimmie checked that JETCARP was switched on in the chat's tools menu and asked
again in a new chat, naming the tools.

## 2. Brian's Brain, "and show me"

> Use the JETCARP tools to run Brian's Brain on a 120 by 80 square grid for 200 generations and
> show me.

(The chat as copied shows the answer, not the calls.) The picture appeared **in the conversation**,
and the model also saved it, unasked: `~/Pictures/JETCARP/brians_brain_120x80_gen200.png`
(960 x 640; copied here as `17-mcp-brians-brain.png`). Its PNG records **generation 200, hash
`c38568895709dcc6`, the tutorial's hash exactly**.

> I ran Brian's Brain (B2/S/C3) on a 120×80 square grid for 200 generations, starting from the
> rule's default random soup (seed 1) with wrapping edges. The picture above is generation 200. …
> The world is still running, with 690 live cells out of 9,600, down from 3,048 at the start. …
> The render was saved on your computer at /Users/Jimmie/Pictures/JETCARP/brians_brain_120x80_gen200.png.
> The run is in JETCARP's private world, not the desktop app.

690 live cells, as in the tutorial.

## 3. 20,000 Life soups and their spaceships

> Run 20,000 Life soups and tell me which spaceships turned up.

Calls, in order (Claude Desktop loaded the tools first):

```json
{"name": "help", "arguments": {"topic": "searches"}}
{"name": "search_start", "arguments": {"hunt": {"rules": ["B3/S23"], "soups": 20000}, "label": "life-20k-soups", "wait_s": …}}
{"name": "library_query", "arguments": {"class": "spaceship", "rule": "B3/S23", "order": "seen"}}
{"name": "job_status", "arguments": {"job": 24, "report": true}}
```

(Reconstructed: the chat shows each call's arguments only in short, as "searches",
"life-20k-soups" and "Class: spaceship, Order: seen, Rule: B3/S23", and the last call by its
answer, the job's Markdown report. `help` returned the searches guide, whose example is this
hunt, and the model followed it.)

```text
Hunt job 24 started (background).
hunt 24: 20,000/20,000 soups, 2087 soups/s, 430,384 objects (ships 38,188, osc 124,582, still 267,614), 50 distinct, 50 new | newest: still life 12c #bf73c4 (B3/S23)
  status done, 10 s run, 19892 settled, 52 died, 56 exploded, 0 unsettled
  newest finds:
    bf73c46c186561ca3b75a3884d0b5ab5  still life 12c #bf73c4   B3/S23   Square soup 17973  (new to the catalog)
    …
{"done":20000,"elapsed_s":9.6,"job":24,"kind":"hunt","label":"life-20k-soups","status":"done","total":20000,"unit":"soups","waited_s":9.7}
```

```text
{"matching": 4, "patterns": [
  {"label": "glider", "speed": "c/4 diagonal", "cells": 5, "seen": 38120, "range": "B3/S23 to B3678/S0235678 (256 B/S rules)"},
  {"label": "LWSS", "speed": "c/2 orthogonal", "cells": 9, "seen": 51, "range": "B3/S23 to B3468/S2378 (32 B/S rules)"},
  {"label": "MWSS", "speed": "c/2 orthogonal", "cells": 11, "seen": 13, "range": "B3/S23 to B3468/S238 (16 B/S rules)"},
  {"label": "HWSS", "speed": "c/2 orthogonal", "cells": 13, "seen": 4, "range": "B3/S23 to B3468/S23 (8 B/S rules)"}]}
```

Its answer (trimmed):

> I ran 20,000 Life (B3/S23) soups in about 10 seconds. … Only the four standard spaceships turned
> up, and no exotic ones.
>
> | Spaceship | Cells | Speed | Period | Times seen |
> |---|---|---|---|---|
> | Glider | 5 | c/4 diagonal | 4 | 38,120 |
> | Lightweight spaceship (LWSS) | 9 | c/2 orthogonal | 4 | 51 |
> | Middleweight spaceship (MWSS) | 11 | c/2 orthogonal | 4 | 13 |
> | Heavyweight spaceship (HWSS) | 13 | c/2 orthogonal | 4 | 4 |
>
> … The run is saved in your JETCARP library as job 24 (life-20k-soups).

**Every count matches the tutorial exactly** (objects, ships, oscillators, still lifes, 50 distinct
and new, settled/died/exploded, and the four ships' sightings), as on the Acer in rc2. 2,087
soups/s here; the tutorial's run had 2,816. `18-mcp-hunt.txt` has the job from the command line.

## 4. AI control

Jimmie ticked *Tools → AI control… → Allow AI control* in the app, then:

> AI control is on in the JETCARP app. Attach to the app and show Brian's Brain on a 120 by 80
> square grid in its window.

```json
{"name": "use_app", "arguments": {}}
```

```text
Attached to the JETCARP app: the tools now act on the world the user is watching.
{ "cas": [{"name": "JACA B2/S12467", …}], "cells": 23940, "generation": 15208, "hash": "7db4deeb04c8ceab",
  "host": {"kind": "app", "note": "this is the world shown in the JETCARP app window; the user can change it too",
           "playing": true, "scene_name": "JACA rainbow fronts (squares)", "screensaver": false}, … }
```

Then (calls not shown in the copy) it saved the app's scene and built the new world:

> Replacing the current scene with Brian's Brain. The app is currently running a JACA scene, "JACA
> rainbow fronts", at generation 15,208. Building the new world replaces it, so I'll save a copy of
> that scene first.
>
> Brian's Brain is now running in the JETCARP window on a fresh 120×80 square grid with wrapping
> edges. … Your "JACA rainbow fronts" scene was in that window, so I saved a copy to
> /Users/Jimmie/Pictures/JETCARP/jaca_rainbow_fronts_before_brians_brain.json. It was saved at
> generation 15,286, and you can reopen it from the app to carry on from there.

**The app's window changed to Brian's Brain, and the change shows in the app's command log**
(Jimmie). The saved scene is a replay (seed plus "step 15286") and verifies:
`ok: generation 15286 hash 07ee9deacc16f6b4`.

## Afterwards

AI control switched off in the app; JETCARP removed from `claude_desktop_config.json` with Claude
Desktop closed (the rest of the file as before).
