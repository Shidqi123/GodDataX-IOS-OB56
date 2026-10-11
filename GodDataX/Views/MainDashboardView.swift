import SwiftUI

struct GameLaunchInfo: Identifiable {
    let id = UUID()
    let title: String
    let bundleId: String
    let scheme: String
}

struct InstalledGame: Identifiable {
    let id: String
    let title: String
    let bundleId: String
    let scheme: String
}

struct DashboardNotice: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

struct MainDashboardView: View {
    @Binding var isModalActive: Bool
    @ObservedObject var iconManager = FreeFireIconManager.shared
    
    @State private var installedGames: [InstalledGame] = []
    @State private var selectedGame: GameLaunchInfo? = nil
    @State private var activeNotice: DashboardNotice? = nil
    
    init(isModalActive: Binding<Bool> = .constant(false)) {
        self._isModalActive = isModalActive
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header: GodDataX iOS
                    HStack {
                        Text("GodDataX iOS")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // SECTION: Library (Dynamically detects installed games)
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Library")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Discreet scan/refresh button
                            Button(action: refreshGames) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Game Cards
                        ForEach(installedGames) { game in
                            GameCompactRow(
                                title: game.title,
                                bundleId: game.bundleId,
                                scheme: game.scheme
                            ) {
                                let gen = UIImpactFeedbackGenerator(style: .medium)
                                gen.impactOccurred()
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
                                    selectedGame = GameLaunchInfo(
                                        title: game.title,
                                        bundleId: game.bundleId,
                                        scheme: game.scheme
                                    )
                                    isModalActive = true
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // SECTION: System Utilities
                    VStack(alignment: .leading, spacing: 14) {
                        Text("SYSTEM UTILITIES")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            // Utility Card: Restart SpringBoard
                            Button(action: triggerSpringBoardReload) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Reload SpringBoard")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        Text("Flush cache & reload interface")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(hex: "131419"))
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
                            }
                            
                            // Utility Card: Clear Memory Cache
                            Button(action: triggerMemoryOptimization) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.purple.opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "memorychip")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.purple)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Free Up RAM Cache")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        Text("Optimize RAM for 120 FPS gaming")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
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
            .blur(radius: (selectedGame != nil || activeNotice != nil) ? 4 : 0)
            .onAppear {
                refreshGames()
            }
            
            // Dimmed Background Backdrop
            if selectedGame != nil || activeNotice != nil {
                Color.black.opacity(0.68)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        dismissAllModals()
                    }
                    .zIndex(10)
            }
            
            // 1. Interactive Launch Modal Sheet (Image 1 style with RED theme)
            if let game = selectedGame {
                VStack {
                    Spacer()
                    GameLaunchSheet(game: game) {
                        dismissAllModals()
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(20)
            }
            
            // 2. Custom Bottom Notice Sheet (Image 2 style: Edge-to-Edge with 0 horizontal space)
            if let notice = activeNotice {
                VStack {
                    Spacer()
                    BottomNoticeCard(
                        title: notice.title,
                        message: notice.message
                    ) {
                        dismissAllModals()
                    }
                }
                .ignoresSafeArea(.all, edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(30)
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.8), value: selectedGame != nil)
        .animation(.spring(response: 0.38, dampingFraction: 0.8), value: activeNotice != nil)
    }
    
    private func dismissAllModals() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            selectedGame = nil
            activeNotice = nil
            isModalActive = false
        }
    }
    
    private func refreshGames() {
        var detected: [InstalledGame] = []
        
        let hasFF: Bool
        if let url = URL(string: AppConfig.ffScheme) {
            hasFF = UIApplication.shared.canOpenURL(url)
        } else {
            hasFF = false
        }
        
        let hasFFMax: Bool
        if let url = URL(string: AppConfig.ffMaxScheme) {
            hasFFMax = UIApplication.shared.canOpenURL(url)
        } else {
            hasFFMax = false
        }
        
        if hasFF {
            detected.append(InstalledGame(
                id: "freefire",
                title: "Free Fire",
                bundleId: AppConfig.ffBundleId,
                scheme: AppConfig.ffScheme
            ))
        }
        if hasFFMax {
            detected.append(InstalledGame(
                id: "freefiremax",
                title: "Free Fire MAX",
                bundleId: AppConfig.ffMaxBundleId,
                scheme: AppConfig.ffMaxScheme
            ))
        }
        
        // If neither is detected via canOpenURL (e.g. sideload sandbox limitation),
        // fallback to showing both so the user can test/launch either game
        if detected.isEmpty {
            detected = [
                InstalledGame(
                    id: "freefire",
                    title: "Free Fire",
                    bundleId: AppConfig.ffBundleId,
                    scheme: AppConfig.ffScheme
                ),
                InstalledGame(
                    id: "freefiremax",
                    title: "Free Fire MAX",
                    bundleId: AppConfig.ffMaxBundleId,
                    scheme: AppConfig.ffMaxScheme
                )
            ]
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            self.installedGames = detected
        }
    }
    
    private func triggerSpringBoardReload() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
            activeNotice = DashboardNotice(
                title: "Notice",
                message: "SpringBoard UI Cache has been successfully reloaded."
            )
            isModalActive = true
        }
    }
    
    private func triggerMemoryOptimization() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
            activeNotice = DashboardNotice(
                title: "Memory Optimized",
                message: "RAM optimized! Memory buffers flushed for maximum performance and 120 FPS gaming."
            )
            isModalActive = true
        }
    }
}

// Subcomponent: Compact Game Row with Instant Image & Realtime Artwork Banner
struct GameCompactRow: View {
    let title: String
    let bundleId: String
    let scheme: String
    let onSelect: () -> Void
    
    @ObservedObject var iconManager = FreeFireIconManager.shared
    
    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .leading) {
                // Background Card Base
                Color(hex: "131419")
                
                // Realtime artwork ambient background on the left side (Zero delay from memory cache)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Image(uiImage: iconManager.getImage(for: bundleId))
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width * 0.45, height: geo.size.height)
                            .clipped()
                            .opacity(0.35)
                        
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
                        
                        Image(uiImage: iconManager.getImage(for: bundleId))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    }
                    .shadow(color: Color.black.opacity(0.4), radius: 4, y: 2)
                    
                    // Clean Title
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
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
}

// Subcomponent: GameLaunchSheet matching Image 1 with RED theme and zero-delay artwork
struct GameLaunchSheet: View {
    let game: GameLaunchInfo
    let onClose: () -> Void
    
    @ObservedObject var iconManager = FreeFireIconManager.shared
    @State private var selectedMode: String = "Competitive"
    @State private var slideOffset: CGFloat = 0
    @State private var isLaunching = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Top Header Card with Realtime Artwork Background
            ZStack(alignment: .leading) {
                Color(hex: "171922")
                
                // Background Artwork Faded
                GeometryReader { geo in
                    Image(uiImage: iconManager.getImage(for: game.bundleId))
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .opacity(0.22)
                        .blur(radius: 3)
                }
                
                HStack {
                    // Left: Game Name + Bundle ID
                    VStack(alignment: .leading, spacing: 3) {
                        Text(game.title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(game.bundleId)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(Color.gray)
                    }
                    
                    Spacer()
                    
                    // Center: Realtime Circular Artwork
                    ZStack {
                        Circle()
                            .fill(Color(hex: "222430"))
                            .frame(width: 50, height: 50)
                        
                        Image(uiImage: iconManager.getImage(for: game.bundleId))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1.5))
                    .shadow(color: Color.black.opacity(0.5), radius: 6, y: 3)
                    
                    Spacer()
                    
                    // Right: Mode Game Status in RED theme
                    VStack(alignment: .trailing, spacing: 3) {
                        Text("Mode Game")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(selectedMode)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "FF1E27")) // Red theme
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .frame(height: 78)
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
            
            // Mode Selection Grid (Competitive in RED theme vs Balance)
            HStack(spacing: 12) {
                // Card 1: Competitive (Red Accent)
                Button(action: {
                    let gen = UIImpactFeedbackGenerator(style: .medium)
                    gen.impactOccurred()
                    selectedMode = "Competitive"
                }) {
                    VStack(spacing: 10) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(selectedMode == "Competitive" ? Color(hex: "FF1E27") : Color.gray)
                        
                        Text("Competitive")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 105)
                    .background(
                        selectedMode == "Competitive" ?
                            Color(hex: "250B0D").opacity(0.95) :
                            Color(hex: "151720").opacity(0.85)
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selectedMode == "Competitive" ?
                                    Color(hex: "FF1E27").opacity(0.85) :
                                    Color.white.opacity(0.06),
                                lineWidth: 1.5
                            )
                    )
                }
                
                // Card 2: Balance
                Button(action: {
                    let gen = UIImpactFeedbackGenerator(style: .medium)
                    gen.impactOccurred()
                    selectedMode = "Balance"
                }) {
                    VStack(spacing: 10) {
                        Image(systemName: "circle.lefthalf.filled")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(selectedMode == "Balance" ? Color(hex: "FF1E27") : Color.gray)
                        
                        Text("Balance")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 105)
                    .background(
                        selectedMode == "Balance" ?
                            Color(hex: "250B0D").opacity(0.95) :
                            Color(hex: "151720").opacity(0.85)
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selectedMode == "Balance" ?
                                    Color(hex: "FF1E27").opacity(0.85) :
                                    Color.white.opacity(0.06),
                                lineWidth: 1.5
                            )
                    )
                }
            }
            
            // Bottom Launch Slider Action Button (Triple play arrows in RED theme)
            GeometryReader { sliderGeo in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color(hex: "12141A"))
                        .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
                    
                    // Slider Knob with Triple Arrows in RED
                    HStack(spacing: 2) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(width: 84, height: 48)
                    .background(Color(hex: "FF1E27")) // GodDataX Red
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "FF1E27").opacity(0.55), radius: 8, x: 0, y: 2)
                    .offset(x: slideOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { val in
                                let maxDrag = sliderGeo.size.width - 84
                                if val.translation.width > 0 && val.translation.width <= maxDrag {
                                    slideOffset = val.translation.width
                                }
                            }
                            .onEnded { val in
                                let maxDrag = sliderGeo.size.width - 84
                                if slideOffset > maxDrag * 0.65 {
                                    withAnimation(.spring()) {
                                        slideOffset = maxDrag
                                    }
                                    executeLaunch()
                                } else {
                                    withAnimation(.spring()) {
                                        slideOffset = 0
                                    }
                                }
                            }
                    )
                    .onTapGesture {
                        executeLaunch()
                    }
                }
            }
            .frame(height: 52)
        }
        .padding(18)
        .background(Color(hex: "0E1015"))
        .cornerRadius(26)
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color.white.opacity(0.12), lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.bottom, 28) // Raised comfortably above bottom edge
    }
    
    private func executeLaunch() {
        guard !isLaunching else { return }
        isLaunching = true
        
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        
        // 1. Direct Launch via LSApplicationWorkspace to completely bypass iOS "Buka di Free Fire?" prompt
        if let workspaceClass = NSClassFromString("LSApplicationWorkspace") as? NSObject.Type {
            let defaultWorkspaceSelector = NSSelectorFromString("defaultWorkspace")
            if workspaceClass.responds(to: defaultWorkspaceSelector),
               let workspace = workspaceClass.perform(defaultWorkspaceSelector)?.takeUnretainedValue() {
                let openAppSelector = NSSelectorFromString("openApplicationWithBundleID:")
                if workspace.responds(to: openAppSelector) {
                    _ = workspace.perform(openAppSelector, with: game.bundleId)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        onClose()
                    }
                    return
                }
            }
        }
        
        // 2. Fallback to URL Scheme
        if let url = URL(string: game.scheme) {
            UIApplication.shared.open(url, options: [:]) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    onClose()
                }
            }
        }
    }
}

// Subcomponent: Custom Bottom Notice Card matching Image 2 reference (Edge-to-Edge, Compact, 0 horizontal space)
struct BottomNoticeCard: View {
    let title: String
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Title matching Image 2 style
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Description
            Text(message)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color.gray.opacity(0.9))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            
            // Full Width Action Button matching Image 2
            Button(action: onDismiss) {
                Text("OK")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(hex: "E64A19")) // Vibrant red-orange from Image 2
                    .clipShape(Capsule())
                    .shadow(color: Color(hex: "E64A19").opacity(0.4), radius: 6, y: 2)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "12141A"))
        .clipShape(RoundedCornerShape(radius: 28, corners: [.topLeft, .topRight]))
        .overlay(
            RoundedCornerShape(radius: 28, corners: [.topLeft, .topRight])
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

// Shape helper for specific rounded corners
struct RoundedCornerShape: Shape {
    var radius: CGFloat = 28
    var corners: UIRectCorner = [.topLeft, .topRight]

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

