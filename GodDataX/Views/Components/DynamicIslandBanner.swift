import SwiftUI

struct DynamicIslandBanner: View {
    @State private var isPulsing = false
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(hex: "00FF66"))
                .frame(width: 8, height: 8)
                .scaleEffect(isPulsing ? 1.3 : 1.0)
                .opacity(isPulsing ? 0.7 : 1.0)
                .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isPulsing)
            
            Image(systemName: "shield.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "FF1E27"))
            
            Text("GODDATAX SECURED • OB56")
                .font(.rajdhani(13, weight: .bold))
                .foregroundColor(.white)
                .kerning(1.2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color(hex: "111116"))
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "FF1E27").opacity(0.8), Color(hex: "880000").opacity(0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.6), radius: 10, y: 5)
        )
        .onAppear {
            isPulsing = true
        }
    }
}

// Hex color extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
