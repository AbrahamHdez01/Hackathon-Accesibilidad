import SwiftUI

public extension Color {
    // Primary text color for light/dark adaptability
    static var textPrimary: Color {
        Color(UIColor.label)
    }

    // Secondary text color
    static var textSecondary: Color {
        Color(UIColor.secondaryLabel)
    }

    // Accent ice blue used in the UI
    static var canIceBlue: Color {
        // A soft ice blue tone
        Color(red: 0.78, green: 0.90, blue: 0.98)
    }

    // Subtle ice background tint used in some fills (fallback if referenced)
    static var canIce: Color {
        Color(red: 0.85, green: 0.93, blue: 0.98)
    }
}
