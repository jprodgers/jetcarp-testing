// Cover a rectangle of the screen with an opaque window above normal windows, for a number of seconds, then quit.
// For R4 #87 (the app goes on behind a hidden window). No Dock icon, takes no focus.
// Usage: cover <x> <y> <w> <h> <seconds>    (Core Graphics' coordinates: origin top left of the main display)
import AppKit
let a = CommandLine.arguments.dropFirst().compactMap { Double($0) }
guard a.count == 5 else { print("usage: cover x y w h seconds"); exit(2) }
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let mainH = NSScreen.screens.first?.frame.height ?? 0
let rect = NSRect(x: a[0], y: mainH - a[1] - a[3], width: a[2], height: a[3])
let win = NSWindow(contentRect: rect, styleMask: [.borderless], backing: .buffered, defer: false)
win.level = .floating
win.isOpaque = true
win.backgroundColor = NSColor(calibratedWhite: 0.12, alpha: 1)
win.ignoresMouseEvents = true
win.collectionBehavior = [.canJoinAllSpaces, .stationary]
let label = NSTextField(labelWithString: "JETCARP rc.4 test #87: covering the app's window for \(Int(a[4])) s")
label.textColor = .lightGray
label.font = .systemFont(ofSize: 18)
label.frame = NSRect(x: 20, y: rect.height / 2, width: rect.width - 40, height: 30)
win.contentView?.addSubview(label)
win.orderFrontRegardless()
DispatchQueue.main.asyncAfter(deadline: .now() + a[4]) { app.terminate(nil) }
print("covering \(Int(a[0])),\(Int(a[1])) \(Int(a[2]))x\(Int(a[3])) for \(a[4]) s"); fflush(stdout)
app.run()
