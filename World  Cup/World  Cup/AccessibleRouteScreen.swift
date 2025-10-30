import SwiftUI

struct AccessibleRouteScreen: View {
    @State private var selectedMode: Mode = .accessible

    // Puntos simulados de la ruta (relativos al rect del mapa)
    private let routePoints: [CGPoint] = [
        CGPoint(x: 0.18, y: 0.78), // inicio
        CGPoint(x: 0.30, y: 0.70),
        CGPoint(x: 0.42, y: 0.62),
        CGPoint(x: 0.56, y: 0.52),
        CGPoint(x: 0.69, y: 0.44),
        CGPoint(x: 0.78, y: 0.36)  // destino
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.routeDarkGreen.ignoresSafeArea()

                VStack(spacing: 16) {
                    // Título
                    Text("Ruta ideal")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.routeText)
                        .padding(.top, 8)

                    // Selector de modo (segmented custom)
                    HStack(spacing: 10) {
                        modeButton(label: "Estándar", isActive: selectedMode == .standard) {
                            selectedMode = .standard
                        }
                        modeButton(label: "Accesible", isActive: selectedMode == .accessible, highlight: true) {
                            selectedMode = .accessible
                        }
                    }
                    .padding(.horizontal, 20)

                    // Mapa + ruta
                    GeometryReader { geo in
                        let size = geo.size

                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.routePanelGreen)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )

                            // Placeholder del mapa (imagen)
                            Image("azteca_plan")
                                .resizable()
                                .scaledToFit()
                                .opacity(0.95)
                                .padding(24)

                            // Ruta simulada
                            Path { path in
                                guard let first = routePoints.first else { return }
                                let start = CGPoint(x: first.x * size.width, y: first.y * size.height)
                                path.move(to: start)
                                for p in routePoints.dropFirst() {
                                    let pt = CGPoint(x: p.x * size.width, y: p.y * size.height)
                                    path.addLine(to: pt)
                                }
                            }
                            .stroke(Color.accessibleLime, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round, dash: [6, 8]))
                            .padding(24)

                            // Marcadores (origen/destino)
                            Group {
                                marker(at: routePoints.first!, size: size, title: "Inicio: Tren Ligero")
                                marker(at: routePoints.last!, size: size, title: "Destino: Puerta 3 – Sección 104")
                            }
                            .padding(24)
                        }
                    }
                    .frame(height: 360)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 8)

                    // Tab inferior (3 botones)
                    HStack(spacing: 18) {
                        NavigationLink(destination: NarratorView()) {
                            tabItem(icon: "megaphone.fill", title: "Narrador\nUniversal", isCurrent: false)
                        }
                        NavigationLink(destination: AccessibleRouteScreen()) {
                            tabItem(icon: "figure.walk.circle", title: "Ruta\nAccesible", isCurrent: true)
                        }
                        NavigationLink(destination: ChatAssistantView()) {
                            tabItem(icon: "bubble.left.and.bubble.right.fill", title: "Asistente\nMultilingüe", isCurrent: false)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Subviews

    private func modeButton(label: String, isActive: Bool, highlight: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isActive ? .black : .routeText)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isActive ? (highlight ? Color.accessibleLime : Color.white.opacity(0.15)) : Color.white.opacity(0.12))
                )
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private func tabItem(icon: String, title: String, isCurrent: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isCurrent ? Color.accessibleLime.opacity(0.25) : Color.white.opacity(0.10))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isCurrent ? .accessibleLime : .routeText)
            }
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.routeMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    private func marker(at relative: CGPoint, size: CGSize, title: String) -> some View {
        let pt = CGPoint(x: relative.x * size.width, y: relative.y * size.height)
        return ZStack(alignment: .topLeading) {
            Circle()
                .fill(Color.accessibleLime)
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(Color.black.opacity(0.25), lineWidth: 1))
                .position(pt)
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.routeText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .position(x: pt.x + 72, y: max(18, pt.y - 18))
        }
        // TODO (MVP FUTURO): Vincular estos marcadores a POIs reales del estadio (JSON secciones y accesos)
    }
}

extension AccessibleRouteScreen {
    enum Mode { case standard, accessible }
}

// TODO (MVP FUTURO):
// - Reemplazar Image("azteca_plan") por SVG/SceneView 3D interactivo (zoom, pan, capas accesibles)
// - Conectar Path de la ruta a un grafo accesible (Dijkstra) con pesos por accesibilidad
// - Integrar Narrador IA + TTS (Pilar 2) para describir pasos
// - Integrar Chatbot Multilingüe (Pilar 3) en pestaña correspondiente

#Preview {
    AccessibleRouteScreen()
}


