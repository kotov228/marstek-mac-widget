import Foundation

func L(_ key: String) -> String {
    let languageCode = language().rawValue
    if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
       let bundle = Bundle(path: path) {
        return bundle.localizedString(forKey: key, value: nil, table: "Localizable")
    }
    return key
}
