import SwiftUI
import SceneKit

struct AccessibleRouteScreen: View {
    @StateObject private var poiService = StadiumPOIService()
    @State private var selectedMode: Mode = .accessible
    @State private var currentRoute: Route?
    @State private var showPOIList = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.routeDarkGreen.ignoresSafeArea()

                ZStack {
                    // Mapa 3D - ocupa todo el espacio disponible
                    Stadium3DView(
                        poiService: poiService,
                        onPOISelected: { poi in
                            handlePOISelection(poi)
                        },
                        currentRoute: currentRoute
                    )
                    .accessibilityLabel("Mapa del Estadio 3D, usa gesto de pinza para zoom, arrastra para moverte y rota con dos dedos")
                    
                    // Controles superiores flotantes
                    VStack(spacing: 12) {
                        // Título y controles
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Ruta ideal")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.routeText)
                                    .accessibilityAddTraits(.isHeader)
                                
                                // Selector de modo compacto
                                HStack(spacing: 8) {
                                    modeButton(label: "Estándar", isActive: selectedMode == .standard) {
                                        selectedMode = .standard
                                        if let start = poiService.selectedStartPOI,
                                           let end = poiService.selectedEndPOI {
                                            currentRoute = poiService.calculateRoute(from: start, to: end, accessible: false)
                                        }
                                    }
                                    modeButton(label: "Accesible", isActive: selectedMode == .accessible, highlight: true) {
                                        selectedMode = .accessible
                                        if let start = poiService.selectedStartPOI,
                                           let end = poiService.selectedEndPOI {
                                            currentRoute = poiService.calculateRoute(from: start, to: end, accessible: true)
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Botón Ver POIs
                            Button(action: {
                                showPOIList.toggle()
                            }) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.accessibleLime)
                                    .padding(10)
                                    .liquidGlass(intensity: .medium, cornerRadius: 20)
                            }
                            .accessibilityLabel("Ver lista de puntos de interés")
                            .accessibilityHint("Doble toque para abrir la lista de puntos de interés")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .liquidGlass(intensity: .medium, cornerRadius: 20, padding: 0)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // Información de selección (solo si hay selección)
                        if let start = poiService.selectedStartPOI, let end = poiService.selectedEndPOI {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Origen: \(start.name)")
                                        .font(.caption)
                                        .foregroundColor(.routeText)
                                    Text("Destino: \(end.name)")
                                        .font(.caption)
                                        .foregroundColor(.routeText)
                                }
                                Spacer()
                                Button(action: {
                                    poiService.selectedStartPOI = nil
                                    poiService.selectedEndPOI = nil
                                    currentRoute = nil
                                }) {
                                    Text("Limpiar")
                                        .font(.caption)
                                        .foregroundColor(.routeText)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .liquidGlass(intensity: .light, cornerRadius: 8, padding: 0)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .liquidGlass(intensity: .medium, cornerRadius: 12, padding: 0)
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer()
                    }
                    
                    // Instrucciones flotantes en la parte inferior
                    VStack {
                        Spacer()
                        
                        if poiService.selectedStartPOI == nil {
                            Text("Toca un punto para seleccionar origen")
                                .font(.caption)
                                .foregroundColor(.routeText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .liquidGlass(intensity: .heavy, cornerRadius: 12, padding: 0)
                                .padding(.bottom, 100) // Por encima del tab bar
                        } else if poiService.selectedEndPOI == nil {
                            Text("Toca otro punto para seleccionar destino")
                                .font(.caption)
                                .foregroundColor(.routeText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .liquidGlass(intensity: .heavy, cornerRadius: 12, padding: 0)
                                .padding(.bottom, 100) // Por encima del tab bar
                        }
                    }
                    .allowsHitTesting(false) // No bloquear gestos del mapa
                    
                    // Información de ruta calculada (flotante en la parte inferior)
                    VStack {
                        Spacer()
                        
                        if let route = currentRoute {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Ruta calculada")
                                        .font(.headline)
                                        .foregroundColor(.routeText)
                                    Spacer()
                                    Text("\(Int(route.estimatedTime / 60)) min")
                                        .font(.caption)
                                        .foregroundColor(.routeMuted)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(route.instructions, id: \.self) { instruction in
                                            Text(instruction)
                                                .font(.caption)
                                                .foregroundColor(.routeText)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .liquidGlass(intensity: .light, cornerRadius: 8, padding: 0)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .liquidGlass(intensity: .medium, cornerRadius: 16, padding: 0)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100) // Por encima del tab bar
                        }
                    }
                    
                    // Tab inferior (3 botones) - siempre visible
                    VStack {
                        Spacer()
                        HStack(spacing: 18) {
                            NavigationLink(destination: NarratorView()) {
                                tabItem(icon: "megaphone.fill", title: "Narrador\nUniversal", isCurrent: false)
                            }
                            NavigationLink(destination: AccessibleRouteScreen()) {
                                tabItem(icon: "figure.walk.circle", title: "Ruta\nAccesible", isCurrent: true)
                            }
                            NavigationLink(destination: ChatAssistantView()) {
                                tabItem(icon: "bubble.left.and.bubble.right.fill", title: "Asistente\nMultilingüe", isCurrent: false)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedCorner(radius: 28, corners: [.topLeft, .topRight])
                                .fill(Color.routePanelGreen.opacity(0.95))
                                .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: -2)
                        )
                    }
                }
            }
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showPOIList) {
                    POIListView(poiService: poiService) { poi in
                        // No cerrar el sheet, solo actualizar la selección
                        // El cálculo de ruta se hará automáticamente cuando haya inicio y fin
                        if let start = poiService.selectedStartPOI,
                           let end = poiService.selectedEndPOI {
                            currentRoute = poiService.calculateRoute(
                                from: start,
                                to: end,
                                accessible: selectedMode == .accessible
                            )
                        }
                    }
                }
                .onChange(of: poiService.selectedStartPOI) { _ in
                    // Recalcular ruta cuando cambia el inicio
                    if let start = poiService.selectedStartPOI,
                       let end = poiService.selectedEndPOI {
                        currentRoute = poiService.calculateRoute(
                            from: start,
                            to: end,
                            accessible: selectedMode == .accessible
                        )
                    } else {
                        currentRoute = nil
                    }
                }
                .onChange(of: poiService.selectedEndPOI) { _ in
                    // Recalcular ruta cuando cambia el fin
                    if let start = poiService.selectedStartPOI,
                       let end = poiService.selectedEndPOI {
                        currentRoute = poiService.calculateRoute(
                            from: start,
                            to: end,
                            accessible: selectedMode == .accessible
                        )
                    } else {
                        currentRoute = nil
                    }
                }
                .onChange(of: selectedMode) { newMode in
                    // Recalcular ruta cuando cambia el modo
                    if let start = poiService.selectedStartPOI,
                       let end = poiService.selectedEndPOI {
                        currentRoute = poiService.calculateRoute(
                            from: start,
                            to: end,
                            accessible: newMode == .accessible
                        )
                    }
                }
        }
    }
    
        // MARK: - Route Handling

        private func handlePOISelection(_ poi: POI) {
            // Permitir seleccionar directamente desde el mapa
            // Si no hay inicio, seleccionar como inicio
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
            
            // Calcular ruta automáticamente si hay inicio y fin
            if let start = poiService.selectedStartPOI,
               let end = poiService.selectedEndPOI {
                currentRoute = poiService.calculateRoute(
                    from: start,
                    to: end,
                    accessible: selectedMode == .accessible
                )
            } else {
                currentRoute = nil
            }
        }
        
    

    // MARK: - Subviews

    private func modeButton(label: String, isActive: Bool, highlight: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isActive ? .black : .routeText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isActive ? (highlight ? Color.accessibleLime : Color.white.opacity(0.15)) : Color.white.opacity(0.12))
                )
        }
        .accessibilityLabel("Modo de ruta: \(label)")
        .accessibilityHint(isActive ? "Modo \(label) seleccionado. Doble toque para cambiar al otro modo" : "Doble toque para seleccionar modo \(label)")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private func tabItem(icon: String, title: String, isCurrent: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isCurrent ? Color.accessibleLime.opacity(0.25) : Color.white.opacity(0.10))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isCurrent ? .accessibleLime : .routeText)
            }
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.routeMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityHint(isCurrent ? "Pantalla actual: \(title). Doble toque para cambiar a otra pantalla" : "Doble toque para abrir \(title)")
        .accessibilityAddTraits(isCurrent ? .isSelected : [])
    }

    private func marker(at relative: CGPoint, size: CGSize, title: String) -> some View {
        let pt = CGPoint(x: relative.x * size.width, y: relative.y * size.height)
        return ZStack(alignment: .topLeading) {
            Circle()
                .fill(Color.accessibleLime)
                .frame(width: 14, height: 14)
                .overlay(Circle().stroke(Color.black.opacity(0.25), lineWidth: 1))
                .position(pt)
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.routeText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .position(x: pt.x + 72, y: max(18, pt.y - 18))
        }
        // TODO (MVP FUTURO): Vincular estos marcadores a POIs reales del estadio (JSON secciones y accesos)
    }
}

extension AccessibleRouteScreen {
    enum Mode { case standard, accessible }
    
    // MARK: - Scene Builder
    
    private func buildStadiumScene() -> SCNScene {
        let scene = SCNScene()
        
        // Intentar cargar el modelo USDZ
        if let modelURL = Bundle.main.url(forResource: "Stadium", withExtension: "usdz") {
            let referenceNode = SCNReferenceNode(url: modelURL)
            
            // Cargar de forma síncrona si ya está disponible, o asíncrona
            referenceNode?.load()
            
            if let stadiumNode = referenceNode {
                // Calcular el bounding box del modelo para escalarlo apropiadamente
                let (bboxMin, bboxMax) = stadiumNode.boundingBox
                let size = SCNVector3(
                    x: bboxMax.x - bboxMin.x,
                    y: bboxMax.y - bboxMin.y,
                    z: bboxMax.z - bboxMin.z
                )
                
                // Escalar el modelo para que tenga un tamaño razonable (ajustar según necesidad)
                let maxSize = max(size.x, size.y, size.z)
                if maxSize > 0 {
                    let targetSize: Float = 20 // Tamaño objetivo en unidades
                    let scale = targetSize / maxSize
                    stadiumNode.scale = SCNVector3(x: scale, y: scale, z: scale)
                } else {
                    // Si no hay bounding box, usar escala por defecto
                    stadiumNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
                }
                
                stadiumNode.position = SCNVector3Zero
                stadiumNode.name = "StadiumModel"
                scene.rootNode.addChildNode(stadiumNode)
                
                // Si la carga es asíncrona, el modelo se cargará después
                // pero la escena ya tiene el nodo, así que retornamos
                // El método fitToModel() se encargará de ajustar la cámara cuando esté listo
                
                return scene
            }
        }
        
        // Crear escena placeholder más visible si no hay modelo
        // Suelo más grande y visible
        let floor = SCNPlane(width: 50, height: 50)
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1.0)
        floorMaterial.lightingModel = .lambert
        floor.materials = [floorMaterial]
        let floorNode = SCNNode(geometry: floor)
        floorNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: -.pi/2)
        floorNode.name = "Floor"
        scene.rootNode.addChildNode(floorNode)
        
        // Agregar un objeto de referencia para ver que funciona
        let box = SCNBox(width: 5, height: 5, length: 5, chamferRadius: 0.5)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor(red: 0.66, green: 1.0, blue: 0.24, alpha: 1.0)
        box.materials = [boxMaterial]
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(x: 0, y: 2.5, z: 0)
        boxNode.name = "ReferenceBox"
        scene.rootNode.addChildNode(boxNode)
        
        return scene
    }
}

// TODO (MVP FUTURO):
// - Reemplazar Image("azteca_plan") por SVG/SceneView 3D interactivo (zoom, pan, capas accesibles)
// - Conectar Path de la ruta a un grafo accesible (Dijkstra) con pesos por accesibilidad
// - Integrar Narrador IA + TTS (Pilar 2) para describir pasos
// - Integrar Chatbot Multilingüe (Pilar 3) en pestaña correspondiente

#Preview {
    AccessibleRouteScreen()
}
