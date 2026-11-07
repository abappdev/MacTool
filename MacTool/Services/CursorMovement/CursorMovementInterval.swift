import Foundation

/// Supported nudge intervals for the Cursor Movement feature.
enum CursorMovementInterval: String, CaseIterable, Identifiable, Codable {
    case off
    case every30Seconds
    case every1Minute
    case every2Minutes
    case every5Minutes
    case every10Minutes

    var id: String { rawValue }

    var title: String {
        switch self {
        case .off: return "Off"
        case .every30Seconds: return "Every 30 sec"
        case .every1Minute: return "1 min"
        case .every2Minutes: return "2 min"
        case .every5Minutes: return "5 min"
        case .every10Minutes: return "10 min"
        }
    }

    /// `nil` means the scheduler should be stopped.
    var timeInterval: TimeInterval? {
        switch self {
        case .off: return nil
        case .every30Seconds: return 30
        case .every1Minute: return 60
        case .every2Minutes: return 120
        case .every5Minutes: return 300
        case .every10Minutes: return 600
        }
    }

    var isActive: Bool { timeInterval != nil }
}
