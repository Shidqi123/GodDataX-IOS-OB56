import SwiftUI

struct FeaturesView: View {
    @ObservedObject var lang = LanguageManager.shared
    @ObservedObject var engine = GamingEngineService.shared
    
    // Default: Semua toggle MATI (false) saat user baru masuk aplikasi
    @AppStorage("feat_screen_smooth_drag") private var smoothDrag = false
    @AppStorage("feat_touch_sampling_boost") private var touchSampling = false
    @AppStorage("feat_screen_anti_sleep") private var antiSleep = false
    @AppStorage("feat_cpu_qos") private var cpuQoS = false
    @AppStorage("feat_memory_purge") private var memoryPurge = false
    
    @AppStorage("feat_network_qos") private var networkQoS = false
    @AppStorage("feat_dns_optimize") private var dnsOptimize = false
    @AppStorage("feat_audio_latency") private var audioLatency = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // Group 1: Optimasi Sentuhan & Layar Free Fire
                VStack(alignment: .leading, spacing: 10) {
                    Text(lang.text(id: "Fitur Utama", en: "Main Features"))
                        .font(.rajdhani(16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                    
                    GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.3), cornerRadius: 18) {
                        VStack(spacing: 12) {
                            CustomToggleRow(
                                title: "GDX Drag",
                                subtitle: lang.text(id: "Kalibrasi inersia digitizer sentuh agar drag shot licin dan tidak kesat", en: "Calibrate digitizer inertia for smoother drag shots without friction"),
                                isOn: $smoothDrag,
                                onChange: { val in
                                    engine.setScreenSmoothDrag(enabled: val)
                                }
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Responsif Sentuhan Ekstrem", en: "Extreme Touch Response"),
                                subtitle: lang.text(id: "Pangkas latensi sampling digitizer ke tingkat tertinggi untuk respon instan", en: "Minimize digitizer polling latency for instant touch input response"),
                                isOn: $touchSampling,
                                onChange: { val in
                                    engine.setTouchSamplingBoost(enabled: val)
                                }
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Stabilizer Layar & Anti-Throttling GPU", en: "Anti-Sleep & GPU Throttle Guard"),
                                subtitle: lang.text(id: "Cegah layar meredup otomatis agar clock GPU tetap stabil saat bermain", en: "Prevent auto screen dimming to keep GPU clocks peak during combat"),
                                isOn: $antiSleep,
                                onChange: { val in
                                    engine.setDisplayAntiSleep(enabled: val)
                                }
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Prioritas Thread CPU Utama", en: "High CPU Thread QoS"),
                                subtitle: lang.text(id: "Tingkatkan alokasi antrian proses sistem ke User-Interactive", en: "Elevate process queue to User-Interactive QoS"),
                                isOn: $cpuQoS,
                                onChange: { val in
                                    engine.setHighPerformanceQoS(enabled: val)
                                }
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Pembersih Berkas Cache & Temp RAM", en: "Temp Cache & RAM Purge"),
                                subtitle: lang.text(id: "Kosongkan alokasi berkas sampah sementara untuk meringankan memori", en: "Clear temp storage files and signal memory heap trim"),
                                isOn: $memoryPurge,
                                onChange: { val in
                                    engine.setMemoryPurge(enabled: val)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Group 2: Konektivitas & Audio Game
                VStack(alignment: .leading, spacing: 10) {
                    Text(lang.text(id: "Fitur Tambahan", en: "Additional Features"))
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
                                }
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "DNS Anti-RTO Cloudflare Gaming", en: "Cloudflare 1.1.1.1 Gaming DNS"),
                                subtitle: lang.text(id: "Rutekan kueri jaringan game ke 1.1.1.1 untuk kurangi packet loss", en: "Route network lookups to 1.1.1.1 to reduce packet loss"),
                                isOn: $dnsOptimize,
                                onChange: { val in
                                    engine.setDNSOptimizer(enabled: val)
                                }
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Buffer Audio Latensi Rendah", en: "Low-Latency Audio Buffer"),
                                subtitle: lang.text(id: "Kurangi buffer audio sistem ke 5ms agar respon suara tidak delay", en: "Reduce system audio buffer to 5ms for zero audio delay"),
                                isOn: $audioLatency,
                                onChange: { val in
                                    engine.setLowLatencyAudio(enabled: val)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 90)
            }
        }
        .onAppear {
            engine.applyAllSettings()
        }
    }
}
