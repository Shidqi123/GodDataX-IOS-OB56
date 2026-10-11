import SwiftUI

struct StatusProfileView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var showingCopiedAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Top Header
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "FF1E27").opacity(0.25), Color.black], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                            .overlay(Circle().stroke(Color(hex: "FF1E27").opacity(0.6), lineWidth: 1.5))
                        
                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .font(.system(size: 34))
                            .foregroundColor(Color(hex: "FF1E27"))
                    }
                    
                    Text("ACTIVE LICENSE")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.green)
                    
                    Text(authService.currentKey.isEmpty ? "VIP ACCESS" : authService.currentKey)
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(.top, 16)
                
                // Card 1: License & Security Details
                GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.3), cornerRadius: 18) {
                    VStack(spacing: 14) {
                        ProfileInfoRow(
                            label: "Version Status",
                            value: "OB56 Support (Native)",
                            icon: "checkmark.seal.fill",
                            color: .green
                        )
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        ProfileInfoRow(
                            label: "Architecture",
                            value: "Apple ARM64 / Pure Swift",
                            icon: "cpu",
                            color: .cyan
                        )
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        ProfileInfoRow(
                            label: "iOS Version",
                            value: "iOS \(UIDevice.current.systemVersion)",
                            icon: "applelogo",
                            color: .white
                        )
                        
                        Divider().background(Color.white.opacity(0.1))
                        
                        ProfileInfoRow(
                            label: "Device Model",
                            value: UIDevice.current.model,
                            icon: "iphone",
                            color: Color(hex: "FF1E27")
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Card 2: Hardware ID (HWID)
                GlassCard(borderColor: Color.white.opacity(0.15), cornerRadius: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("HARDWARE ID (HWID)")
                                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                                .foregroundColor(.gray)
                            Spacer()
                            Button(action: copyHWID) {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.on.doc")
                                    Text("COPY")
                                }
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "FF1E27"))
                            }
                        }
                        
                        Text(authService.hwid)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                
                // Card 3: Credits & Developer Info
                GlassCard(borderColor: Color.white.opacity(0.1), cornerRadius: 18) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Developer")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("Kutoo")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Divider().background(Color.white.opacity(0.08))
                        
                        HStack {
                            Text("Engine")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("GodDataX Pure iOS")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "FF1E27"))
                        }
                        
                        Divider().background(Color.white.opacity(0.08))
                        
                        HStack {
                            Text("Package")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("Standalone .IPA (No Domain)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Logout Button
                Button(action: logout) {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("LOGOUT SESSION")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "FF1E27"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "FF1E27").opacity(0.1))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "FF1E27").opacity(0.3), lineWidth: 1))
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 80)
            }
        }
        .alert(isPresented: $showingCopiedAlert) {
            Alert(title: Text("Notice"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func copyHWID() {
        UIPasteboard.general.string = authService.hwid
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
        alertMessage = "HWID copied to clipboard!"
        showingCopiedAlert = true
    }
    
    private func logout() {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        authService.logout()
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
