import SwiftUI

struct FeaturesView: View {
    @ObservedObject var lang = LanguageManager.shared
    @ObservedObject var engine = GamingEngineService.shared
    
    // Default: Semua toggle MATI (false) saat user baru masuk aplikasi
    @AppStorage("feat_screen_anti_sleep") private var antiSleep = false
    @AppStorage("feat_cpu_qos") private var cpuQoS = false
    @AppStorage("feat_haptic_touch") private var hapticTouch = false
    @AppStorage("feat_memory_purge") private var memoryPurge = false
    
    @AppStorage("feat_network_qos") private var networkQoS = false
    @AppStorage("feat_dns_optimize") private var dnsOptimize = false
    @AppStorage("feat_audio_latency") private var audioLatency = false
    @AppStorage("feat_bg_suspend") private var bgSuspend = false
    
    // Status Feedback
    @State private var feedbackMessage: String? = nil
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Group 1: Optimasi Sistem & Layar (Hardware & OS Level)
                    VStack(alignment: .leading, spacing: 10) {
                        Text(lang.text(id: "Optimasi Sistem & Layar", en: "System & Display Optimization"))
                            .font(.rajdhani(16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                        
                        GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.3), cornerRadius: 18) {
                            VStack(spacing: 12) {
                                CustomToggleRow(
                                    title: lang.text(id: "Layar Anti-Sleep & Throttle Guard", en: "Anti-Sleep & Throttle Guard"),
                                    subtitle: lang.text(id: "Cegah layar meredup otomatis agar GPU tidak downclock", en: "Prevent auto screen dimming to keep GPU active"),
                                    isOn: $antiSleep,
                                    onChange: { val in
                                        engine.setDisplayAntiSleep(enabled: val)
                                        showStatus(val ? "Layar Anti-Sleep Aktif" : "Layar Anti-Sleep Dinonaktifkan")
                                    }
                                )
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                CustomToggleRow(
                                    title: lang.text(id: "Prioritas Thread CPU Utama", en: "High CPU Thread QoS"),
                                    subtitle: lang.text(id: "Tingkatkan alokasi antrian proses sistem ke User-Interactive", en: "Elevate process queue to User-Interactive QoS"),
                                    isOn: $cpuQoS,
                                    onChange: { val in
                                        engine.setHighPerformanceQoS(enabled: val)
                                        showStatus(val ? "Prioritas Thread Diaktifkan" : "Prioritas Thread Standar")
                                    }
                                )
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                CustomToggleRow(
                                    title: lang.text(id: "Respon Sentuh Haptic Terkalibrasi", en: "Calibrated Haptic Touch"),
                                    subtitle: lang.text(id: "Aktifkan aktuator getar haptic instan saat tombol ditekan", en: "Pre-warm haptic engine for instant button tactile response"),
                                    isOn: $hapticTouch,
                                    onChange: { val in
                                        engine.setHapticResponse(enabled: val)
                                        showStatus(val ? "Haptic Respon Aktif" : "Haptic Respon Dinonaktifkan")
                                    }
                                )
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                CustomToggleRow(
                                    title: lang.text(id: "Pembersih Berkas Cache & Temp RAM", en: "Temp Cache & RAM Purge"),
                                    subtitle: lang.text(id: "Kosongkan alokasi berkas sampah sementara untuk meringankan memori", en: "Clear temp storage files and signal memory heap trim"),
                                    isOn: $memoryPurge,
                                    onChange: { val in
                                        engine.setMemoryPurge(enabled: val)
                                        showStatus(val ? "Cache & Memori Telah Dibersihkan" : "Pembersih Cache Mati")
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Group 2: Konektivitas & Stabilitas Jaringan
                    VStack(alignment: .leading, spacing: 10) {
                        Text(lang.text(id: "Konektivitas & Audio Game", en: "Connectivity & Game Audio"))
                            .font(.rajdhani(16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                        
                        GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.3), cornerRadius: 18) {
                            VStack(spacing: 12) {
                                CustomToggleRow(
                                    title: lang.text(id: "Prioritas Socket Jaringan Gaming", en: "Gaming Socket Priority"),
                                    subtitle: lang.text(id: "Alokasikan bandwidth soket prioritas tinggi untuk stabilkan koneksi", en: "Prioritize socket buffer bandwidth for lower latency"),
                                    isOn: $networkQoS,
                                    onChange: { val in
                                        engine.setNetworkQoS(enabled: val)
                                        showStatus(val ? "Socket Jaringan Diprioritaskan" : "Socket Jaringan Standar")
                                    }
                                )
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                CustomToggleRow(
                                    title: lang.text(id: "DNS Anti-RTO Cloudflare Gaming", en: "Cloudflare 1.1.1.1 Gaming DNS"),
                                    subtitle: lang.text(id: "Rutekan kueri jaringan game ke 1.1.1.1 untuk kurangi packet loss", en: "Route network lookups to 1.1.1.1 to reduce packet loss"),
                                    isOn: $dnsOptimize,
                                    onChange: { val in
                                        engine.setDNSOptimizer(enabled: val)
                                        showStatus(val ? "DNS Cloudflare Aktif" : "DNS Standar")
                                    }
                                )
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                CustomToggleRow(
                                    title: lang.text(id: "Buffer Audio Latensi Rendah", en: "Low-Latency Audio Buffer"),
                                    subtitle: lang.text(id: "Kurangi buffer audio sistem ke 5ms agar respon suara tidak delay", en: "Reduce system audio buffer to 5ms for zero audio delay"),
                                    isOn: $audioLatency,
                                    onChange: { val in
                                        engine.setLowLatencyAudio(enabled: val)
                                        showStatus(val ? "Buffer Audio 5ms Aktif" : "Buffer Audio Standar")
                                    }
                                )
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                CustomToggleRow(
                                    title: lang.text(id: "Suspensi Tugas Latar Belakang", en: "Background Task Suspension"),
                                    subtitle: lang.text(id: "Hentikan sinkronisasi aplikasi background selama sesi game", en: "Throttle background sync to dedicate CPU to game"),
                                    isOn: $bgSuspend,
                                    onChange: { val in
                                        engine.setBackgroundSuspension(enabled: val)
                                        showStatus(val ? "Background Task Ditangguhkan" : "Background Task Normal")
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 90)
                }
            }
            
            // Subtle Status Feedback Banner at top
            if let msg = feedbackMessage {
                VStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: "FF1E27"))
                            .frame(width: 8, height: 8)
                        Text(msg)
                            .font(.rajdhani(13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "1A1D24"))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color(hex: "FF1E27").opacity(0.4), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.4), radius: 6, y: 3)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .onAppear {
            engine.applyAllSettings()
        }
    }
    
    private func showStatus(_ text: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            feedbackMessage = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.2)) {
                if feedbackMessage == text {
                    feedbackMessage = nil
                }
            }
        }
    }
}
