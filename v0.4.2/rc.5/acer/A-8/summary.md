# A-8 on rc.5: two monitors without Fit, #112's monitor change, #130 (the Acer, 2026-11-17, 16:08–16:20 EST)

rc.5's host ran in its own folder (`~/jetcarp-rc5/a8`, every `JETCARP_*` set, the warning answered there with
`setup --seizure-warning`), on Jimmie's desktop. Displays:
- the laptop: `\\.\DISPLAY1`, 1920×1080, the main display, 100%;
- the AOC: `\\.\DISPLAY5`, 2560×1440 at x = −2560 (on the left), 100%.

`a8.ps1` ran the commands. Its `watch` step logged `host status --json` every second, with each wallpaper window's
place and its monitor's DPI (`a8.txt`). Jimmie did the plugging, scaling and looking.

| Step | Result |
|---|---|
| 1, two screens, one per monitor | **pass.** `host wallpaper on --screen 0 --monitor 0`, then `--screen 1 --monitor 1 --rotation "Classics, hourly"` (the book's lines). Screen 0 on the laptop: "A classic a day", Penrose waves, 280,000 cells of 2.4 px. Screen 1 on the AOC: "Classics, hourly", Forest fire, 921,600 cells of 2 px (1280×720). Each was at its scene's own size and 30 of 30 generations a second, on the UHD. Each wallpaper window sat on its monitor (−2560,0 2560×1440; 0,0 1920×1080). Jimmie: "Both looked right". Pictures: `shot-two-screens-0.jpg` (the AOC) and `-1.jpg` (the laptop). |
| 3, unplug and replug while the host runs | **pass.** AOC out at 16:10:46, back at 16:11:17. The same host process throughout, never held, no tune or fit field. Screen 0 went on at 30 a second (Jimmie: "laptop kept going unplugged"), and both screens were back on their monitors at once ("both back after with the same images"). While the AOC was out, screen 1 stayed bound to it and kept stepping, unseen (#130, below). |
| 4, the AOC's scaling changed | **pass.** The AOC went 100% → 125% → 225% → 100%, its effective DPI 96 → 120 → 216 → 96. Only screen 1 was rebuilt each time, at its own size scaled to the monitor: 2 px → 3 px (409,440 cells) → 5 px (147,456) → 2 px (921,600). The laptop's screen ran straight through. Jimmie needed 225% to see the change in Forest fire's fine texture. |
| #112, a monitor change starts no fit | **pass.** No tune or fit key anywhere in the status through every change; `host.json` E7D496CA7D4B unchanged from the start to the end. |
| #130, the host started with the AOC unplugged | **confirmed on Windows, as on the Mac** (for 0.4.3). Screen 1, bound to monitor 1, was "wallpaper on monitor 1 (not connected)", yet at generation 1,348 after 47 s, 30 a second on the GPU, at a fallback 1280×720 (230,400 cells), with no window (one wallpaper window only, the laptop's). The host's GPU use was 49–52% (62% with both screens visible). Plugged back in, screen 1 got its window on the AOC at once and rebuilt at 921,600 cells of 2 px (Jimmie: "AOC shows forest fire again, laptop still Penrose"). |
| The end | `host stop`: "stopped", no jetcarp process left; the desktop picture's file (85FF3BB2371A) unchanged throughout. |

**A first try at step 4 is set aside.** Jimmie changed "the scale" with Display settings as it opened. The log then
showed only the *laptop's* screen rebuilt, at 3.0 px (2.4 × 1.25) and then 4.0 px (2.4 × 1.5, rounded up), while the
AOC's screen didn't change ("it looked the same regardless"). That fits the laptop's scale changing: Display settings
opens on the main display. That log had no DPI readings yet. The repeat, with the AOC's box chosen and its DPI logged,
is the result above.
