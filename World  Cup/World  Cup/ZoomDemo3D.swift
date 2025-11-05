import SwiftUI
import SceneKit

// MARK: - Zoom Demo 3D View
struct ZoomDemo3D: View {
    @StateObject private var poiService = StadiumPOIService()
    
    var body: some View {
        ZStack {
            Color.routeDarkGreen.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Mapa 3D - Navegación con Zoom y Pan")
                    .font(.headline)
                    .foregroundColor(.routeText)
                    .padding(.top)
                
                ZoomPanSceneView(
                    config: .init(
                        minDistance: 12,
                        maxDistance: 85,
                        maxOrbitElevation: .pi / 2.8,
                        panBounds: .init(140, 140)
                    ),
                    sceneProvider: {
                        buildDemoScene()
                    },
                    poiService: poiService,
                    onPOISelected: { poi in
                        print("POI seleccionado: \(poi.name)")
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityLabel("Mapa del Estadio 3D, usa gesto de pinza para zoom y arrastra para moverte")
                
                // Instrucciones
                VStack(spacing: 8) {
                    Text("Instrucciones:")
                        .font(.caption)
                        .foregroundColor(.routeText)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 4) {
                        Label("Un dedo: órbita", systemImage: "hand.point.up.left")
                            .font(.caption2)
                            .foregroundColor(.routeMuted)
                        Label("Dos dedos: mover", systemImage: "hand.draw")
                            .font(.caption2)
                            .foregroundColor(.routeMuted)
                        Label("Pinza: zoom", systemImage: "hand.point.up.left.and.text")
                            .font(.caption2)
                            .foregroundColor(.routeMuted)
                        Label("Doble toque: acercar", systemImage: "hand.tap")
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
    
    private func buildDemoScene() -> SCNScene {
        let scene = SCNScene()
        
        // Cargar el modelo USDZ si existe
        if let modelURL = Bundle.main.url(forResource: "Stadium", withExtension: "usdz") {
            let referenceNode = SCNReferenceNode(url: modelURL)
            referenceNode?.load()
            
            if let stadiumNode = referenceNode {
                stadiumNode.scale = SCNVector3(x: 1, y: 1, z: 1)
                stadiumNode.position = SCNVector3Zero
                scene.rootNode.addChildNode(stadiumNode)
                return scene
            }
        }
        
        // Crear escena de ejemplo si no hay modelo
        // Suelo
        let floor = SCNPlane(width: 20, height: 20)
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0)
        floor.materials = [floorMaterial]
        let floorNode = SCNNode(geometry: floor)
        floorNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: -.pi/2)
        scene.rootNode.addChildNode(floorNode)
        
        // Cancha (rectángulo central)
        let field = SCNPlane(width: 10, height: 6)
        let fieldMaterial = SCNMaterial()
        fieldMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        field.materials = [fieldMaterial]
        let fieldNode = SCNNode(geometry: field)
        fieldNode.position = SCNVector3(x: 0, y: 0.1, z: 0)
        fieldNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: -.pi/2)
        scene.rootNode.addChildNode(fieldNode)
        
        // Gradas (cajas simples)
        for i in 0..<4 {
            let stand = SCNBox(width: 2, height: 1, length: 2, chamferRadius: 0.1)
            let standMaterial = SCNMaterial()
            standMaterial.diffuse.contents = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
            stand.materials = [standMaterial]
            let standNode = SCNNode(geometry: stand)
            
            let angle = Float(i) * .pi / 2
            standNode.position = SCNVector3(
                x: 6 * cos(angle),
                y: 0.5,
                z: 6 * sin(angle)
            )
            scene.rootNode.addChildNode(standNode)
        }
        
        // Iluminación
        let light = SCNLight()
        light.type = .omni
        light.intensity = 1000
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        return scene
    }
}

#Preview {
    ZoomDemo3D()
}

