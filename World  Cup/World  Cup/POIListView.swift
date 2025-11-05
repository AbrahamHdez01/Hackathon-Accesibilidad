import SwiftUI

// MARK: - POI List View
struct POIListView: View {
    @ObservedObject var poiService: StadiumPOIService
    var onPOISelected: ((POI) -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: POI.POIType?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.routeDarkGreen.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filtro por tipo
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            typeFilterButton(type: nil, label: "Todos")
                            
                            ForEach([POI.POIType.entrance, .exit, .section, .landmark, .service, .restroom, .elevator, .ramp], id: \.self) { type in
                                typeFilterButton(type: type, label: type.rawValue)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    
                    // Información de selección actual
                    if poiService.selectedStartPOI != nil || poiService.selectedEndPOI != nil {
                        HStack(spacing: 12) {
                            if let start = poiService.selectedStartPOI {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Inicio:")
                                        .font(.caption)
                                        .foregroundColor(.routeMuted)
                                    Text(start.name)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.accessibleLime)
                                }
                            }
                            
                            if let end = poiService.selectedEndPOI {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Fin:")
                                        .font(.caption)
                                        .foregroundColor(.routeMuted)
                                    Text(end.name)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.accessibleLime)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                poiService.selectedStartPOI = nil
                                poiService.selectedEndPOI = nil
                            }) {
                                Text("Limpiar")
                                    .font(.caption)
                                    .foregroundColor(.routeText)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .liquidGlass(intensity: .light, cornerRadius: 8, padding: 0)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .liquidGlass(intensity: .medium, cornerRadius: 12, padding: 0)
                        .padding(.horizontal)
                    }
                    
                    // Lista de POIs
                    List {
                        ForEach(filteredPOIs) { poi in
                            POIListRow(
                                poiService: poiService,
                                poi: poi,
                                isStart: poi.id == poiService.selectedStartPOI?.id,
                                isEnd: poi.id == poiService.selectedEndPOI?.id
                            ) {
                                // Permitir seleccionar como inicio o fin
                                handlePOISelection(poi)
                            }
                            .listRowBackground(Color.routePanelGreen)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Puntos de Interés")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func handlePOISelection(_ poi: POI) {
        // Si no hay inicio seleccionado, seleccionar como inicio
        if poiService.selectedStartPOI == nil {
            poiService.selectedStartPOI = poi
        }
        // Si ya hay inicio pero no fin, seleccionar como fin
        else if poiService.selectedEndPOI == nil && poi.id != poiService.selectedStartPOI?.id {
            poiService.selectedEndPOI = poi
        }
        // Si ambos están seleccionados y se toca el inicio, cambiarlo
        else if poi.id == poiService.selectedStartPOI?.id {
            poiService.selectedStartPOI = nil
        }
        // Si ambos están seleccionados y se toca el fin, cambiarlo
        else if poi.id == poiService.selectedEndPOI?.id {
            poiService.selectedEndPOI = nil
        }
        // Si se toca otro punto, reemplazar el fin
        else {
            poiService.selectedEndPOI = poi
        }
        
        // Llamar al callback si existe
        onPOISelected?(poi)
    }
    
    private var filteredPOIs: [POI] {
        if let type = selectedType {
            return poiService.pois.filter { $0.type == type }
        }
        return poiService.pois
    }
    
    private func typeFilterButton(type: POI.POIType?, label: String) -> some View {
        Button(action: {
            selectedType = type
        }) {
            Text(label)
                .font(.caption)
                .fontWeight(selectedType == type ? .semibold : .regular)
                .foregroundColor(selectedType == type ? .routeDarkGreen : .routeText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedType == type ? Color.accessibleLime : Color.routePanelGreen)
                .cornerRadius(8)
        }
    }
}

// MARK: - POI List Row
struct POIListRow: View {
    @ObservedObject var poiService: StadiumPOIService
    let poi: POI
    let isStart: Bool
    let isEnd: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Icono según tipo
                Image(systemName: iconForType(poi.type))
                    .font(.title3)
                    .foregroundColor(.accessibleLime)
                    .frame(width: 40, height: 40)
                    .background(Color.accessibleLime.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(poi.name)
                            .font(.headline)
                            .foregroundColor(.routeText)
                        
                        if isStart {
                            Text("INICIO")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.routeDarkGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accessibleLime)
                                .cornerRadius(4)
                        }
                        
                        if isEnd {
                            Text("FIN")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.routeDarkGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(poi.description)
                        .font(.caption)
                        .foregroundColor(.routeMuted)
                    
                    // Indicadores de accesibilidad
                    if poi.accessibility.wheelchairAccessible {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.roll")
                                .font(.caption2)
                            Text("Accesible")
                                .font(.caption2)
                        }
                        .foregroundColor(.accessibleLime)
                    }
                }
                
                Spacer()
                
                // Botones de acción
                HStack(spacing: 8) {
                    // Botón para seleccionar como inicio
                    Button(action: {
                        poiService.selectedStartPOI = poi
                        onSelect()
                    }) {
                        Image(systemName: isStart ? "location.fill" : "location")
                            .font(.caption)
                            .foregroundColor(isStart ? .accessibleLime : .routeMuted)
                            .padding(8)
                            .background(isStart ? Color.accessibleLime.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                    }
                    
                    // Botón para seleccionar como fin
                    Button(action: {
                        poiService.selectedEndPOI = poi
                        onSelect()
                    }) {
                        Image(systemName: isEnd ? "flag.fill" : "flag")
                            .font(.caption)
                            .foregroundColor(isEnd ? .blue : .routeMuted)
                            .padding(8)
                            .background(isEnd ? Color.blue.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForType(_ type: POI.POIType) -> String {
        switch type {
        case .entrance: return "door.left.hand.open"
        case .exit: return "door.right.hand.open"
        case .section: return "mappin.circle.fill"
        case .landmark: return "star.fill"
        case .service: return "info.circle.fill"
        case .restroom: return "toilet.fill"
        case .elevator: return "arrow.up.arrow.down"
        case .ramp: return "figure.roll"
        }
    }
}

#Preview {
    POIListView(poiService: StadiumPOIService(), onPOISelected: nil)
}

