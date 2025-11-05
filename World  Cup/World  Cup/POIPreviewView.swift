import SwiftUI

// MARK: - POI Preview Sheet
struct POIPreviewSheet: View {
    let poi: POI
    let onSelectAsOrigin: () -> Void
    let onSelectAsDestination: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.routeDarkGreen.ignoresSafeArea()
                
                ScrollView {
                    POIPreviewView(poi: poi, onSelectAsOrigin: onSelectAsOrigin, onSelectAsDestination: onSelectAsDestination)
                        .padding()
                }
            }
            .navigationTitle(poi.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        onDismiss()
                    }
                    .foregroundColor(.accessibleLime)
                }
            }
        }
    }
}

// MARK: - POI Preview View
struct POIPreviewView: View {
    let poi: POI
    let onSelectAsOrigin: () -> Void
    let onSelectAsDestination: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header con nombre y tipo
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(poi.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.routeText)
                    
                    Text(poi.type.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.routeMuted)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.routePanelGreen)
                        )
                }
                
                Spacer()
                
                // Indicador de accesibilidad
                if poi.accessibility.wheelchairAccessible {
                    Image(systemName: "figure.walk.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.accessibleLime)
                        .accessibilityLabel("Accesible")
                } else {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                        .accessibilityLabel("No accesible")
                }
            }
            
            Divider()
                .background(Color.routeMuted)
            
            // Descripción
            Text(poi.description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.routeText)
                .multilineTextAlignment(.leading)
            
            // Información de accesibilidad
            VStack(alignment: .leading, spacing: 12) {
                Text("Accesibilidad")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.routeText)
                
                VStack(alignment: .leading, spacing: 8) {
                    if poi.accessibility.wheelchairAccessible {
                        Label("Accesible para silla de ruedas", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.accessibleLime)
                    } else {
                        Label("No accesible para silla de ruedas", systemImage: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                    
                    if poi.accessibility.hasElevator {
                        Label("Tiene elevador", systemImage: "arrow.up.arrow.down.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.accessibleLime)
                    }
                    
                    if poi.accessibility.hasRamp {
                        Label("Tiene rampa", systemImage: "arrow.up.right.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.accessibleLime)
                    }
                    
                    if poi.accessibility.hasAccessibleRestroom {
                        Label("Baño accesible disponible", systemImage: "figure.restroom")
                            .font(.system(size: 14))
                            .foregroundColor(.accessibleLime)
                    }
                }
            }
            
            // Puntos de referencia visual
            if !poi.accessibility.visualLandmarks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Puntos de referencia")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.routeText)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(poi.accessibility.visualLandmarks, id: \.self) { landmark in
                                Text(landmark)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.routeText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .liquidGlass(intensity: .light, cornerRadius: 20, padding: 0)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Botones de acción
            VStack(spacing: 12) {
                Button(action: onSelectAsOrigin) {
                    HStack {
                        Image(systemName: "location.circle.fill")
                        Text("Usar como Origen")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.routeDarkGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.accessibleLime)
                    )
                }
                .accessibilityLabel("Usar como punto de origen")
                
                Button(action: onSelectAsDestination) {
                    HStack {
                        Image(systemName: "flag.fill")
                        Text("Usar como Destino")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.routeDarkGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.accessibleLime.opacity(0.8))
                    )
                }
                .accessibilityLabel("Usar como punto de destino")
            }
        }
        .padding(20)
        .liquidGlass(intensity: .medium, cornerRadius: 20, padding: 0)
    }
}

#Preview {
    ZStack {
        Color.routeDarkGreen.ignoresSafeArea()
        POIPreviewView(
            poi: POI(
                id: "test",
                name: "Entrada Principal",
                description: "Entrada principal del Estadio Azteca con acceso completo",
                type: .entrance,
                coordinates: SIMD3<Float>(0, 0, 0),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Monumento", "Fuente", "Pantallas grandes"],
                    hasElevator: true,
                    hasRamp: true,
                    hasAccessibleRestroom: true
                )
            ),
            onSelectAsOrigin: {},
            onSelectAsDestination: {}
        )
        .padding()
    }
}

