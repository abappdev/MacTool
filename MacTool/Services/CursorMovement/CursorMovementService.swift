import Foundation

/// Schedules periodic 1px synthetic mouse nudges on a chosen interval.
@MainActor
final class CursorMovementService: ObservableObject {
    @Published private(set) var interval: CursorMovementInterval

    private let settings: SettingsStoring
    private let nudger: MouseNudgePerforming
    private var timer: Timer?

    init(
        settings: SettingsStoring,
        nudger: MouseNudgePerforming = CGEventMouseNudger()
    ) {
        self.settings = settings
        self.nudger = nudger
        let raw = settings.cursorMovementIntervalRaw
        self.interval = CursorMovementInterval(rawValue: raw) ?? .off
        apply(interval: self.interval, persist: false)
    }

    func setInterval(_ newValue: CursorMovementInterval) {
        apply(interval: newValue, persist: true)
    }

    func stop() {
        apply(interval: .off, persist: true)
    }

    /// Call from app termination to cancel the timer without rewriting preferences.
    func cancelScheduling() {
        timer?.invalidate()
        timer = nil
    }

    private func apply(interval newValue: CursorMovementInterval, persist: Bool) {
        timer?.invalidate()
        timer = nil
        interval = newValue

        if persist {
            settings.cursorMovementIntervalRaw = newValue.rawValue
        }

        guard let period = newValue.timeInterval else { return }

        let timer = Timer(timeInterval: period, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.nudger.performOnePixelNudge()
            }
        }
        timer.tolerance = min(1.0, period * 0.1)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
}
