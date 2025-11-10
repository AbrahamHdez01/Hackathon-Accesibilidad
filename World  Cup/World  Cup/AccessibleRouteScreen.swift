import SwiftUI
import SceneKit

struct AccessibleRouteScreen: View {
    @StateObject private var poiService = StadiumPOIService()
    @State private var selectedMode: Mode = .accessible
    @State private var currentRoute: Route?
    @State private var showPOIList = false
    @State private var showRouteDetails = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo sólido verde fuerte (sin gradiente rainbow)
                Color.wc_mexGreen
                    .ignoresSafeArea()

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
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ruta ideal")
                                    .font(.worldCupTitle)
                                    .foregroundColor(.wc_textPrimary)
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
                            
                            // Botón Ver POIs (resaltado en verde lima)
                            Button(action: {
                                showPOIList.toggle()
                            }) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.wc_mexLime)
                                    .padding(12)
                                    .mexicoGlassCard(cornerRadius: 20)
                            }
                            .accessibilityLabel("Ver lista de puntos de interés")
                            .accessibilityHint("Doble toque para abrir la lista de puntos de interés")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .mexicoGlassCard(cornerRadius: 24)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // Información de selección (solo si hay selección)
                        if let start = poiService.selectedStartPOI, let end = poiService.selectedEndPOI {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Origen: \(start.name)")
                                        .font(.worldCupCaption)
                                        .foregroundColor(.wc_textPrimary)
                                    Text("Destino: \(end.name)")
                                        .font(.worldCupCaption)
                                        .foregroundColor(.wc_textPrimary)
                                }
                                Spacer()
                                Button(action: {
                                    withAnimation(.spring()) {
                                        poiService.selectedStartPOI = nil
                                        poiService.selectedEndPOI = nil
                                        currentRoute = nil
                                    }
                                }) {
                                    Text("Limpiar")
                                        .font(.worldCupCaption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.wc_textPrimary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .mexicoGlassCard(cornerRadius: 12)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .mexicoGlassCard(cornerRadius: 16)
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer()
                    }
                    
                    // Instrucciones flotantes en la parte media-inferior
                    VStack {
                        Spacer()
                        
                        if poiService.selectedStartPOI == nil {
                            Text("Toca un punto para seleccionar origen")
                                .font(.worldCupHeadline)
                                .foregroundColor(.wc_textPrimary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .mexicoGlassCard(cornerRadius: 20)
                                .padding(.bottom, 180)
                        } else if poiService.selectedEndPOI == nil {
                            Text("Toca otro punto para seleccionar destino")
                                .font(.worldCupHeadline)
                                .foregroundColor(.wc_textPrimary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .mexicoGlassCard(cornerRadius: 20)
                                .padding(.bottom, 180)
                        }
                    }
                    .allowsHitTesting(false) // No bloquear gestos del mapa
                    
                    // Botón desplegable de ruta calculada (flotante en la parte media-inferior)
                    VStack {
                        Spacer()
                        
                        if let route = currentRoute {
                            VStack(spacing: 0) {
                                // Botón para expandir/colapsar
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        showRouteDetails.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text("Ruta calculada")
                                            .font(.worldCupHeadline)
                                            .foregroundColor(.wc_textPrimary)
                                        Spacer()
                                        HStack(spacing: 8) {
                                            Text(formatEstimatedTime(route.estimatedTime))
                                                .font(.worldCupBody)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.wc_mexLime)
                                            Image(systemName: showRouteDetails ? "chevron.down" : "chevron.up")
                                                .font(.worldCupCaption)
                                                .foregroundColor(.wc_mexLime)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                
                                // Contenido desplegable
                                if showRouteDetails {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Divider()
                                                .background(Color.wc_textSecondary.opacity(0.3))
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 12) {
                                                ForEach(route.instructions, id: \.self) { instruction in
                                                    Text(instruction)
                                                        .font(.worldCupCaption)
                                                        .foregroundColor(.wc_textPrimary)
                                                        .padding(.horizontal, 16)
                                                        .padding(.vertical, 10)
                                                        .mexicoGlassCard(cornerRadius: 12)
                                                }
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 16)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                                }
                            }
                            .mexicoGlassCard(cornerRadius: 20)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 180)
                        }
                    }
                    
                    // Tab inferior (3 botones) - siempre visible con gradiente World Cup
                    VStack {
                        Spacer()
                        HStack(spacing: 20) {
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedCorner(radius: 28, corners: [.topLeft, .topRight])
                                .fill(.ultraThinMaterial)
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
                // Evitar seleccionar puntos demasiado cercanos entre sí
                if let start = poiService.selectedStartPOI {
                    let dx = poi.coordinates.x - start.coordinates.x
                    let dz = poi.coordinates.z - start.coordinates.z
                    let dist = sqrt(dx*dx + dz*dz)
                    if dist < 8.0 {
                        // Si están muy cerca, ignorar para mantener separación notoria
                        return
                    }
                }
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
        
    

    // MARK: - Helper Functions
    
    private func formatEstimatedTime(_ timeInSeconds: TimeInterval) -> String {
        let totalSeconds = Int(timeInSeconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        // Asegurar que siempre muestre al menos 1 minuto si hay una ruta válida
        if minutes == 0 && seconds < 30 {
            return "~1 min"
        } else if minutes == 0 {
            return "~1 min"
        } else if seconds < 30 {
            return "\(minutes) min"
        } else {
            return "~\(minutes + 1) min"
        }
    }
    
    // MARK: - Subviews

    private func modeButton(label: String, isActive: Bool, highlight: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            Text(label)
                .font(.worldCupCaption)
                .fontWeight(.semibold)
                .foregroundColor(isActive ? (highlight ? .black : .wc_textPrimary) : .wc_textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isActive ? (highlight ? Color.wc_mexLime : Color.wc_mexRed.opacity(0.7)) : Color.white.opacity(0.15))
                )
        }
        .accessibilityLabel("Modo de ruta: \(label)")
        .accessibilityHint(isActive ? "Modo \(label) seleccionado. Doble toque para cambiar al otro modo" : "Doble toque para seleccionar modo \(label)")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private func tabItem(icon: String, title: String, isCurrent: Bool) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isCurrent ? Color.wc_mexLime.opacity(0.3) : Color.white.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isCurrent ? .wc_mexLime : .wc_textPrimary)
            }
            Text(title)
                .font(.worldCupCaption)
                .fontWeight(.semibold)
                .foregroundColor(isCurrent ? .wc_textPrimary : .wc_textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
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
