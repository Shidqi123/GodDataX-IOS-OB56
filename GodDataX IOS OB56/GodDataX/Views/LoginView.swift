import SwiftUI

struct LoginView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var inputKey: String = ""
    @State private var showErrorAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var logoPulse = false
    
    var body: some View {
        ZStack {
            // Background Cyberpunk Gradient
            Color(hex: "0A0A0F").ignoresSafeArea()
            
            // Atmospheric Glows
            Circle()
                .fill(Color.orange.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(y: -150)
            
            Circle()
                .fill(Color.red.opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(y: 180)
            
            VStack(spacing: 28) {
                Spacer()
                
                // Top Logo & Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.orange.opacity(0.2), Color.red.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 130, height: 130)
                            .overlay(
                                Circle().stroke(Color.orange.opacity(0.4), lineWidth: 1.5)
                            )
                            .scaleEffect(logoPulse ? 1.05 : 0.98)
                            .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: logoPulse)
                        
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    
                    Text("GODDATAX")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "FF8800")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(3)
                    
                    Text("iOS Edition • OB56 Support")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.gray)
                }
                .onAppear {
                    logoPulse = true
                }
                
                // Login Card Form
                GlassCard(borderColor: Color.orange.opacity(0.3), cornerRadius: 20) {
                    VStack(spacing: 20) {
                        // Key Input Field
                        HStack(spacing: 12) {
                            Image(systemName: "key.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 16))
                            
                            SecureField("Enter Access License Key", text: $inputKey)
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
                        .background(Color(hex: "08080C"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        
                        // Error Notice if any
                        if let error = authService.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Submit Button
                        Button(action: handleLogin) {
                            HStack(spacing: 10) {
                                if authService.isVerifying {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("ENTER OB56")
                                        .font(.system(size: 15, weight: .heavy))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "FF5500"), Color(hex: "CC1100")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.orange.opacity(0.4), radius: 8, y: 3)
                        }
                        .disabled(authService.isVerifying)
                    }
                }
                .padding(.horizontal, 24)
                
                // Device HWID Info
                VStack(spacing: 6) {
                    Text("DEVICE HWID:")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        Text(authService.hwid)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color.orange.opacity(0.9))
                        
                        Button(action: copyHWID) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 11))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Footer
                Text("Version 2.0 • OB56 Native Core • by Kutoo")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.gray.opacity(0.6))
                    .padding(.bottom, 16)
            }
        }
    }
    
    private func handleLogin() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        authService.login(key: inputKey) { success, msg in
            if !success {
                let errorGen = UINotificationFeedbackGenerator()
                errorGen.notificationOccurred(.error)
            } else {
                let successGen = UINotificationFeedbackGenerator()
                successGen.notificationOccurred(.success)
            }
        }
    }
    
    private func copyHWID() {
        UIPasteboard.general.string = authService.hwid
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
    }
}
