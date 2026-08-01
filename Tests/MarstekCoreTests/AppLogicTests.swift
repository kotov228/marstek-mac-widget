import Foundation
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

    func testReportedModeAlwaysWinsOverLastKnownMode() {
        XCTAssertEqual(
            MarstekAppLogic.effectiveMode(reportedMode: "UPS", lastKnownMode: "Manual"),
            "UPS"
        )
    }

    func testLastKnownModeSurvivesAnEmptyModeResponse() {
        XCTAssertEqual(
            MarstekAppLogic.effectiveMode(reportedMode: nil, lastKnownMode: "Auto"),
            "Auto"
        )
        XCTAssertNil(MarstekAppLogic.effectiveMode(reportedMode: nil, lastKnownMode: nil))
    }

    func testStoredModeMigratesLegacyValueToSelectedHost() {
        XCTAssertEqual(
            MarstekAppLogic.storedMode(
                savedMode: "UPS",
                savedModeHost: nil,
                selectedHost: savedStation
            ),
            "UPS"
        )
    }

    func testStoredModeRejectsValueFromAnotherHost() {
        XCTAssertNil(
            MarstekAppLogic.storedMode(
                savedMode: "UPS",
                savedModeHost: otherStation,
                selectedHost: savedStation
            )
        )
    }

    func testAcknowledgedManualHandlesFirmwareUPSReport() {
        XCTAssertEqual(
            MarstekAppLogic.effectiveMode(
                reportedMode: "UPS",
                lastKnownMode: "UPS",
                acknowledgedMode: "Manual"
            ),
            "Manual"
        )
        XCTAssertEqual(
            MarstekAppLogic.effectiveMode(
                reportedMode: nil,
                lastKnownMode: "UPS",
                acknowledgedMode: "Manual"
            ),
            "Manual"
        )
    }

    func testOtherAcknowledgedModesNeverMaskReportedUPS() {
        XCTAssertEqual(
            MarstekAppLogic.effectiveMode(
                reportedMode: "UPS",
                lastKnownMode: "Auto",
                acknowledgedMode: "Auto"
            ),
            "UPS"
        )
    }

    func testManualPowerUsesAnExplicitSign() {
        XCTAssertEqual(MarstekAppLogic.signedPower(1500), "+1500 W")
        XCTAssertEqual(MarstekAppLogic.signedPower(-1500), "−1500 W")
        XCTAssertEqual(MarstekAppLogic.signedPower(0), "0 W")
    }

    func testResponseIDMatchesSwiftIntAndNSNumber() {
        XCTAssertTrue(MarstekAppLogic.responseIDMatches(response: ["id": 42], expectedID: 42))
        XCTAssertTrue(
            MarstekAppLogic.responseIDMatches(
                response: ["id": NSNumber(value: 42)],
                expectedID: 42
            )
        )
    }

    func testResponseIDRejectsMissingNilAndMismatchedIDs() {
        XCTAssertFalse(MarstekAppLogic.responseIDMatches(response: nil, expectedID: 42))
        XCTAssertFalse(MarstekAppLogic.responseIDMatches(response: [:], expectedID: 42))
        XCTAssertFalse(MarstekAppLogic.responseIDMatches(response: ["id": 41], expectedID: 42))
        XCTAssertFalse(
            MarstekAppLogic.responseIDMatches(
                response: ["id": NSNumber(value: 43)],
                expectedID: 42
            )
        )
        XCTAssertFalse(MarstekAppLogic.responseIDMatches(response: ["id": "42"], expectedID: 42))
    }

    func testNormalizedSigned16ConvertsUnsignedHighBitValues() {
        XCTAssertEqual(MarstekAppLogic.normalizedSigned16(32768), -32768)
        XCTAssertEqual(MarstekAppLogic.normalizedSigned16(32769), -32767)
        XCTAssertEqual(MarstekAppLogic.normalizedSigned16(65534), -2)
        XCTAssertEqual(MarstekAppLogic.normalizedSigned16(65535), -1)
    }

    func testNormalizedSigned16PreservesOtherValues() {
        XCTAssertNil(MarstekAppLogic.normalizedSigned16(nil))
        XCTAssertEqual(MarstekAppLogic.normalizedSigned16(-32768), -32768)
        XCTAssertEqual(MarstekAppLogic.normalizedSigned16(-1), -1)
        XCTAssertEqual(MarstekAppLogic.normalizedSigned16(0), 0)
        XCTAssertEqual(MarstekAppLogic.normalizedSigned16(32767), 32767)
        XCTAssertEqual(MarstekAppLogic.normalizedSigned16(65536), 65536)
        XCTAssertEqual(MarstekAppLogic.normalizedSigned16(100_000), 100_000)
    }

    func testStoredManualPowerUsesDefaultOnlyForMissingValue() {
        XCTAssertEqual(MarstekAppLogic.storedManualPower(nil), 1000)
        XCTAssertEqual(MarstekAppLogic.storedManualPower(nil, defaultValue: 750), 750)
    }

    func testStoredManualPowerPreservesExplicitValuesIncludingZero() {
        XCTAssertEqual(MarstekAppLogic.storedManualPower(NSNumber(value: 0)), 0)
        XCTAssertEqual(MarstekAppLogic.storedManualPower(NSNumber(value: 2500)), 2500)
        XCTAssertEqual(MarstekAppLogic.storedManualPower(NSNumber(value: -2500)), -2500)
    }
}
