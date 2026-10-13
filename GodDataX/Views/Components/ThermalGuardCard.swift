import SwiftUI

struct ThermalGuardCard: View {
    @ObservedObject var engine = GamingEngineService.shared
    @ObservedObject var lang = LanguageManager.shared
    
    // Status warna sesuai tema GodDataX Merah
    var thermalColor: Color {
        switch engine.thermalState {
        case .nominal:
            return Color.white.opacity(0.9)
        case .fair:
            return Color(hex: "FF1E27").opacity(0.7)
        case .serious, .critical:
            return Color(hex: "FF1E27")
        @unknown default:
            return Color.white.opacity(0.9)
        }
    }
    
    var thermalTitle: String {
        switch engine.thermalState {
        case .nominal:
            return lang.text(id: "OPTIMAL / NORMAL", en: "OPTIMAL / NORMAL")
        case .fair:
            return lang.text(id: "HANGAT NORMAL", en: "WARM (SAFE)")
        case .serious:
            return lang.text(id: "PANAS (THROTTLING)", en: "HOT (THROTTLING)")
        case .critical:
            return lang.text(id: "KRITIS (OVERHEAT)", en: "CRITICAL OVERHEAT")
        @unknown default:
            return "NORMAL"
        }
    }
    
    var thermalDescription: String {
        switch engine.thermalState {
        case .nominal:
            return lang.text(id: "SoC iPhone berjalan di frekuensi clock maksimum tanpa throttling.", en: "iPhone SoC is at peak clocks without thermal throttling.")
        case .fair:
            return lang.text(id: "Suhu perangkat mulai naik. Performa game masih stabil.", en: "Device temperature rising. Game performance still stable.")
        case .serious:
            return lang.text(id: "Layar berisiko meredup otomatis dan FPS drop. Disarankan pendinginan.", en: "Risk of auto screen dimming and FPS drop. Cooldown advised.")
        case .critical:
            return lang.text(id: "Suhu ekstrem. Segera dinginkan perangkat untuk melindungi baterai.", en: "Extreme temperature. Cool down immediately to protect battery.")
        @unknown default:
            return ""
        }
    }
    
    var body: some View {
        GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.4), cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 16) {
                
                // 1. Header Card GodDataX Red Theme
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "FF1E27"))
                                .frame(width: 4, height: 16)
                            
                            Text("GDX THERMAL SHIELD")
                                .font(.rajdhani(18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(lang.text(id: "Monitor Suhu Real-Time & Throttle Guard", en: "Real-time Thermal Monitor & Throttle Guard"))
                            .font(.rajdhani(12, weight: .medium))
                            .foregroundColor(Color.gray.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    Text(thermalTitle)
                        .font(.rajdhani(11, weight: .bold))
                        .foregroundColor(thermalColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color(hex: "FF1E27").opacity(0.15)))
                        .overlay(Capsule().stroke(Color(hex: "FF1E27").opacity(0.4), lineWidth: 1))
                }
                
                Divider().background(Color.white.opacity(0.08))
                
                // 2. Telemetri Suhu Real-Time
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text(String(format: "%.1f", engine.simulatedTemperature))
                                .font(.rajdhani(36, weight: .bold))
                                .foregroundColor(.white)
                            Text("°C")
                                .font(.rajdhani(18, weight: .bold))
                                .foregroundColor(Color(hex: "FF1E27"))
                        }
                        
                        Text(lang.text(id: "Estimasi Suhu SoC", en: "Estimated SoC Temp"))
                            .font(.rajdhani(11, weight: .medium))
                            .foregroundColor(Color.gray.opacity(0.75))
                    }
                    
                    Spacer()
                    
                    // Visualisasi Bar Beban Termal
                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 4) {
                            ForEach(0..<10) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(barColor(for: index))
                                    .frame(width: 8, height: 18)
                            }
                        }
                        
                        Text(thermalDescription)
                            .font(.rajdhani(11, weight: .medium))
                            .foregroundColor(Color.gray.opacity(0.75))
                            .multilineTextAlignment(.trailing)
                            .lineLimit(2)
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "171821")))
                
                // 3. Toggle Auto-Thermal Guard & Tombol Dinginkan Sekarang
                VStack(spacing: 12) {
                    CustomToggleRow(
                        title: "Auto Thermal Guard",
                        subtitle: lang.text(id: "Otomatis pangkas alokasi cache saat iPhone mulai memanas", en: "Automatically trims cache allocation when iPhone gets warm"),
                        isOn: $engine.isThermalGuardActive
                    )
                    
                    // Tombol Dinginkan Sekarang (Tema Merah GodDataX)
                    Button(action: {
                        engine.triggerEmergencyCooldown()
                    }) {
                        HStack(spacing: 8) {
                            if engine.isCoolingInProgress {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "snow")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            
                            Text(engine.isCoolingInProgress ? lang.text(id: "SEDANG DIDINGINKAN...", en: "COOLING DOWN...") : lang.text(id: "DINGINKAN SEKARANG (FLUSH CACHE & RAM)", en: "COOLDOWN NOW (FLUSH CACHE & RAM)"))
                                .font(.rajdhani(14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    colors: [Color(hex: "FF1E27"), Color(hex: "A01016")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: Color(hex: "FF1E27").opacity(0.35), radius: 6, y: 2)
                    }
                    .disabled(engine.isCoolingInProgress)
                }
                
                // Notifikasi hasil cooldown
                if !engine.lastCooldownMessage.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "FF1E27"))
                        Text(engine.lastCooldownMessage)
                            .font(.rajdhani(11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(hex: "171821")))
                }
            }
        }
    }
    
    private func barColor(for index: Int) -> Color {
        let maxActiveBars: Int
        switch engine.thermalState {
        case .nominal: maxActiveBars = 3
        case .fair: maxActiveBars = 6
        case .serious: maxActiveBars = 8
        case .critical: maxActiveBars = 10
        @unknown default: maxActiveBars = 3
        }
        
        if index < maxActiveBars {
            return Color(hex: "FF1E27")
        } else {
            return Color.white.opacity(0.08)
        }
    }
}
