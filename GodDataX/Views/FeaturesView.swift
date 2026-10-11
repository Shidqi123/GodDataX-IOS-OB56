import SwiftUI

struct FeaturesView: View {
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
                    Text("OB56 FEATURES")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Configured for Free Fire OB56 Engine")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "FF1E27"))
                }
                .padding(.top, 14)
                
                // Group 1: Security & Protection
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                        Text("Security & Bypass")
                            .font(.system(size: 15, weight: .bold))
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
                        Text("Aim & Combat Tuning")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 4)
                    
                    GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.3), cornerRadius: 18) {
                        VStack(spacing: 12) {
                            CustomToggleRow(
                                title: "Aim Assist OB56",
                                subtitle: "Magnetic crosshair targeting",
                                icon: "target",
                                iconColor: Color(hex: "FF1E27"),
                                isOn: $aimAssist
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: "Headshot Calibration",
                                subtitle: "Auto adjust vertical drag recoil",
                                icon: "cross.circle.fill",
                                iconColor: Color(hex: "FF3B47"),
                                isOn: $headshotAssist
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: "Zero Recoil Stabilizer",
                                subtitle: "Smooth weapon spray patterns",
                                icon: "waveform.path.ecg",
                                iconColor: Color(hex: "FF5E68"),
                                isOn: $recoilControl
                            )
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            CustomToggleRow(
                                title: "Scope Stability",
                                subtitle: "Removes sniper weapon sway",
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
                        Text("Device Boost (iOS)")
                            .font(.system(size: 15, weight: .bold))
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
