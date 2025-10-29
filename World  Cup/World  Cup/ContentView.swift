//
//  ContentView.swift
//  World  Cup
//
//  Created by Abraham Martinez Hernandez on 27/10/25.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State
    @State private var showAccessibilitySheet = false
    @State private var navigateToDashboard = false

    // MARK: - Helper Functions
    private func hasLottieAnimation(_ name: String) -> Bool {
        if Bundle.main.path(forResource: name, ofType: "json") != nil { return true }
        if Bundle.main.path(forResource: name, ofType: "lottie") != nil { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient - Solo el fondo ignora safe area
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.4, blue: 0.2), // Coral/naranja rojizo
                        Color(red: 0.2, green: 0.6, blue: 0.8),  // Turquesa
                        Color(red: 0.1, green: 0.4, blue: 0.6)   // Turquesa oscuro
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Subtle decorative shapes (low opacity) - También ignoran safe area
                GeometryReader { geo in
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: min(geo.size.width, geo.size.height) * 0.6)
                        .position(x: geo.size.width * 0.8, y: geo.size.height * 0.15)
                        .blur(radius: 30)

                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: min(geo.size.width, geo.size.height) * 0.35)
                        .position(x: geo.size.width * 0.2, y: geo.size.height * 0.75)
                        .blur(radius: 18)
                }

                // Main content - Respeta safe area
                VStack(spacing: 0) {
                    // Accessibility settings button en la parte superior
                    HStack {
                        Spacer()
                        Button(action: {
                            showAccessibilitySheet.toggle()
                        }) {
                            Image(systemName: "person.crop.circle")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                        .frame(minWidth: 44, minHeight: 44)
                        .padding()
                        .accessibilityLabel("Ajustes de accesibilidad")
                        .accessibilityHint("Abrir configuración de accesibilidad")
                        .accessibilityAddTraits(.isButton)
                    }
                    
                    // Contenido principal centrado
                    Spacer()
                    WelcomeStartScreenView(onEnter: {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            navigateToDashboard = true
                        }
                    })
                    Spacer()
                }
            }
            // Bottom bar usando safeAreaInset
            .safeAreaInset(edge: .bottom) {
                BottomBarView()
            }
            .sheet(isPresented: $showAccessibilitySheet) {
                AccessibilitySettingsView()
            }
            // Modern NavigationStack destinations
            .navigationDestination(isPresented: $navigateToDashboard) {
                MainDashboardView()
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - WelcomeStartScreenView (extracted from original main content)
private struct WelcomeStartScreenView: View {
    var onEnter: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Trophy - Tamaño fijo responsivo
            AssetVisual(name: hasLottieAnimation("TrophyAnim") ? "TrophyAnim" : "Trophie", preferLottie: true, lottieLoop: .loop, lottieSpeed: 1.0)
                .frame(maxWidth: 200, maxHeight: 200)
                .aspectRatio(1, contentMode: .fit)
                .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 6)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Trofeo FIFA World Cup 2026 con patrón mexicano")
                .accessibilityHint("Elemento decorativo principal")

            // Event text - Centrado y con padding horizontal
            VStack(spacing: 6) {
                Text("FIFA WORLD CUP 2026")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 1)
                    .accessibilityAddTraits(.isHeader)

                Text("MEXICO - USA - CANADA")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .accessibilityElement(children: .combine)
            .accessibilitySortPriority(1)

            // Flags row
            FlagsRowView(isVisible: true)
                .padding(.horizontal, 20)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Países anfitriones: México, Canadá y  Estados Unidos")
                .accessibilityHint("Lista de países anfitriones")
            
            // Confetti animado (opcional)
            AssetVisual(name: "Confetti", preferLottie: true, lottieLoop: .playOnce)
                .allowsHitTesting(false)
                .frame(height: 80)
                .opacity(0.8)

            // Botón principal - Anclado arriba del bottom bar
            Button(action: onEnter) {
                Text("Entrar al estadio")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .accessibilityLabel("Entrar al estadio")
            .accessibilityHint("Ir al tablero principal")
            .accessibilityAddTraits(.isButton)
        }
    }
    
    // Helper for Lottie check
    private func hasLottieAnimation(_ name: String) -> Bool {
        if Bundle.main.path(forResource: name, ofType: "json") != nil { return true }
        if Bundle.main.path(forResource: name, ofType: "lottie") != nil { return true }
        return false
    }
}

// MARK: - BottomBarView
private struct BottomBarView: View {
    var body: some View {
        HStack(spacing: 0) {
            // Home
            VStack(spacing: 4) {
                Image(systemName: "house.fill")
                    .font(.system(size: 20))
                Text("Home")
                    .font(.caption2)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            
            // Schedule
            VStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                Text("Schedule")
                    .font(.caption2)
            }
            .foregroundColor(.white.opacity(0.7))
            .frame(maxWidth: .infinity)
            
            // Venues
            VStack(spacing: 4) {
                Image(systemName: "building.2")
                    .font(.system(size: 20))
                Text("Venues")
                    .font(.caption2)
            }
            .foregroundColor(.white.opacity(0.7))
            .frame(maxWidth: .infinity)
            
            // Favorites
            VStack(spacing: 4) {
                Image(systemName: "star")
                    .font(.system(size: 20))
                Text("Favorites")
                    .font(.caption2)
            }
            .foregroundColor(.white.opacity(0.7))
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Barra de navegación inferior")
    }
}

// MARK: - FlagsRowView
private struct FlagsRowView: View {
    var isVisible: Bool

    var body: some View {
        GeometryReader { geometry in
            let maxWidth = geometry.size.width
            let flagSize = min(maxWidth / 4, 60) // Máximo 60pt o 1/4 del ancho disponible
            let spacing = min(maxWidth / 8, 16) // Espaciado proporcional
            
            HStack(spacing: spacing) {
                FlagItem(country: "Mexico", label: "Bandera de México", isVisible: isVisible, size: flagSize)
                FlagItem(country: "Canada", label: "Bandera de Canadá", isVisible: isVisible, size: flagSize)
                FlagItem(country: "USA", label: "Bandera de Estados Unidos", isVisible: isVisible, size: flagSize)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .frame(height: 80) // Altura fija para evitar cambios de layout
    }

    private struct FlagItem: View {
        let country: String
        let label: String
        var isVisible: Bool
        let size: CGFloat

        var body: some View {
            ZStack {
                Circle()
                    .fill(flagColor)
                    .frame(width: size, height: size)
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
                
                // Usar AssetVisual para mostrar animación Lottie o emoji como fallback
                Group {
                    if hasLottieAnimation(lottieFileName) {
                        AssetVisual(name: lottieFileName, preferLottie: true, lottieLoop: .loop, lottieSpeed: 0.8)
                            .frame(width: size * 0.6, height: size * 0.6) // 60% del tamaño del círculo
                            .clipShape(Circle())
                    } else {
                        Text(flagEmoji)
                            .font(.system(size: size * 0.4)) // Tamaño proporcional
                    }
                }
            }
            .scaleEffect(isVisible ? 1 : 0.6)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isVisible)
            .accessibilityLabel(label)
            .accessibilityHint("Toca para ver información del país anfitrión")
            .accessibilityAddTraits(.isButton)
        }
        
        private var flagColor: Color {
            switch country {
            case "Mexico": return Color.green
            case "Canada": return Color.red
            case "USA": return Color.blue
            default: return Color.gray
            }
        }
        
        private var lottieFileName: String {
            switch country {
            case "Mexico": return "Mexico_flag"
            case "Canada": return "CANADA_flag"
            case "USA": return "USA_flag"
            default: return "flag_placeholder"
            }
        }
        
        private var flagEmoji: String {
            switch country {
            case "Mexico": return "🇲🇽"
            case "Canada": return "🇨🇦"
            case "USA": return "🇺🇸"
            default: return "🏳️"
            }
        }
        
        private func hasLottieAnimation(_ name: String) -> Bool {
            if Bundle.main.path(forResource: name, ofType: "json") != nil { return true }
            if Bundle.main.path(forResource: name, ofType: "lottie") != nil { return true }
            return false
        }
    }
 }

// MARK: - Placeholders for navigation targets
private struct AccessibilitySettingsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Ajustes de accesibilidad")
                .font(.title2).bold()
            Text("Aquí irán las opciones de accesibilidad (contraste, tamaño de texto, etc.).")
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

private struct MainDashboardView: View {
    var body: some View {
        Text("Main Dashboard (placeholder)")
            .font(.title)
    }
}

#Preview {
    ContentView()
}


