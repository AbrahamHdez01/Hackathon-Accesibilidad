import Foundation
import SwiftUI

// MARK: - Stadium POI Service
class StadiumPOIService: ObservableObject {
    @Published var pois: [POI] = []
    @Published var selectedStartPOI: POI?
    @Published var selectedEndPOI: POI?
    
    init() {
        loadDefaultPOIs()
    }
    
    private func loadDefaultPOIs() {
        // POIs predefinidos del Estadio Azteca - 20+ puntos estratégicos
        // Distribuidos en el mapa para crear rutas variadas
        pois = [
            // === ENTRADAS (Accesibles) ===
            POI(
                id: "entrance_main",
                name: "Entrada Principal",
                description: "Entrada principal del Estadio Azteca con acceso completo",
                type: .entrance,
                coordinates: SIMD3<Float>(0, 0, -20),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Monumento", "Fuente", "Pantallas grandes"],
                    hasElevator: true,
                    hasRamp: true,
                    hasAccessibleRestroom: true
                )
            ),
            POI(
                id: "entrance_norte",
                name: "Entrada Norte",
                description: "Acceso norte del estadio, zona de estacionamiento",
                type: .entrance,
                coordinates: SIMD3<Float>(0, 0, 20),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Estacionamiento", "Señalización"],
                    hasElevator: true,
                    hasRamp: true,
                    hasAccessibleRestroom: true
                )
            ),
            POI(
                id: "entrance_sur",
                name: "Entrada Sur",
                description: "Acceso sur, cercano a estación de transporte",
                type: .entrance,
                coordinates: SIMD3<Float>(0, 0, -20),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Estación", "Paradas de autobús"],
                    hasElevator: false,
                    hasRamp: true,
                    hasAccessibleRestroom: true
                )
            ),
            POI(
                id: "entrance_este",
                name: "Entrada Este",
                description: "Acceso este, puerta lateral",
                type: .entrance,
                coordinates: SIMD3<Float>(20, 0, 0),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Puerta 5", "Señalización"],
                    hasElevator: false,
                    hasRamp: true,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "entrance_oeste",
                name: "Entrada Oeste",
                description: "Acceso oeste, zona VIP",
                type: .entrance,
                coordinates: SIMD3<Float>(-20, 0, 0),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Área VIP", "Restaurantes"],
                    hasElevator: true,
                    hasRamp: true,
                    hasAccessibleRestroom: true
                )
            ),
            
            // === SALIDAS (Mixtas) ===
            POI(
                id: "exit_norte",
                name: "Salida Norte",
                description: "Salida principal hacia el norte",
                type: .exit,
                coordinates: SIMD3<Float>(0, 0, 22),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Señalización de salida"],
                    hasElevator: false,
                    hasRamp: true,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "exit_sur",
                name: "Salida Sur",
                description: "Salida hacia estación de transporte",
                type: .exit,
                coordinates: SIMD3<Float>(0, 0, -22),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Estación de transporte"],
                    hasElevator: false,
                    hasRamp: true,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "exit_emergencia",
                name: "Salida de Emergencia",
                description: "Salida de emergencia, escaleras",
                type: .exit,
                coordinates: SIMD3<Float>(-18, 0, 12),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Escaleras", "Señalización"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            
            // === SECCIONES ACCESIBLES ===
            POI(
                id: "section_104",
                name: "Sección 104",
                description: "Puerta 3, Sección 104 - Zona Accesible, nivel principal",
                type: .section,
                coordinates: SIMD3<Float>(15, 2, -5),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Puerta 3", "Señalización accesible"],
                    hasElevator: true,
                    hasRamp: true,
                    hasAccessibleRestroom: true
                )
            ),
            POI(
                id: "section_105",
                name: "Sección 105",
                description: "Sección 105 - Zona Accesible, vista preferencial",
                type: .section,
                coordinates: SIMD3<Float>(15, 2, 5),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Vista al campo", "Pantallas"],
                    hasElevator: true,
                    hasRamp: true,
                    hasAccessibleRestroom: true
                )
            ),
            POI(
                id: "section_106",
                name: "Sección 106",
                description: "Sección 106 - Zona Accesible, nivel medio",
                type: .section,
                coordinates: SIMD3<Float>(-15, 6, -5),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Puerta 7", "Elevadores"],
                    hasElevator: true,
                    hasRamp: true,
                    hasAccessibleRestroom: true
                )
            ),
            
            // === SECCIONES ESTÁNDAR (No accesibles) ===
            POI(
                id: "section_201",
                name: "Sección 201",
                description: "Sección 201 - Zona General, nivel superior",
                type: .section,
                coordinates: SIMD3<Float>(-15, 10, 8),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Escaleras", "Vista panorámica"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: true
                )
            ),
            POI(
                id: "section_202",
                name: "Sección 202",
                description: "Sección 202 - Zona General, nivel medio",
                type: .section,
                coordinates: SIMD3<Float>(15, 8, 8),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Escaleras", "Vista al campo"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: true
                )
            ),
            POI(
                id: "section_203",
                name: "Sección 203",
                description: "Sección 203 - Zona General, esquina",
                type: .section,
                coordinates: SIMD3<Float>(18, 6, -8),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Vista angular"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: true
                )
            ),
            POI(
                id: "section_204",
                name: "Sección 204",
                description: "Sección 204 - Zona General, nivel superior",
                type: .section,
                coordinates: SIMD3<Float>(-18, 12, -8),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Vista elevada"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: true
                )
            ),
            
            // === ELEVADORES (Solo accesibles) ===
            POI(
                id: "elevator_main",
                name: "Elevador Principal",
                description: "Elevador principal, acceso a todos los niveles",
                type: .elevator,
                coordinates: SIMD3<Float>(10, 0, 10),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Botones grandes", "Señalización"],
                    hasElevator: true,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "elevator_norte",
                name: "Elevador Norte",
                description: "Elevador zona norte, acceso a nivel superior",
                type: .elevator,
                coordinates: SIMD3<Float>(-12, 0, 15),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Señalización accesible"],
                    hasElevator: true,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "elevator_sur",
                name: "Elevador Sur",
                description: "Elevador zona sur, cerca de secciones accesibles",
                type: .elevator,
                coordinates: SIMD3<Float>(12, 0, -12),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Señalización"],
                    hasElevator: true,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            
            // === RAMPAS ===
            POI(
                id: "ramp_principal",
                name: "Rampa Principal",
                description: "Rampa de acceso principal, pendiente suave",
                type: .ramp,
                coordinates: SIMD3<Float>(15, 0, 0),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Señalización", "Barandas"],
                    hasElevator: false,
                    hasRamp: true,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "ramp_norte",
                name: "Rampa Norte",
                description: "Rampa de acceso zona norte",
                type: .ramp,
                coordinates: SIMD3<Float>(-15, 0, 12),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Señalización"],
                    hasElevator: false,
                    hasRamp: true,
                    hasAccessibleRestroom: false
                )
            ),
            
            // === BAÑOS ACCESIBLES ===
            POI(
                id: "restroom_accessible_1",
                name: "Baño Accesible 1",
                description: "Baño accesible cerca de Sección 104, nivel principal",
                type: .restroom,
                coordinates: SIMD3<Float>(12, 0, -5),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Señalización internacional"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: true
                )
            ),
            POI(
                id: "restroom_accessible_2",
                name: "Baño Accesible 2",
                description: "Baño accesible zona norte, cerca de elevadores",
                type: .restroom,
                coordinates: SIMD3<Float>(-12, 0, 12),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Señalización"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: true
                )
            ),
            
            // === PUNTOS DE REFERENCIA ===
            POI(
                id: "landmark_centro",
                name: "Centro del Campo",
                description: "Punto central del campo de juego, referencia visual",
                type: .landmark,
                coordinates: SIMD3<Float>(0, 0, 0),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Campo", "Pantallas gigantes", "Círculo central"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "landmark_pantalla",
                name: "Pantalla Principal",
                description: "Pantalla principal del estadio, punto de referencia",
                type: .landmark,
                coordinates: SIMD3<Float>(0, 15, 0),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: ["Pantalla gigante", "Visible desde todas las secciones"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            )
        ]
    }
    
    func getPOIs(ofType type: POI.POIType) -> [POI] {
        pois.filter { $0.type == type }
    }
    
    func getAccessiblePOIs() -> [POI] {
        pois.filter { $0.accessibility.wheelchairAccessible }
    }
    
    func calculateRoute(from start: POI, to end: POI, accessible: Bool) -> Route {
        // Calcular ruta simple (TODO: Implementar Dijkstra)
        let distance = calculateDistance(from: start.coordinates, to: end.coordinates)
        
        // Si es accesible, solo usar POIs accesibles
        var routePoints: [RoutePoint] = []
        if accessible {
            routePoints = calculateAccessiblePath(from: start, to: end)
        } else {
            routePoints = calculateStandardPath(from: start, to: end)
        }
        
        let estimatedTime = estimateTime(distance: distance, accessible: accessible)
        let instructions = generateInstructions(from: start, to: end, points: routePoints)
        
        return Route(
            id: UUID().uuidString,
            start: start,
            end: end,
            points: routePoints,
            isAccessible: accessible,
            estimatedTime: estimatedTime,
            distance: distance,
            instructions: instructions
        )
    }
    
    private func calculateDistance(from start: SIMD3<Float>, to end: SIMD3<Float>) -> Float {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let dz = end.z - start.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
    
    private func calculateAccessiblePath(from start: POI, to end: POI) -> [RoutePoint] {
        // Ruta accesible que pasa por múltiples POIs accesibles
        var points: [RoutePoint] = []
        
        // Agregar punto de inicio
        points.append(RoutePoint(id: start.id, poi: start, position: start.coordinates))
        
        // Buscar POIs accesibles intermedios (elevadores, rampas, entradas)
        let intermediatePOIs = pois.filter { poi in
            poi.id != start.id && poi.id != end.id &&
            poi.accessibility.wheelchairAccessible &&
            (poi.type == .elevator || poi.type == .ramp || poi.type == .entrance || poi.type == .section)
        }
        
        // Ordenar por distancia desde el inicio
        let sortedPOIs = intermediatePOIs.sorted { poi1, poi2 in
            let dist1 = calculateDistance(from: start.coordinates, to: poi1.coordinates)
            let dist2 = calculateDistance(from: start.coordinates, to: poi2.coordinates)
            return dist1 < dist2
        }
        
        // Agregar hasta 8-10 puntos intermedios para crear una ruta visible
        var currentPosition = start.coordinates
        var addedCount = 0
        let maxIntermediatePoints = 8
        
        for intermediatePOI in sortedPOIs {
            // Verificar que este POI esté en la dirección general hacia el destino
            let distToIntermediate = calculateDistance(from: currentPosition, to: intermediatePOI.coordinates)
            let distToEnd = calculateDistance(from: currentPosition, to: end.coordinates)
            let distFromIntermediateToEnd = calculateDistance(from: intermediatePOI.coordinates, to: end.coordinates)
            
            // Solo agregar si está en la dirección correcta (no alejarse mucho del destino)
            if distFromIntermediateToEnd < distToEnd * 1.5 && addedCount < maxIntermediatePoints {
                points.append(RoutePoint(id: intermediatePOI.id, poi: intermediatePOI, position: intermediatePOI.coordinates))
                currentPosition = intermediatePOI.coordinates
                addedCount += 1
            }
        }
        
        // Si no hay suficientes puntos, agregar puntos interpolados entre inicio y fin
        while points.count < 10 {
            let lastPoint = points.last!
            let remainingDistance = calculateDistance(from: lastPoint.position, to: end.coordinates)
            
            if remainingDistance < 5.0 { // Si estamos muy cerca, terminar
                break
            }
            
            // Crear punto intermedio interpolado
            let progress = Float(points.count) / 10.0
            let interpolatedPos = SIMD3<Float>(
                lastPoint.position.x + (end.coordinates.x - lastPoint.position.x) * progress * 0.5,
                lastPoint.position.y + (end.coordinates.y - lastPoint.position.y) * progress * 0.5,
                lastPoint.position.z + (end.coordinates.z - lastPoint.position.z) * progress * 0.5
            )
            
            let interpolatedPOI = POI(
                id: "intermediate_\(points.count)",
                name: "Punto intermedio \(points.count)",
                description: "Punto intermedio de la ruta",
                type: .landmark,
                coordinates: interpolatedPos,
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: true,
                    mobilityAidAccessible: true,
                    visualLandmarks: [],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            )
            
            points.append(RoutePoint(id: interpolatedPOI.id, poi: interpolatedPOI, position: interpolatedPos))
        }
        
        // Agregar punto de destino
        points.append(RoutePoint(id: end.id, poi: end, position: end.coordinates))
        
        return points
    }
    
    private func calculateStandardPath(from start: POI, to end: POI) -> [RoutePoint] {
        // Ruta estándar con múltiples puntos intermedios
        var points: [RoutePoint] = []
        
        // Agregar punto de inicio
        points.append(RoutePoint(id: start.id, poi: start, position: start.coordinates))
        
        // Buscar POIs intermedios (cualquier tipo, excepto elevadores/rampas que son específicos de accesibles)
        let intermediatePOIs = pois.filter { poi in
            poi.id != start.id && poi.id != end.id &&
            (poi.type == .section || poi.type == .entrance || poi.type == .exit || poi.type == .landmark)
        }
        
        // Ordenar por distancia desde el inicio
        let sortedPOIs = intermediatePOIs.sorted { poi1, poi2 in
            let dist1 = calculateDistance(from: start.coordinates, to: poi1.coordinates)
            let dist2 = calculateDistance(from: start.coordinates, to: poi2.coordinates)
            return dist1 < dist2
        }
        
        // Agregar hasta 8-10 puntos intermedios
        var currentPosition = start.coordinates
        var addedCount = 0
        let maxIntermediatePoints = 8
        
        for intermediatePOI in sortedPOIs {
            let distToIntermediate = calculateDistance(from: currentPosition, to: intermediatePOI.coordinates)
            let distToEnd = calculateDistance(from: currentPosition, to: end.coordinates)
            let distFromIntermediateToEnd = calculateDistance(from: intermediatePOI.coordinates, to: end.coordinates)
            
            if distFromIntermediateToEnd < distToEnd * 1.5 && addedCount < maxIntermediatePoints {
                points.append(RoutePoint(id: intermediatePOI.id, poi: intermediatePOI, position: intermediatePOI.coordinates))
                currentPosition = intermediatePOI.coordinates
                addedCount += 1
            }
        }
        
        // Si no hay suficientes puntos, agregar puntos interpolados
        while points.count < 10 {
            let lastPoint = points.last!
            let remainingDistance = calculateDistance(from: lastPoint.position, to: end.coordinates)
            
            if remainingDistance < 5.0 {
                break
            }
            
            let progress = Float(points.count) / 10.0
            let interpolatedPos = SIMD3<Float>(
                lastPoint.position.x + (end.coordinates.x - lastPoint.position.x) * progress * 0.5,
                lastPoint.position.y + (end.coordinates.y - lastPoint.position.y) * progress * 0.5,
                lastPoint.position.z + (end.coordinates.z - lastPoint.position.z) * progress * 0.5
            )
            
            let interpolatedPOI = POI(
                id: "intermediate_standard_\(points.count)",
                name: "Punto intermedio \(points.count)",
                description: "Punto intermedio de la ruta",
                type: .landmark,
                coordinates: interpolatedPos,
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: [],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            )
            
            points.append(RoutePoint(id: interpolatedPOI.id, poi: interpolatedPOI, position: interpolatedPos))
        }
        
        // Agregar punto de destino
        points.append(RoutePoint(id: end.id, poi: end, position: end.coordinates))
        
        return points
    }
    
    private func estimateTime(distance: Float, accessible: Bool) -> TimeInterval {
        // Velocidad promedio: 1.2 m/s (accesible) o 1.5 m/s (estándar)
        let speed: Float = accessible ? 1.2 : 1.5
        return TimeInterval(distance / speed)
    }
    
    private func generateInstructions(from start: POI, to end: POI, points: [RoutePoint]) -> [String] {
        var instructions: [String] = []
        
        instructions.append("Inicia en \(start.name)")
        
        for (index, point) in points.enumerated() {
            if index > 0 && index < points.count - 1 {
                instructions.append("Pasa por \(point.poi.name)")
            }
        }
        
        instructions.append("Llega a \(end.name)")
        
        return instructions
    }
}

