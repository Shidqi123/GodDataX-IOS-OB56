import SwiftUI
import Darwin

struct StatusProfileView: View {
    @ObservedObject var authService = AuthService.shared
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // Realtime Service Monitoring Timer
    @State private var elapsedSeconds: Int = 1119 // Starting around ~00:18:39 for realistic initial look
    @State private var timerActive = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // 1. TOP USER CARD (From Image 2 reference, without Elite/Plus subscription boxes)
                GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.25), cornerRadius: 20) {
                    HStack(spacing: 14) {
                        // User Avatar Icon (Matching Image 2 rounded rectangle with person icon)
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "1A1D26"))
                                .frame(width: 58, height: 58)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 26))
                                .foregroundColor(Color.gray.opacity(0.9))
                        }
                        
                        // User Details
                        VStack(alignment: .leading, spacing: 5) {
                            // Top Tag (Red theme)
                            HStack(spacing: 6) {
                                Text("GodDataX VIP")
                                    .font(.rajdhani(11, weight: .bold))
                                    .foregroundColor(Color(hex: "FF1E27"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(hex: "FF1E27").opacity(0.16))
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color(hex: "FF1E27").opacity(0.35), lineWidth: 1))
                                
                                Spacer()
                                
                                // Copy Key / UID Action
                                Button(action: copyUserKey) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            // Username with verified seal
                            HStack(spacing: 6) {
                                Text(displayUsername)
                                    .font(.rajdhani(18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "FF1E27")) // Theme Red
                            }
                            
                            // Expiry Date (Waktu Kedaluwarsa)
                            HStack(spacing: 4) {
                                Text("Waktu Kedaluwarsa :")
                                    .font(.rajdhani(13, weight: .medium))
                                    .foregroundColor(Color.gray.opacity(0.85))
                                
                                Text("27 Nov 2026")
                                    .font(.rajdhani(13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // 2. PEMANTAUAN LAYANAN CARD (From Image 3 reference, matching RED theme)
                GlassCard(borderColor: Color.white.opacity(0.08), cornerRadius: 20) {
                    VStack(alignment: .leading, spacing: 14) {
                        // Header Row
                        HStack {
                            Text("Pemantauan Layanan")
                                .font(.rajdhani(15, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.85))
                            
                            Spacer()
                            
                            // Status Pill in RED Theme
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(Color(hex: "FF1E27"))
                                    .frame(width: 7, height: 7)
                                Text("Terhubung")
                                    .font(.rajdhani(12, weight: .bold))
                                    .foregroundColor(Color(hex: "FF1E27"))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(hex: "FF1E27").opacity(0.12))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color(hex: "FF1E27").opacity(0.3), lineWidth: 1))
                        }
                        
                        // Realtime Digital Timer (Hours : Minutes : Seconds)
                        Text(formatTimer(elapsedSeconds))
                            .font(.rajdhani(36, weight: .bold))
                            .foregroundColor(Color(hex: "FF1E27")) // Red theme
                            .padding(.vertical, 2)
                        
                        // 3 Metrics Boxes: PID, UID, VER
                        HStack(spacing: 12) {
                            ServiceStatBox(
                                title: "PID",
                                value: "\(ProcessInfo.processInfo.processIdentifier)"
                            )
                            
                            ServiceStatBox(
                                title: "UID",
                                value: "\(getuid() == 0 ? 2000 : getuid())"
                            )
                            
                            ServiceStatBox(
                                title: "VER",
                                value: "2.0"
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // 3. SETELAN DASAR CARD (From Image 3 reference)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Setelan dasar")
                        .font(.rajdhani(14, weight: .bold))
                        .foregroundColor(Color.gray.opacity(0.85))
                        .padding(.horizontal, 24)
                    
                    GlassCard(borderColor: Color.white.opacity(0.06), cornerRadius: 18) {
                        VStack(spacing: 0) {
                            ProfileMenuRow(
                                title: "Mengelola Key Mapping"
                            ) {
                                showAlert(title: "Key Mapping", message: "Key Mapping engine aktif dan terkalibrasi untuk OB56.")
                            }
                            
                            Divider().background(Color.white.opacity(0.06)).padding(.vertical, 8)
                            
                            ProfileMenuRow(
                                title: "Pengaturan Tambahan"
                            ) {
                                showAlert(title: "Pengaturan Tambahan", message: "Optimasi sistem hardware Apple ARM64 berjalan otomatis.")
                            }
                            
                            Divider().background(Color.white.opacity(0.06)).padding(.vertical, 8)
                            
                            ProfileMenuRow(
                                title: "Bahasa",
                                trailingText: "System Default"
                            ) {
                                showAlert(title: "Bahasa", message: "Bahasa aplikasi mengikuti pengaturan default perangkat iOS Anda.")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // 4. DUKUNG KAMI CARD (From Image 3 reference)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dukung Kami")
                        .font(.rajdhani(14, weight: .bold))
                        .foregroundColor(Color.gray.opacity(0.85))
                        .padding(.horizontal, 24)
                    
                    GlassCard(borderColor: Color.white.opacity(0.06), cornerRadius: 18) {
                        VStack(spacing: 0) {
                            ProfileMenuRow(
                                title: "Saluran WhatsApp"
                            ) {
                                openSupportURL("https://whatsapp.com/channel/goddatax")
                            }
                            
                            Divider().background(Color.white.opacity(0.06)).padding(.vertical, 8)
                            
                            ProfileMenuRow(
                                title: "Server Discord"
                            ) {
                                openSupportURL("https://discord.gg/goddatax")
                            }
                            
                            Divider().background(Color.white.opacity(0.06)).padding(.vertical, 8)
                            
                            ProfileMenuRow(
                                title: "TikTok Resmi"
                            ) {
                                openSupportURL("https://tiktok.com/@goddatax")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // 5. HARDWARE ID & LOGOUT
                VStack(spacing: 12) {
                    // Copy HWID Button
                    Button(action: copyHWID) {
                        HStack(spacing: 8) {
                            Image(systemName: "cpu")
                            Text("HWID: \(authService.hwid)")
                        }
                        .font(.rajdhani(12, weight: .medium))
                        .foregroundColor(Color.gray)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 14)
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(8)
                    }
                    
                    // Logout Action
                    Button(action: logout) {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("LOGOUT SESSION")
                        }
                        .font(.rajdhani(15, weight: .bold))
                        .foregroundColor(Color(hex: "FF1E27"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(hex: "FF1E27").opacity(0.12))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "FF1E27").opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 90)
            }
        }
        .onReceive(timer) { _ in
            if timerActive {
                elapsedSeconds += 1
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Helpers
    private var displayUsername: String {
        if !authService.currentKey.isEmpty {
            return authService.currentKey
        }
        return "user-00b9987d2"
    }
    
    private func formatTimer(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func copyUserKey() {
        UIPasteboard.general.string = displayUsername
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        showAlert(title: "Tersalin", message: "User ID / Lisensi berhasil disalin ke clipboard.")
    }
    
    private func copyHWID() {
        UIPasteboard.general.string = authService.hwid
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        showAlert(title: "HWID Tersalin", message: "Hardware ID Anda: \(authService.hwid)")
    }
    
    private func openSupportURL(_ urlStr: String) {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: "Info", message: "Tautan dukungan resmi telah diaktifkan.")
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
    private func logout() {
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.warning)
        authService.logout()
    }
}

// Subcomponent: Stat Box (PID, UID, VER in RED theme)
struct ServiceStatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.rajdhani(11, weight: .bold))
                .foregroundColor(Color.gray.opacity(0.85))
            
            Text(value)
                .font(.rajdhani(18, weight: .bold))
                .foregroundColor(Color(hex: "FF1E27")) // GodDataX Red Theme
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(Color(hex: "151722"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "FF1E27").opacity(0.2), lineWidth: 1)
        )
    }
}

// Subcomponent: Clean Profile Navigation Row with Chevron
struct ProfileMenuRow: View {
    let title: String
    var trailingText: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.rajdhani(16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let trailing = trailingText {
                    Text(trailing)
                        .font(.rajdhani(14, weight: .medium))
                        .foregroundColor(Color.gray)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.gray.opacity(0.7))
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
