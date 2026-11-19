# The release (v0.4.0) through Homebrew and Scoop

**What this wave tests:**
1. **Installing the final release with a package manager:** Homebrew on the Mac, Scoop on the Acer.
   Neither has been tried on a real machine yet. The tap (`jprodgers/homebrew-jetcarp`) and the
   bucket (`jprodgers/scoop-jetcarp`) were made on release day.
2. **The fixes made after rc3, which the laptops haven't seen:**
   - a finished build's entries appear in the Quick Start about a second later, without opening a
     world first (Acer rc3 finding 1);
   - the Hunts list shows a pack's hunt as *imported*, *from a pack*, with no run time (Acer
     finding 3);
   - atlas cards with no catalog name are titled by mood and rule, such as *Battle JACA +B3/S23
     -B37/S23* (Mac finding 4);
   - `jetcarp verify` reads a PNG that JETCARP exported (Mac finding).
3. **Paths that must survive the package manager's next upgrade.** Homebrew and Scoop keep each
   version in its own folder and delete the old one on upgrade, so whatever JETCARP records (the
   login item, the recorded host program, the screen saver) must name the stable link, not the
   versioned folder.

**The release:** https://github.com/jprodgers/jetcarp/releases/tag/v0.4.0 (public, final). Nothing
here changes the release: failures go into 0.4.1.

**One machine at a time, in either order.** Each section stands on its own.

Same method as before:
- record each step as **pass**, **fail** or **skip**, with a note, in your machine's table;
- save outputs and screenshots to `results/v0.4.0/<machine>/`;
- commit and push after each section (or after each step if it's going slowly);
- ask Jimmie each "Check" one at a time, and say before anything changes the desktop.

Both laptops ended rc3 with JETCARP uninstalled and the settings and library kept, so there should
be no `jetcarp` on the PATH to start with.

---

## Mac (macOS 27): Homebrew

### H1. Before installing

1. `which -a jetcarp`: expect nothing. If a copy turns up, record where it is and ask Jimmie before
   going on.
2. `brew --version`. **If Homebrew isn't installed,** ask Jimmie whether to install it (the line at
   https://brew.sh; it asks for their admin password, so they run it). If they'd rather not, stop
   here and say so in the notes.
3. Record what rc3 left: `ls -la ~/Library/Application\ Support/jetcarp` and its `paths.json`, if
   there is one. rc3's notes say it names the Researcher folder `~/Documents/jetcarp-data`, which
   then went to the Trash. That is a known finding; H2 and H3 record what JETCARP does about it.

### H2. Install with Homebrew

    brew install jprodgers/jetcarp/jetcarp

The session may run it; if auto mode blocks it, Jimmie runs it. Save the output.

Checks:
1. `which jetcarp` says `/opt/homebrew/bin/jetcarp`, and `jetcarp --version` says `jetcarp 0.4.0`.
2. `brew test jetcarp` passes.
3. `jetcarp paths`: does `bundled:` name Homebrew's `share/jetcarp/packs`? And what does it say about
   the data folder, given that `paths.json` names a folder in the Trash? Record it exactly.
4. `ls "$(brew --prefix)/lib/jetcarp"` lists `libjetcarp_saver.dylib`.
5. `brew audit --strict --online jprodgers/jetcarp/jetcarp`: save the full output. It isn't pass or
   fail: it lists what Homebrew's own collection would want, which matters only if JETCARP goes
   there one day.
6. `jetcarp doctor`: save the output.

### H3. A first run with the Homebrew copy

1. **With rc3's settings still in place,** start `jetcarp` from the terminal. Does it start? Does it
   say anything about the missing data folder? Is there any Gatekeeper dialog? Quit (Cmd+Q).
2. Move rc3's settings aside as rc3 did, so the wizard sees a first run: `app.json`, `host.json`,
   `setup.json`, `paths.json` and `desktop-pictures/` go to
   `~/Library/Application Support/jetcarp-rc3-settings/`. Leave `data/` (the library) where it is.
   Note exactly what moved.
3. Start `jetcarp`. Choose **Explorer**, keep the starter pack, set the search to **2 minutes**, and
   press Start. Before starting, note the Quick Start menu's *Atlas* count if you can see it.
   Checks:
   - When the done page appears, press *Later* and look at the Quick Start **without opening a
     world**. Are the new entries there already, with the *Atlas* count gone up? (In rc3 they
     appeared only after a world was opened and closed.)
   - This build's atlas cards: do the ones without a catalog name read like *Battle JACA +B3/S23
     -B37/S23*, *Fractal HexW3 5033* or *Oscillating B2/S13/C7*, rather than many cards with one
     title? Count the distinct and repeated titles among **this build's** entries with read-only
     queries of the library, as rc3 did (`results/rc3/acer/08-quickstart-library.txt`). Older
     builds' entries keep their old titles: that's known, so don't count them.
4. *Tools → Hunts…*: the starter pack's hunt. Checks: does its row in the list say *imported* (not
   "0 soups"), *–* for the time, and *from a pack*? Does the detail name the pack's feed (such as
   *JETCARP starter pack*) rather than a `sha256:` hash?
5. Open any card, then *File → Export the view as PNG…*. In the terminal, run `jetcarp verify <that
   PNG>`. Check: does it say `ok: generation … hash …`? (In rc3 it said "stream did not contain
   valid UTF-8".)
6. Quit the app (Cmd+Q).

### H4. Paths that must survive `brew upgrade`

Homebrew keeps this version in `/opt/homebrew/Cellar/jetcarp/0.4.0/` and deletes that folder when
a later version is installed. Anything JETCARP records should name `/opt/homebrew/bin/jetcarp`, the
link that stays.

1. `jetcarp host login on`, then `jetcarp host start`. Check: does the LaunchAgent in
   `~/Library/LaunchAgents/` that names JETCARP run `/opt/homebrew/bin/jetcarp` (good) or a path
   under `/opt/homebrew/Cellar/` (a finding)? If `~/Library/Application Support/jetcarp/host-program`
   exists, record what it says too.
2. `jetcarp host saver install`. Checks: does it find the saver's code, with no "was not found"? Is
   JETCARP listed in System Settings' screen savers? (Quit and reopen System Settings if it was
   already open.) Don't leave it selected. Then run `jetcarp host saver remove`: is Flurry back?
3. `jetcarp host stop`, then `jetcarp host login off`. Is the LaunchAgent gone?

### H5. Clean up

1. Ask Jimmie whether to keep the Homebrew copy as their everyday JETCARP, or remove it. To remove
   it: `jetcarp uninstall --yes`, then `brew uninstall jetcarp` and `brew untap jprodgers/jetcarp`.
   Record what's left.
2. Ask Jimmie whether to put rc3's moved-aside settings back or move them to the Trash.
3. Add a dated note at the end of `NOTES.md`, then commit and push.

### Mac results

| Step | Result | Note |
|---|---|---|
| H1 | pass | No `jetcarp` on the PATH or in the old install places. Homebrew 7.0.12 at `/opt/homebrew`, no taps. rc3 left `app.json`, `host.json`, `setup.json`, `paths.json` and `data/` (no `desktop-pictures/`); `paths.json` names `~/Documents/jetcarp-data`, which doesn't exist. The library is rc1's: 364 built-in entries, **no atlas or pack entries**. |
| H2 | pass | `brew install` exit 0 in 8 s; `/opt/homebrew/bin/jetcarp`, `jetcarp 0.4.0`; `brew test` passes (and turned on Homebrew's developer mode); the saver dylib is in `lib/jetcarp`. **`bundled:` names the versioned `Cellar/jetcarp/0.4.0/share/jetcarp/packs`**, not the stable `share/jetcarp/packs`. `data:` names the missing `~/Documents/jetcarp-data` with no remark (`doctor`: "not created yet"). Audit: 1 problem (`version` is redundant). |
| H3 | pass (titles: partly) | With rc3's settings: starts, **no Gatekeeper dialog, no remark about the missing data folder** (and doesn't create it). First run: Explorer, 2 min, **2 min 24 s** Start to done, 713 atlas entries; **the Quick Start showed them (Atlas 713) without opening a world**. Titles: 515 distinct of 713, but *Oscillating Priority* ×44, **Battle JACA ×18 (JACA notations over ~20 characters fall back)**, *Forest fire* ×14, and one-rule families repeat per tiling. Hunts row: *imported*, *–*, *from a pack*, detail names the feed (`jobs status 25` in the terminal still says "hunt 0: 0 soups"). **`verify` reads both exported PNGs.** WAL 0 bytes. Job 3's spec records the Cellar path of the pack. |
| H4 | pass | The LaunchAgent runs **`/opt/homebrew/bin/jetcarp host serve --login`**; `host-program` says **`/opt/homebrew/bin/jetcarp host serve`**; the host runs from the link. `saver install` found the saver's code (no "was not found"), wrote a self-contained `JETCARP.saver` naming no Homebrew path; JETCARP listed in System Settings; `saver remove` left Flurry selected and JETCARP gone, the store identical. `login off` removes the LaunchAgent (launchd keeps rc1's loaded job until logout: known since rc1). |
| H5 | done | Jimmie **keeps the Homebrew copy** (0.4.0, tap `jprodgers/jetcarp`) as the everyday JETCARP, with today's Explorer settings and library (713 atlas entries); no host, login item or saver; Flurry. rc3's moved-aside settings went to the Trash. Homebrew's developer mode, which `brew test` turned on, is off again (Jimmie). |

---

## Acer (Windows 11): Scoop

PowerShell as Jimmie's own user, **not** as administrator. The session runs the commands unless
auto mode blocks one; then Jimmie runs it.

### S1. Before installing

1. `Get-Command jetcarp -All -ErrorAction SilentlyContinue`: expect nothing. If a copy turns up,
   record where it is and ask Jimmie.
2. Save the user PATH and its registry type, as in rc3 (`00-path-before.txt`,
   `00-path-type-before.txt`). It should be ExpandString, with `%PNPM_HOME%\bin`.
3. `scoop --version`. **If Scoop isn't installed,** ask Jimmie whether to install it. If they agree,
   Jimmie runs:

       Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
       irm get.scoop.sh | iex
       scoop install git

   (Scoop needs git to add a bucket.) Then save the PATH and its type again. Check: did Scoop's
   installer keep the PATH as ExpandString, with `%PNPM_HOME%\bin` unexpanded? (This tests Scoop,
   not JETCARP, but it is Jimmie's PATH.)
4. Record what rc3 left in `%APPDATA%\jetcarp` (the settings) and `%LOCALAPPDATA%\jetcarp` (the
   library).

### S2. Install with Scoop

    scoop bucket add jetcarp https://github.com/jprodgers/scoop-jetcarp
    scoop install jetcarp

Save the output.

Checks:
1. Is there any Defender or SmartScreen alert? Also check Defender's history
   (`Get-MpThreatDetection`) for anything new since rc3.
2. `(Get-Command jetcarp).Source` names Scoop's `shims\jetcarp.exe`, and `jetcarp --version` says
   `jetcarp 0.4.0`.
3. `jetcarp paths`: does `bundled:` name the starter pack under `scoop\apps\jetcarp\`?
4. `scoop info jetcarp` shows 0.4.0 from the bucket `jetcarp`, and `scoop status` shows nothing
   outdated.
5. Has the PATH changed since S1 (other than Scoop's own `shims` folder)? It shouldn't have.
6. `jetcarp doctor`: save the output.

### S3. A first run with the Scoop copy

1. Move rc3's settings aside so the wizard sees a first run: `%APPDATA%\jetcarp` goes to
   `%APPDATA%\jetcarp-rc3-settings`. Keep the library in `%LOCALAPPDATA%\jetcarp`.
2. Start JETCARP from **Start → Scoop Apps → JETCARP**. Check: does it open with **no console
   window**?
3. Choose **Explorer**, keep the starter pack, set the search to **2 minutes**, and press Start.
   Note the Quick Start's *Atlas* count first if you can see it. Checks:
   - When the done page appears, press *Later* and look at the Quick Start **without opening a
     world**. Are the new entries there already, with the *Atlas* count gone up? (This is the Acer's
     rc3 finding 1: they appeared only after a world was opened and closed.)
   - This build's atlas titles, counted with read-only queries as in rc3
     (`results/rc3/acer/08-quickstart-library.txt`): do the untitled ones carry a rule notation,
     rather than many cards with one title? Count only this build's entries.
4. *Tools → Hunts…*: the starter pack's hunt. Checks: does its row say *imported*, *–* for the time
   and *from a pack* (rc3: "0 soups", "0 s run", an empty *What*)? Does the detail name the pack's
   feed rather than `sha256:a78bbe8d…`?
5. Open any card, then *File → Export the view as PNG…*, then run `jetcarp verify <that PNG>`.
   Check: does it say `ok: generation … hash …`?
6. Close the app.

### S4. Paths that must survive `scoop update`

Scoop keeps this version in `scoop\apps\jetcarp\0.4.0\`, with `scoop\apps\jetcarp\current` as a
link to it. An update moves the link and later deletes the old folder. Anything JETCARP records
should name `...\apps\jetcarp\current\...`.

1. `jetcarp host login on`, then `jetcarp host start`. Checks:
   - `reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run`: does JETCARP's value name
     `...\current\jetcarpw.exe` (good) or `...\0.4.0\...` (a finding)?
   - `Get-Content $env:APPDATA\jetcarp\host-program`: does it name `...\current\...`?
2. `jetcarp host saver install`: it copies `JETCARP.scr` to `%LOCALAPPDATA%\JETCARP` and opens
   *Screen Saver Settings*. Check: does the small preview in that dialog show JETCARP? (The `.scr`
   finds `jetcarp.exe` through `host-program`, so this checks the recorded path.) Don't leave it
   selected; close the dialog, then run `jetcarp host saver remove`.
3. `jetcarp host stop`, then `jetcarp host login off`. Is the `Run` value gone?

### S5. Clean up

1. Ask Jimmie whether to keep the Scoop copy as their everyday JETCARP, or remove it. To remove it:
   `jetcarp uninstall --yes`, then `scoop uninstall jetcarp` and `scoop bucket rm jetcarp`. Record
   what's left, and the PATH and its type.
2. Ask Jimmie whether to keep Scoop itself, and whether to put rc3's moved-aside settings back or
   delete them.
3. Add a dated note at the end of `NOTES.md`, then commit and push.

### Acer results

| Step | Result | Note |
|---|---|---|
| S1 | pass | No `jetcarp` on the PATH or in rc3's install place. PATH ExpandString with `%PNPM_HOME%\bin`. **Scoop wasn't installed:** Jimmie installed it (v0.6.0) with `irm get.scoop.sh \| iex`, no alert, 9 s; `scoop install git` skipped (Git for Windows is on the PATH). **Scoop kept the PATH ExpandString, `%PNPM_HOME%\bin` unexpanded**, and only prepended `~\scoop\shims`. rc3's settings (`app.json`, `host.json`, `setup.json`) and the library (atlas 1,779, the starter pack already imported) are in place. |
| S2 | pass | `bucket add` + `install` (run by Claude) exit 0 in **8 s**; the manifest's hash matches `SHA256SUMS`. No Defender or SmartScreen alert, nothing new in Defender's history. `jetcarp` is `~\scoop\shims\jetcarp.exe` → `apps\jetcarp\current\jetcarp.exe`, `jetcarp 0.4.0` (now with a version resource). **`bundled:` names `apps\jetcarp\0.4.0\packs`, not `current`** (the junction is resolved, as the Mac resolves the Cellar). `scoop info` 0.4.0 from `jetcarp`; `scoop status` all ok; the PATH unchanged since Scoop's install; `doctor` clean. |
| S3 | pass (titles: partly) | Start → Scoop Apps → JETCARP: **no console window**; the wizard over 2,221 entries (Atlas 1,779). Explorer, 2 min: **2 min 30 s** Start to done, 349 atlas entries, CPU peak 10.5 cores; **the Quick Start showed them (Atlas 2,128) after *Later* without opening a world**. Titles: 256 distinct of 349, but *Oscillating Priority* ×16, *Frozen Priority* ×12, **Battle JACA ×9 (all notations 24-33 characters; notated ones ≤19)**, and one rule on many tilings repeat, as on the Mac. **The 0.4.0 starter pack was re-imported (new manifest) and rc2's 79 pack entries stay: Packs 127, 10 shown twice.** Job 32's spec records `apps\jetcarp\0.4.0\packs\...`. Hunts row: *imported*, *–*, *from a pack*; detail "Imported from pack jetcarp-starter". **`verify` reads both exported PNGs.** Closed with exit 0, WAL 0 bytes. |
| S4 | pass | The `Run` value is **`"…\scoop\apps\jetcarp\current\jetcarpw.exe" host serve --login`**; `host-program` says **`…\current\jetcarpw.exe host serve`**; the host runs from `current` (exit 0 at once; one ordinary window, since `host.json` was moved aside). `saver install` (Jimmie): **the dialog's preview shows JETCARP**, run as `…\current\jetcarp.exe host scr /p`; the list calls it "Jetcarp". `saver remove`: removed, `SCRNSAVE.EXE` cleared, timeout as before. `host stop` (exit 0) and `login off`: **the `Run` value is gone.** |
| S5 | done | Jimmie **keeps the Scoop copy** (0.4.0, bucket `jetcarp`) as the everyday JETCARP, with today's Explorer settings and the library; no host, login entry or saver. **Scoop stays** (v0.6.0); the PATH is the pre-wave value plus `~\scoop\shims`, ExpandString, `%PNPM_HOME%\bin` kept. rc3's moved-aside settings went to the Recycle Bin. |
