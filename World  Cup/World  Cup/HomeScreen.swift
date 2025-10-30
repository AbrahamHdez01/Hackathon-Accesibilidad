import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Background
                LinearGradient(gradient: Gradient(colors: [Color.pitchGreen, Color.actionGreen]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HeaderBar()
                        .padding(.top, 8)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            welcomeCard
                            infoCards
                            pillarsGrid
                        }
                        .padding()
                    }

                    // Spacer to push content above bottom bar
                    Spacer(minLength: 0)
                        .frame(height: 0)
                }

                BottomBar()
                    .frame(height: 84)
                    .ignoresSafeArea(edges: .bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Subviews

    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome to World Cup")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("Accessibility-first experience for fans and organizers.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .background(Color.white.opacity(0.12))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 2)
    }

    private var infoCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                smallCard(title: "Matches", value: "48")
                smallCard(title: "Stadiums", value: "10")
            }

            HStack(spacing: 12) {
                smallCard(title: "Teams", value: "32")
                smallCard(title: "Days", value: "28")
            }
        }
    }

    private func smallCard(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.06))
        .cornerRadius(10)
    }

    // Navegación a los 3 pilares: Mapa, Narrador, Chatbot
    private var pillarsGrid: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: AccessibleRouteScreen()) {
                pillarButton(icon: "map", title: "Mapa\nAccesible")
            }
            NavigationLink(destination: NarratorView()) {
                pillarButton(icon: "megaphone.fill", title: "Narrador\nUniversal")
            }
            NavigationLink(destination: ChatAssistantView()) {
                pillarButton(icon: "bubble.left.and.bubble.right.fill", title: "Asistente\nMultilingüe")
            }
        }
    }

    private func pillarButton(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .frame(height: 84)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HomeScreen()
}
