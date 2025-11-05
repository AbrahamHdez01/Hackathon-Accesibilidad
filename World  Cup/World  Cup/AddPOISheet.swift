import SwiftUI

// MARK: - Add POI Sheet
struct AddPOISheet: View {
    @ObservedObject var poiService: StadiumPOIService
    var onPOIAdded: (POI) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var poiName: String = ""
    @State private var poiDescription: String = ""
    @State private var selectedType: POI.POIType = .landmark
    @State private var coordinates: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    @State private var wheelchairAccessible: Bool = true
    @State private var mobilityAidAccessible: Bool = true
    @State private var hasElevator: Bool = false
    @State private var hasRamp: Bool = false
    @State private var hasAccessibleRestroom: Bool = false
    @State private var visualLandmarks: [String] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.routeDarkGreen.ignoresSafeArea()
                
                Form {
                    Section("Información básica") {
                        TextField("Nombre del punto", text: $poiName)
                            .foregroundColor(.routeText)
                        TextField("Descripción", text: $poiDescription)
                            .foregroundColor(.routeText)
                        
                        Picker("Tipo", selection: $selectedType) {
                            ForEach([POI.POIType.entrance, .exit, .section, .landmark, .service, .restroom, .elevator, .ramp], id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .foregroundColor(.routeText)
                    }
                    
                    Section("Coordenadas 3D") {
                        HStack {
                            Text("X:")
                            TextField("0", value: $coordinates.x, format: .number)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.routeText)
                        }
                        HStack {
                            Text("Y:")
                            TextField("0", value: $coordinates.y, format: .number)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.routeText)
                        }
                        HStack {
                            Text("Z:")
                            TextField("0", value: $coordinates.z, format: .number)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.routeText)
                        }
                        
                        Text("Nota: Las coordenadas se pueden ajustar después en el mapa 3D")
                            .font(.caption)
                            .foregroundColor(.routeMuted)
                    }
                    
                    Section("Accesibilidad") {
                        Toggle("Accesible para silla de ruedas", isOn: $wheelchairAccessible)
                            .foregroundColor(.routeText)
                        Toggle("Accesible para ayudas de movilidad", isOn: $mobilityAidAccessible)
                            .foregroundColor(.routeText)
                        Toggle("Tiene elevador", isOn: $hasElevator)
                            .foregroundColor(.routeText)
                        Toggle("Tiene rampa", isOn: $hasRamp)
                            .foregroundColor(.routeText)
                        Toggle("Tiene baño accesible", isOn: $hasAccessibleRestroom)
                            .foregroundColor(.routeText)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.routeDarkGreen)
            }
            .navigationTitle("Agregar Punto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Agregar") {
                        addPOI()
                    }
                    .disabled(poiName.isEmpty)
                }
            }
        }
    }
    
    private func addPOI() {
        let newPOI = POI(
            id: UUID().uuidString,
            name: poiName,
            description: poiDescription.isEmpty ? "Nuevo punto de interés" : poiDescription,
            type: selectedType,
            coordinates: coordinates,
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: wheelchairAccessible,
                mobilityAidAccessible: mobilityAidAccessible,
                visualLandmarks: visualLandmarks,
                hasElevator: hasElevator,
                hasRamp: hasRamp,
                hasAccessibleRestroom: hasAccessibleRestroom
            )
        )
        
        onPOIAdded(newPOI)
        dismiss()
    }
}

#Preview {
    AddPOISheet(poiService: StadiumPOIService()) { _ in }
}

