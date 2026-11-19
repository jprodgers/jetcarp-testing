# F-3 on rc.5: the 8-hour soak of the desktop background on GNOME (the Framework, 2026-11-17, 9:10 AM–5:10 PM EST)

**Result: pass.**

## How it ran

The Framework's first overnight-length run of the cycle: Fedora 45, GNOME Shell 51.1, Radeon 8060S on Vulkan. Jimmie
stayed logged in and used the machine for light work throughout.
- **A private headless GNOME Shell**, so nothing reached Jimmie's own session:
  - `start.sh` runs `env -i … dbus-run-session -- bash inner.sh`, with every XDG folder and the D-Bus session under
    the test folder, and one virtual 2560 × 1440 monitor;
  - `inner.sh` refuses to start unless the settings, data, output and runtime folders, the dconf file and the bus are
    all the test's own.
- **rc.5's release build** (the Linux archive, sha256 68c920e4…). In order:
  1. `setup --seizure-warning no-disorder`;
  2. the GNOME extension enabled in the test's own dconf, then `host gnome install`;
  3. `host serve`, `host rotation "Classics, hourly"`, `host wallpaper on`.

  The status showed "wallpaper: showing · lock screen: live", with the extension loaded.
- **Measured:** a sample every 5 minutes (96 in all) of `host status --json`, the host's RSS and its CPU (`top`), in
  `soak.csv`. A screenshot every hour, through the shell's own Screenshot call (`shot.py`).
- **Jimmie's real settings:** read before and after (`gsettings get` of `org.gnome.shell enabled-extensions` and the
  background's `picture-uri`). They were the same.

## Results (`soak.csv`, `run.log`)

- **Alive in all 96 samples, one host (pid 3525518):** never held, never paused. The generation moved in every
  interval.
- **Full speed throughout.** The lowest measured speed was 99.97% of the asked-for one. Two kinds of scene:
  - the two ants, at 240 generations a second on the CPU (the world is too small to be worth the GPU);
  - the other five, at 30 a second on the Radeon (Vulkan).
- **Every hour's scene change came on time**, through all seven classics. The rotation began at item 2 (Langton's ant)
  and reached item 7 (Hodgepodge) at 5:02 PM:

  | Time (EST) | Scene | Simulation | Memory (MB) |
  |---|---|---|---|
  | 9:10 AM | Langton's ant | CPU, 240/s | 334–335 |
  | 10:00 AM | Penrose waves | GPU, 30/s | 467 |
  | 11:01 AM | Turmite llrr | CPU, 240/s | 467 |
  | 12:01 PM | Cyclic spirals | GPU, 30/s | 407 |
  | 1:01 PM | Life | GPU, 30/s | 407 |
  | 2:01 PM | Langton's ant | CPU, 240/s | 408 |
  | 3:02 PM | Turmite llrr | CPU, 240/s | 409 |
  | 4:02 PM | Forest fire | GPU, 30/s | 409 |
  | 5:02 PM | Hodgepodge | GPU, 30/s | 409 |

- **Memory: no climb.**
  - It rose to 467 MB on Penrose waves, fell to 407 MB at the next GPU scene, and stayed at 407–409 MB for the last
    five hours, across five scene changes.
  - The host keeps some of what the largest scene took (the ant used 335 MB at the start and 408 MB at 2 PM), but the
    total doesn't grow.
  - The laptops' soaks on rc.4 behaved the same way.
- **CPU (`top`, % of one core):** median 36% on the GPU scenes and 53% on the CPU ones; 70% at most.
- **The end:** `host stop` → "stopped". No process from the private session was left, no mount, and Jimmie's GNOME
  settings were unchanged.

## The pictures (`shots/`)

- **What they show:** each hour's picture (`f3-00h` to `f3-07h`, JPEG at 1280 wide; the PNGs' sha256 in
  `png-sha256.txt`) shows the scene as the desktop background.
- **What's in front:** the test's new home made GNOME open in the overview, with Fedora's "Welcome" dialog, so each
  picture is dimmed and the dialog covers the centre.
- **The two ant hours** (`f3-00h`, `f3-05h`) look empty: Langton's ant draws from the centre, under the dialog. The
  samples show it stepping at 240 a second. The other scenes fill the screen around the dialog (`contact.jpg`).

## Logs

- **`shell.log`:** two error lines, both GNOME's own at start-up. The accessibility bus can't be started in a private
  session, and there's no geolocation permission entry. One `libmutter-CRITICAL` at 9:10:19 about window stacking
  came as the shell started.
- **`host.log`:** one line, the GPU in use.
- **`run.log`:** "GNOME Shell was not found in this session" comes from `host gnome install`, run before the shell
  started, as the script intends.
