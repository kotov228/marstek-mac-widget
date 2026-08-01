import Foundation

public enum MarstekAppLogic {
    public static let supportedModes = ["Auto", "AI", "Manual", "UPS"]

    public static func canonicalMode(_ value: String?) -> String? {
        guard let value else { return nil }
        return supportedModes.first { $0.caseInsensitiveCompare(value) == .orderedSame }
    }

    public static func effectiveMode(
        reportedMode: String?,
        lastKnownMode: String?,
        acknowledgedMode: String? = nil
    ) -> String? {
        let effectiveReported = canonicalMode(reportedMode) ?? canonicalMode(lastKnownMode)
        let acknowledged = canonicalMode(acknowledgedMode)
        if effectiveReported == "UPS", acknowledged == "Manual" {
            return "Manual"
        }
        return effectiveReported
    }

    public static func storedMode(
        savedMode: String?,
        savedModeHost: String?,
        selectedHost: String
    ) -> String? {
        guard !selectedHost.isEmpty else { return nil }
        if let savedModeHost, !savedModeHost.isEmpty, savedModeHost != selectedHost {
            return nil
        }
        return canonicalMode(savedMode)
    }

    public static func signedPower(_ watts: Int) -> String {
        if watts > 0 { return "+\(watts) W" }
        if watts < 0 { return "−\(abs(watts)) W" }
        return "0 W"
    }

    public static func selectedHost(discoveredHosts: [String], savedHost: String) -> String? {
        let uniqueHosts = discoveredHosts.reduce(into: [String]()) { result, host in
            guard !host.isEmpty, !result.contains(host) else { return }
            result.append(host)
        }
        if !savedHost.isEmpty, uniqueHosts.contains(savedHost) { return savedHost }
        if uniqueHosts.count == 1 { return uniqueHosts[0] }
        if uniqueHosts.isEmpty, !savedHost.isEmpty { return savedHost }
        return nil
    }

    public static func responseIDMatches(response: [String: Any]?, expectedID: Int) -> Bool {
        guard let responseID = response?["id"] else { return false }
        if let value = responseID as? Int { return value == expectedID }
        if let value = responseID as? NSNumber {
            return value.compare(NSNumber(value: expectedID)) == .orderedSame
        }
        return false
    }

    public static func normalizedSigned16(_ value: Double?) -> Double? {
        guard let value else { return nil }
        guard (32768...65535).contains(value) else { return value }
        return value - 65536
    }

    public static func storedManualPower(_ value: NSNumber?, defaultValue: Int = 1000) -> Int {
        value?.intValue ?? defaultValue
    }

    public static func setResultSucceeded(response: [String: Any]?) -> Bool {
        guard let response, response["error"] == nil,
              let result = response["result"] as? [String: Any] else { return false }
        if let value = result["set_result"] as? NSNumber { return value.intValue == 1 }
        if let value = result["set_result"] as? Int { return value == 1 }
        return false
    }
}
