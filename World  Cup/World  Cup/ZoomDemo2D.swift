import SwiftUI

// MARK: - Zoom Demo 2D View
struct ZoomDemo2D: View {
    var body: some View {
        ZStack {
            Color.routeDarkGreen.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Mapa 2D - Navegación con Zoom y Pan")
                    .font(.headline)
                    .foregroundColor(.routeText)
                    .padding(.top)
                
                ZoomPanScrollView(
                    config: .init(
                        minScale: 0.6,
                        maxScale: 3.5,
                        doubleTapScale: 1.8,
                        extraPanInset: 180
                    )
                ) {
                    // Imagen del mapa o SVG
                    Image("azteca_plan")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.1))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Mapa del Estadio, usa gesto de pinza para zoom y arrastra para moverte")
                
                // Instrucciones
                VStack(spacing: 8) {
                    Text("Instrucciones:")
                        .font(.caption)
                        .foregroundColor(.routeText)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 16) {
                        Label("Pinza para zoom", systemImage: "hand.point.up.left.and.text")
                            .font(.caption2)
                            .foregroundColor(.routeMuted)
                        Label("Doble toque", systemImage: "hand.tap")
                            .font(.caption2)
                            .foregroundColor(.routeMuted)
                        Label("Arrastra", systemImage: "hand.draw")
                            .font(.caption2)
                            .foregroundColor(.routeMuted)
                    }
                }
                .padding()
                .background(Color.routePanelGreen.opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

#Preview {
    ZoomDemo2D()
}

