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
                        
                        FeaturesView()
                            .tag(1)
                        
                        StatusProfileView()
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Floating Cyberpunk Bottom Navbar
                    HStack(spacing: 0) {
                        NavBarItem(icon: "gamecontroller.fill", title: "Home", isSelected: selectedTab == 0) {
                            switchTab(0)
                        }
                        
                        NavBarItem(icon: "slider.horizontal.3", title: "Features", isSelected: selectedTab == 1) {
                            switchTab(1)
                        }
                        
                        NavBarItem(icon: "person.crop.circle.fill", title: "Status", isSelected: selectedTab == 2) {
                            switchTab(2)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color(hex: "12121A").opacity(0.95))
                            .overlay(
                                Capsule().stroke(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.4), Color.red.opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                            )
                            .shadow(color: Color.black.opacity(0.7), radius: 15, y: 8)
                    )
                    .padding(.horizontal, 28)
                    .padding(.bottom, 12)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authService.isAuthenticated)
    }
    
    private func switchTab(_ index: Int) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedTab = index
        }
    }
}

struct NavBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .gray)
                
                if isSelected {
                    Text(title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, isSelected ? 16 : 14)
            .background(
                Capsule()
                    .fill(isSelected ? Color.orange : Color.clear)
            )
        }
        .frame(maxWidth: .infinity)
    }
}
