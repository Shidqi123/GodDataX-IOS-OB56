import SwiftUI

@main
struct GodDataXApp: App {
    init() {
        AppFont.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
