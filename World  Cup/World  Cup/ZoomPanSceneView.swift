import SwiftUI
import SceneKit

// MARK: - Scene Configuration
struct SceneConfig {
    var minDistance: Float = 10
    var maxDistance: Float = 80
    var maxOrbitElevation: Float = .pi / 3  // ~60°
    var panBounds: SIMD2<Float> = .init(120, 120) // overscroll XY
    var zoomFactor: Float = 0.6 // Factor de zoom en double tap
}

// MARK: - Zoom Pan Scene View
struct ZoomPanSceneView: UIViewRepresentable {
    var config: SceneConfig
    var sceneProvider: () -> SCNScene?
    var poiService: StadiumPOIService?
    var onPOISelected: ((POI) -> Void)?
    var currentRoute: Route?
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.allowsCameraControl = false // Usamos gestos propios
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.clear
        
        // Crear escena
        let scene = sceneProvider() ?? SCNScene()
        sceneView.scene = scene
        
        // Configurar iluminación mejorada
        setupLighting(in: scene)
        
        // Configurar cámara
        setupCamera(in: sceneView, context: context)
        
        // Configurar gestos
        setupGestures(for: sceneView, context: context)
        
        // Guardar referencia
        context.coordinator.sceneView = sceneView
        
        // Ajustar cámara al modelo después de cargar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !context.coordinator.hasFittedToModel {
                context.coordinator.fitToModel()
                context.coordinator.hasFittedToModel = true
            }
        }
        
        return sceneView
    }
    
    private func setupLighting(in scene: SCNScene) {
        // Iluminación ambiental
        scene.background.contents = UIColor(red: 0.06, green: 0.21, blue: 0.19, alpha: 1.0)
        
        // Luz principal (sol)
        let mainLight = SCNLight()
        mainLight.type = .directional
        mainLight.intensity = 1000
        mainLight.castsShadow = true
        let mainLightNode = SCNNode()
        mainLightNode.light = mainLight
        mainLightNode.position = SCNVector3(x: 5, y: 15, z: 5)
        mainLightNode.look(at: SCNVector3Zero)
        scene.rootNode.addChildNode(mainLightNode)
        
        // Luz de relleno
        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.intensity = 500
        let fillLightNode = SCNNode()
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(x: -5, y: 10, z: -5)
        scene.rootNode.addChildNode(fillLightNode)
        
        // Luz ambiental
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 300
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Actualizar escena si cambia
        if let newScene = sceneProvider() {
            uiView.scene = newScene
        }
        
        // Actualizar POIs si cambian
        if let poiService = poiService {
            context.coordinator.updatePOIs(poiService: poiService, scene: uiView.scene ?? SCNScene())
        }
        
        // Actualizar ruta si cambia
        if let route = currentRoute {
            context.coordinator.updateRoute(route: route, scene: uiView.scene ?? SCNScene())
        }
    }
    
    private func setupCamera(in sceneView: SCNView, context: Context) {
        guard let scene = sceneView.scene else { return }
        
        // Crear cámara
        let cameraNode = SCNNode()
        cameraNode.name = "CameraNode"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 55
        cameraNode.camera?.wantsHDR = true
        cameraNode.camera?.wantsExposureAdaptation = true
        
        // Posición inicial más cercana
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 20)
        
        // Create a hidden target node for look-at
        let targetNode = SCNNode()
        targetNode.name = "CameraLookAtTarget"
        targetNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(targetNode)
        
        let lookAt = SCNLookAtConstraint(target: targetNode)
        lookAt.isGimbalLockEnabled = true
        cameraNode.constraints = [lookAt]
        
        scene.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode
        
        // Guardar referencia
        context.coordinator.cameraNode = cameraNode
        context.coordinator.lookAtTargetNode = targetNode
        context.coordinator.initialDistance = distance(from: cameraNode.position, to: SCNVector3Zero)
        context.coordinator.currentDistance = context.coordinator.initialDistance
        context.coordinator.currentPanOffset = SIMD2<Float>(0, 0)
    }
    
    private func setupGestures(for sceneView: SCNView, context: Context) {
        // Pinch para zoom
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
        context.coordinator.pinchGesture = pinchGesture
        
        // Pan con un dedo para órbita
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGesture)
        context.coordinator.panGesture = panGesture
        
        // Pan con dos dedos para strafe
        let twoFingerPan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTwoFingerPan(_:)))
        twoFingerPan.minimumNumberOfTouches = 2
        twoFingerPan.maximumNumberOfTouches = 2
        sceneView.addGestureRecognizer(twoFingerPan)
        context.coordinator.twoFingerPanGesture = twoFingerPan
        
        // Doble tap para zoom
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(doubleTapGesture)
        context.coordinator.doubleTapGesture = doubleTapGesture
        
        // Tap simple para seleccionar POI
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.require(toFail: doubleTapGesture)
        sceneView.addGestureRecognizer(tapGesture)
        context.coordinator.tapGesture = tapGesture
        
        // Guardar referencias
        context.coordinator.config = config
        context.coordinator.onPOISelected = onPOISelected
        context.coordinator.poiService = poiService
    }
    
    private func distance(from point1: SCNVector3, to point2: SCNVector3) -> Float {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        let dz = point2.z - point1.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var sceneView: SCNView?
        var cameraNode: SCNNode?
        var lookAtTargetNode: SCNNode?
        var config: SceneConfig = SceneConfig()
        
        // Estado de cámara
        var initialDistance: Float = 30
        var currentDistance: Float = 30
        var currentPanOffset: SIMD2<Float> = .zero
        var orbitAngle: Float = 0
        var elevationAngle: Float = 0
        var hasFittedToModel: Bool = false // Flag para hacer fit solo una vez
        
        // Gestos
        var pinchGesture: UIPinchGestureRecognizer?
        var panGesture: UIPanGestureRecognizer?
        var twoFingerPanGesture: UIPanGestureRecognizer?
        var doubleTapGesture: UITapGestureRecognizer?
        var tapGesture: UITapGestureRecognizer?
        
        // Callbacks
        var onPOISelected: ((POI) -> Void)?
        var poiService: StadiumPOIService?
        var poiNodes: [SCNNode] = []
        var routeNodes: [SCNNode] = []
        
        // MARK: - Gesture Handlers
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let cameraNode = cameraNode,
                  gesture.state != .failed else { return }
            
            // Deshabilitar otros gestos mientras se hace pinch
            if gesture.state == .began {
                panGesture?.isEnabled = false
                twoFingerPanGesture?.isEnabled = false
                initialDistance = currentDistance
            }
            
            if gesture.state == .began {
                gesture.scale = CGFloat(currentDistance / initialDistance)
            }
            
            let newDistance = Float(gesture.scale) * initialDistance
            currentDistance = max(config.minDistance, min(config.maxDistance, newDistance))
            
            if gesture.state == .ended || gesture.state == .cancelled {
                // Rehabilitar otros gestos
                panGesture?.isEnabled = true
                twoFingerPanGesture?.isEnabled = true
                initialDistance = currentDistance
            }
            
            updateCameraPosition()
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard gesture.numberOfTouches == 1,
                  gesture.state != .failed else { return }
            
            // Deshabilitar otros gestos mientras se hace pan
            if gesture.state == .began {
                pinchGesture?.isEnabled = false
                twoFingerPanGesture?.isEnabled = false
            }
            
            let translation = gesture.translation(in: sceneView)
            let sensitivity: Float = 0.01
            
            orbitAngle += Float(translation.x) * sensitivity
            elevationAngle += Float(-translation.y) * sensitivity
            
            // Limitar elevación
            elevationAngle = max(-config.maxOrbitElevation, min(config.maxOrbitElevation, elevationAngle))
            
            if gesture.state == .ended || gesture.state == .cancelled {
                // Rehabilitar otros gestos
                pinchGesture?.isEnabled = true
                twoFingerPanGesture?.isEnabled = true
            }
            
            updateCameraPosition()
            
            // Resetear la traducción para movimiento relativo
            gesture.setTranslation(.zero, in: sceneView)
        }
        
        @objc func handleTwoFingerPan(_ gesture: UIPanGestureRecognizer) {
            guard gesture.numberOfTouches == 2,
                  gesture.state != .failed else { return }
            
            // Deshabilitar otros gestos mientras se hace pan con dos dedos
            if gesture.state == .began {
                panGesture?.isEnabled = false
                pinchGesture?.isEnabled = false
            }
            
            let translation = gesture.translation(in: sceneView)
            let sensitivity: Float = 0.5
            
            let deltaX = Float(translation.x) * sensitivity
            let deltaY = Float(translation.y) * sensitivity
            
            currentPanOffset.x += deltaX
            currentPanOffset.y += deltaY
            
            // Aplicar límites suaves
            currentPanOffset.x = max(-config.panBounds.x, min(config.panBounds.x, currentPanOffset.x))
            currentPanOffset.y = max(-config.panBounds.y, min(config.panBounds.y, currentPanOffset.y))
            
            if gesture.state == .ended || gesture.state == .cancelled {
                // Rehabilitar otros gestos
                panGesture?.isEnabled = true
                pinchGesture?.isEnabled = true
            }
            
            updateCameraPosition()
            
            // Resetear la traducción para movimiento relativo
            gesture.setTranslation(.zero, in: sceneView)
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView?.hitTest(location, options: [:])
            
            // Optionally use the hit point in the future to animate focus
            _ = hitResults?.first?.worldCoordinates
            
            // Reduce distance (zoom in)
            currentDistance *= config.zoomFactor
            currentDistance = max(config.minDistance, min(config.maxDistance, currentDistance))
            
            updateCameraPosition()
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = sceneView else { return }
            
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: [:])
            
            // Verificar si se tocó un POI
            var poiFound = false
            if let firstResult = hitResults.first {
                let node = firstResult.node
                
                // Buscar por nombre del nodo
                if let nodeName = node.name,
                   let poi = poiService?.pois.first(where: { $0.id == nodeName }) {
                    onPOISelected?(poi)
                    poiFound = true
                }
                // También buscar en nodos padre (si el texto fue tocado)
                else if let parent = node.parent,
                        let parentName = parent.name,
                        let poi = poiService?.pois.first(where: { $0.id == parentName }) {
                    onPOISelected?(poi)
                    poiFound = true
                }
            }
            
            // Si no se tocó un POI, no hacer nada (los puntos están preestablecidos)
        }
        
        // MARK: - Camera Updates
        
        private func updateCameraPosition() {
            guard let cameraNode = cameraNode else { return }
            
            // Calcular posición en esfera orbital
            let x = currentDistance * cos(elevationAngle) * sin(orbitAngle) + currentPanOffset.x
            let y = currentDistance * sin(elevationAngle) + currentPanOffset.y
            let z = currentDistance * cos(elevationAngle) * cos(orbitAngle)
            
            cameraNode.position = SCNVector3(x: x, y: y, z: z)
            
            // Mirar hacia el origen (con offset de pan)
            let lookAtPoint = SCNVector3(
                x: currentPanOffset.x,
                y: 0,
                z: currentPanOffset.y
            )
            
            if let targetNode = lookAtTargetNode {
                targetNode.position = lookAtPoint
                if let constraints = cameraNode.constraints, let lookAtConstraint = constraints.compactMap({ $0 as? SCNLookAtConstraint }).first {
                    // already set
                } else {
                    let lookAt = SCNLookAtConstraint(target: targetNode)
                    lookAt.isGimbalLockEnabled = true
                    cameraNode.constraints = [lookAt]
                }
            }
        }
        
        // MARK: - POI Management
        
        func updatePOIs(poiService: StadiumPOIService, scene: SCNScene) {
            // Remover POIs anteriores
            poiNodes.forEach { $0.removeFromParentNode() }
            poiNodes.removeAll()
            
            // Crear marcadores para cada POI
            for poi in poiService.pois {
                let markerNode = createPOIMarker(for: poi)
                scene.rootNode.addChildNode(markerNode)
                poiNodes.append(markerNode)
            }
        }
        
        private func createPOIMarker(for poi: POI) -> SCNNode {
            let sphere = SCNSphere(radius: 0.3)
            let material = SCNMaterial()
            let accessibleColor = UIColor(red: 0.66, green: 1.0, blue: 0.24, alpha: 1.0)
            material.diffuse.contents = poi.accessibility.wheelchairAccessible ? accessibleColor : UIColor.blue
            material.emission.contents = poi.accessibility.wheelchairAccessible ? accessibleColor.withAlphaComponent(0.3) : UIColor.blue.withAlphaComponent(0.3)
            sphere.materials = [material]
            
            let markerNode = SCNNode(geometry: sphere)
            markerNode.position = SCNVector3(
                x: poi.coordinates.x,
                y: poi.coordinates.y,
                z: poi.coordinates.z
            )
            markerNode.name = poi.id
            
            return markerNode
        }
        
        // MARK: - Route Management
        
        func updateRoute(route: Route, scene: SCNScene) {
            // Remover ruta anterior
            routeNodes.forEach { $0.removeFromParentNode() }
            routeNodes.removeAll()
            
            // Crear línea de ruta
            let routePath = createRoutePath(points: route.points)
            let routeNode = SCNNode(geometry: routePath)
            routeNode.position = SCNVector3Zero
            scene.rootNode.addChildNode(routeNode)
            routeNodes.append(routeNode)
        }
        
        private func createRoutePath(points: [RoutePoint]) -> SCNGeometry {
            let path = UIBezierPath()
            
            guard let firstPoint = points.first else {
                return SCNGeometry()
            }
            
            let first2D = CGPoint(x: CGFloat(firstPoint.position.x), y: CGFloat(firstPoint.position.z))
            path.move(to: first2D)
            
            for point in points.dropFirst() {
                let point2D = CGPoint(x: CGFloat(point.position.x), y: CGFloat(point.position.z))
                path.addLine(to: point2D)
            }
            
            let shape = SCNShape(path: path, extrusionDepth: 0.1)
            let material = SCNMaterial()
            let accessibleColor = UIColor(red: 0.66, green: 1.0, blue: 0.24, alpha: 1.0)
            material.diffuse.contents = accessibleColor
            material.emission.contents = accessibleColor.withAlphaComponent(0.5)
            shape.materials = [material]
            
            return shape
        }
        
        // MARK: - Public Methods
        
        func fitToModel() {
            guard let scene = sceneView?.scene,
                  let cameraNode = cameraNode else { return }
            
            // Esperar un poco más si el modelo se está cargando
            var attempts = 0
            let maxAttempts = 10
            
            func calculateFit() {
                attempts += 1
                
                // Calcular bounding box de toda la escena
                var minPoint = SCNVector3(x: Float.infinity, y: Float.infinity, z: Float.infinity)
                var maxPoint = SCNVector3(x: -Float.infinity, y: -Float.infinity, z: -Float.infinity)
                var hasGeometry = false
                
                scene.rootNode.enumerateChildNodes { node, _ in
                    // Ignorar cámara, luces y nodos especiales
                    if node.name == "CameraLookAtTarget" || 
                       node.name == "CameraNode" ||
                       node.light != nil || 
                       node.camera != nil {
                        return
                    }
                    
                    // Verificar si el nodo tiene geometría válida
                    if node.geometry != nil {
                        let bbox = node.boundingBox
                        let localMin = bbox.min
                        let localMax = bbox.max
                        
                        // Verificar que el bounding box sea válido
                        if localMax.x > localMin.x || localMax.y > localMin.y || localMax.z > localMin.z {
                            hasGeometry = true
                            let worldMin = scene.rootNode.convertPosition(localMin, from: node)
                            let worldMax = scene.rootNode.convertPosition(localMax, from: node)
                            
                            minPoint.x = Swift.min(minPoint.x, Swift.min(worldMin.x, worldMax.x))
                            minPoint.y = Swift.min(minPoint.y, Swift.min(worldMin.y, worldMax.y))
                            minPoint.z = Swift.min(minPoint.z, Swift.min(worldMin.z, worldMax.z))
                            
                            maxPoint.x = Swift.max(maxPoint.x, Swift.max(worldMin.x, worldMax.x))
                            maxPoint.y = Swift.max(maxPoint.y, Swift.max(worldMin.y, worldMax.y))
                            maxPoint.z = Swift.max(maxPoint.z, Swift.max(worldMin.z, worldMax.z))
                        }
                    }
                }
                
                // Si no hay geometría válida y aún no hemos intentado mucho, esperar
                if !hasGeometry && attempts < maxAttempts {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        calculateFit()
                    }
                    return
                }
                
                // Si no hay geometría, usar valores por defecto
                if minPoint.x == Float.infinity {
                    minPoint = SCNVector3(x: -10, y: -5, z: -10)
                    maxPoint = SCNVector3(x: 10, y: 5, z: 10)
                }
                
                // Calcular centro y tamaño
                let center = SCNVector3(
                    x: (minPoint.x + maxPoint.x) / 2,
                    y: (minPoint.y + maxPoint.y) / 2,
                    z: (minPoint.z + maxPoint.z) / 2
                )
                
                let size = SCNVector3(
                    x: maxPoint.x - minPoint.x,
                    y: maxPoint.y - minPoint.y,
                    z: maxPoint.z - minPoint.z
                )
                
                let maxSize = max(size.x, size.y, size.z)
                
                // Calcular distancia óptima para ver todo el modelo
                let fovRadians = Float(55) * .pi / 180.0
                var distance: Float = 30 // Valor por defecto
                
                if maxSize > 0 {
                    distance = (maxSize / 2) / tan(fovRadians / 2) * 1.5 // 1.5x para dar margen
                }
                
                // Ajustar distancia
                currentDistance = max(config.minDistance, min(config.maxDistance, distance))
                initialDistance = currentDistance
                
                // Posicionar cámara en órbita
                orbitAngle = 0
                elevationAngle = .pi / 6 // 30 grados de elevación
                
                // Mover el look-at target al centro del modelo
                if let targetNode = lookAtTargetNode {
                    targetNode.position = center
                }
                
                // Actualizar posición de cámara
                updateCameraPosition()
            }
            
            calculateFit()
        }
        
        func focus(on node: SCNNode) {
            guard let cameraNode = cameraNode else { return }
            
            let targetPosition = node.position
            let distance: Float = 15
            
            // Calcular posición orbital
            let x = targetPosition.x + distance * sin(orbitAngle)
            let y = targetPosition.y + distance * sin(elevationAngle)
            let z = targetPosition.z + distance * cos(orbitAngle)
            
            let newPosition = SCNVector3(x: x, y: y, z: z)
            
            // Animar
            let moveAction = SCNAction.move(to: newPosition, duration: 0.5)
            moveAction.timingMode = .easeInEaseOut
            
            cameraNode.runAction(moveAction)
        }
    }
}

// MARK: - Preview
#Preview {
    ZoomPanSceneView(
        config: .init(minDistance: 12, maxDistance: 85, maxOrbitElevation: .pi/2.8, panBounds: .init(140, 140)),
        sceneProvider: {
            let scene = SCNScene()
            let plane = SCNPlane(width: 10, height: 10)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.gray
            plane.materials = [material]
            let planeNode = SCNNode(geometry: plane)
            scene.rootNode.addChildNode(planeNode)
            return scene
        }
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.routeDarkGreen)
}

