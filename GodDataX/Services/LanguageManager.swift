import SwiftUI

public enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case indonesian = "id"
    case english = "en"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .system: return "System Default"
        case .indonesian: return "Bahasa Indonesia"
        case .english: return "English"
        }
    }
}

public class LanguageManager: ObservableObject {
    public static let shared = LanguageManager()
    
    @AppStorage("goddatax_app_language") public var currentLanguageRaw: String = AppLanguage.system.rawValue {
        didSet {
            objectWillChange.send()
        }
    }
    
    public var currentLanguage: AppLanguage {
        get {
            AppLanguage(rawValue: currentLanguageRaw) ?? .system
        }
        set {
            currentLanguageRaw = newValue.rawValue
        }
    }
    
    public var isEnglish: Bool {
        return currentLanguage == .english
    }
    
    public func setLanguage(_ lang: AppLanguage) {
        currentLanguage = lang
        objectWillChange.send()
    }
    
    public func text(id: String, en: String) -> String {
        return isEnglish ? en : id
    }
}
