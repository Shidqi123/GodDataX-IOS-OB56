import SwiftUI

struct ContentView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Main Theme Background
            Color(hex: "09090D").ignoresSafeArea()
            
            if !authService.isAuthenticated {
                LoginView()
                    .transition(.opacity)
            } else {
                ZStack(alignment: .bottom) {
                    // Tab Content
                    TabView(selection: $selectedTab) {
                        MainDashboardView()
                            .tag(0)
                        
                        StatusProfileView()
                            .tag(1)
                        
                        FeaturesView()
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Floating Bottom Navbar matching screenshot reference
                    HStack(spacing: 8) {
                        // Tab 0: Mulai Game
                        NavBarButton(
                            icon: "gamecontroller.fill",
                            title: "Mulai Game",
                            isSelected: selectedTab == 0
                        ) {
                            switchTab(0)
                        }
                        
                        Spacer()
                        
                        // Tab 1: Profile
                        NavBarButton(
                            icon: "person.crop.circle.fill",
                            title: "Profil",
                            isSelected: selectedTab == 1
                        ) {
                            switchTab(1)
                        }
                        
                        Spacer()
                        
                        // Tab 2: Settings / Features
                        NavBarButton(
                            icon: "gearshape.fill",
                            title: "Fitur",
                            isSelected: selectedTab == 2
                        ) {
                            switchTab(2)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(hex: "0F1014"))
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.8), radius: 18, y: 8)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
    }
    
    private func switchTab(_ index: Int) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            selectedTab = index
        }
    }
}

// Subcomponent: Custom Navbar Button matching the green active capsule design
struct NavBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                if isSelected {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, isSelected ? 18 : 14)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(Color(hex: "185838")) // Emerald forest green from screenshot
                            .shadow(color: Color(hex: "185838").opacity(0.35), radius: 6, y: 2)
                    } else {
                        Color.clear
                    }
                }
            )
        }
    }
}
