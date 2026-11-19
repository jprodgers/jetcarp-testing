// Compare two images pixel by pixel: how many pixels differ, and the box round them (x, y from the top left).
// Usage: imgdiff a.png b.png
import CoreGraphics
import Foundation
import ImageIO
func load(_ p: String) -> (Int, Int, [UInt8]) {
    let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: p) as CFURL, nil)!
    let img = CGImageSourceCreateImageAtIndex(src, 0, nil)!
    let w = img.width, h = img.height
    var buf = [UInt8](repeating: 0, count: w * h * 4)
    let ctx = CGContext(data: &buf, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                        space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
    return (w, h, buf)
}
let (w, h, a) = load(CommandLine.arguments[1]); let (w2, h2, b) = load(CommandLine.arguments[2])
guard w == w2 && h == h2 else { print("sizes differ: \(w)x\(h) and \(w2)x\(h2)"); exit(1) }
var n = 0, x0 = w, y0 = h, x1 = -1, y1 = -1
for y in 0..<h { for x in 0..<w {
    let i = (y * w + x) * 4
    if a[i] != b[i] || a[i+1] != b[i+1] || a[i+2] != b[i+2] { n += 1; x0 = min(x0, x); x1 = max(x1, x); y0 = min(y0, y); y1 = max(y1, y) }
} }
print(n == 0 ? "identical pixels (\(w)x\(h))" : "\(n) pixels differ, in the box x \(x0)-\(x1), y \(y0)-\(y1) of \(w)x\(h)")
