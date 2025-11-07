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
            // NOTA: Se elimina el POI del centro del campo para evitar rutas hacia el campo
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
            ),
            
            // === PUNTOS ESTÁNDAR ADICIONALES (Para rutas no accesibles) ===
            // Estos puntos pueden compartirse con rutas accesibles
            POI(
                id: "checkpoint_1",
                name: "Checkpoint 1",
                description: "Punto de control exterior, zona norte",
                type: .landmark,
                coordinates: SIMD3<Float>(18, 0, 15),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Señalización", "Punto de referencia"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "checkpoint_2",
                name: "Checkpoint 2",
                description: "Punto de control exterior, zona sur",
                type: .landmark,
                coordinates: SIMD3<Float>(18, 0, -15),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Señalización", "Punto de referencia"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "checkpoint_3",
                name: "Checkpoint 3",
                description: "Punto de control exterior, zona este",
                type: .landmark,
                coordinates: SIMD3<Float>(22, 0, 0),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Señalización", "Punto de referencia"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "checkpoint_4",
                name: "Checkpoint 4",
                description: "Punto de control exterior, zona oeste",
                type: .landmark,
                coordinates: SIMD3<Float>(-22, 0, 0),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Señalización", "Punto de referencia"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "pathway_1",
                name: "Sendero Principal",
                description: "Sendero principal que rodea el estadio",
                type: .landmark,
                coordinates: SIMD3<Float>(0, 0, 18),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Sendero", "Señalización"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "pathway_2",
                name: "Sendero Secundario",
                description: "Sendero secundario, zona este",
                type: .landmark,
                coordinates: SIMD3<Float>(18, 0, 8),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Sendero", "Señalización"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "pathway_3",
                name: "Sendero Oeste",
                description: "Sendero oeste del estadio",
                type: .landmark,
                coordinates: SIMD3<Float>(-18, 0, 8),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Sendero", "Señalización"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "pathway_4",
                name: "Sendero Sur",
                description: "Sendero sur del estadio",
                type: .landmark,
                coordinates: SIMD3<Float>(8, 0, -18),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Sendero", "Señalización"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "pathway_5",
                name: "Sendero Norte",
                description: "Sendero norte del estadio",
                type: .landmark,
                coordinates: SIMD3<Float>(8, 0, 18),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Sendero", "Señalización"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "crossing_1",
                name: "Cruce Principal",
                description: "Cruce principal de caminos",
                type: .landmark,
                coordinates: SIMD3<Float>(15, 0, 12),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Cruce", "Señalización"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "crossing_2",
                name: "Cruce Secundario",
                description: "Cruce secundario de caminos",
                type: .landmark,
                coordinates: SIMD3<Float>(-15, 0, 12),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Cruce", "Señalización"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "crossing_3",
                name: "Cruce Este",
                description: "Cruce este del estadio",
                type: .landmark,
                coordinates: SIMD3<Float>(15, 0, -12),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Cruce", "Señalización"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "crossing_4",
                name: "Cruce Oeste",
                description: "Cruce oeste del estadio",
                type: .landmark,
                coordinates: SIMD3<Float>(-15, 0, -12),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Cruce", "Señalización"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            ),
            POI(
                id: "section_205",
                name: "Sección 205",
                description: "Sección 205 - Zona General, nivel medio",
                type: .section,
                coordinates: SIMD3<Float>(18, 7, 5),
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
                id: "section_206",
                name: "Sección 206",
                description: "Sección 206 - Zona General, nivel superior",
                type: .section,
                coordinates: SIMD3<Float>(18, 9, -5),
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
                id: "section_207",
                name: "Sección 207",
                description: "Sección 207 - Zona General, esquina",
                type: .section,
                coordinates: SIMD3<Float>(-18, 8, 5),
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: false,
                    mobilityAidAccessible: false,
                    visualLandmarks: ["Vista angular"],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: true
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

    // Zona prohibida: campo de juego (evitar rutas por el centro)
    // Asumimos un rectángulo aproximado de radio 10x6 alrededor del origen a nivel del suelo
    private func isForbiddenField(_ pos: SIMD3<Float>) -> Bool {
        let rX: Float = 10 // radio aproximado eje X
        let rZ: Float = 6  // radio aproximado eje Z
        // En el suelo o cercano al suelo
        let nearGround = abs(pos.y) <= 1.0
        return nearGround && abs(pos.x) <= rX && abs(pos.z) <= rZ
    }

    // Proyecta un punto fuera del campo si cae dentro de la zona prohibida
    private func projectOutsideField(_ pos: SIMD3<Float>) -> SIMD3<Float> {
        if !isForbiddenField(pos) { return pos }
        var x = pos.x
        var z = pos.z
        let rX: Float = 10
        let rZ: Float = 6
        // Empujar al borde más cercano manteniendo dirección
        let scaleX = (x >= 0) ? rX : -rX
        let scaleZ = (z >= 0) ? rZ : -rZ
        if abs(x/rX) > abs(z/rZ) {
            x = scaleX
        } else {
            z = scaleZ
        }
        return SIMD3<Float>(x, 0, z)
    }
    
    private func calculateAccessiblePath(from start: POI, to end: POI) -> [RoutePoint] {
        // Ruta accesible optimizada - algoritmo tipo A* simplificado
        let startGroundPos = SIMD3<Float>(start.coordinates.x, 0, start.coordinates.z)
        let endGroundPos = SIMD3<Float>(end.coordinates.x, 0, end.coordinates.z)
        
        // Calcular distancia directa
        let directDistance = calculateDistance(from: startGroundPos, to: endGroundPos)
        
        // Si la distancia es corta (< 25 unidades), usar ruta directa con pocos puntos
        if directDistance < 25 {
            return createDirectRoute(from: start, to: end, startPos: startGroundPos, endPos: endGroundPos, accessible: true)
        }
        
        // Para distancias mayores, buscar POIs accesibles que realmente acorten la ruta
        let accessiblePOIs = pois.filter { poi in
            poi.id != start.id && poi.id != end.id &&
            poi.accessibility.wheelchairAccessible &&
            (poi.type == .elevator || poi.type == .ramp || poi.type == .entrance || poi.type == .section) &&
            !isForbiddenField(SIMD3<Float>(poi.coordinates.x, 0, poi.coordinates.z))
        }
        
        // Encontrar el POI intermedio que más acorte la ruta (si existe)
        var bestIntermediate: POI?
        var bestSavings: Float = 0
        
        for intermediatePOI in accessiblePOIs {
            let intermediatePos = SIMD3<Float>(intermediatePOI.coordinates.x, 0, intermediatePOI.coordinates.z)
            let distToIntermediate = calculateDistance(from: startGroundPos, to: intermediatePos)
            let distFromIntermediateToEnd = calculateDistance(from: intermediatePos, to: endGroundPos)
            let totalViaIntermediate = distToIntermediate + distFromIntermediateToEnd
            
            // Solo considerar si acorta la ruta en al menos 10%
            let savings = directDistance - totalViaIntermediate
            if savings > bestSavings && savings > directDistance * 0.1 {
                bestSavings = savings
                bestIntermediate = intermediatePOI
            }
        }
        
        // Construir ruta con o sin intermedio
        var points: [RoutePoint] = []
        points.append(RoutePoint(id: start.id, poi: start, position: projectOutsideField(startGroundPos)))
        
        if let intermediate = bestIntermediate {
            let intermediatePos = projectOutsideField(SIMD3<Float>(intermediate.coordinates.x, 0, intermediate.coordinates.z))
            points.append(RoutePoint(id: intermediate.id, poi: intermediate, position: intermediatePos))
            
            // Agregar puntos interpolados solo si la distancia es significativa
            let distToIntermediate = calculateDistance(from: startGroundPos, to: intermediatePos)
            let distFromIntermediate = calculateDistance(from: intermediatePos, to: endGroundPos)
            
            // Solo agregar interpolados si el segmento es largo (> 15 unidades)
            if distToIntermediate > 15 {
                addInterpolatedPoints(from: startGroundPos, to: intermediatePos, to: &points, accessible: true, maxPoints: 3)
            }
            if distFromIntermediate > 15 {
                addInterpolatedPoints(from: intermediatePos, to: endGroundPos, to: &points, accessible: true, maxPoints: 3)
            }
        } else {
            // Ruta directa con interpolados mínimos
            addInterpolatedPoints(from: startGroundPos, to: endGroundPos, to: &points, accessible: true, maxPoints: 5)
        }
        
        points.append(RoutePoint(id: end.id, poi: end, position: projectOutsideField(endGroundPos)))
        
        return points
    }
    
    // Helper para crear ruta directa simple
    private func createDirectRoute(from start: POI, to end: POI, startPos: SIMD3<Float>, endPos: SIMD3<Float>, accessible: Bool) -> [RoutePoint] {
        var points: [RoutePoint] = []
        points.append(RoutePoint(id: start.id, poi: start, position: startPos))
        
        let distance = calculateDistance(from: startPos, to: endPos)
        // Solo agregar 1-2 puntos intermedios para distancias cortas
        if distance > 10 {
            let midPoint = SIMD3<Float>(
                (startPos.x + endPos.x) / 2,
                0,
                (startPos.z + endPos.z) / 2
            )
            
            let midPOI = POI(
                id: "mid_\(start.id)_\(end.id)",
                name: "Punto medio",
                description: "Punto intermedio de la ruta",
                type: .landmark,
                coordinates: midPoint,
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: accessible,
                    mobilityAidAccessible: accessible,
                    visualLandmarks: [],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            )
            points.append(RoutePoint(id: midPOI.id, poi: midPOI, position: midPoint))
        }
        
        points.append(RoutePoint(id: end.id, poi: end, position: endPos))
        return points
    }
    
    // Helper para agregar puntos interpolados de forma eficiente
    private func addInterpolatedPoints(from start: SIMD3<Float>, to end: SIMD3<Float>, to points: inout [RoutePoint], accessible: Bool, maxPoints: Int) {
        let distance = calculateDistance(from: start, to: end)
        let numPoints = min(maxPoints, max(1, Int(distance / 12))) // Un punto cada 12 unidades
        
        for i in 1..<numPoints {
            let progress = Float(i) / Float(numPoints)
            let x = start.x + (end.x - start.x) * progress
            let z = start.z + (end.z - start.z) * progress
            let interpolatedPos = SIMD3<Float>(x, 0, z)
            
            // Verificar que no esté muy cerca del último punto
            if let lastPoint = points.last {
                let dist = calculateDistance(from: lastPoint.position, to: interpolatedPos)
                if dist < 5.0 { continue }
            }
            
            let interpolatedPOI = POI(
                id: "intermediate_\(points.count)",
                name: "Punto \(points.count)",
                description: "Punto intermedio de la ruta",
                type: .landmark,
                coordinates: interpolatedPos,
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: accessible,
                    mobilityAidAccessible: accessible,
                    visualLandmarks: [],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            )
            points.append(RoutePoint(id: interpolatedPOI.id, poi: interpolatedPOI, position: interpolatedPos))
        }
    }
    
    private func calculateStandardPath(from start: POI, to end: POI) -> [RoutePoint] {
        // Ruta estándar optimizada - más directa y eficiente
        let startGroundPos = SIMD3<Float>(start.coordinates.x, 0, start.coordinates.z)
        let endGroundPos = SIMD3<Float>(end.coordinates.x, 0, end.coordinates.z)
        
        // Calcular distancia directa
        let directDistance = calculateDistance(from: startGroundPos, to: endGroundPos)
        
        // Si la distancia es corta (< 25 unidades), usar ruta directa
        if directDistance < 25 {
            return createDirectRoute(from: start, to: end, startPos: startGroundPos, endPos: endGroundPos, accessible: false)
        }
        
        // Para distancias mayores, buscar POIs que realmente acorten la ruta
        let intermediatePOIs = pois.filter { poi in
            poi.id != start.id && poi.id != end.id &&
            (poi.type == .section || poi.type == .entrance || poi.type == .exit || poi.type == .landmark)
        }
        
        // Encontrar el POI intermedio que más acorte la ruta (si existe)
        var bestIntermediate: POI?
        var bestSavings: Float = 0
        
        for intermediatePOI in intermediatePOIs {
            let intermediatePos = SIMD3<Float>(intermediatePOI.coordinates.x, 0, intermediatePOI.coordinates.z)
            let distToIntermediate = calculateDistance(from: startGroundPos, to: intermediatePos)
            let distFromIntermediateToEnd = calculateDistance(from: intermediatePos, to: endGroundPos)
            let totalViaIntermediate = distToIntermediate + distFromIntermediateToEnd
            
            // Solo considerar si acorta la ruta en al menos 15% (más estricto para estándar)
            let savings = directDistance - totalViaIntermediate
            if savings > bestSavings && savings > directDistance * 0.15 {
                bestSavings = savings
                bestIntermediate = intermediatePOI
            }
        }
        
        // Construir ruta con o sin intermedio
        var points: [RoutePoint] = []
        points.append(RoutePoint(id: start.id, poi: start, position: projectOutsideField(startGroundPos)))
        
        if let intermediate = bestIntermediate {
            let intermediatePos = projectOutsideField(SIMD3<Float>(intermediate.coordinates.x, 0, intermediate.coordinates.z))
            points.append(RoutePoint(id: intermediate.id, poi: intermediate, position: intermediatePos))
            
            // Agregar puntos interpolados solo si la distancia es significativa
            let distToIntermediate = calculateDistance(from: startGroundPos, to: intermediatePos)
            let distFromIntermediate = calculateDistance(from: intermediatePos, to: endGroundPos)
            
            // Solo agregar interpolados si el segmento es largo (> 15 unidades)
            if distToIntermediate > 15 {
                addInterpolatedPoints(from: startGroundPos, to: intermediatePos, to: &points, accessible: false, maxPoints: 2)
            }
            if distFromIntermediate > 15 {
                addInterpolatedPoints(from: intermediatePos, to: endGroundPos, to: &points, accessible: false, maxPoints: 2)
            }
        } else {
            // Ruta directa con interpolados mínimos
            addInterpolatedPoints(from: startGroundPos, to: endGroundPos, to: &points, accessible: false, maxPoints: 4)
        }
        
        points.append(RoutePoint(id: end.id, poi: end, position: projectOutsideField(endGroundPos)))
        
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

