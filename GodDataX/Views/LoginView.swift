import SwiftUI

struct LoginView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var inputKey: String = ""
    @State private var logoPulse: Bool = false
    @State private var showShake: Bool = false
    
    var body: some View {
        ZStack {
            // Dark luxury background with deep red ambient glow
            Color(hex: "09090C")
                .ignoresSafeArea()
            
            // Subtle ambient red background circles
            GeometryReader { proxy in
                Circle()
                    .fill(Color(hex: "FF1E27").opacity(0.12))
                    .frame(width: proxy.size.width * 0.9)
                    .blur(radius: 90)
                    .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.25)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // Top Cloud Logo & Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FF1E27").opacity(0.25), Color.black.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 130, height: 130)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "FF1E27").opacity(0.8), Color(hex: "770000").opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: Color(hex: "FF1E27").opacity(0.35), radius: 15, y: 0)
                            .scaleEffect(logoPulse ? 1.04 : 0.98)
                            .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: logoPulse)
                        
                        // Cloud GodDataX Logo
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 95, height: 95)
                            .clipShape(Circle())
                    }
                    
                    Text("GodDataX iOS")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .kerning(1.5)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "FF3B47")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .onAppear {
                    logoPulse = true
                }
                
                // Login Card Form
                GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.35), cornerRadius: 20) {
                    VStack(spacing: 18) {
                        // Key Input Field
                        HStack(spacing: 12) {
                            Image(systemName: "key.fill")
                                .foregroundColor(Color(hex: "FF1E27"))
                                .font(.system(size: 16))
                            
                            SecureField("Masukkan Lisensi", text: $inputKey)
                                .foregroundColor(.white)
                                .autocapitalization(.allCharacters)
                                .disableAutocorrection(true)
                            
                            if !inputKey.isEmpty {
                                Button(action: { inputKey = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color(hex: "06060A"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "FF1E27").opacity(0.25), lineWidth: 1)
                        )
                        
                        // Error Notice without emojis
                        if let error = authService.errorMessage {
                            Text(error)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "FF3B30"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 4)
                                .transition(.opacity)
                        }
                        
                        // Submit Button "Login"
                        Button(action: handleLogin) {
                            HStack {
                                if authService.isVerifying {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Login")
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "FF1E27"), Color(hex: "990000")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color(hex: "FF1E27").opacity(0.45), radius: 10, y: 3)
                        }
                        .disabled(authService.isVerifying)
                    }
                    .padding(.vertical, 6)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                Spacer()
            }
        }
    }
    
    private func handleLogin() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        authService.login(key: inputKey) { success, _ in
            if !success {
                let errorGen = UINotificationFeedbackGenerator()
                errorGen.notificationOccurred(.error)
            } else {
                let successGen = UINotificationFeedbackGenerator()
                successGen.notificationOccurred(.success)
            }
        }
    }
}
