F-2: JETCARP 0.4.2-rc.5 in a new Fedora account (the Framework)
=================================================================

Note anything that confuses you, even if it works out in the end: what you tried, and what happened.
Switch back to your own account and tell the main session as you go, or at the end of each part.

THE BOOK: use http://localhost:3000 (rc.5's book, served from your own account). The online book
is still 0.4.1's.

Setting up
----------
1. Settings > System > Users > Add User: a Standard account (say "Ada Test"), with a password.
2. Your menu (top right) > Power > Switch User, and log in as Ada. Your own session keeps running.
3. In Ada's account, open this file: Text Editor > Open > /tmp/jetcarp-f2.md (or: cat /tmp/jetcarp-f2.md).

Part A: a newcomer's first hour (rc.5)
--------------------------------------
A1. Read the book's Getting started (localhost:3000) and follow it as written.
A2. Install. The book's command fetches the latest release, which is still 0.4.1 (pre-releases are
    never "latest"). So use this release's installer instead:
       curl -LsSf https://github.com/jprodgers/jetcarp/releases/download/v0.4.2-rc.5/jetcarp-installer.sh | sh
    Then, in a NEW terminal: jetcarp --version  (should say 0.4.2-rc.5). Did `jetcarp` work at once?
A3. Start the app: jetcarp
    - the seizure warning comes first;
    - setup: choose Desktop art and follow it through to a live desktop background (GNOME asks
      for one logout and login to load the extension: do it);
    - then, in a terminal: jetcarp setup --status
A4. A first Quick Start world; a first search (a short hunt); a find saved, and seen in the library.
A5. (Optional; skip if Claude Code isn't set up in Ada's account) the book's MCP steps:
       claude mcp add --scope user jetcarp -- jetcarp mcp
    then /mcp from another folder: is jetcarp there?
A6. Remove it all, as the book's Uninstalling page says:
    - jetcarp uninstall          (read the plan it prints)
    - jetcarp uninstall --yes    (and say yes to deleting settings and data)
    - curl -LsSf https://github.com/jprodgers/jetcarp/releases/download/v0.4.2-rc.5/jetcarp-installer.sh | sh -s -- --uninstall
      (#134: it should NOT say it kept your settings, since they're gone)
    - Is anything of JETCARP left? ls ~/.local/share/gnome-shell/extensions ~/.config/autostart ~/.cache/jetcarp
      (~/.cache/jetcarp left behind is known: #135)

Part B: the upgrade from 0.4.1
------------------------------
B1. Install 0.4.1 the everyday way:
       curl -LsSf https://github.com/jprodgers/jetcarp/releases/download/v0.4.1/jetcarp-installer.sh | sh
    jetcarp --version  (0.4.1)
B2. Use it a little: setup with a profile; a hunt with finds; the desktop background on, starting at login.
B3. Upgrade by installing rc.5 over it:
       curl -LsSf https://github.com/jprodgers/jetcarp/releases/download/v0.4.2-rc.5/jetcarp-installer.sh | sh
    Then check:
    - jetcarp --version says 0.4.2-rc.5;
    - the library has the same finds, and the settings are kept;
    - the seizure warning: the desktop background holds still until it's answered (open the app);
    - log out and in: the host comes back, as rc.5, and GNOME has the refreshed extension;
    - nothing is lost.
B4. jetcarp uninstall --yes, then the installer's --uninstall, as in A6.

At the end: switch back to your account. Removing Ada's account is up to you
(Settings > Users > Ada > Remove User).
