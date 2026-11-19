// One line of what macOS reports about the displays and the session, for #95:
// CGDisplayIsAsleep / CGDisplayIsActive for every online display, and CGSessionCopyCurrentDictionary's
// CGSSessionScreenIsLocked (what the host's locked() reads).
import CoreGraphics
import Foundation
var ids = [CGDirectDisplayID](repeating: 0, count: 16); var n: UInt32 = 0
CGGetOnlineDisplayList(16, &ids, &n)
let disp = (0..<Int(n)).map { "d\(ids[$0]) asleep=\(CGDisplayIsAsleep(ids[$0])) active=\(CGDisplayIsActive(ids[$0]))" }.joined(separator: " ")
var cg = "nil"
if let d = CGSessionCopyCurrentDictionary() as? [String: Any] { cg = "\(d["CGSSessionScreenIsLocked"] ?? "absent")" }
print("\(disp) | CGSession locked=\(cg)")
