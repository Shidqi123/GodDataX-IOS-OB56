import SwiftUI

struct FeaturesView: View {
    @ObservedObject var lang = LanguageManager.shared
    
    // Performance State
    @AppStorage("feat_high_fps") private var highFPS = true
    @AppStorage("feat_frame_drop") private var antiFrameDrop = true
    @AppStorage("feat_touch_boost") private var touchBoost = true
    @AppStorage("feat_ping_optimizer") private var pingOptimizer = true
    
    // Combat & Controls Tuning
    @AppStorage("feat_dpi_boost") private var dpiBoost = true
    @AppStorage("feat_recoil_control") private var recoilControl = true
    @AppStorage("feat_sniper_scope") private var sniperScope = false
    @AppStorage("feat_3d_touch") private var threeDTouch = true
    
    // Security & Protection
    @AppStorage("feat_anti_ban") private var antiBan = true
    @AppStorage("feat_log_anonymizer") private var logAnonymizer = true
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                // Group 1: Hardware & Performance Boost (iOS Engine)
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(Color(hex: "FF1E27"))
                            .font(.system(size: 14))
                        Text(lang.text(id: "Optimasi Performa & Layar (iOS)", en: "Performance & Display (iOS)"))
                            .font(.rajdhani(16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 4)
                    
                    GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.3), cornerRadius: 18) {
                        VStack(spacing: 12) {
                            CustomToggleRow(
                                title: "120 FPS ProMotion Unlock",
                                subtitle: lang.text(id: "Kunci refresh rate 120Hz maksimal", en: "Force 120Hz display refresh rate"),
                                icon: "speedometer",
                                iconColor: Color(hex: "FF1E27"),
                                isOn: $highFPS
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Anti-Drop Frame Governor", en: "Anti-Drop Frame Governor"),
                                subtitle: lang.text(id: "Cegah lag & throttling saat war ramai", en: "Prevent FPS drops during heavy combat"),
                                icon: "flame.fill",
                                iconColor: .orange,
                                isOn: $antiFrameDrop
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Ultra Touch Response (240Hz)", en: "Ultra Touch Response (240Hz)"),
                                subtitle: lang.text(id: "Sampling layar instan untuk drag shot", en: "Zero latency touch sampling"),
                                icon: "hand.tap.fill",
                                iconColor: .cyan,
                                isOn: $touchBoost
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Stabilizer Ping & DNS", en: "Ping & DNS Stabilizer"),
                                subtitle: lang.text(id: "Optimalkan jalur buffer paket jaringan", en: "Optimize socket queue & connection"),
                                icon: "wifi",
                                iconColor: .blue,
                                isOn: $pingOptimizer
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Group 2: Combat & Controls Tuning (Free Fire)
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "scope")
                            .foregroundColor(Color(hex: "FF1E27"))
                            .font(.system(size: 14))
                        Text(lang.text(id: "Tuning Kontrol & Drag Shot (FF)", en: "Controls & Drag Shot Tuning (FF)"))
                            .font(.rajdhani(16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 4)
                    
                    GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.3), cornerRadius: 18) {
                        VStack(spacing: 12) {
                            CustomToggleRow(
                                title: lang.text(id: "DPI Drag Sensitivity Booster", en: "DPI Drag Sensitivity Booster"),
                                subtitle: lang.text(id: "Sensitivitas layar lebih licin & presisi", en: "Smoother drag aim for faster headshots"),
                                icon: "arrow.up.and.down.and.arrow.left.and.right",
                                iconColor: Color(hex: "FF1E27"),
                                isOn: $dpiBoost
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Stabilizer Recoil & Spray", en: "Recoil & Spray Stabilizer"),
                                subtitle: lang.text(id: "Pola sebaran peluru lebih stabil", en: "Stabilize crosshair recoil spray"),
                                icon: "waveform.path.ecg",
                                iconColor: Color(hex: "FF3B47"),
                                isOn: $recoilControl
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Stabilitas Scope Sniper", en: "Sniper Scope Stability"),
                                subtitle: lang.text(id: "Redam getaran saat open scope AWM", en: "Eliminate sniper crosshair shake"),
                                icon: "viewfinder",
                                iconColor: .purple,
                                isOn: $sniperScope
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Respon Sentuh 3D Touch", en: "3D Touch Trigger Response"),
                                subtitle: lang.text(id: "Haptic feedback tombol tembak instan", en: "Instant fire trigger feedback"),
                                icon: "button.programmable",
                                iconColor: .pink,
                                isOn: $threeDTouch
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Group 3: Security & Protection
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                        Text(lang.text(id: "Keamanan & Proteksi", en: "Security & Protection"))
                            .font(.rajdhani(16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 4)
                    
                    GlassCard(borderColor: Color.green.opacity(0.3), cornerRadius: 18) {
                        VStack(spacing: 12) {
                            CustomToggleRow(
                                title: "Anti-Ban Protection",
                                subtitle: lang.text(id: "Proteksi isolasi memory hook iOS", en: "iOS memory hook sandbox protection"),
                                icon: "checkmark.shield.fill",
                                iconColor: .green,
                                isOn: $antiBan
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: "Log Anonymizer",
                                subtitle: lang.text(id: "Matikan pengiriman telemetri game", en: "Disable crash telemetry reporting"),
                                icon: "eye.slash.fill",
                                iconColor: .teal,
                                isOn: $logAnonymizer
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 90)
            }
        }
    }
}
