import SwiftUI

struct TouchMatrixCard: View {
    @ObservedObject var engine = GamingEngineService.shared
    @ObservedObject var lang = LanguageManager.shared
    
    @State private var showExportSuccess: Bool = false
    
    var body: some View {
        GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.35), cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 20) {
                
                // 1. Header Card: GDX Touch Matrix
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "FF1E27"))
                                .frame(width: 4, height: 16)
                            
                            Text("GDX Touch Matrix")
                                .font(.rajdhani(18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(lang.text(id: "Multiplikator Sumbu X & Y Engine OB56", en: "OB56 Engine X & Y Axis Multiplier"))
                            .font(.rajdhani(12, weight: .medium))
                            .foregroundColor(Color.gray.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    GamingToggle(isOn: $engine.isMasterTouchEnabled) { _ in
                        let haptic = UIImpactFeedbackGenerator(style: .medium)
                        haptic.impactOccurred()
                    }
                }
                
                Divider().background(Color.white.opacity(0.08))
                
                // 2. Slider Sens X (Sesuai Desain Gambar 2)
                CustomLevelSlider(
                    title: "Sens X",
                    level: $engine.sensXLevel,
                    minLevel: 1,
                    maxLevel: 7,
                    isEnabled: engine.isMasterTouchEnabled,
                    onChange: { val in
                        engine.updateSensXLevel(val)
                    }
                )
                
                Divider().background(Color.white.opacity(0.06))
                
                // 3. Slider Sens Y (Sesuai Desain Gambar 2)
                CustomLevelSlider(
                    title: "Sens Y",
                    level: $engine.sensYLevel,
                    minLevel: 1,
                    maxLevel: 7,
                    isEnabled: engine.isMasterTouchEnabled,
                    onChange: { val in
                        engine.updateSensYLevel(val)
                    }
                )
                
                Divider().background(Color.white.opacity(0.08))
                
                // 4. Native Engine Direct Accelerator (100% Anti-Ban, Tanpa Dylib)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled")
                            .foregroundColor(Color(hex: "FF1E27"))
                            .font(.system(size: 13))
                        
                        Text(lang.text(id: "Mode Native (100% Anti-Ban, Tanpa Dylib)", en: "Native Mode (100% Anti-Ban, No Dylib)"))
                            .font(.rajdhani(13, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(engine.isMasterTouchEnabled ? "AKTIF" : "NONAKTIF")
                            .font(.rajdhani(11, weight: .bold))
                            .foregroundColor(engine.isMasterTouchEnabled ? Color(hex: "FF1E27") : Color.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(engine.isMasterTouchEnabled ? Color(hex: "FF1E27").opacity(0.15) : Color.white.opacity(0.05))
                            )
                    }
                    
                    Text(lang.text(id: "Sens X & Y langsung mempercepat sampling layar ProMotion 120Hz dan memprioritaskan antrean sentuh hardware tanpa menyentuh file game.", en: "Sens X & Y directly accelerate ProMotion 120Hz screen sampling and prioritize hardware touch queues without touching game files."))
                        .font(.rajdhani(11, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.85))
                        .lineSpacing(2)
                    
                    HStack(spacing: 10) {
                        Button(action: {
                            engine.openSystemTouchSettings()
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 10))
                                Text("SETTING SENTUHAN IOS")
                                    .font(.rajdhani(11, weight: .bold))
                            }
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.08))
                            )
                        }
                        
                        Button(action: {
                            engine.applyNativeTouchBoost()
                            withAnimation {
                                showExportSuccess = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation {
                                    showExportSuccess = false
                                }
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: showExportSuccess ? "checkmark" : "bolt.fill")
                                    .font(.system(size: 10))
                                Text(showExportSuccess ? "DITERAPKAN" : "TERAPKAN SISTEM")
                                    .font(.rajdhani(11, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "FF1E27"))
                            )
                        }
                    }
                }
            }
        }
    }
}

/// Custom Slider persis sesuai Gambar Referensi 2:
/// - Judul di kiri (Sens X / Sens Y)
/// - Angka "Level: X" warna merah di kanan
/// - Active track merah & Inactive track abu-abu
/// - Thumb berbentuk Rounded Capsule Merah vertikal
/// - Angka 1, 4, 7 di bawah slider
struct CustomLevelSlider: View {
    let title: String
    @Binding var level: Int
    var minLevel: Int = 1
    var maxLevel: Int = 7
    var isEnabled: Bool = true
    var onChange: ((Int) -> Void)? = nil
    
    @State private var dragPositionX: CGFloat? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Baris Atas: Label Kiri & Level Kanan
            HStack {
                Text(title)
                    .font(.rajdhani(16, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Level: \(level)")
                    .font(.rajdhani(16, weight: .bold))
                    .foregroundColor(Color(hex: "D3162A"))
            }
            
            // Slider Track & Thumb (Desain Gambar 2)
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let thumbWidth: CGFloat = 10
                let thumbHeight: CGFloat = 26
                let trackHeight: CGFloat = 8
                
                let progress = CGFloat(level - minLevel) / CGFloat(maxLevel - minLevel)
                let activeWidth = progress * (totalWidth - thumbWidth)
                
                ZStack(alignment: .leading) {
                    
                    // Inactive Track (Abu-abu Gelap)
                    Capsule()
                        .fill(Color(hex: "282C34"))
                        .frame(height: trackHeight)
                        .frame(maxWidth: .infinity)
                    
                    // Active Track (Merah GodDataX)
                    Capsule()
                        .fill(Color(hex: "D3162A"))
                        .frame(width: max(trackHeight, activeWidth + (thumbWidth / 2)), height: trackHeight)
                    
                    // Thumb: Rounded Capsule Merah Vertikal (Gambar 2)
                    Capsule()
                        .fill(Color(hex: "D3162A"))
                        .frame(width: thumbWidth, height: thumbHeight)
                        .offset(x: activeWidth)
                        .shadow(color: Color(hex: "D3162A").opacity(0.4), radius: 3)
                }
                .frame(height: thumbHeight)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            guard isEnabled else { return }
                            let touchX = max(0, min(gesture.location.x, totalWidth - thumbWidth))
                            let ratio = touchX / (totalWidth - thumbWidth)
                            let newLevel = minLevel + Int(round(ratio * CGFloat(maxLevel - minLevel)))
                            let clamped = max(minLevel, min(newLevel, maxLevel))
                            if clamped != level {
                                level = clamped
                                let haptic = UISelectionFeedbackGenerator()
                                haptic.selectionChanged()
                                onChange?(clamped)
                            }
                        }
                )
            }
            .frame(height: 26)
            .opacity(isEnabled ? 1.0 : 0.45)
            
            // Baris Bawah: Angka 1, 4, 7
            HStack {
                Text("\(minLevel)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color.gray.opacity(0.6))
                
                Spacer()
                
                Text("\((minLevel + maxLevel) / 2)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color.gray.opacity(0.6))
                
                Spacer()
                
                Text("\(maxLevel)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Color.gray.opacity(0.6))
            }
            .padding(.horizontal, 2)
        }
    }
}
