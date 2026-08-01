import XCTest
@testable import MarstekCore

final class AppLogicTests: XCTestCase {
    private let savedStation = "saved-station"
    private let otherStation = "other-station"
    private let replacementStation = "replacement-station"

    func testSetResultRequiresExplicitSuccess() {
        XCTAssertTrue(MarstekAppLogic.setResultSucceeded(response: ["result": ["set_result": 1]]))
        XCTAssertFalse(MarstekAppLogic.setResultSucceeded(response: ["result": ["set_result": 0]]))
        XCTAssertFalse(MarstekAppLogic.setResultSucceeded(response: ["result": [:]]))
        XCTAssertFalse(MarstekAppLogic.setResultSucceeded(response: ["error": ["code": -1], "result": ["set_result": 1]]))
        XCTAssertFalse(MarstekAppLogic.setResultSucceeded(response: nil))
    }

    func testSavedStationWinsWhenSeveralStationsRespond() {
        XCTAssertEqual(
            MarstekAppLogic.selectedHost(
                discoveredHosts: [otherStation, savedStation],
                savedHost: savedStation
            ),
            savedStation
        )
    }

    func testSingleStationCanReplaceAnOldAddress() {
        XCTAssertEqual(
            MarstekAppLogic.selectedHost(
                discoveredHosts: [replacementStation],
                savedHost: savedStation
            ),
            replacementStation
        )
    }

    func testSeveralUnknownStationsRequireUserSelection() {
        XCTAssertNil(
            MarstekAppLogic.selectedHost(
                discoveredHosts: [savedStation, otherStation],
                savedHost: ""
            )
        )
    }

    func testSavedAddressIsOnlyFallbackWhenDiscoveryIsEmpty() {
        XCTAssertEqual(
            MarstekAppLogic.selectedHost(discoveredHosts: [], savedHost: savedStation),
            savedStation
        )
    }

    func testUnknownModeDoesNotDefaultToAuto() {
        XCTAssertNil(MarstekAppLogic.canonicalMode(nil))
        XCTAssertNil(MarstekAppLogic.canonicalMode("—"))
        XCTAssertNil(MarstekAppLogic.canonicalMode("Passive"))
        XCTAssertEqual(MarstekAppLogic.canonicalMode("manual"), "Manual")
    }
}
