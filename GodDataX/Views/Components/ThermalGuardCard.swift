import SwiftUI

struct ThermalGuardCard: View {
    @ObservedObject var engine = GamingEngineService.shared
    @ObservedObject var lang = LanguageManager.shared
    @State private var cooldownProgress: CGFloat = 0.0
    @State private var isCooldownSuccess: Bool = false
    
    // Status warna sesuai tema GodDataX Merah (Real-Time Responsif)
    var thermalColor: Color {
        if engine.simulatedTemperature >= 38.0 || engine.thermalState == .serious || engine.thermalState == .critical {
            return Color(hex: "FF1E27")
        } else if engine.simulatedTemperature >= 34.5 || engine.thermalState == .fair {
            return Color(hex: "FF1E27").opacity(0.8)
        } else {
            return Color.white.opacity(0.9)
        }
    }
    
    // Status teks badge real-time: langsung berubah saat suhu perangkat naik
    var thermalTitle: String {
        if engine.simulatedTemperature >= 42.0 || engine.thermalState == .critical {
            return lang.text(id: "KRITIS (OVERHEAT)", en: "CRITICAL OVERHEAT")
        } else if engine.simulatedTemperature >= 38.0 || engine.thermalState == .serious {
            return lang.text(id: "PANAS (THROTTLING)", en: "HOT (THROTTLING)")
        } else if engine.simulatedTemperature >= 34.5 || engine.thermalState == .fair {
            return lang.text(id: "HANGAT (STABIL)", en: "WARM (STABLE)")
        } else {
            return lang.text(id: "OPTIMAL / NORMAL", en: "OPTIMAL / NORMAL")
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
                
                // 1. Header Card GodDataX Red Theme (Tanpa Garis Merah di Kiri Teks)
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("GDX Thermal Shield")
                            .font(.rajdhani(18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(lang.text(id: "Monitor Suhu Real-Time & Throttle Guard", en: "Real-time Thermal Monitor & Throttle Guard"))
                            .font(.rajdhani(12, weight: .medium))
                            .foregroundColor(Color.gray.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    // Badge Real-time yang langsung berubah saat suhu naik/turun
                    Text(thermalTitle)
                        .font(.rajdhani(11, weight: .bold))
                        .foregroundColor(thermalColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color(hex: "FF1E27").opacity(0.15)))
                        .overlay(Capsule().stroke(Color(hex: "FF1E27").opacity(0.4), lineWidth: 1))
                        .animation(.easeInOut(duration: 0.3), value: thermalTitle)
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
                    
                    // Indikator Ukuran Cache Terdeteksi
                    HStack {
                        Text(lang.text(id: "Cache & Buffering Terdeteksi:", en: "Detected Cache & Buffering:"))
                            .font(.rajdhani(11, weight: .semibold))
                            .foregroundColor(Color.gray.opacity(0.85))
                        
                        Spacer()
                        
                        Text(String(format: "%.1f MB", engine.detectedCacheMB))
                            .font(.rajdhani(11, weight: .bold))
                            .foregroundColor(engine.detectedCacheMB > 100 ? Color(hex: "FF1E27") : Color.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(engine.detectedCacheMB > 100 ? Color(hex: "FF1E27").opacity(0.18) : Color.white.opacity(0.06))
                            )
                    }
                    
                    // Tombol Dinginkan Sekarang (Animasi Halus & Tenang dari Kiri ke Kanan)
                    Button(action: {
                        guard !engine.isCoolingInProgress else { return }
                        cooldownProgress = 0.0
                        isCooldownSuccess = false
                        let dynamicDuration = engine.computeCooldownDuration()
                        engine.triggerEmergencyCooldown(customDuration: dynamicDuration)
                        
                        withAnimation(.easeInOut(duration: dynamicDuration)) {
                            cooldownProgress = 1.0
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + dynamicDuration) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isCooldownSuccess = true
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + dynamicDuration + 1.2) {
                            withAnimation(.easeInOut(duration: 0.35)) {
                                isCooldownSuccess = false
                                cooldownProgress = 0.0
                            }
                        }
                    }) {
                        ZStack {
                            // Background bar animasi mengisi halus dari kiri ke kanan
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "171821"))
                                    
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(LinearGradient(
                                            colors: [Color(hex: "FF1E27"), Color(hex: "A01016")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                        .frame(width: engine.isCoolingInProgress ? max(0, min(geo.size.width, geo.size.width * cooldownProgress)) : geo.size.width)
                                    
                                    // Garis aksen lembut di ujung progress bar
                                    if engine.isCoolingInProgress && cooldownProgress > 0.02 && cooldownProgress < 0.98 {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.35))
                                            .frame(width: 3, height: geo.size.height)
                                            .offset(x: max(0, (geo.size.width * cooldownProgress) - 1.5))
                                    }
                                }
                            }
                            
                            // Konten Teks & Ikon Tenang (Tanpa Putaran Pusing)
                            HStack(spacing: 8) {
                                if isCooldownSuccess {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                } else {
                                    Image(systemName: "snow")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                
                                Text(isCooldownSuccess ? lang.text(id: "PENDINGINAN SELESAI", en: "COOLDOWN COMPLETED") : (engine.isCoolingInProgress ? lang.text(id: "MEMBERSIHKAN CACHE & MEMORI...", en: "FLUSHING CACHE & MEMORY...") : lang.text(id: "DINGINKAN SEKARANG (FLUSH CACHE & RAM)", en: "COOLDOWN NOW (FLUSH CACHE & RAM)")))
                                    .font(.rajdhani(13, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
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
