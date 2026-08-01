import Foundation

public enum MarstekAppLogic {
    public static let supportedModes = ["Auto", "AI", "Manual", "UPS"]

    public static func canonicalMode(_ value: String?) -> String? {
        guard let value else { return nil }
        return supportedModes.first { $0.caseInsensitiveCompare(value) == .orderedSame }
    }

    public static func effectiveMode(reportedMode: String?, lastKnownMode: String?) -> String? {
        canonicalMode(reportedMode) ?? canonicalMode(lastKnownMode)
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

    public static func setResultSucceeded(response: [String: Any]?) -> Bool {
        guard let response, response["error"] == nil,
              let result = response["result"] as? [String: Any] else { return false }
        if let value = result["set_result"] as? NSNumber { return value.intValue == 1 }
        if let value = result["set_result"] as? Int { return value == 1 }
        return false
    }
}
