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
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "FF1E27"))
                .onChange(of: isOn) { _ in
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
        }
        .padding(.vertical, 4)
    }
}
