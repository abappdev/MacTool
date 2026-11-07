import XCTest
@testable import MacTool

final class CursorMovementProgressTests: XCTestCase {
    func testCycleProgressTracksDuration() {
        let start = Date(timeIntervalSince1970: 1_000)
        XCTAssertEqual(
            CursorMovementService.cycleProgress(startedAt: start, duration: 30, now: start)!,
            0,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            CursorMovementService.cycleProgress(
                startedAt: start,
                duration: 30,
                now: start.addingTimeInterval(15)
            )!,
            0.5,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            CursorMovementService.cycleProgress(
                startedAt: start,
                duration: 30,
                now: start.addingTimeInterval(30)
            )!,
            1.0,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            CursorMovementService.cycleProgress(
                startedAt: start,
                duration: 30,
                now: start.addingTimeInterval(45)
            )!,
            1.0,
            accuracy: 0.0001
        )
    }

    func testCycleProgressNilForInvalidDuration() {
        XCTAssertNil(
            CursorMovementService.cycleProgress(
                startedAt: Date(),
                duration: 0,
                now: Date()
            )
        )
    }
}
