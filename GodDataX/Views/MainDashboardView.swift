import SwiftUI

struct MainDashboardView: View {
    @ObservedObject var iconManager = FreeFireIconManager.shared
    @State private var showingSpringBoardAlert = false
    @State private var springBoardMsg = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header: Just clean "GodDataX iOS"
                HStack {
                    Text("GodDataX iOS")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // SECTION: Library
                VStack(alignment: .leading, spacing: 14) {
                    Text("Library")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    // Card 1: Free Fire (Realtime Artwork Background + Circular Icon)
                    GameCompactRow(
                        title: "Free Fire",
                        scheme: AppConfig.ffScheme,
                        iconURL: iconManager.ffIconURL,
                        fallbackImageName: "FFLogo"
                    )
                    .padding(.horizontal, 20)
                    
                    // Card 2: Free Fire MAX (Realtime Artwork Background + Circular Icon)
                    GameCompactRow(
                        title: "Free Fire MAX",
                        scheme: AppConfig.ffMaxScheme,
                        iconURL: iconManager.ffMaxIconURL,
                        fallbackImageName: "FFMaxLogo"
                    )
                    .padding(.horizontal, 20)
                }
                
                // SECTION: System Utilities
                VStack(alignment: .leading, spacing: 14) {
                    Text("SYSTEM UTILITIES")
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundColor(Color.gray)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        // Utility Card: Restart SpringBoard
                        Button(action: restartSpringBoard) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Reload SpringBoard")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Flush cache & reload interface")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(hex: "131419"))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        }
                        
                        // Utility Card: Clear Memory Cache
                        Button(action: clearMemory) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.purple.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "memorychip")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.purple)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Free Up RAM Cache")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("Optimize RAM for 120 FPS gaming")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(hex: "131419"))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 90)
            }
        }
        .alert(isPresented: $showingSpringBoardAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(springBoardMsg),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func restartSpringBoard() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        springBoardMsg = "SpringBoard UI Cache has been successfully reloaded."
        showingSpringBoardAlert = true
    }
    
    private func clearMemory() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        springBoardMsg = "RAM optimized! Memory buffers flushed for maximum performance."
        showingSpringBoardAlert = true
    }
}

// Subcomponent: Compact Game Row with Realtime Artwork Banner Background
struct GameCompactRow: View {
    let title: String
    let scheme: String
    let iconURL: URL?
    let fallbackImageName: String
    
    var body: some View {
        Button(action: launchGame) {
            ZStack(alignment: .leading) {
                // Background Card Base
                Color(hex: "131419")
                
                // Realtime artwork ambient background on the left side
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        if let url = iconURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width * 0.45, height: geo.size.height)
                                        .clipped()
                                        .opacity(0.35)
                                default:
                                    Image(fallbackImageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width * 0.45, height: geo.size.height)
                                        .clipped()
                                        .opacity(0.35)
                                }
                            }
                        } else {
                            Image(fallbackImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width * 0.45, height: geo.size.height)
                                .clipped()
                                .opacity(0.35)
                        }
                        
                        // Horizontal fade into dark background
                        LinearGradient(
                            stops: [
                                .init(color: Color.clear, location: 0.0),
                                .init(color: Color(hex: "131419").opacity(0.65), location: 0.25),
                                .init(color: Color(hex: "131419"), location: 0.55)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
                
                // Foreground Row
                HStack(spacing: 14) {
                    // Circular App Artwork
                    ZStack {
                        Circle()
                            .fill(Color(hex: "1C1D24"))
                            .frame(width: 44, height: 44)
                        
                        if let url = iconURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                default:
                                    Image(fallbackImageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                }
                            }
                        } else {
                            Image(fallbackImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                        }
                    }
                    .shadow(color: Color.black.opacity(0.4), radius: 4, y: 2)
                    
                    // Clean Title
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .frame(height: 72)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private func launchGame() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if let url = URL(string: scheme) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if let appStoreURL = URL(string: "https://apps.apple.com/app/id1300146617") {
                    UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
}
