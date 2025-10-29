import SwiftUI

struct StartScreenView: View {
    var onEnter: (() -> Void)?

    private let bg = Color(red: 7/255, green: 60/255, blue: 56/255)
    private let accent = LinearGradient(colors: [Color(red: 46/255, green: 204/255, blue: 113/255), Color(red: 39/255, green: 174/255, blue: 96/255)], startPoint: .topLeading, endPoint: .bottomTrailing)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.white.opacity(0.12), in: Circle())
                        .accessibilityLabel("Perfil")

                    Spacer()

                    Text("FIFA WORLD CUP")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.white.opacity(0.12), in: Circle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

                Spacer(minLength: 8)

                // Hero area
                ZStack {
                    // Right flags stack (behind trophy)
                    VStack(spacing: 10) {
                        AnimatedAssetView(name: "flag_canada")
                            .frame(width: 140, height: 90)
                        AnimatedAssetView(name: "flag_mexico")
                            .frame(width: 140, height: 90)
                        AnimatedAssetView(name: "flag_usa")
                            .frame(width: 140, height: 90)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 24)
                    .offset(x: 10)
                    .allowsHitTesting(false)

                    // Left year with separators
                    VStack(spacing: 10) {
                        Divider().background(.white.opacity(0.6))
                        Text("20")
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .kerning(1.5)
                        Text("26")
                            .font(.system(size: 72, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .kerning(1.5)
                        Divider().background(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)

                    // Center trophy
                    Image("trophy")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 340)
                        .shadow(color: .black.opacity(0.45), radius: 24, x: 0, y: 14)
                        .accessibilityLabel("Trofeo de la Copa del Mundo")
                }
                .frame(maxWidth: .infinity, maxHeight: 480)

                Spacer()

                // CTA button
                Button(action: { onEnter?() }) {
                    Text("EXPLORE TOURNAMENT")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accent, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.white.opacity(0.18), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .accessibilityLabel("Explorar torneo")
            }
        }
    }
}

#Preview {
    StartScreenView(onEnter: {})
}
