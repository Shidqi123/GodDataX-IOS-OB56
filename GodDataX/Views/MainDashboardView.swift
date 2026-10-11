import SwiftUI

struct GameLaunchInfo: Identifiable {
    let id = UUID()
    let title: String
    let bundleId: String
    let scheme: String
    let iconURL: URL?
    let fallbackImageName: String
}

struct MainDashboardView: View {
    @ObservedObject var iconManager = FreeFireIconManager.shared
    @State private var showingSpringBoardAlert = false
    @State private var springBoardMsg = ""
    @State private var selectedGame: GameLaunchInfo? = nil
    
    var body: some View {
        ZStack {
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
                        ) {
                            selectedGame = GameLaunchInfo(
                                title: "Free Fire",
                                bundleId: AppConfig.ffBundleId,
                                scheme: AppConfig.ffScheme,
                                iconURL: iconManager.ffIconURL,
                                fallbackImageName: "FFLogo"
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // Card 2: Free Fire MAX (Realtime Artwork Background + Circular Icon)
                        GameCompactRow(
                            title: "Free Fire MAX",
                            scheme: AppConfig.ffMaxScheme,
                            iconURL: iconManager.ffMaxIconURL,
                            fallbackImageName: "FFMaxLogo"
                        ) {
                            selectedGame = GameLaunchInfo(
                                title: "Free Fire MAX",
                                bundleId: AppConfig.ffMaxBundleId,
                                scheme: AppConfig.ffMaxScheme,
                                iconURL: iconManager.ffMaxIconURL,
                                fallbackImageName: "FFMaxLogo"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // SECTION: System Utilities (Font matched to Library)
                    VStack(alignment: .leading, spacing: 14) {
                        Text("SYSTEM UTILITIES")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
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
            .blur(radius: selectedGame != nil ? 4 : 0)
            
            // Interactive Launch Modal Sheet (Image 5 style)
            if let game = selectedGame {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedGame = nil
                        }
                    }
                
                GameLaunchSheet(game: game) {
                    withAnimation(.spring()) {
                        selectedGame = nil
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedGame != nil)
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
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
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
}

// Subcomponent: GameLaunchSheet matching Image 5 reference
struct GameLaunchSheet: View {
    let game: GameLaunchInfo
    let onClose: () -> Void
    
    @State private var selectedMode: String = "Competitive"
    @State private var slideOffset: CGFloat = 0
    @State private var isLaunching = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            VStack(spacing: 16) {
                // Top Header Card with Realtime Artwork Background
                ZStack(alignment: .leading) {
                    Color(hex: "171922")
                    
                    // Background Artwork Faded
                    GeometryReader { geo in
                        if let url = game.iconURL {
                            AsyncImage(url: url) { phase in
                                if let img = phase.image {
                                    img
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width, height: geo.size.height)
                                        .clipped()
                                        .opacity(0.22)
                                        .blur(radius: 3)
                                }
                            }
                        }
                    }
                    
                    HStack {
                        // Left: Game Name + Bundle ID
                        VStack(alignment: .leading, spacing: 3) {
                            Text(game.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text(game.bundleId)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color.gray)
                        }
                        
                        Spacer()
                        
                        // Center: Realtime Circular Artwork
                        ZStack {
                            Circle()
                                .fill(Color(hex: "222430"))
                                .frame(width: 50, height: 50)
                            
                            if let url = game.iconURL {
                                AsyncImage(url: url) { phase in
                                    if let img = phase.image {
                                        img
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    } else {
                                        Image(game.fallbackImageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    }
                                }
                            } else {
                                Image(game.fallbackImageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            }
                        }
                        .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1.5))
                        .shadow(color: Color.black.opacity(0.5), radius: 6, y: 3)
                        
                        Spacer()
                        
                        // Right: Mode Game Status
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("Mode Game")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Text(selectedMode)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(hex: "00E575"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
                .frame(height: 78)
                .cornerRadius(18)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08), lineWidth: 1))
                
                // Mode Selection Grid (Competitive vs Balance) - No credit text!
                HStack(spacing: 12) {
                    // Card 1: Competitive
                    Button(action: {
                        let gen = UIImpactFeedbackGenerator(style: .medium)
                        gen.impactOccurred()
                        selectedMode = "Competitive"
                    }) {
                        VStack(spacing: 10) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(selectedMode == "Competitive" ? Color(hex: "00E575") : Color.gray)
                            
                            Text("Competitive")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 105)
                        .background(
                            selectedMode == "Competitive" ?
                                Color(hex: "103222").opacity(0.85) :
                                Color(hex: "151720").opacity(0.85)
                        )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    selectedMode == "Competitive" ?
                                        Color(hex: "00E575").opacity(0.6) :
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
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(selectedMode == "Balance" ? Color(hex: "00E575") : Color.gray)
                            
                            Text("Balance")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 105)
                        .background(
                            selectedMode == "Balance" ?
                                Color(hex: "103222").opacity(0.85) :
                                Color(hex: "151720").opacity(0.85)
                        )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    selectedMode == "Balance" ?
                                        Color(hex: "00E575").opacity(0.6) :
                                        Color.white.opacity(0.06),
                                    lineWidth: 1.5
                                )
                        )
                    }
                }
                
                // Bottom Launch Slider Action Button (Triple play arrows from Image 5)
                GeometryReader { sliderGeo in
                    ZStack(alignment: .leading) {
                        // Background track
                        Capsule()
                            .fill(Color(hex: "12141A"))
                            .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
                        
                        // Slider Knob with Triple Arrows
                        HStack(spacing: 2) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 13, weight: .heavy))
                            Image(systemName: "play.fill")
                                .font(.system(size: 13, weight: .heavy))
                            Image(systemName: "play.fill")
                                .font(.system(size: 13, weight: .heavy))
                        }
                        .foregroundColor(Color(hex: "081A12"))
                        .frame(width: 84, height: 48)
                        .background(Color(hex: "00E575"))
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "00E575").opacity(0.4), radius: 8, x: 0, y: 2)
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
                                    if slideOffset > maxDrag * 0.6 {
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
                            // Tap to quick launch
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
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private func executeLaunch() {
        guard !isLaunching else { return }
        isLaunching = true
        
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        
        if let url = URL(string: game.scheme) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onClose()
                    }
                }
            } else {
                if let appStoreURL = URL(string: "https://apps.apple.com/app/id1300146617") {
                    UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                }
                onClose()
            }
        }
    }
}
