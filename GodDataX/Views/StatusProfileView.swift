import SwiftUI

struct StatusProfileView: View {
    @ObservedObject var authService = AuthService.shared
    @ObservedObject var lang = LanguageManager.shared
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingLanguageSheet = false
    
    // Realtime timer starting from 00:00:00 when the user enters the app
    @State private var elapsedSeconds: Int = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // 1. TOP USER CARD (Matching Image 2 with device-specific random user-id and GREEN verified checkmark)
                GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.25), cornerRadius: 20) {
                    HStack(spacing: 14) {
                        // User Avatar Icon (Rounded rectangle with person icon)
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
                            }
                            
                            // Random device user ID with GREEN checkmark and copy button on the right
                            HStack(spacing: 6) {
                                Text(authService.deviceUserId)
                                    .font(.rajdhani(18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                // GREEN Verified Checkmark
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                                
                                Spacer()
                                
                                // Copy User ID Action Button
                                Button(action: copyUserKey) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            // Expiry Date (Waktu Kedaluwarsa) - Dynamic Firebase / OB57 Countdown
                            HStack(spacing: 4) {
                                Text(lang.text(id: "Waktu Kedaluwarsa :", en: "Expiration Date :"))
                                    .font(.rajdhani(13, weight: .medium))
                                    .foregroundColor(Color.gray.opacity(0.85))
                                
                                Text(authService.expiryDateString)
                                    .font(.rajdhani(13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                // 2. PANTAU USER CARD (Changed from Pemantauan Layanan, starting from 00:00:00, without PID/UID/VER)
                GlassCard(borderColor: Color.white.opacity(0.08), cornerRadius: 20) {
                    VStack(alignment: .leading, spacing: 14) {
                        // Header Row
                        HStack {
                            Text(lang.text(id: "Pantau User", en: "Monitor User"))
                                .font(.rajdhani(16, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.85))
                            
                            Spacer()
                            
                            // Status Pill in RED Theme
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(Color(hex: "FF1E27"))
                                    .frame(width: 7, height: 7)
                                Text(lang.text(id: "Terhubung", en: "Connected"))
                                    .font(.rajdhani(12, weight: .bold))
                                    .foregroundColor(Color(hex: "FF1E27"))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color(hex: "FF1E27").opacity(0.12))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color(hex: "FF1E27").opacity(0.3), lineWidth: 1))
                        }
                        
                        // Realtime Digital Timer starting when user enters app (HH:MM:SS)
                        Text(formatTimer(elapsedSeconds))
                            .font(.rajdhani(38, weight: .bold))
                            .foregroundColor(Color(hex: "FF1E27")) // Theme Red
                            .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal, 20)
                
                // 3. SETELAN DASAR CARD (Without Key Mapping, with fully functional Bahasa selector)
                VStack(alignment: .leading, spacing: 8) {
                    Text(lang.text(id: "Setelan dasar", en: "Basic Settings"))
                        .font(.rajdhani(14, weight: .bold))
                        .foregroundColor(Color.gray.opacity(0.85))
                        .padding(.horizontal, 24)
                    
                    GlassCard(borderColor: Color.white.opacity(0.06), cornerRadius: 18) {
                        VStack(spacing: 0) {
                            // Pengaturan Tambahan
                            ProfileMenuRow(
                                title: lang.text(id: "Pengaturan Tambahan", en: "Additional Settings")
                            ) {
                                showAlert(
                                    title: lang.text(id: "Pengaturan Tambahan", en: "Additional Settings"),
                                    message: lang.text(
                                        id: "Optimasi sistem hardware Apple ARM64 aktif. HWID: \(authService.hwid)",
                                        en: "Apple ARM64 hardware optimization active. HWID: \(authService.hwid)"
                                    )
                                )
                            }
                            
                            Divider().background(Color.white.opacity(0.06)).padding(.vertical, 8)
                            
                            // Bahasa (Functional 3 options)
                            ProfileMenuRow(
                                title: lang.text(id: "Bahasa", en: "Language"),
                                trailingText: lang.currentLanguage.title
                            ) {
                                showingLanguageSheet = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // 4. DUKUNG KAMI CARD (Without TikTok, only WhatsApp & Discord)
                VStack(alignment: .leading, spacing: 8) {
                    Text(lang.text(id: "Dukung Kami", en: "Support Us"))
                        .font(.rajdhani(14, weight: .bold))
                        .foregroundColor(Color.gray.opacity(0.85))
                        .padding(.horizontal, 24)
                    
                    GlassCard(borderColor: Color.white.opacity(0.06), cornerRadius: 18) {
                        VStack(spacing: 0) {
                            // Saluran WhatsApp
                            ProfileMenuRow(
                                title: lang.text(id: "Saluran WhatsApp", en: "WhatsApp Channel")
                            ) {
                                openSupportURL("https://www.whatsapp.com/channel/0029VbCiXoHBA1f7z76iVB2I")
                            }
                            
                            Divider().background(Color.white.opacity(0.06)).padding(.vertical, 8)
                            
                            // Server Discord
                            ProfileMenuRow(
                                title: lang.text(id: "Server Discord", en: "Discord Server")
                            ) {
                                openSupportURL("https://discord.com/invite/5HDEahaFXJ")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 90)
            }
        }
        .onAppear {
            elapsedSeconds = max(0, Int(Date().timeIntervalSince(authService.sessionStartTime)))
        }
        .onReceive(timer) { _ in
            elapsedSeconds = max(0, Int(Date().timeIntervalSince(authService.sessionStartTime)))
        }
        .actionSheet(isPresented: $showingLanguageSheet) {
            ActionSheet(
                title: Text(lang.text(id: "Pilih Bahasa", en: "Select Language")),
                message: Text(lang.text(id: "Pilih bahasa tampilan untuk aplikasi GodDataX", en: "Choose application display language")),
                buttons: [
                    .default(Text("System Default (Bahasa Indonesia)")) {
                        lang.setLanguage(.system)
                    },
                    .default(Text("Bahasa Indonesia")) {
                        lang.setLanguage(.indonesian)
                    },
                    .default(Text("English")) {
                        lang.setLanguage(.english)
                    },
                    .cancel(Text(lang.text(id: "Batal", en: "Cancel")))
                ]
            )
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
    private func formatTimer(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func copyUserKey() {
        UIPasteboard.general.string = authService.deviceUserId
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        showAlert(
            title: lang.text(id: "Tersalin", en: "Copied"),
            message: lang.text(id: "User ID berhasil disalin ke clipboard.", en: "User ID successfully copied to clipboard.")
        )
    }
    
    private func openSupportURL(_ urlStr: String) {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
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
                        .foregroundColor(Color(hex: "FF1E27"))
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
