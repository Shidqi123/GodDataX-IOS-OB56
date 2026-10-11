import SwiftUI

struct ContentView: View {
    @ObservedObject var authService = AuthService.shared
    @ObservedObject var lang = LanguageManager.shared
    @State private var selectedTab = 0
    @State private var isModalActive: Bool = false
    
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
                        MainDashboardView(isModalActive: $isModalActive)
                            .tag(0)
                        
                        StatusProfileView()
                            .tag(1)
                        
                        FeaturesView()
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Floating Bottom Navbar - Hide when modal/notice sheet is active to prevent collision
                    if !isModalActive {
                        HStack(spacing: 8) {
                            // Tab 0: Home
                            NavBarButton(
                                icon: "house.fill",
                                title: "Home",
                                isSelected: selectedTab == 0
                            ) {
                                switchTab(0)
                            }
                            
                            // Tab 1: Profile
                            NavBarButton(
                                icon: "person.text.rectangle.fill",
                                title: lang.text(id: "Profil", en: "Profile"),
                                isSelected: selectedTab == 1
                            ) {
                                switchTab(1)
                            }
                            
                            // Tab 2: Settings / Features
                            NavBarButton(
                                icon: "slider.horizontal.3",
                                title: lang.text(id: "Fitur", en: "Features"),
                                isSelected: selectedTab == 2
                            ) {
                                switchTab(2)
                            }
                        }
                        .padding(6)
                        .background(
                            Capsule()
                                .fill(Color(hex: "0E1015"))
                                .overlay(
                                    Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.75), radius: 20, y: 8)
                        )
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isModalActive)
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

// Subcomponent: Custom Navbar Button with Red Active Capsule
struct NavBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                if isSelected {
                    Text(title)
                        .font(.rajdhani(15, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, isSelected ? 18 : 14)
            .frame(minWidth: isSelected ? nil : 46, minHeight: 40)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(Color(hex: "FF1E27")) // GodDataX Red
                            .shadow(color: Color(hex: "FF1E27").opacity(0.45), radius: 8, y: 2)
                    } else {
                        Color.clear
                    }
                }
            )
        }
    }
}
