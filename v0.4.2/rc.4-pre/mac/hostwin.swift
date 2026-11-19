// Print every window of a process, at any level (the host's wallpaper sits at the desktop level):
// "<window id> <layer> <width>x<height> <on screen 0/1>", largest first.
// Usage: hostwin <pid>
import CoreGraphics
import Foundation
let pid = Int(CommandLine.arguments[1]) ?? -1
let info = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] ?? []
var rows: [(Int, Int, Int, Int, Int)] = []
for w in info where (w[kCGWindowOwnerPID as String] as? Int) == pid {
    let b = w[kCGWindowBounds as String] as? [String: Any] ?? [:]
    let wd = (b["Width"] as? NSNumber)?.intValue ?? 0, ht = (b["Height"] as? NSNumber)?.intValue ?? 0
    let on = (w[kCGWindowIsOnscreen as String] as? Bool) == true ? 1 : 0
    rows.append((w[kCGWindowNumber as String] as? Int ?? 0, w[kCGWindowLayer as String] as? Int ?? 0, wd, ht, on))
}
for r in rows.sorted(by: { $0.2 * $0.3 > $1.2 * $1.3 }) { print("\(r.0) \(r.1) \(r.2)x\(r.3) \(r.4)") }
