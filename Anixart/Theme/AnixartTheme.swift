import SwiftUI

enum AnixartColor {
    static let background = Color(hex: 0x121212)
    static let surface = Color(hex: 0x1E1E1E)
    static let surfaceElevated = Color(hex: 0x252525)
    static let accent = Color(hex: 0xF04E5C)
    static let accentPurple = Color(hex: 0xB976FF)
    static let accentDeepPurple = Color(hex: 0x7C4DFF)
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0xB3B3B3)
    static let textDisabled = Color(hex: 0x666666)
    static let divider = Color.white.opacity(0.12)
    static let ripple = Color.white.opacity(0.1)
    static let green = Color(hex: 0x4CAF50)
    static let yellow = Color(hex: 0xFFC107)
    static let blue = Color(hex: 0x2196F3)
}

extension Color {
    init(hex: Int) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}

enum AnixartFont {
    static let title = Font.system(size: 20, weight: .bold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 15, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 13, weight: .medium, design: .rounded)
    static let small = Font.system(size: 11, weight: .medium, design: .rounded)
}

struct AnixartCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AnixartColor.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func anixartCard() -> some View {
        modifier(AnixartCardStyle())
    }
}
