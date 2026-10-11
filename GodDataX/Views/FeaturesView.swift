import SwiftUI

struct FeaturesView: View {
    @ObservedObject var lang = LanguageManager.shared
    
    // Combat Features State
    @State private var aimAssist = true
    @State private var headshotAssist = true
    @State private var recoilControl = false
    @State private var sniperScope = false
    
    // Security State
    @State private var antiBan = true
    @State private var logAnonymizer = true
    
    // Performance State
    @State private var highFPS = true
    @State private var touchBoost = true
    @State private var threeDTouch = true
    @State private var pingReducer = true
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Text(lang.text(id: "FITUR OB56", en: "OB56 FEATURES"))
                        .font(.rajdhani(26, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(lang.text(id: "Dikonfigurasi untuk Engine Free Fire OB56", en: "Configured for Free Fire OB56 Engine"))
                        .font(.rajdhani(13, weight: .medium))
                        .foregroundColor(Color(hex: "FF1E27"))
                }
                .padding(.top, 14)
                
                // Group 1: Security & Protection
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                        Text(lang.text(id: "Keamanan & Bypass", en: "Security & Bypass"))
                            .font(.rajdhani(16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 4)
                    
                    GlassCard(borderColor: Color.green.opacity(0.3), cornerRadius: 18) {
                        VStack(spacing: 12) {
                            CustomToggleRow(
                                title: "Anti-Ban Protection",
                                subtitle: "OB56 Memory hook bypass",
                                icon: "checkmark.shield.fill",
                                iconColor: .green,
                                isOn: $antiBan
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: "Log Anonymizer",
                                subtitle: "Disable crash telemetry reporting",
                                icon: "eye.slash.fill",
                                iconColor: .teal,
                                isOn: $logAnonymizer
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Group 2: Combat Enhancements
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "scope")
                            .foregroundColor(Color(hex: "FF1E27"))
                            .font(.system(size: 14))
                        Text(lang.text(id: "Tuning Aim & Tempur", en: "Aim & Combat Tuning"))
                            .font(.rajdhani(16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 4)
                    
                    GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.3), cornerRadius: 18) {
                        VStack(spacing: 12) {
                            CustomToggleRow(
                                title: lang.text(id: "Bantuan Bidik OB56", en: "Aim Assist OB56"),
                                subtitle: lang.text(id: "Target crosshair magnetik", en: "Magnetic crosshair targeting"),
                                icon: "target",
                                iconColor: Color(hex: "FF1E27"),
                                isOn: $aimAssist
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Kalibrasi Headshot", en: "Headshot Calibration"),
                                subtitle: lang.text(id: "Stabilisasi recoil drag vertikal", en: "Auto adjust vertical drag recoil"),
                                icon: "cross.circle.fill",
                                iconColor: Color(hex: "FF3B47"),
                                isOn: $headshotAssist
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Stabilizer Tanpa Recoil", en: "Zero Recoil Stabilizer"),
                                subtitle: lang.text(id: "Pola spray senjata lebih halus", en: "Smooth weapon spray patterns"),
                                icon: "waveform.path.ecg",
                                iconColor: Color(hex: "FF5E68"),
                                isOn: $recoilControl
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: lang.text(id: "Stabilitas Scope", en: "Scope Stability"),
                                subtitle: lang.text(id: "Hilangkan goyangan senjata sniper", en: "Removes sniper weapon sway"),
                                icon: "viewfinder",
                                iconColor: .purple,
                                isOn: $sniperScope
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Group 3: Hardware & Performance Boost
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(Color(hex: "FF1E27"))
                            .font(.system(size: 14))
                        Text(lang.text(id: "Peningkatan Perangkat (iOS)", en: "Device Boost (iOS)"))
                            .font(.rajdhani(16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 4)
                    
                    GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.3), cornerRadius: 18) {
                        VStack(spacing: 12) {
                            CustomToggleRow(
                                title: "120 FPS ProMotion Unlock",
                                subtitle: "Force 120Hz display refresh rate",
                                icon: "speedometer",
                                iconColor: Color(hex: "FF1E27"),
                                isOn: $highFPS
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: "Ultra Touch Response",
                                subtitle: "Minimize touch sampling latency",
                                icon: "hand.tap.fill",
                                iconColor: .cyan,
                                isOn: $touchBoost
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: "3D Touch Trigger",
                                subtitle: "Haptic feedback on fire input",
                                icon: "button.programmable",
                                iconColor: .pink,
                                isOn: $threeDTouch
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: "Network Ping Reducer",
                                subtitle: "Bypass packet queue throttling",
                                icon: "wifi",
                                iconColor: .blue,
                                isOn: $pingReducer
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 80)
            }
        }
    }
}
