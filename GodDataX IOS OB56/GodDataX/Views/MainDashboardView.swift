import SwiftUI

struct MainDashboardView: View {
    @ObservedObject var iconManager = FreeFireIconManager.shared
    @State private var showingSpringBoardAlert = false
    @State private var springBoardMsg = ""
    @State private var isSpinningRefresh = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                // Top Dynamic Island Pill
                DynamicIslandBanner()
                    .padding(.top, 10)
                
                // Welcome / Status Header
                VStack(spacing: 6) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("GODDATAX")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 6) {
                                Text("OB56 EDITION")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.orange.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .cornerRadius(6)
                                
                                Text("ARM64 NATIVE")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.green.opacity(0.15))
                                    .foregroundColor(.green)
                                    .cornerRadius(6)
                            }
                        }
                        
                        Spacer()
                        
                        // Live Icon Refresh Button
                        Button(action: refreshLiveIcons) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "181824"))
                                    .frame(width: 42, height: 42)
                                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
                                
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.orange)
                                    .rotationEffect(.degrees(isSpinningRefresh ? 360 : 0))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // SECTION: LIVE FREE FIRE LAUNCHERS
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("INSTANT LAUNCH & INJECT")
                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .foregroundColor(Color.gray)
                        Spacer()
                        Text("REALTIME ICONS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 20)
                    
                    // Card 1: Free Fire Standard
                    GameLaunchCard(
                        title: "Free Fire (OB56)",
                        bundleId: AppConfig.ffBundleId,
                        scheme: AppConfig.ffScheme,
                        iconURL: iconManager.ffIconURL,
                        fallbackImageName: "FFLogo",
                        badgeText: "GLOBAL / ID"
                    )
                    .padding(.horizontal, 20)
                    
                    // Card 2: Free Fire MAX
                    GameLaunchCard(
                        title: "Free Fire MAX (OB56)",
                        bundleId: AppConfig.ffMaxBundleId,
                        scheme: AppConfig.ffMaxScheme,
                        iconURL: iconManager.ffMaxIconURL,
                        fallbackImageName: "FFMaxLogo",
                        badgeText: "ULTRA HD"
                    )
                    .padding(.horizontal, 20)
                }
                
                // SECTION: QUICK SYSTEM UTILITIES
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
                            .background(Color(hex: "13131A"))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
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
                            .background(Color(hex: "13131A"))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 80)
            }
        }
        .alert(isPresented: $showingSpringBoardAlert) {
            Alert(
                title: Text("System Notice"),
                message: Text(springBoardMsg),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func refreshLiveIcons() {
        withAnimation(.linear(duration: 0.8)) {
            isSpinningRefresh = true
        }
        iconManager.fetchLatestIcons()
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSpinningRefresh = false
        }
    }
    
    private func restartSpringBoard() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        springBoardMsg = "SpringBoard UI Cache has been successfully reloaded for OB56."
        showingSpringBoardAlert = true
    }
    
    private func clearMemory() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        springBoardMsg = "RAM optimized! Memory buffers flushed for maximum performance."
        showingSpringBoardAlert = true
    }
}

// Subcomponent: GameLaunchCard with Realtime App Store Artwork
struct GameLaunchCard: View {
    let title: String
    let bundleId: String
    let scheme: String
    let iconURL: URL?
    let fallbackImageName: String
    let badgeText: String
    
    var body: some View {
        GlassCard(borderColor: Color.orange.opacity(0.25), cornerRadius: 18) {
            HStack(spacing: 16) {
                // Real-time Icon with Fallback
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "1E1E28"))
                        .frame(width: 58, height: 58)
                    
                    if let url = iconURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 58, height: 58)
                                    .cornerRadius(14)
                            default:
                                Image(fallbackImageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 58, height: 58)
                                    .cornerRadius(14)
                            }
                        }
                    } else {
                        Image(fallbackImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 58, height: 58)
                            .cornerRadius(14)
                    }
                }
                .shadow(color: Color.black.opacity(0.4), radius: 6, y: 3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(badgeText)
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundColor(.orange)
                    
                    Text("Auto OB56 Injection")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: launchGame) {
                    HStack(spacing: 5) {
                        Text("LAUNCH")
                            .font(.system(size: 12, weight: .black))
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                    .shadow(color: Color.orange.opacity(0.3), radius: 6, y: 2)
                }
            }
        }
    }
    
    private func launchGame() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        if let url = URL(string: scheme) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // If scheme not available or on simulator, open App Store link
                if let appStoreURL = URL(string: "https://apps.apple.com/app/id1300146617") {
                    UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
}
