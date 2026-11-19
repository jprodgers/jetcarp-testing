// The largest normal-level (layer 0) window of a process: "<x> <y> <w> <h> <on screen 0/1>" in screen points,
// origin at the top left of the main display (Core Graphics' coordinates). Nothing printed if it has none.
// Usage: winframe <pid>
import CoreGraphics
import Foundation
let pid = Int(CommandLine.arguments[1]) ?? -1
let info = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] ?? []
var best: (Int, Int, Int, Int, Int)? = nil
for w in info where (w[kCGWindowOwnerPID as String] as? Int) == pid && (w[kCGWindowLayer as String] as? Int) == 0 {
    let b = w[kCGWindowBounds as String] as? [String: Any] ?? [:]
    let v = { (k: String) in (b[k] as? NSNumber)?.intValue ?? 0 }
    let on = (w[kCGWindowIsOnscreen as String] as? Bool) == true ? 1 : 0
    let r = (v("X"), v("Y"), v("Width"), v("Height"), on)
    if r.2 * r.3 > (best.map { $0.2 * $0.3 } ?? 0) { best = r }
}
if let b = best { print("\(b.0) \(b.1) \(b.2) \(b.3) \(b.4)") }
