# F3 on 0.4.2: the GNOME extension refresh on Jimmie's real session (the Framework, 2026-11-17, 7:33–7:51 PM EST)

**Result: pass.**

What was there before: JETCARP 0.4.1 as a plain file at `~/.local/bin/jetcarp`, the login item
(`~/.config/autostart/jetcarp-host.desktop`, running `~/.local/bin/jetcarp host serve --login`), and 0.4.1's extension,
active. No host was running.

1. **The program.**
   - The draft release's Linux archive (`jetcarp-0.4.2-x86_64-unknown-linux-gnu.tar.gz`, the same file as the
     published one) checked against the release's `SHA256SUMS`: OK.
   - Its `jetcarp` was moved into place over the 0.4.1 file, kept aside as a backup. It answered `jetcarp 0.4.2`.
2. **The refresh.** `jetcarp host gnome status`:
   ```
   updated the GNOME extension to JETCARP 0.4.2's; log out and back in once to load it
   The GNOME extension was updated to JETCARP 0.4.2's, but GNOME still has an older version loaded. Log out and back in once to load the new one.
   ```
   - The extension's `metadata.json` went from no `version-name` (0.4.1's) to "0.4.2".
   - It stayed enabled; `enabled-extensions` was unchanged.
3. **One logout and login** (Jimmie, about 7:45 PM). After it (`F3-after-login.txt`):
   - **The extension:** version 0.4.2, enabled, ACTIVE. `host gnome status`: "The GNOME extension is running."
   - **The host:** the login item started 0.4.2's host, 5 minutes before the check. Its status says the
     photosensitive seizure warning has been accepted, and the scenes run.
   - **The desktop:** Jimmie's own rotation, "wallpaper: showing · lock screen: live".
