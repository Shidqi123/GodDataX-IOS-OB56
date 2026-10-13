import SwiftUI

struct TouchMatrixCard: View {
    @ObservedObject var engine = GamingEngineService.shared
    @ObservedObject var lang = LanguageManager.shared
    
    // State untuk Interactive Drag Test Box
    @State private var dragCurrentOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    @State private var hasHitHeadshotZone: Bool = false
    @State private var showExportSuccess: Bool = false
    
    var body: some View {
        GlassCard(borderColor: Color(hex: "FF1E27").opacity(0.4), cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 18) {
                
                // 1. Header Card GodDataX Red Theme
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "FF1E27"))
                                .frame(width: 4, height: 16)
                            
                            Text("GDX TOUCH MATRIX")
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
                
                // 2. Preset Senjata Cepat (GodDataX Red Theme)
                VStack(alignment: .leading, spacing: 8) {
                    Text(lang.text(id: "PRESET SENJATA", en: "WEAPON PRESETS"))
                        .font(.rajdhani(11, weight: .bold))
                        .foregroundColor(Color.gray.opacity(0.75))
                        .tracking(1.2)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(WeaponPreset.allCases) { preset in
                                Button(action: {
                                    engine.applyPreset(preset)
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: preset.icon)
                                            .font(.system(size: 11, weight: .bold))
                                        Text(preset.rawValue)
                                            .font(.rajdhani(13, weight: .bold))
                                    }
                                    .padding(.vertical, 7)
                                    .padding(.horizontal, 12)
                                    .background(
                                        Capsule()
                                            .fill(engine.activePreset == preset ? Color(hex: "FF1E27") : Color(hex: "171821"))
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(engine.activePreset == preset ? Color(hex: "FF1E27") : Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                    .foregroundColor(.white)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                // 3. Slider Sumbu X (Horizontal Look)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SUMBU X • HORIZONTAL LOOK")
                                .font(.rajdhani(13, weight: .bold))
                                .foregroundColor(.white)
                            Text(lang.text(id: "Kelincahan putaran layar dan geser horizontal", en: "Horizontal look and camera agility"))
                                .font(.rajdhani(11, weight: .medium))
                                .foregroundColor(Color.gray.opacity(0.75))
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Button(action: { engine.adjustSensitivityX(by: -0.05) }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color(hex: "232630"))
                                    .clipShape(Circle())
                            }
                            
                            Text(String(format: "%.2fx", engine.sensitivityX))
                                .font(.rajdhani(16, weight: .bold))
                                .foregroundColor(Color(hex: "FF1E27"))
                                .frame(minWidth: 46)
                            
                            Button(action: { engine.adjustSensitivityX(by: 0.05) }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color(hex: "232630"))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    Slider(
                        value: $engine.sensitivityX,
                        in: 0.50...5.00,
                        step: 0.05
                    )
                    .accentColor(Color(hex: "FF1E27"))
                    .disabled(!engine.isMasterTouchEnabled)
                    .opacity(engine.isMasterTouchEnabled ? 1.0 : 0.45)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "171821")))
                
                // 4. Slider Sumbu Y (Vertical Drag Headshot)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SUMBU Y • VERTICAL DRAG SHOT")
                                .font(.rajdhani(13, weight: .bold))
                                .foregroundColor(.white)
                            Text(lang.text(id: "Kelicinan tarikan vertikal khusus headshot", en: "Vertical drag flick multiplier for headshots"))
                                .font(.rajdhani(11, weight: .medium))
                                .foregroundColor(Color.gray.opacity(0.75))
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Button(action: { engine.adjustSensitivityY(by: -0.05) }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color(hex: "232630"))
                                    .clipShape(Circle())
                            }
                            
                            Text(String(format: "%.2fx", engine.sensitivityY))
                                .font(.rajdhani(16, weight: .bold))
                                .foregroundColor(Color(hex: "FF1E27"))
                                .frame(minWidth: 46)
                            
                            Button(action: { engine.adjustSensitivityY(by: 0.05) }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color(hex: "232630"))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    Slider(
                        value: $engine.sensitivityY,
                        in: 0.50...5.00,
                        step: 0.05
                    )
                    .accentColor(Color(hex: "FF1E27"))
                    .disabled(!engine.isMasterTouchEnabled)
                    .opacity(engine.isMasterTouchEnabled ? 1.0 : 0.45)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "171821")))
                
                // 5. Arena Uji Tarikan Drag (Test Pad)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(lang.text(id: "ARENA UJI TARIKAN DRAG", en: "DRAG FLICK TEST PAD"))
                            .font(.rajdhani(12, weight: .bold))
                            .foregroundColor(Color.gray.opacity(0.85))
                        
                        Spacer()
                        
                        if hasHitHeadshotZone {
                            Text("TARGET HEADSHOT TERCAPAI")
                                .font(.rajdhani(12, weight: .bold))
                                .foregroundColor(Color(hex: "FF1E27"))
                                .transition(.opacity)
                        } else {
                            Text("Tarik Tombol Ke Atas")
                                .font(.rajdhani(11, weight: .medium))
                                .foregroundColor(Color.gray.opacity(0.6))
                        }
                    }
                    
                    ZStack {
                        // Background Box
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "0D0E12"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(hasHitHeadshotZone ? Color(hex: "FF1E27") : Color.white.opacity(0.08), lineWidth: 1)
                            )
                        
                        // Headshot Target Zone di bagian atas
                        VStack {
                            HStack {
                                Spacer()
                                Capsule()
                                    .fill(Color(hex: "FF1E27").opacity(hasHitHeadshotZone ? 0.35 : 0.15))
                                    .frame(width: 140, height: 22)
                                    .overlay(
                                        Text("HEADSHOT ZONE")
                                            .font(.rajdhani(10, weight: .bold))
                                            .foregroundColor(Color(hex: "FF1E27"))
                                    )
                                Spacer()
                            }
                            .padding(.top, 8)
                            Spacer()
                        }
                        
                        // Titik Drag Visualizer
                        if isDragging {
                            Circle()
                                .fill(Color(hex: "FF1E27"))
                                .frame(width: 26, height: 26)
                                .shadow(color: Color(hex: "FF1E27"), radius: 6)
                                .offset(x: dragCurrentOffset.width, y: dragCurrentOffset.height)
                        } else {
                            VStack(spacing: 4) {
                                Image(systemName: "hand.draw.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.white.opacity(0.35))
                                Text(lang.text(id: "Tahan dan geser ke atas untuk menguji tarikan", en: "Touch and flick upward to test drag"))
                                    .font(.rajdhani(12, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.4))
                            }
                        }
                    }
                    .frame(height: 110)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDragging = true
                                let scaledX = value.translation.width * CGFloat(engine.sensitivityX * 0.4)
                                let scaledY = value.translation.height * CGFloat(engine.sensitivityY * 0.4)
                                dragCurrentOffset = CGSize(width: scaledX, height: scaledY)
                                
                                if scaledY < -30 && !hasHitHeadshotZone {
                                    hasHitHeadshotZone = true
                                    let haptic = UINotificationFeedbackGenerator()
                                    haptic.notificationOccurred(.success)
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                                dragCurrentOffset = .zero
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    withAnimation {
                                        hasHitHeadshotZone = false
                                    }
                                }
                            }
                    )
                }
                
                // 6. Sinkronisasi Konfigurasi
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(Color(hex: "FF1E27"))
                        .font(.system(size: 13))
                    
                    Text(lang.text(id: "Sinkronisasi Konfigurasi Touch Engine", en: "Touch Engine Config Synchronization"))
                        .font(.rajdhani(12, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                    
                    Spacer()
                    
                    Button(action: {
                        engine.exportTouchConfig()
                        let haptic = UIImpactFeedbackGenerator(style: .medium)
                        haptic.impactOccurred()
                        withAnimation {
                            showExportSuccess = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                showExportSuccess = false
                            }
                        }
                    }) {
                        Text(showExportSuccess ? "TERSINKRON" : "SYNC CONFIG")
                            .font(.rajdhani(11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color(hex: "FF1E27")))
                    }
                }
                .padding(.top, 2)
            }
        }
    }
}
