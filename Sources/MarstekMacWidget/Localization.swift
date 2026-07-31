import Foundation

func L(_ key: String) -> String {
    let languageCode = language().rawValue
    if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
       let bundle = Bundle(path: path) {
        return bundle.localizedString(forKey: key, value: nil, table: "Localizable")
    }
    return key
}

struct GitHubRelease: Decodable {
    let tagName: String
    let assets: [GitHubReleaseAsset]

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case assets
    }
}

struct GitHubReleaseAsset: Decodable {
    let name: String
    let downloadURL: URL

    enum CodingKeys: String, CodingKey {
        case name
        case downloadURL = "browser_download_url"
    }
}

func appVersion() -> String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
}

func versionComponents(_ value: String) -> [Int] {
    value
        .trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
        .split(separator: ".")
        .map { Int($0.filter(\.isNumber)) ?? 0 }
}

func isVersion(_ candidate: String, newerThan current: String) -> Bool {
    let candidateParts = versionComponents(candidate)
    let currentParts = versionComponents(current)
    let count = max(candidateParts.count, currentParts.count)
    for index in 0..<count {
        let candidatePart = index < candidateParts.count ? candidateParts[index] : 0
        let currentPart = index < currentParts.count ? currentParts[index] : 0
        if candidatePart != currentPart { return candidatePart > currentPart }
    }
    return false
}
