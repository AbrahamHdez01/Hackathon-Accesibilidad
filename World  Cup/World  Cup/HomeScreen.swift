import SwiftUI
import UIKit

#if canImport(Lottie)
import Lottie
#endif

struct HomeScreen: View {
    private let sidePadding: CGFloat = 20
    private let numberColumnWidthFactor: CGFloat = 0.30
    private let trophyWidthFactor: CGFloat = 0.40 // jugador más compacto, al lado de 2026
    private let trophyHeightFactor: CGFloat = 0.50 // proporcional y sin invadir banderas
    private let topSpacingFactor: CGFloat = 0.12
    private let bottomSpacingFactor: CGFloat = 0.14   // aire extra sobre el botón

    // NUEVO: perilla para bajar solo las banderas (sin afectar el resto del layout)
    private let flagsTopPadding: CGFloat = 32         // ajusta 24–40 a tu gusto

    // NUEVO: perilla para hacer MÁS PEQUEÑO SOLO al balón (Lottie), sin mover layout
    private let playerScale: CGFloat = 0.20         // balón más pequeño; ajusta 0.4–0.7

    // NUEVO: tamaño manual de las banderas (todas en una línea)
    private let flagWidthManual: CGFloat = 80
    private let flagHeightManual: CGFloat = 100
    private let flagsSpacingManual: CGFloat = 14

    var body: some View {
        ZStack {
            // Fondo
            LinearGradient(colors: [.pitchGreen, .pitchGreen.opacity(0.92)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                VStack(spacing: 0) {
                    // Header
                    HeaderBar()

                    // Espaciador superior
                    Spacer()
                        .frame(height: h * topSpacingFactor)

                    // Bloque central
                    VStack(spacing: 18) {
                        // HStack: 2026 + Panel derecho
                        HStack(alignment: .center, spacing: 0) {

                            // Columna "2026"
                            VStack(spacing: 12) {
                                sepLine
                                Text("20")
                                    .font(.system(size: min(120, w * 0.22), weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .kerning(2)
                                Text("26")
                                    .font(.system(size: min(120, w * 0.22), weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .kerning(2)
                                sepLine
                            }
                            .frame(width: max(140, w * numberColumnWidthFactor), alignment: .leading)
                            .padding(.leading, sidePadding)
                            .layoutPriority(1)

                            Spacer(minLength: max(14, w * 0.04))

                            // Panel derecho: Lottie o imagen
                            ZStack {
                                // Fondo: intentar imagen del trofeo primero
                                if UIImage(named: "Trophie") != nil {
                                    Image("Trophie")
                                        .resizable()
                                        .scaledToFit()
                                        .opacity(0.3)
                                }

                                // Overlay: Lottie del balón (ESCALADO sin afectar el contenedor)
                                AnimatedAssetView(name: "balon")
                                    .scaleEffect(playerScale)   // << SOLO cambia el tamaño visual del jugador
                            }
                            .frame(
                                width: min(270, w * trophyWidthFactor),
                                height: min(300, h * trophyHeightFactor)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 10)
                            .layoutPriority(0.6)

                            Spacer(minLength: max(14, w * 0.04))
                        }
                        .padding(.horizontal, sidePadding)

                        // Banderas (una línea, tamaño manual, centradas)
                        HStack(spacing: 0) {
                            Spacer()
                            HStack(spacing: flagsSpacingManual) {
                                AnimatedAssetView(name: "CANADA_flag", contentMode: .scaleAspectFit)
                                    .frame(width: flagWidthManual, height: flagHeightManual, alignment: .center)
                                AnimatedAssetView(name: "Mexico_flag", contentMode: .scaleAspectFit)
                                    .frame(width: flagWidthManual, height: flagHeightManual, alignment: .center)
                                AnimatedAssetView(name: "USA_flag", contentMode: .scaleAspectFit)
                                    .frame(width: flagWidthManual, height: flagHeightManual, alignment: .center)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, sidePadding)
                        .padding(.top, flagsTopPadding)
                        .padding(.bottom, 6)
                    }

                    // Espaciador inferior (aire para el contenido; el botón va en safeAreaInset)
                    Spacer()
                        .frame(height: h * bottomSpacingFactor)
                }
                .safeAreaInset(edge: .bottom) {
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
            }
        }
    }

    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.08))
            Text("trophy.png?")
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 18, weight: .semibold))
        }
        #if DEBUG
        .onAppear { print("⚠️ Ni Lottie 'balon' ni imagen 'Trophie' encontrados") }
        #endif
    }

    private var sepLine: some View {
        Rectangle()
            .fill(.white.opacity(0.6))
            .frame(height: 1)
            .padding(.horizontal, 6)
    }
}

#Preview { HomeScreen() }
