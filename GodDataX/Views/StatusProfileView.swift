import SwiftUI

struct NoticeData: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

struct StatusProfileView: View {
    @ObservedObject var authService = AuthService.shared
    @ObservedObject var lang = LanguageManager.shared
    @Binding var isModalActive: Bool
    
    @State private var activeNotice: NoticeData? = nil
    @State private var showingLanguageSheet = false
    
    // Realtime timer starting from 00:00:00 when the user enters the app
    @State private var elapsedSeconds: Int = 0
    @State private var ob57CountdownString: String = AuthService.getOB57CountdownString()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(isModalActive: Binding<Bool> = .constant(false)) {
        self._isModalActive = isModalActive
    }
    
    var body: some View {
        ZStack {
            // Main Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 1. TOP USER CARD (Matching Image 2 with device-specific random user-id, GREEN checkmark & copy button)
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
                                        .padding(6)
                                    }
                                }
                                
                                // Expiry Date (Waktu Kedaluwarsa) - Dynamic Firebase / OB57 Countdown
                                HStack(spacing: 4) {
                                    Text(lang.text(id: "Waktu Kedaluwarsa :", en: "Expiration Date :"))
                                        .font(.rajdhani(13, weight: .medium))
                                        .foregroundColor(Color.gray.opacity(0.85))
                                    
                                    Text(ob57CountdownString)
                                        .font(.rajdhani(13, weight: .bold))
                                        .foregroundColor(Color(hex: "FF1E27"))
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
                    
                    // 3. SETELAN DASAR CARD (Without Key Mapping, with custom bottom popup sheet for Bahasa)
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
                                    showNotice(
                                        title: lang.text(id: "Pengaturan Tambahan", en: "Additional Settings"),
                                        message: lang.text(
                                            id: "Optimasi sistem hardware Apple ARM64 aktif.\nHWID: \(authService.hwid)\nUser ID: \(authService.deviceUserId)",
                                            en: "Apple ARM64 hardware optimization active.\nHWID: \(authService.hwid)\nUser ID: \(authService.deviceUserId)"
                                        )
                                    )
                                }
                                
                                Divider().background(Color.white.opacity(0.06)).padding(.vertical, 8)
                                
                                // Bahasa (Opens custom bottom popup sheet matching Image 2)
                                ProfileMenuRow(
                                    title: lang.text(id: "Bahasa", en: "Language"),
                                    trailingText: lang.currentLanguage.title
                                ) {
                                    openLanguageSheet()
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
            .blur(radius: (showingLanguageSheet || activeNotice != nil) ? 4 : 0)
            
            // Dimmed Background Backdrop
            if showingLanguageSheet || activeNotice != nil {
                Color.black.opacity(0.68)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        dismissAllModals()
                    }
                    .zIndex(10)
            }
            
            // Custom Language Selection Sheet matching Image 2 reference (with Red accents, NO green text)
            if showingLanguageSheet {
                VStack {
                    Spacer()
                    LanguagePickerSheet(isPresented: $showingLanguageSheet, onDismiss: {
                        dismissAllModals()
                    })
                }
                .ignoresSafeArea(.all, edges: .bottom)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(20)
            }
            
            // Custom Bottom Notice Card matching Image 3 reference & menu Home style
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
        .animation(.spring(response: 0.38, dampingFraction: 0.8), value: showingLanguageSheet)
        .animation(.spring(response: 0.38, dampingFraction: 0.8), value: activeNotice != nil)
        .onAppear {
            elapsedSeconds = max(0, Int(Date().timeIntervalSince(authService.sessionStartTime)))
            ob57CountdownString = authService.getLiveCountdownString(dayLabel: lang.text(id: "Hari", en: "Days"))
            authService.syncUserWithFirebase()
        }
        .onReceive(timer) { _ in
            elapsedSeconds = max(0, Int(Date().timeIntervalSince(authService.sessionStartTime)))
            ob57CountdownString = authService.getLiveCountdownString(dayLabel: lang.text(id: "Hari", en: "Days"))
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
        showNotice(
            title: lang.text(id: "Tersalin", en: "Copied"),
            message: lang.text(id: "User ID berhasil disalin ke clipboard.", en: "User ID successfully copied to clipboard.")
        )
    }
    
    private func openLanguageSheet() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.impactOccurred()
        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
            activeNotice = nil
            showingLanguageSheet = true
            isModalActive = true
        }
    }
    
    private func showNotice(title: String, message: String) {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
            showingLanguageSheet = false
            activeNotice = NoticeData(title: title, message: message)
            isModalActive = true
        }
    }
    
    private func dismissAllModals() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            showingLanguageSheet = false
            activeNotice = nil
            isModalActive = false
        }
    }
    
    private func openSupportURL(_ urlStr: String) {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        }
    }
}

// Subcomponent: Custom Language Selection Bottom Sheet matching Image 2 reference
struct LanguagePickerSheet: View {
    @ObservedObject var lang = LanguageManager.shared
    @Binding var isPresented: Bool
    var onDismiss: () -> Void
    @State private var searchText: String = ""
    
    let languages: [(id: AppLanguage, title: String)] = [
        (.system, "System Default"),
        (.english, "English"),
        (.indonesian, "Indonesia")
    ]
    
    var filteredLanguages: [(id: AppLanguage, title: String)] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return languages
        }
        return languages.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(lang.text(id: "Bahasa", en: "Language"))
                    .font(.rajdhani(22, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color.gray.opacity(0.6))
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            
            // Search Bar matching Image 2
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.gray.opacity(0.7))
                    .font(.system(size: 15, weight: .semibold))
                
                TextField(lang.text(id: "Cari bahasa", en: "Search language"), text: $searchText)
                    .font(.rajdhani(16, weight: .medium))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.gray.opacity(0.6))
                            .font(.system(size: 15))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(hex: "1A1D24"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 22)
            
            // Language list rows with RED active radio buttons
            VStack(spacing: 4) {
                ForEach(filteredLanguages, id: \.id) { item in
                    Button(action: {
                        let gen = UIImpactFeedbackGenerator(style: .medium)
                        gen.impactOccurred()
                        lang.setLanguage(item.id)
                        onDismiss()
                    }) {
                        HStack {
                            Text(item.title)
                                .font(.rajdhani(17, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Radio Button in RED theme matching our app
                            ZStack {
                                Circle()
                                    .stroke(
                                        lang.currentLanguage == item.id ? Color(hex: "FF1E27") : Color.gray.opacity(0.4),
                                        lineWidth: 2
                                    )
                                    .frame(width: 22, height: 22)
                                
                                if lang.currentLanguage == item.id {
                                    Circle()
                                        .fill(Color(hex: "FF1E27"))
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 22)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 4)
            .padding(.bottom, 36)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "12141A"))
        .clipShape(RoundedCornerShape(radius: 28, corners: [.topLeft, .topRight]))
        .overlay(
            RoundedCornerShape(radius: 28, corners: [.topLeft, .topRight])
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
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
