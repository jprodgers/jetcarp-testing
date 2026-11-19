// Print the on-screen windows of a process: "<window id> <width>x<height> <title>", largest first.
// Usage: winlist <pid>
import CoreGraphics
import Foundation
let pid = Int(CommandLine.arguments[1]) ?? -1
let info = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] ?? []
var rows: [(Int, Int, Int, String)] = []
for w in info where (w[kCGWindowOwnerPID as String] as? Int) == pid && (w[kCGWindowLayer as String] as? Int) == 0 {
    let b = w[kCGWindowBounds as String] as? [String: Any] ?? [:]
    let wd = (b["Width"] as? NSNumber)?.intValue ?? 0, ht = (b["Height"] as? NSNumber)?.intValue ?? 0
    rows.append((w[kCGWindowNumber as String] as? Int ?? 0, wd, ht, w[kCGWindowName as String] as? String ?? ""))
}
for r in rows.sorted(by: { $0.1 * $0.2 > $1.1 * $1.2 }) { print("\(r.0) \(r.1)x\(r.2) \(r.3)") }
