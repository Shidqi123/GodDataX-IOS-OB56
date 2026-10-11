import SwiftUI
import CoreText

public enum AppFont {
    public static func registerFonts() {
        let fonts = [
            "Rajdhani-Bold",
            "Rajdhani-SemiBold",
            "Rajdhani-Medium",
            "Rajdhani-Regular"
        ]
        
        for fontName in fonts {
            var foundUrl: URL? = Bundle.main.url(forResource: fontName, withExtension: "ttf")
            if foundUrl == nil {
                foundUrl = Bundle.main.url(forResource: fontName, withExtension: "ttf", subdirectory: "Fonts")
            }
            
            if let url = foundUrl {
                var error: Unmanaged<CFError>?
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            }
        }
    }
}

extension Font {
    public static func rajdhani(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        switch weight {
        case .bold, .heavy, .black:
            fontName = "Rajdhani-Bold"
        case .semibold:
            fontName = "Rajdhani-SemiBold"
        case .medium:
            fontName = "Rajdhani-Medium"
        default:
            fontName = "Rajdhani-Regular"
        }
        
        if UIFont(name: fontName, size: size) != nil {
            return Font.custom(fontName, size: size)
        }
        return Font.system(size: size, weight: weight, design: .rounded)
    }
}
