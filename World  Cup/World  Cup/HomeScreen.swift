import SwiftUI
import UIKit

struct HomeScreen: View {
    // --- Perillas rápidas de espaciado ---
    private let gutter: CGFloat = 12              // espacio vertical del bloque central
    private let sidePadding: CGFloat = 20         // margen horizontal a los lados
    private let numberColumnWidthFactor: CGFloat = 0.22 // ancho de la columna "2026" relativo al ancho
    private let trophyWidthFactor: CGFloat = 0.36 // ajuste fino para centrar visualmente
    private let trophyHeightFactor: CGFloat = 0.42 // ajuste fino para centrar visualmente

    var body: some View {
        ZStack {
            // Fondo a pantalla completa
            LinearGradient(colors: [.pitchGreen, .pitchGreen.opacity(0.92)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            GeometryReader { topGeo in
                Color.sandBeige
                    .frame(height: topGeo.safeAreaInsets.top + 12)
                    .ignoresSafeArea(edges: .top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                VStack(spacing: 0) {
                    // Header con fondo beige que cubre Dynamic Island
                    HeaderBar()
                        .background(
                            Color.sandBeige.ignoresSafeArea(edges: .top)
                        )
                    
                    // ----------- Bloque central -----------
                    HStack(alignment: .center, spacing: 0) {

                        // Columna "2026" con líneas
                        VStack(spacing: 10) {
                            sepLine
                            Text("20")
                                .font(.system(size: min(72, w * 0.16), weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .kerning(1.5)
                            Text("26")
                                .font(.system(size: min(72, w * 0.16), weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .kerning(1.5)
                            sepLine
                        }
                        .frame(width: max(110, w * numberColumnWidthFactor), alignment: .leading)
                        .padding(.leading, sidePadding)
                        .layoutPriority(1)

                        Spacer(minLength: max(8, w * 0.02))

                        // Trofeo (responsivo) con placeholder si falta
                        Group {
                            if UIImage(named: "trophy") != nil {
                                Image("trophy")
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.white.opacity(0.08))
                                    Text("trophy.png?")
                                        .foregroundColor(.white.opacity(0.9))
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                #if DEBUG
                                .onAppear { print("⚠️ trophy.png no encontrado en el bundle") }
                                #endif
                            }
                        }
                        .frame(
                            width: min(260, w * trophyWidthFactor),
                            height: min(360, h * trophyHeightFactor)
                        )
                        .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 10)
                        .accessibilityLabel("World Cup Trophy")
                        .layoutPriority(0.6)

                        Spacer(minLength: max(8, w * 0.02))

                        // Banderas Lottie
                        VStack(spacing: -6) {
                            AnimatedAssetView(name: "flag_canada")
                                .frame(width: min(120, w * 0.28), height: min(80, h * 0.12))
                                .offset(x: 6)

                            AnimatedAssetView(name: "flag_mexico")
                                .frame(width: min(120, w * 0.28), height: min(80, h * 0.12))
                                .offset(x: -4)

                            AnimatedAssetView(name: "flag_usa")
                                .frame(width: min(120, w * 0.28), height: min(80, h * 0.12))
                                .offset(x: 4)
                        }
                        .frame(width: max(120, w * 0.30))
                        .padding(.trailing, sidePadding)
                        .layoutPriority(1)
                    }
                    .padding(.vertical, gutter)
                    .frame(maxWidth: .infinity)

                    Spacer(minLength: 0)
                }
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 0) {
                        Button(action: { /* navegar */ }) {
                            Text("Explora")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                                        .fill(Color.actionGreen)
                                )
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                    }
                    .background(Color.clear)
                }
            }
        }
    }

    private var sepLine: some View {
        Rectangle()
            .fill(.white.opacity(0.6))
            .frame(height: 1)
            .padding(.horizontal, 6)
    }
}

#Preview { HomeScreen() }

