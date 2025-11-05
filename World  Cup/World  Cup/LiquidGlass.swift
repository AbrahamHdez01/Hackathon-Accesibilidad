import SwiftUI

// MARK: - Liquid Glass View Modifier
struct LiquidGlassModifier: ViewModifier {
    var intensity: GlassIntensity = .medium
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(materialForIntensity(intensity))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .padding(padding)
    }
    
    private func materialForIntensity(_ intensity: GlassIntensity) -> some ShapeStyle {
        switch intensity {
        case .light:
            return .ultraThinMaterial
        case .medium:
            return .thinMaterial
        case .heavy:
            return .regularMaterial
        case .ultra:
            return .thickMaterial
        }
    }
}

// MARK: - Glass Intensity
enum GlassIntensity {
    case light
    case medium
    case heavy
    case ultra
}

// MARK: - View Extension
extension View {
    /// Aplica efecto liquid glass a la vista
    /// - Parameters:
    ///   - intensity: Intensidad del efecto (light, medium, heavy, ultra)
    ///   - cornerRadius: Radio de las esquinas
    ///   - padding: Padding interno
    func liquidGlass(
        intensity: GlassIntensity = .medium,
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 0
    ) -> some View {
        self.modifier(
            LiquidGlassModifier(
                intensity: intensity,
                cornerRadius: cornerRadius,
                padding: padding
            )
        )
    }
}

// MARK: - Liquid Glass Container
struct LiquidGlassContainer<Content: View>: View {
    let intensity: GlassIntensity
    let cornerRadius: CGFloat
    let padding: CGFloat
    let content: Content
    
    init(
        intensity: GlassIntensity = .medium,
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.intensity = intensity
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .liquidGlass(intensity: intensity, cornerRadius: cornerRadius)
    }
}

// MARK: - Liquid Glass Card
struct LiquidGlassCard<Content: View>: View {
    let intensity: GlassIntensity
    let cornerRadius: CGFloat
    let content: Content
    
    init(
        intensity: GlassIntensity = .medium,
        cornerRadius: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.intensity = intensity
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        LiquidGlassContainer(
            intensity: intensity,
            cornerRadius: cornerRadius,
            padding: 20
        ) {
            content
        }
    }
}

#Preview {
    ZStack {
        // Fondo de ejemplo
        LinearGradient(
            colors: [
                Color(red: 0.06, green: 0.21, blue: 0.19),
                Color(red: 0.10, green: 0.28, blue: 0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 30) {
            // Ejemplo light
            LiquidGlassCard(intensity: .light, cornerRadius: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Light Glass")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Efecto de vidrio ligero")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Ejemplo medium
            LiquidGlassCard(intensity: .medium, cornerRadius: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Medium Glass")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Efecto de vidrio medio")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Ejemplo heavy
            LiquidGlassCard(intensity: .heavy, cornerRadius: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Heavy Glass")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Efecto de vidrio pesado")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

