import SwiftUI
import SceneKit
import ARKit
import simd

// MARK: - Stadium 3D View
struct Stadium3DView: UIViewRepresentable {
    @ObservedObject var poiService: StadiumPOIService
    var onPOISelected: (POI) -> Void
    var currentRoute: Route?
    
    // Ajustes de cámara/gestos
    private let minDistance: Float = 3.0
    private let maxDistance: Float = 60.0
    private let panSpeed: Float = 0.01  // Reducido de 0.02 para movimiento más lento
    private let zoomSpeed: Float = 0.6   // Reducido de 0.8 para zoom más lento
    private let initialDistance: Float = 14.0
    private let initialHeight: Float = 6.0
    
    // Límites de elevación (pitch) de la órbita
    // x negativo = mirar hacia abajo; permitimos casi top-down (-~86°)
    private let minOrbitPitch: Float = -1.50   // ~ -86º (arriba)
    private let maxOrbitPitch: Float = 0.60    // ~ 34º  (no dejar ver "desde abajo")
    private let orbitPanSensitivity: Float = 0.002 // Reducido de 0.005 para movimiento más lento
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = SCNScene()
        sceneView.allowsCameraControl = false // Usaremos nuestros propios gestos
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.clear
        
        // Configurar la escena
        setupScene(in: sceneView, context: context)
        
        // Configurar gestos
        setupGestures(for: sceneView, context: context)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Actualizar POIs si cambian
        updatePOIMarkers(in: uiView, context: context)
        
        // Actualizar ruta si cambia
        if let route = currentRoute {
            updateRoute(in: uiView, route: route, context: context)
        } else {
            // Limpiar ruta si no hay
            context.coordinator.routeNodes.forEach { $0.removeFromParentNode() }
            context.coordinator.routeNodes.removeAll()
        }
    }
    
    private func setupScene(in sceneView: SCNView, context: Context) {
        guard let scene = sceneView.scene else { return }
        
        // Cargar el modelo USDZ
        guard let modelURL = Bundle.main.url(forResource: "Stadium", withExtension: "usdz") else {
            print("⚠️ No se encontró el archivo Stadium.usdz en el bundle")
            createPlaceholderScene(in: scene)
            setupCameraRig(in: scene, context: context) // aun con placeholder
            updatePOIMarkers(in: sceneView, context: context)
            return
        }
        
        // Cargar el modelo USDZ usando SceneKit
        let referenceNode = SCNReferenceNode(url: modelURL)
        
        // Configurar rig de cámara (antes de cargar para evitar parpadeos)
        setupCameraRig(in: scene, context: context)
        
        // Cargar de forma asíncrona
        DispatchQueue.global(qos: .userInitiated).async {
            referenceNode?.load()
            DispatchQueue.main.async {
                if let stadiumNode = referenceNode {
                    // Escalar y posicionar el modelo
                    stadiumNode.scale = SCNVector3(x: 1, y: 1, z: 1)
                    stadiumNode.position = SCNVector3(x: 0, y: 0, z: 0)
                    
                    // Ocultar cualquier plano verde o elemento visual no deseado
                    self.hideUnwantedGeometry(in: stadiumNode)
                    
                    scene.rootNode.addChildNode(stadiumNode)
                    context.coordinator.stadiumNode = stadiumNode
                    // Agregar POIs después de cargar el modelo
                    self.updatePOIMarkers(in: sceneView, context: context)
                } else {
                    print("⚠️ No se pudo cargar el modelo Stadium.usdz")
                    self.createPlaceholderScene(in: scene)
                }
            }
        }
        
        // Iluminación
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // Marcadores iniciales
        updatePOIMarkers(in: sceneView, context: context)
    }
    
    private func setupCameraRig(in scene: SCNScene, context: Context) {
        // targetNode es el "punto de mira" (centro del estadio)
        let targetNode = SCNNode()
        targetNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(targetNode)
        
        // orbitNode rota alrededor del target (órbita Y y X)
        let orbitNode = SCNNode()
        targetNode.addChildNode(orbitNode)
        
        // cameraNode se coloca atrás/arriba mirando al target
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, initialHeight, initialDistance)
        
        // Mirar siempre al target
        let look = SCNLookAtConstraint(target: targetNode)
        look.isGimbalLockEnabled = true
        cameraNode.constraints = [look]
        orbitNode.addChildNode(cameraNode)
        
        scene.rootNode.addChildNode(targetNode)
        
        // Guardar en el coordinador
        context.coordinator.cameraNode = cameraNode
        context.coordinator.targetNode = targetNode
        context.coordinator.orbitNode = orbitNode
        context.coordinator.currentDistance = initialDistance
        context.coordinator.initialDistance = initialDistance
        context.coordinator.initialHeight = initialHeight
        
        // Límites/sensibilidad de pitch
        context.coordinator.minOrbitPitch = minOrbitPitch
        context.coordinator.maxOrbitPitch = maxOrbitPitch
        context.coordinator.orbitPanSensitivity = orbitPanSensitivity
    }
    
    private func createPlaceholderScene(in scene: SCNScene) {
        // Crear un plano como placeholder (solo si no hay modelo)
        // No crear el plano verde si el modelo está cargado
        // El plano verde se elimina porque no es necesario y causa una raya visual
    }
    
    // Función para ocultar elementos visuales no deseados (planos verdes, etc.)
    private func hideUnwantedGeometry(in node: SCNNode) {
        // Recursivamente buscar y ocultar planos verdes o elementos no deseados
        if let geometry = node.geometry {
            // Verificar si es un plano
            if let plane = geometry as? SCNPlane {
                // Verificar el color del material
                if let material = geometry.firstMaterial {
                    var shouldHide = false
                    
                    // Verificar color en diffuse
                    if let color = material.diffuse.contents as? UIColor {
                        let components = color.cgColor.components ?? []
                        if components.count >= 3 {
                            let red = components[0]
                            let green = components[1]
                            let blue = components[2]
                            // Si es verde brillante (similar al color accesible lime), ocultarlo
                            if green > 0.8 && blue > 0.2 && blue < 0.3 && red < 0.7 {
                                shouldHide = true
                            }
                        }
                    }
                    
                    // También verificar si el nombre del nodo sugiere que es un plano no deseado
                    if let nodeName = node.name?.lowercased() {
                        if nodeName.contains("plane") || nodeName.contains("ground") || nodeName.contains("floor") {
                            shouldHide = true
                        }
                    }
                    
                    // Si es un plano horizontal (rotado en X o Y), es más probable que sea la raya
                    let rotation = node.eulerAngles
                    let isHorizontal = abs(rotation.x) > 1.4 || abs(rotation.y) > 1.4 || abs(rotation.z) > 1.4
                    
                    if shouldHide || (isHorizontal && plane.width > 5 && plane.height > 5) {
                        node.isHidden = true
                        return
                    }
                }
            }
        }
        
        // Recursivamente procesar nodos hijos
        for childNode in node.childNodes {
            hideUnwantedGeometry(in: childNode)
        }
    }
    
    private func updatePOIMarkers(in sceneView: SCNView, context: Context) {
        guard let scene = sceneView.scene else { return }
        
        // Remover marcadores anteriores
        context.coordinator.poiNodes.forEach { $0.removeFromParentNode() }
        context.coordinator.poiNodes.removeAll()
        
        // Solo mostrar POIs seleccionados (inicio y fin)
        if let startPOI = poiService.selectedStartPOI {
            let markerNode = createPOIMarker(for: startPOI, isStart: true, isEnd: false)
            scene.rootNode.addChildNode(markerNode)
            context.coordinator.poiNodes.append(markerNode)
        }
        
        if let endPOI = poiService.selectedEndPOI {
            let markerNode = createPOIMarker(for: endPOI, isStart: false, isEnd: true)
            scene.rootNode.addChildNode(markerNode)
            context.coordinator.poiNodes.append(markerNode)
        }
    }
    
    private func createPOIMarker(for poi: POI, isStart: Bool, isEnd: Bool) -> SCNNode {
        // Crear marcador visible en el mapa
        let markerGroup = SCNNode()
        
        // Esfera principal (más grande y visible)
        let sphere = SCNSphere(radius: 0.6)
        let material = SCNMaterial()
        
        // Color según tipo (inicio = verde, fin = azul)
        let startColor = UIColor(red: 0.66, green: 1.0, blue: 0.24, alpha: 1.0) // Verde
        let endColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0) // Azul
        
        let nodeColor = isStart ? startColor : (isEnd ? endColor : (poi.accessibility.wheelchairAccessible ? startColor : endColor))
        
        material.diffuse.contents = nodeColor
        material.emission.contents = nodeColor.withAlphaComponent(0.8)
        material.transparency = 0.9
        sphere.materials = [material]
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(0, 0.3, 0) // Más cerca del suelo
        markerGroup.addChildNode(sphereNode)
        
        // Cilindro base más grande para que se vea mejor en el suelo
        let cylinder = SCNCylinder(radius: 0.5, height: 0.15)
        let baseMaterial = SCNMaterial()
        baseMaterial.diffuse.contents = nodeColor
        baseMaterial.emission.contents = nodeColor.withAlphaComponent(0.6)
        cylinder.materials = [baseMaterial]
        
        let baseNode = SCNNode(geometry: cylinder)
        baseNode.position = SCNVector3(0, 0.075, 0) // En el suelo
        markerGroup.addChildNode(baseNode)
        
        // Texto distintivo: INICIO o FIN
        let labelText = isStart ? "INICIO" : (isEnd ? "FIN" : poi.name)
        let text = SCNText(string: labelText, extrusionDepth: 0.05)
        text.font = UIFont.systemFont(ofSize: 1.0, weight: .bold)
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.firstMaterial?.emission.contents = UIColor.white.withAlphaComponent(0.8)
        
        let textNode = SCNNode(geometry: text)
        let textBounds = text.boundingBox
        let textWidth = textBounds.max.x - textBounds.min.x
        textNode.position = SCNVector3(-textWidth * 0.05, 1.5, 0) // Más arriba
        textNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
        
        // Fondo para el texto con color distintivo
        let textBackground = SCNPlane(width: CGFloat(textWidth * 0.1) + 1.0, height: 0.4)
        let bgMaterial = SCNMaterial()
        bgMaterial.diffuse.contents = nodeColor.withAlphaComponent(0.9)
        bgMaterial.emission.contents = nodeColor.withAlphaComponent(0.3)
        textBackground.materials = [bgMaterial]
        
        let bgNode = SCNNode(geometry: textBackground)
        bgNode.position = SCNVector3(-textWidth * 0.05, 1.5, -0.01)
        bgNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0) // Rotar para que sea horizontal
        markerGroup.addChildNode(bgNode)
        markerGroup.addChildNode(textNode)
        
        // Nombre del POI debajo del distintivo
        let nameText = SCNText(string: poi.name, extrusionDepth: 0.03)
        nameText.font = UIFont.systemFont(ofSize: 0.6, weight: .semibold)
        nameText.firstMaterial?.diffuse.contents = UIColor.white
        nameText.firstMaterial?.emission.contents = UIColor.white.withAlphaComponent(0.5)
        
        let nameTextNode = SCNNode(geometry: nameText)
        let nameTextBounds = nameText.boundingBox
        let nameTextWidth = nameTextBounds.max.x - nameTextBounds.min.x
        nameTextNode.position = SCNVector3(-nameTextWidth * 0.03, 1.0, 0)
        nameTextNode.scale = SCNVector3(x: 0.06, y: 0.06, z: 0.06)
        markerGroup.addChildNode(nameTextNode)
        
        // Posicionar el grupo en las coordenadas del POI
        // Asegurar que los puntos estén en el suelo (y = 0 o muy cerca del suelo)
        // Los puntos deben estar alrededor del estadio, no flotando
        let groundY: Float = 0.0 // Altura del suelo
        markerGroup.position = SCNVector3(
            x: poi.coordinates.x,
            y: groundY, // Siempre en el suelo
            z: poi.coordinates.z
        )
        
        // Guardar referencia al POI
        markerGroup.name = poi.id
        
        // Agregar animación pulsante para hacerlo más visible
        let pulseAction = SCNAction.sequence([
            SCNAction.scale(to: 1.2, duration: 1.0),
            SCNAction.scale(to: 1.0, duration: 1.0)
        ])
        let repeatPulse = SCNAction.repeatForever(pulseAction)
        sphereNode.runAction(repeatPulse)
        
        return markerGroup
    }
    
    private func updateRoute(in sceneView: SCNView, route: Route, context: Context) {
        guard let scene = sceneView.scene else { return }
        
        // Remover ruta anterior
        context.coordinator.routeNodes.forEach { $0.removeFromParentNode() }
        context.coordinator.routeNodes.removeAll()
        
        // Crear ruta usando nodos
        createRouteNodes(points: route.points, isAccessible: route.isAccessible, scene: scene, context: context)
    }
    
    private func createRouteNodes(points: [RoutePoint], isAccessible: Bool, scene: SCNScene, context: Context) {
        guard points.count >= 2 else { return }
        
        // Colores
        let accessibleColor = UIColor(red: 0.66, green: 1.0, blue: 0.24, alpha: 1.0)
        let standardColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
        let routeColor = isAccessible ? accessibleColor : standardColor
        
        // Crear líneas entre puntos usando tubos 3D para mejor visibilidad
        for i in 0..<points.count - 1 {
            let startPoint = points[i].position
            let endPoint = points[i + 1].position
            
            // Calcular distancia y dirección
            let dx = endPoint.x - startPoint.x
            let dy = endPoint.y - startPoint.y
            let dz = endPoint.z - startPoint.z
            let distance = sqrt(dx*dx + dy*dy + dz*dz)
            
            // Crear tubo cilíndrico entre los puntos
            let cylinder = SCNCylinder(radius: 0.3, height: CGFloat(distance))
            let material = SCNMaterial()
            material.diffuse.contents = routeColor
            material.emission.contents = routeColor.withAlphaComponent(0.8)
            material.transparency = 0.9
            cylinder.materials = [material]
            
            let cylinderNode = SCNNode(geometry: cylinder)
            
            // Posicionar el cilindro en el punto medio
            // Asegurar que las rutas exteriores estén en el suelo
            let isExteriorRoute = abs(startPoint.x) > 10 || abs(startPoint.z) > 10 || abs(endPoint.x) > 10 || abs(endPoint.z) > 10
            let startY = isExteriorRoute ? 0.0 : startPoint.y
            let endY = isExteriorRoute ? 0.0 : endPoint.y
            
            let midPoint = SCNVector3(
                (startPoint.x + endPoint.x) / 2,
                (startY + endY) / 2,
                (startPoint.z + endPoint.z) / 2
            )
            cylinderNode.position = midPoint
            
            // Rotar el cilindro para que apunte de un punto al otro
            // Calcular el ángulo de rotación en el plano XZ (horizontal)
            let horizontalAngle = atan2(dx, dz)
            
            // Calcular el ángulo vertical si hay cambio en Y
            let horizontalDist = sqrt(dx*dx + dz*dz)
            let verticalAngle = horizontalDist > 0.01 ? atan2(dy, horizontalDist) : 0
            
            // Rotar el cilindro: primero alrededor del eje Y (horizontal), luego alrededor del eje X (vertical)
            // El cilindro por defecto está orientado verticalmente (eje Y), así que necesitamos rotarlo
            cylinderNode.eulerAngles = SCNVector3(
                Float.pi / 2 - verticalAngle, // Rotación vertical (eje X)
                horizontalAngle,              // Rotación horizontal (eje Y)
                0                             // Sin rotación en Z
            )
            
            scene.rootNode.addChildNode(cylinderNode)
            context.coordinator.routeNodes.append(cylinderNode)
        }
        
        // Crear esferas más grandes y visibles en cada punto de la ruta
        for (index, point) in points.enumerated() {
            let sphere = SCNSphere(radius: 0.4)
            let sphereMaterial = SCNMaterial()
            
            // Esfera más brillante para inicio y fin
            if index == 0 || index == points.count - 1 {
                sphereMaterial.diffuse.contents = routeColor
                sphereMaterial.emission.contents = routeColor.withAlphaComponent(1.0)
            } else {
                sphereMaterial.diffuse.contents = routeColor
                sphereMaterial.emission.contents = routeColor.withAlphaComponent(0.6)
            }
            
            sphere.materials = [sphereMaterial]
            
            let sphereNode = SCNNode(geometry: sphere)
            // Asegurar que estén en el suelo - todas las rutas deben estar en y=0
            // Para rutas exteriores, siempre en el suelo
            let isExteriorRoute = abs(point.position.x) > 10 || abs(point.position.z) > 10
            let groundY: Float = isExteriorRoute ? 0.0 : max(0.0, point.position.y)
            sphereNode.position = SCNVector3(
                point.position.x,
                groundY + 0.4,
                point.position.z
            )
            
            scene.rootNode.addChildNode(sphereNode)
            context.coordinator.routeNodes.append(sphereNode)
        }
    }
    
    // MARK: - Gestos
    private func setupGestures(for sceneView: SCNView, context: Context) {
        let coordinator = context.coordinator
        coordinator.sceneView = sceneView
        coordinator.poiService = poiService
        coordinator.onPOISelected = onPOISelected
        
        // Tap para POIs
        let tapGesture = UITapGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        
        // Pinch (zoom/dolly)
        let pinchGesture = UIPinchGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePinch(_:)))
        
        // Rotación (órbita yaw con gesto de rotación)
        let rotationGesture = UIRotationGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleRotation(_:)))
        
        // Pan (desplazar target XZ) - UN dedo
        let panGesture = UIPanGestureRecognizer(target: coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        
        // Pan de dos dedos (órbita yaw/pitch)
        let orbitPanGesture = UIPanGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleOrbitPan(_:)))
        orbitPanGesture.minimumNumberOfTouches = 2
        orbitPanGesture.maximumNumberOfTouches = 2
        
        // Doble tap para reset
        let doubleTap = UITapGestureRecognizer(target: coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        
        // Delegates para simultáneo
        [pinchGesture, rotationGesture, panGesture, orbitPanGesture, tapGesture, doubleTap].forEach {
            $0.delegate = coordinator
            sceneView.addGestureRecognizer($0)
        }
        
        // El tap de POIs debe esperar a que se decidan otros gestos
        tapGesture.require(toFail: pinchGesture)
        tapGesture.require(toFail: rotationGesture)
        tapGesture.require(toFail: panGesture)
        tapGesture.require(toFail: orbitPanGesture)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(minDistance: minDistance,
                    maxDistance: maxDistance,
                    panSpeed: panSpeed,
                    zoomSpeed: zoomSpeed)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        // Escena/rig
        var sceneView: SCNView?
        var stadiumNode: SCNReferenceNode?
        var cameraNode: SCNNode?
        var targetNode: SCNNode?
        var orbitNode: SCNNode?
        
        // Colecciones
        var poiNodes: [SCNNode] = []
        var routeNodes: [SCNNode] = []
        
        // Servicios/closures
        var poiService: StadiumPOIService?
        var onPOISelected: ((POI) -> Void)?
        
        // Estado de cámara/gestos
        var currentDistance: Float = 10
        var initialDistance: Float = 10
        var initialHeight: Float = 4
        
        private let minDistance: Float
        private let maxDistance: Float
        private let panSpeed: Float
        private let zoomSpeed: Float
        
        // Pitch (arriba/abajo)
        var minOrbitPitch: Float = -1.50
        var maxOrbitPitch: Float = 0.60
        var orbitPanSensitivity: Float = 0.005
        
        init(minDistance: Float, maxDistance: Float, panSpeed: Float, zoomSpeed: Float) {
            self.minDistance = minDistance
            self.maxDistance = maxDistance
            self.panSpeed = panSpeed
            self.zoomSpeed = zoomSpeed
        }
        
        // Permitir reconocimiento simultáneo (pinch + rotate + pans)
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = sceneView else { return }
            let location = gesture.location(in: sceneView)
            
            // Hit test para detectar qué se tocó
            let hitResults = sceneView.hitTest(location, options: [:])
            
            // ¿Se tocó un POI?
            if let firstResult = hitResults.first,
               let nodeName = firstResult.node.name,
               let poi = poiService?.pois.first(where: { $0.id == nodeName }) {
                onPOISelected?(poi)
            }
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            // Reset de cámara
            guard let cameraNode = cameraNode,
                  let targetNode = targetNode,
                  let orbitNode = orbitNode else { return }
            
            currentDistance = initialDistance
            cameraNode.position = SCNVector3(0, initialHeight, currentDistance)
            targetNode.position = SCNVector3Zero
            orbitNode.eulerAngles = SCNVector3Zero
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let cameraNode = cameraNode else { return }
            if gesture.state == .changed {
                let factor = Float(gesture.scale)
                // Corregir zoom invertido: cuando factor > 1 (pinch out) debe acercar (reducir distancia)
                // Cuando factor < 1 (pinch in) debe alejar (aumentar distancia)
                let proposed = currentDistance / factor // Invertir la lógica
                currentDistance = max(minDistance, min(maxDistance, proposed))
                cameraNode.position.z = currentDistance
                gesture.scale = 1.0
            }
        }
        
        // Yaw con gesto de rotación (opcional, también se puede con el pan de 2 dedos)
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let orbitNode = orbitNode else { return }
            if gesture.state == .changed {
                let delta = Float(gesture.rotation) * 0.5  // Reducir sensibilidad a la mitad
                orbitNode.eulerAngles.y += delta
                gesture.rotation = 0
            }
        }
        
        // Pan de 1 dedo: desplazar target en X-Z
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let targetNode = targetNode,
                  let cameraNode = cameraNode,
                  let view = sceneView else { return }
            
            let translation = gesture.translation(in: view)
            gesture.setTranslation(.zero, in: view)
            
            // Ejes de la cámara
            let camTransform = cameraNode.presentation.worldTransform
            let right = SCNVector3(camTransform.m11, camTransform.m12, camTransform.m13)
            let forward = SCNVector3(-camTransform.m31, -camTransform.m32, -camTransform.m33)
            
            let rightXZ = SCNVector3(right.x, 0, right.z)
            let forwardXZ = SCNVector3(forward.x, 0, forward.z)
            
            func normalize(_ v: SCNVector3) -> SCNVector3 {
                let l = max(0.0001, sqrt(v.x*v.x + v.y*v.y + v.z*v.z))
                return SCNVector3(v.x/l, v.y/l, v.z/l)
            }
            let r = normalize(rightXZ)
            let f = normalize(forwardXZ)
            
            let scale = panSpeed * max(1, currentDistance * 0.5)
            
            let dx = Float(translation.x) * scale
            let dy = Float(translation.y) * scale
            
            let move = SCNVector3(-dx*r.x + dy*f.x, 0, -dx*r.z + dy*f.z)
            targetNode.position = targetNode.position + move
        }
        
        // Pan de 2 dedos: órbita yaw/pitch (incluye mirar "desde arriba")
        @objc func handleOrbitPan(_ gesture: UIPanGestureRecognizer) {
            guard let orbitNode = orbitNode,
                  let view = sceneView else { return }
            let t = gesture.translation(in: view)
            gesture.setTranslation(.zero, in: view)
            
            // Horizontal → yaw
            orbitNode.eulerAngles.y += Float(t.x) * orbitPanSensitivity
            
            // Vertical → pitch (invertido para que arrastrar hacia arriba “levante” la cámara)
            let desiredPitch = orbitNode.eulerAngles.x + Float(-t.y) * orbitPanSensitivity
            orbitNode.eulerAngles.x = clamp(desiredPitch, minOrbitPitch, maxOrbitPitch)
        }
        
        private func clamp(_ v: Float, _ minV: Float, _ maxV: Float) -> Float {
            return max(minV, min(maxV, v))
        }
    }
}

// MARK: - Utilidades
fileprivate func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
}
