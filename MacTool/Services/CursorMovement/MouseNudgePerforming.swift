import AppKit
import CoreGraphics
import Foundation

/// Seam for posting a tiny cursor nudge. Swap in fakes for tests.
protocol MouseNudgePerforming: AnyObject {
    /// Moves the pointer by ±1px then restores position when possible.
    func performOnePixelNudge()
}

/// Posts a synthetic 1px mouse move via `CGEvent` (public Quartz Events API).
///
/// **TCC / entitlements**
/// - Requires the process to be trusted for **Accessibility** so synthetic HID
///   events are accepted system-wide (required for posting mouse events).
/// - Does **not** use private APIs.
/// - Sandboxed App Store builds typically cannot post synthetic input that
///   affects other apps; distribute outside the sandbox (Developer ID) or
///   document the limitation. See `docs/architecture.md`.
final class CGEventMouseNudger: MouseNudgePerforming {
    func performOnePixelNudge() {
        let current = NSEvent.mouseLocation
        // AppKit y is flipped relative to Quartz screen coordinates.
        guard let screenHeight = NSScreen.main?.frame.height else { return }
        let quartzY = screenHeight - current.y
        let origin = CGPoint(x: current.x, y: quartzY)
        let nudged = CGPoint(x: origin.x + 1, y: origin.y)

        postMouseMoved(to: nudged)
        postMouseMoved(to: origin)
    }

    private func postMouseMoved(to point: CGPoint) {
        guard let event = CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: point,
            mouseButton: .left
        ) else {
            return
        }
        event.post(tap: .cghidEventTap)
    }
}
