import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var borderColor: Color = Color.white.opacity(0.12)
    var cornerRadius: CGFloat = 16
    
    init(borderColor: Color = Color.white.opacity(0.12), cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(hex: "13131A").opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                    )
            )
    }
}

struct CustomToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.rajdhani(16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.rajdhani(13, weight: .medium))
                    .foregroundColor(Color.gray.opacity(0.85))
            }
            
            Spacer()
            
            GamingToggle(isOn: $isOn)
        }
        .padding(.vertical, 4)
    }
}

// Gaming Toggle matching reference Image 4 (Red Track, Squircle Thumb)
struct GamingToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                isOn.toggle()
            }
        }) {
            ZStack(alignment: isOn ? .trailing : .leading) {
                // Background Track
                RoundedRectangle(cornerRadius: 8)
                    .fill(isOn ? Color(hex: "FF1E27") : Color(hex: "232630"))
                    .frame(width: 48, height: 26)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isOn ? Color(hex: "FF1E27") : Color.white.opacity(0.12), lineWidth: 1)
                    )
                
                // Rounded Square Thumb matching Image 4
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .padding(.horizontal, 3)
                    .shadow(color: Color.black.opacity(0.35), radius: 2, y: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
