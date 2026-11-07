import XCTest
@testable import MacTool

final class CursorMovementIntervalTests: XCTestCase {
    func testOffHasNoTimeInterval() {
        XCTAssertNil(CursorMovementInterval.off.timeInterval)
        XCTAssertFalse(CursorMovementInterval.off.isActive)
    }

    func testActiveIntervalsMatchTitlesAndDurations() {
        XCTAssertEqual(CursorMovementInterval.every30Seconds.timeInterval, 30)
        XCTAssertEqual(CursorMovementInterval.every1Minute.timeInterval, 60)
        XCTAssertEqual(CursorMovementInterval.every2Minutes.timeInterval, 120)
        XCTAssertEqual(CursorMovementInterval.every5Minutes.timeInterval, 300)
        XCTAssertEqual(CursorMovementInterval.every10Minutes.timeInterval, 600)

        XCTAssertEqual(CursorMovementInterval.every30Seconds.title, "Every 30 sec")
        XCTAssertEqual(CursorMovementInterval.off.title, "Off")
    }

    func testAllCasesCount() {
        XCTAssertEqual(CursorMovementInterval.allCases.count, 6)
    }
}

final class SettingsStoreTests: XCTestCase {
    func testPersistsIntervalRawValue() {
        let suite = "MacToolTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = UserDefaultsSettingsStore(defaults: defaults)
        XCTAssertEqual(store.cursorMovementIntervalRaw, CursorMovementInterval.off.rawValue)

        store.cursorMovementIntervalRaw = CursorMovementInterval.every2Minutes.rawValue
        XCTAssertEqual(store.cursorMovementIntervalRaw, "every2Minutes")
    }
}
