import XCTest
@testable import MarstekCore

final class AppLogicTests: XCTestCase {
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
                discoveredHosts: ["192.168.0.166", "192.168.0.165"],
                savedHost: "192.168.0.165"
            ),
            "192.168.0.165"
        )
    }

    func testSingleStationCanReplaceAnOldAddress() {
        XCTAssertEqual(
            MarstekAppLogic.selectedHost(
                discoveredHosts: ["192.168.0.200"],
                savedHost: "192.168.0.165"
            ),
            "192.168.0.200"
        )
    }

    func testSeveralUnknownStationsRequireUserSelection() {
        XCTAssertNil(
            MarstekAppLogic.selectedHost(
                discoveredHosts: ["192.168.0.165", "192.168.0.166"],
                savedHost: ""
            )
        )
    }

    func testSavedAddressIsOnlyFallbackWhenDiscoveryIsEmpty() {
        XCTAssertEqual(
            MarstekAppLogic.selectedHost(discoveredHosts: [], savedHost: "192.168.0.165"),
            "192.168.0.165"
        )
    }

    func testUnknownModeDoesNotDefaultToAuto() {
        XCTAssertNil(MarstekAppLogic.canonicalMode(nil))
        XCTAssertNil(MarstekAppLogic.canonicalMode("—"))
        XCTAssertNil(MarstekAppLogic.canonicalMode("Passive"))
        XCTAssertEqual(MarstekAppLogic.canonicalMode("manual"), "Manual")
    }
}
