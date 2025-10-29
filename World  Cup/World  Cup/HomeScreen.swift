import SwiftUI

struct HomeScreen: View {
    var body: some View {
        ZStack {
            // Background: solo el fondo ignora safe area
            LinearGradient(colors: [.pitchGreen, .pitchGreen.opacity(0.92)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Contenido respeta safe area
            GeometryReader { geo in
                VStack(spacing: 0) {
                    // Header (respects safe area)
                    HeaderBar()
                        .padding(.top, 8)

                    Spacer(minLength: 8)

                    // Center composition
                    HStack(alignment: .center, spacing: 0) {
                        // Year
                        VStack(spacing: 8) {
                            Rectangle().fill(.white.opacity(0.6)).frame(height: 1)
                            Text("20")
                                .font(.system(size: 64, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .kerning(1.5)
                            Text("26")
                                .font(.system(size: 64, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .kerning(1.5)
                            Rectangle().fill(.white.opacity(0.6)).frame(height: 1)
                        }
                        .frame(width: 110)
                        .padding(.leading, 16)

                        Spacer(minLength: 6)

                        // Trophy (responsive: 32–38% del ancho)
                        Image("trophy")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: min(230, geo.size.width * 0.38),
                                height: min(330, geo.size.height * 0.42)
                            )
                            .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 10)
                            .accessibilityLabel("World Cup Trophy")

                        Spacer(minLength: 6)

                        // Flags stack (Lottie)
                        VStack(spacing: 10) {
                            AnimatedAssetView(name: "flag_canada")
                                .frame(width: 120, height: 80)
                                .offset(x: 4)
                            AnimatedAssetView(name: "flag_mexico")
                                .frame(width: 120, height: 80)
                                .offset(x: -2)
                            AnimatedAssetView(name: "flag_usa")
                                .frame(width: 120, height: 80)
                                .offset(x: 2)
                        }
                        .padding(.trailing, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)

                    Spacer(minLength: 0)
                }
                // Inserta botón + barra DENTRO del safe area inferior
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 12) {
                        Button(action: { /* navigate */ }) {
                            Text("EXPLORE TOURNAMENT")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(Color.actionGreen)
                                )
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 24)

                        BottomBar()
                    }
                    .background(Color.clear)
                }
            }
        }
    }
}

#Preview { HomeScreen() }
