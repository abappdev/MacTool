import Foundation

/// Schedules periodic 1px synthetic mouse nudges on a chosen interval.
@MainActor
final class CursorMovementService: ObservableObject {
    @Published private(set) var interval: CursorMovementInterval
    /// Start of the current countdown cycle (nil when Off).
    @Published private(set) var cycleStartedAt: Date?
    /// Length of the current cycle in seconds (nil when Off).
    @Published private(set) var cycleDuration: TimeInterval?

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
        cycleStartedAt = nil
        cycleDuration = nil
    }

    /// 0…1 progress through the current countdown at `date`. `nil` when Off.
    func progress(at date: Date = Date()) -> Double? {
        guard let start = cycleStartedAt, let duration = cycleDuration else { return nil }
        return Self.cycleProgress(startedAt: start, duration: duration, now: date)
    }

    /// Pure countdown math for tests and the tray ring.
    static func cycleProgress(startedAt: Date, duration: TimeInterval, now: Date) -> Double? {
        guard duration > 0 else { return nil }
        let elapsed = now.timeIntervalSince(startedAt)
        return min(1, max(0, elapsed / duration))
    }

    private func apply(interval newValue: CursorMovementInterval, persist: Bool) {
        timer?.invalidate()
        timer = nil
        interval = newValue

        if persist {
            settings.cursorMovementIntervalRaw = newValue.rawValue
        }

        guard let period = newValue.timeInterval else {
            cycleStartedAt = nil
            cycleDuration = nil
            return
        }

        cycleDuration = period
        cycleStartedAt = Date()

        let timer = Timer(timeInterval: period, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.fireCycle()
            }
        }
        timer.tolerance = min(1.0, period * 0.1)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func fireCycle() {
        nudger.performOnePixelNudge()
        // Restart the ring for the next interval.
        cycleStartedAt = Date()
    }
}
