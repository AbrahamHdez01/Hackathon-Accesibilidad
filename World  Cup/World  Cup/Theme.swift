import SwiftUI

// MARK: - México (Ruta Accesible)
struct ThemeColor {
    // México: Verde, Rojo, Lima (más fuertes)
    static let mexGreen = Color(hex: "004D2E")      // Verde México más fuerte
    static let mexRed = Color(hex: "DA291C")        // Rojo México
    static let mexLime = Color(hex: "7FFF00")       // Lima acento más fuerte (Chartreuse)
    
    // USA: Navy, Rojo, Blanco
    static let usaNavy = Color(hex: "0B1D39")       // Navy USA
    static let usaRed = Color(hex: "E41E2B")        // Rojo USA
    static let usaWhite = Color(hex: "FFFFFF")      // Blanco USA
    
    // Canadá: Rojo, Azul Hielo, Hielo
    static let canRed = Color(hex: "D90429")        // Rojo Canadá
    static let canIceBlue = Color(hex: "B3D9FF")    // Azul hielo
    static let canIce = Color(hex: "F7F7F7")        // Hielo
    
    // Colores de texto (comunes)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.75)
    static let textTertiary = Color.white.opacity(0.6)
    
    // Colores de estado
    static let statusLive = Color.red
    static let statusUpcoming = Color.orange
    static let statusPrevious = Color.gray
    
    // Colores de ruta
    static let routeAccessible = ThemeColor.mexLime
    static let routeStandard = Color(red: 0.2, green: 0.5, blue: 0.9)
    
    // Mantener compatibilidad con colores existentes
    static let routeDarkGreen = ThemeColor.mexGreen
    static let routePanelGreen = ThemeColor.mexGreen.opacity(0.8)
    static let routeText = ThemeColor.textPrimary
    static let routeMuted = ThemeColor.textSecondary
    static let accessibleLime = ThemeColor.mexLime
}

// Optional convenience accessors with a wc_ prefix to avoid symbol clashes
extension Color {
    static var wc_mexGreen: Color { ThemeColor.mexGreen }
    static var wc_mexRed: Color { ThemeColor.mexRed }
    static var wc_mexLime: Color { ThemeColor.mexLime }

    static var wc_usaNavy: Color { ThemeColor.usaNavy }
    static var wc_usaRed: Color { ThemeColor.usaRed }
    static var wc_usaWhite: Color { ThemeColor.usaWhite }

    static var wc_canRed: Color { ThemeColor.canRed }
    static var wc_canIceBlue: Color { ThemeColor.canIceBlue }
    static var wc_canIce: Color { ThemeColor.canIce }

    static var wc_textPrimary: Color { ThemeColor.textPrimary }
    static var wc_textSecondary: Color { ThemeColor.textSecondary }
    static var wc_textTertiary: Color { ThemeColor.textTertiary }

    static var wc_statusLive: Color { ThemeColor.statusLive }
    static var wc_statusUpcoming: Color { ThemeColor.statusUpcoming }
    static var wc_statusPrevious: Color { ThemeColor.statusPrevious }

    static var wc_routeAccessible: Color { ThemeColor.routeAccessible }
    static var wc_routeStandard: Color { ThemeColor.routeStandard }

    static var wc_routeDarkGreen: Color { ThemeColor.routeDarkGreen }
    static var wc_routePanelGreen: Color { ThemeColor.routePanelGreen }
    static var wc_routeText: Color { ThemeColor.routeText }
    static var wc_routeMuted: Color { ThemeColor.routeMuted }
    static var wc_accessibleLime: Color { ThemeColor.accessibleLime }
}

// Helper para crear Color desde hex
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradientes por País
extension LinearGradient {
    // México: Verde → Lima (Ruta Accesible)
    static var mexicoBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color.wc_mexGreen.opacity(0.95),
                Color.wc_mexGreen.opacity(0.85),
                Color.wc_mexLime.opacity(0.7)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // USA: Navy profundo (Narrador Universal)
    static var usaBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color.wc_usaNavy.opacity(0.98),
                Color.wc_usaNavy.opacity(0.95),
                Color(hex: "1A2F4A").opacity(0.9)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // Canadá: Rojo → Granate (Asistente Multilingüe)
    static var canadaBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color.wc_canRed.opacity(0.95),
                Color(hex: "B8001F").opacity(0.9),
                Color(hex: "8B0015").opacity(0.85)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // Tab bar con gradiente combinado
    static var worldCupBottomBar: LinearGradient {
        LinearGradient(
            colors: [
                Color.wc_canRed.opacity(0.8),
                Color.wc_mexGreen.opacity(0.7),
                Color.wc_usaNavy.opacity(0.8)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - View Modifiers con Tema por País
struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let intensity: Material
    let theme: CountryTheme
    
    enum CountryTheme {
        case mexico    // Verde, rojo, lima
        case usa       // Navy, rojo, blanco
        case canada    // Rojo, azul hielo, hielo
    }
    
    init(cornerRadius: CGFloat = 24, intensity: Material = .ultraThinMaterial, theme: CountryTheme = .mexico) {
        self.cornerRadius = cornerRadius
        self.intensity = intensity
        self.theme = theme
    }
    
    func body(content: Content) -> some View {
        content
            .background(intensity)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        borderGradient(for: theme),
                        lineWidth: 1
                    )
            )
    }
    
    private func borderGradient(for theme: CountryTheme) -> LinearGradient {
        switch theme {
        case .mexico:
            return LinearGradient(
                colors: [Color.wc_mexLime.opacity(0.4), Color.wc_mexGreen.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .usa:
            return LinearGradient(
                colors: [Color.wc_usaWhite.opacity(0.3), Color.wc_usaRed.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .canada:
            return LinearGradient(
                colors: [Color.wc_canIceBlue.opacity(0.5), Color.wc_canIce.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 24, intensity: Material = .ultraThinMaterial, theme: GlassCardModifier.CountryTheme = .mexico) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, intensity: intensity, theme: theme))
    }
    
    // Helpers por país
    func mexicoGlassCard(cornerRadius: CGFloat = 24, intensity: Material = .ultraThinMaterial) -> some View {
        glassCard(cornerRadius: cornerRadius, intensity: intensity, theme: .mexico)
    }
    
    func usaGlassCard(cornerRadius: CGFloat = 24, intensity: Material = .ultraThinMaterial) -> some View {
        glassCard(cornerRadius: cornerRadius, intensity: intensity, theme: .usa)
    }
    
    func canadaGlassCard(cornerRadius: CGFloat = 24, intensity: Material = .ultraThinMaterial) -> some View {
        glassCard(cornerRadius: cornerRadius, intensity: intensity, theme: .canada)
    }
}

struct WorldCupButtonStyle: ButtonStyle {
    let isSelected: Bool
    let highlightColor: Color?
    
    init(isSelected: Bool = false, highlightColor: Color? = nil) {
        self.isSelected = isSelected
        self.highlightColor = highlightColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(isSelected ? (highlightColor != nil ? .black : .wc_textPrimary) : .wc_textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                (isSelected ? (highlightColor ?? Color.accentColor) : Color.white.opacity(0.1))
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Tipografía del tema
extension Font {
    static var worldCupTitle: Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }
    
    static var worldCupHeadline: Font {
        .system(size: 20, weight: .semibold, design: .rounded)
    }
    
    static var worldCupBody: Font {
        .system(size: 16, weight: .regular, design: .rounded)
    }
    
    static var worldCupCaption: Font {
        .system(size: 14, weight: .regular, design: .rounded)
    }
}

// MARK: - Patrones Visuales por País
// México: Franjas diagonales (papel picado)
struct DiagonalStripesPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let stripeWidth: CGFloat = 40
                let angle: CGFloat = 15 * .pi / 180 // 15 grados
                
                var x: CGFloat = -stripeWidth
                while x < width + height * tan(angle) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x + height * tan(angle), y: height))
                    path.addLine(to: CGPoint(x: x + height * tan(angle) + stripeWidth, y: height))
                    path.addLine(to: CGPoint(x: x + stripeWidth, y: 0))
                    path.closeSubpath()
                    x += stripeWidth * 2
                }
            }
            .fill(Color.wc_mexLime.opacity(0.1))
        }
    }
}

// USA: Micro-estrellas difuminadas
struct StarsPattern: View {
    // Posiciones deterministas para las estrellas
    private let starPositions: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.1, 0.15, 2.5), (0.3, 0.25, 3.0), (0.5, 0.1, 2.0), (0.7, 0.3, 2.8),
        (0.2, 0.5, 3.2), (0.4, 0.6, 2.3), (0.6, 0.55, 2.7), (0.8, 0.45, 2.1),
        (0.15, 0.75, 2.9), (0.35, 0.85, 2.4), (0.55, 0.8, 3.1), (0.75, 0.7, 2.6),
        (0.9, 0.2, 2.2), (0.25, 0.4, 2.8), (0.65, 0.35, 2.5), (0.45, 0.9, 2.3),
        (0.85, 0.6, 2.7), (0.5, 0.25, 2.1), (0.3, 0.65, 2.9), (0.7, 0.15, 2.4)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<starPositions.count, id: \.self) { index in
                    let pos = starPositions[index]
                    Circle()
                        .fill(Color.wc_usaWhite.opacity(0.1))
                        .frame(width: pos.size, height: pos.size)
                        .position(
                            x: pos.x * geometry.size.width,
                            y: pos.y * geometry.size.height
                        )
                }
            }
        }
    }
}

// USA: Banda diagonal "broadcast"
struct BroadcastBand: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let bandHeight: CGFloat = 60
                
                path.move(to: CGPoint(x: 0, y: height * 0.3))
                path.addLine(to: CGPoint(x: width, y: height * 0.3 - width * 0.1))
                path.addLine(to: CGPoint(x: width, y: height * 0.3 - width * 0.1 + bandHeight))
                path.addLine(to: CGPoint(x: 0, y: height * 0.3 + bandHeight))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [Color.wc_usaRed.opacity(0.15), Color.wc_usaRed.opacity(0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
    }
}

// Canadá: Sombra hoja de maple (difusa)
struct MapleLeafShadow: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sombra difusa de hoja de maple
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color.wc_canRed.opacity(0.1), Color.clear],
                            center: .center,
                            startRadius: 50,
                            endRadius: 200
                        )
                    )
                    .frame(width: 300, height: 300)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                    .blur(radius: 30)
            }
        }
    }
}

