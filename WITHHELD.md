# What this copy leaves out

This is a copy of the private repository in which JETCARP's release candidates are planned and their results recorded. Everything committed there is here, except the following.

## Left out, trimmed or masked as personal, and not evidence

- **Other programs and projects.** The names of other programs on the test machines (in the Windows Run key and PATH, and macOS login items and launch agents), and of the developer's other projects: masked as *another program*, or a PATH list cut to JETCARP's and Scoop's entries with a count of the rest. Text that JETCARP itself printed is not masked, whatever it names.
- **Names and numbers that identify a machine.** The network names of two of the computers read `framework` and `ACER`. Hardware, display and desktop-space identifiers read `HARDWARE-UUID`, `DISPLAY-1-UUID`, `SPACE-1-UUID` and so on, the same word for the same identifier throughout, so a record that compares two of them still reads true. A battery's id and a hash of one PATH value read `(left out)`.
- **File names of the developer's own pictures**, where a log names the wallpaper that was set before a test: `own-picture.png`.
- **The per-session folder names of the test sessions' scratch space:** `SESSION`.
- **Two pictures.** One screenshot is cropped to the app's window, and one photograph of a terminal has the computer's name covered with grey blocks.
- Files that only clutter: `.DS_Store`, Python caches, marker files.

Each mask replaces the value where it stood and changes nothing else in the file. Hashes of JETCARP's own output, tool and driver versions, GPU names, timings, and the names of the user accounts and folders the tests ran in are evidence, and are as recorded.

## Left out until a fix is released

Nothing at present. The records of a security problem are left out until a release fixes it (see the README); when one is, this section says how severe it is, which releases have it and which one fixes it.

## Rewritten or added for this copy

- `RULES.md` is the private repository's README, with its opening rewritten to say what it is.
- `README.md`, `MOVED.md`, each cycle's `README.md`, `audits/` and `tools/` were written for this copy.

Nothing else was changed: the logs, outputs, tables and notes are as the test sessions wrote them, in folders arranged by release cycle (`MOVED.md` lists where each was before).
