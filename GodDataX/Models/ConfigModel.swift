import SwiftUI

struct AppConfig {
    static let appName = "GodDataX iOS"
    static let appVersion = "2.2.1 (Build 221)"
    static let targetOBVersion = "OB56"
    static let developer = "Kutoo"
    static let minIOS = "15.0"
    static let supportedVersions = "iOS 15.0 - 18.x"
    
    // Bundle IDs for App Store lookup
    static let ffBundleId = "com.dts.freefireth"
    static let ffMaxBundleId = "com.dts.freefiremax"
    
    // URL Schemes to launch games directly
    static let ffScheme = "freefire://"
    static let ffMaxScheme = "freefiremax://"
    
    // Official iTunes lookup URLs for real-time icon fetching
    static let ffLookupURL = "https://itunes.apple.com/lookup?bundleId=com.dts.freefireth&country=id"
    static let ffMaxLookupURL = "https://itunes.apple.com/lookup?bundleId=com.dts.freefiremax&country=id"
}

struct FeatureItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    var isEnabled: Bool
    let tag: String
}
