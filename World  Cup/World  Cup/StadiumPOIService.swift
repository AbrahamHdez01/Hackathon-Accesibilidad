import Foundation
import SwiftUI

// MARK: - Stadium POI Service
class StadiumPOIService: ObservableObject {
    @Published var pois: [POI] = []
    @Published var selectedStartPOI: POI?
    @Published var selectedEndPOI: POI?
    
    // Radios de control (en unidades del modelo)
    // Aumentamos la zona prohibida para evitar cualquier cruce por el interior del estadio
    private let stadiumForbiddenRadius: Float = 12.0   // Ninguna ruta/nodo debe entrar aquí
    private let accessibleRingRadius: Float = 24.0     // Anillo exterior (rutas accesibles)
    private let standardRingRadius: Float = 16.0       // Anillo interior (rutas estándar)
    private let minPointSpacing: Float = 6.0           // Separación mínima entre puntos de ruta interpolados
    
    init() {
        loadDefaultPOIs()
    }
    
    private func loadDefaultPOIs() {
        // POIs reorganizados para DIFERENCIAR claramente rutas accesibles vs estándar
        // TODOS los POIs están FUERA del estadio (y = 0)
        // Los POIs accesibles forman un ANILLO EXTERIOR (más alejados del centro)
        // Los POIs estándar forman un ANILLO INTERIOR (más cercanos al centro, con escaleras)
        
    pois = [
        // ==========================================
        // ANILLO EXTERIOR: POIs ACCESIBLES (y = 0)
        // Rampas, Elevadores, Entradas con acceso
        // Ubicados más lejos del centro (~20-25 unidades)
        // ==========================================
        
        // === ENTRADAS ACCESIBLES (Anillo Exterior) ===
        POI(
            id: "entrance_norte_accesible",
            name: "Entrada Norte Accesible",
            description: "Entrada norte con rampa y elevador",
            type: .entrance,
            coordinates: SIMD3<Float>(0, 0, 25),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Rampa ancha", "Elevador", "Señalización grande"],
                hasElevator: true,
                hasRamp: true,
                hasAccessibleRestroom: true
            )
        ),
        POI(
            id: "entrance_sur_accesible",
            name: "Entrada Sur Accesible",
            description: "Entrada sur con rampa",
            type: .entrance,
            coordinates: SIMD3<Float>(0, 0, -25),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Rampa", "Estación de transporte"],
                hasElevator: false,
                hasRamp: true,
                hasAccessibleRestroom: true
            )
        ),
        POI(
            id: "entrance_este_accesible",
            name: "Entrada Este Accesible",
            description: "Entrada este con elevador",
            type: .entrance,
            coordinates: SIMD3<Float>(25, 0, 0),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Elevador", "Zona VIP accesible"],
                hasElevator: true,
                hasRamp: true,
                hasAccessibleRestroom: true
            )
        ),
        POI(
            id: "entrance_oeste_accesible",
            name: "Entrada Oeste Accesible",
            description: "Entrada oeste con rampa",
            type: .entrance,
            coordinates: SIMD3<Float>(-25, 0, 0),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Rampa amplia", "Estacionamiento accesible"],
                hasElevator: false,
                hasRamp: true,
                hasAccessibleRestroom: true
            )
        ),
        
        // === ELEVADORES (Anillo Exterior) ===
        POI(
            id: "elevator_noreste",
            name: "Elevador Noreste",
            description: "Elevador zona noreste",
            type: .elevator,
            coordinates: SIMD3<Float>(18, 0, 18),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Botones grandes", "Audio"],
                hasElevator: true,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "elevator_noroeste",
            name: "Elevador Noroeste",
            description: "Elevador zona noroeste",
            type: .elevator,
            coordinates: SIMD3<Float>(-18, 0, 18),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Botones grandes", "Audio"],
                hasElevator: true,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "elevator_sureste",
            name: "Elevador Sureste",
            description: "Elevador zona sureste",
            type: .elevator,
            coordinates: SIMD3<Float>(18, 0, -18),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Botones grandes", "Audio"],
                hasElevator: true,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "elevator_suroeste",
            name: "Elevador Suroeste",
            description: "Elevador zona suroeste",
            type: .elevator,
            coordinates: SIMD3<Float>(-18, 0, -18),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Botones grandes", "Audio"],
                hasElevator: true,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        
        // === RAMPAS (Anillo Exterior) ===
        POI(
            id: "ramp_norte",
            name: "Rampa Norte",
            description: "Rampa de acceso norte, pendiente suave",
            type: .ramp,
            coordinates: SIMD3<Float>(-8, 0, 22),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Barandas", "Superficie antideslizante"],
                hasElevator: false,
                hasRamp: true,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "ramp_sur",
            name: "Rampa Sur",
            description: "Rampa de acceso sur, pendiente suave",
            type: .ramp,
            coordinates: SIMD3<Float>(8, 0, -22),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Barandas", "Superficie antideslizante"],
                hasElevator: false,
                hasRamp: true,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "ramp_este",
            name: "Rampa Este",
            description: "Rampa de acceso este, pendiente suave",
            type: .ramp,
            coordinates: SIMD3<Float>(22, 0, 8),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Barandas", "Superficie antideslizante"],
                hasElevator: false,
                hasRamp: true,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "ramp_oeste",
            name: "Rampa Oeste",
            description: "Rampa de acceso oeste, pendiente suave",
            type: .ramp,
            coordinates: SIMD3<Float>(-22, 0, -8),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Barandas", "Superficie antideslizante"],
                hasElevator: false,
                hasRamp: true,
                hasAccessibleRestroom: false
            )
        ),
        
        // === BAÑOS ACCESIBLES (Anillo Exterior) ===
        POI(
            id: "restroom_norte_accesible",
            name: "Baño Accesible Norte",
            description: "Baño accesible zona norte",
            type: .restroom,
            coordinates: SIMD3<Float>(8, 0, 22),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Señalización internacional", "Barras de apoyo"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: true
            )
        ),
        POI(
            id: "restroom_sur_accesible",
            name: "Baño Accesible Sur",
            description: "Baño accesible zona sur",
            type: .restroom,
            coordinates: SIMD3<Float>(-8, 0, -22),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Señalización internacional", "Barras de apoyo"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: true
            )
        ),
        
        // === SALIDAS ACCESIBLES (Anillo Exterior) ===
        POI(
            id: "exit_norte_accesible",
            name: "Salida Norte Accesible",
            description: "Salida norte con rampa",
            type: .exit,
            coordinates: SIMD3<Float>(10, 0, 25),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Señalización de salida", "Iluminación"],
                hasElevator: false,
                hasRamp: true,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "exit_sur_accesible",
            name: "Salida Sur Accesible",
            description: "Salida sur con rampa",
            type: .exit,
            coordinates: SIMD3<Float>(-10, 0, -25),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: true,
                mobilityAidAccessible: true,
                visualLandmarks: ["Señalización de salida", "Iluminación"],
                hasElevator: false,
                hasRamp: true,
                hasAccessibleRestroom: false
            )
        ),
        
        // ==========================================
        // ANILLO INTERIOR: POIs ESTÁNDAR (y = 0)
        // Con escaleras, más directos pero NO accesibles
        // Ubicados más cerca del centro (~12-17 unidades)
        // ==========================================
        
        // === ENTRADAS ESTÁNDAR (Anillo Interior - con escaleras) ===
        POI(
            id: "entrance_norte_standard",
            name: "Entrada Norte Principal",
            description: "Entrada norte con escaleras (más directa)",
            type: .entrance,
            coordinates: SIMD3<Float>(0, 0, 17),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras amplias", "Taquillas"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "entrance_sur_standard",
            name: "Entrada Sur Principal",
            description: "Entrada sur con escaleras (más directa)",
            type: .entrance,
            coordinates: SIMD3<Float>(0, 0, -17),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras", "Zona de boletos"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "entrance_este_standard",
            name: "Entrada Este Principal",
            description: "Entrada este con escaleras",
            type: .entrance,
            coordinates: SIMD3<Float>(17, 0, 0),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras", "Puerta 5"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "entrance_oeste_standard",
            name: "Entrada Oeste Principal",
            description: "Entrada oeste con escaleras",
            type: .entrance,
            coordinates: SIMD3<Float>(-17, 0, 0),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras", "Zona VIP"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        
        // === PUNTOS DE PASO ESTÁNDAR (Anillo Interior) ===
        POI(
            id: "checkpoint_noreste",
            name: "Checkpoint Noreste",
            description: "Punto de control noreste (con escaleras)",
            type: .landmark,
            coordinates: SIMD3<Float>(12, 0, 12),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras", "Señalización"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "checkpoint_noroeste",
            name: "Checkpoint Noroeste",
            description: "Punto de control noroeste (con escaleras)",
            type: .landmark,
            coordinates: SIMD3<Float>(-12, 0, 12),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras", "Señalización"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "checkpoint_sureste",
            name: "Checkpoint Sureste",
            description: "Punto de control sureste (con escaleras)",
            type: .landmark,
            coordinates: SIMD3<Float>(12, 0, -12),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras", "Señalización"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "checkpoint_suroeste",
            name: "Checkpoint Suroeste",
            description: "Punto de control suroeste (con escaleras)",
            type: .landmark,
            coordinates: SIMD3<Float>(-12, 0, -12),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras", "Señalización"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        
        // === SENDEROS DIRECTOS (Anillo Interior) ===
        POI(
            id: "pathway_norte",
            name: "Sendero Norte Directo",
            description: "Sendero norte con escalones",
            type: .landmark,
            coordinates: SIMD3<Float>(5, 0, 15),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escalones", "Sendero directo"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "pathway_sur",
            name: "Sendero Sur Directo",
            description: "Sendero sur con escalones",
            type: .landmark,
            coordinates: SIMD3<Float>(-5, 0, -15),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escalones", "Sendero directo"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "pathway_este",
            name: "Sendero Este Directo",
            description: "Sendero este con escalones",
            type: .landmark,
            coordinates: SIMD3<Float>(15, 0, 5),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escalones", "Sendero directo"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "pathway_oeste",
            name: "Sendero Oeste Directo",
            description: "Sendero oeste con escalones",
            type: .landmark,
            coordinates: SIMD3<Float>(-15, 0, -5),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escalones", "Sendero directo"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        
        // === SALIDAS ESTÁNDAR (Anillo Interior - con escaleras) ===
        POI(
            id: "exit_noreste_standard",
            name: "Salida Noreste Rápida",
            description: "Salida rápida noreste con escaleras",
            type: .exit,
            coordinates: SIMD3<Float>(15, 0, 15),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras", "Salida de emergencia"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "exit_noroeste_standard",
            name: "Salida Noroeste Rápida",
            description: "Salida rápida noroeste con escaleras",
            type: .exit,
            coordinates: SIMD3<Float>(-15, 0, 15),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras", "Salida de emergencia"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "exit_sureste_standard",
            name: "Salida Sureste Rápida",
            description: "Salida rápida sureste con escaleras",
            type: .exit,
            coordinates: SIMD3<Float>(15, 0, -15),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras", "Salida de emergencia"],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        ),
        POI(
            id: "exit_suroeste_standard",
            name: "Salida Suroeste Rápida",
            description: "Salida rápida suroeste con escaleras",
            type: .exit,
            coordinates: SIMD3<Float>(-15, 0, -15),
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: false,
                mobilityAidAccessible: false,
                visualLandmarks: ["Escaleras", "Salida de emergencia"],
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
        // Si es accesible, solo usar POIs accesibles
        var routePoints: [RoutePoint] = []
        if accessible {
            routePoints = calculateAccessiblePath(from: start, to: end)
        } else {
            routePoints = calculateStandardPath(from: start, to: end)
        }
        
        // Calcular distancia total de la ruta real (sumando segmentos)
        let totalDistance = calculateRouteDistance(points: routePoints)
        
        let estimatedTime = estimateTime(distance: totalDistance, accessible: accessible)
        let instructions = generateInstructions(from: start, to: end, points: routePoints, accessible: accessible)
        
        return Route(
            id: UUID().uuidString,
            start: start,
            end: end,
            points: routePoints,
            isAccessible: accessible,
            estimatedTime: estimatedTime,
            distance: totalDistance,
            instructions: instructions
        )
    }
    
    private func calculateRouteDistance(points: [RoutePoint]) -> Float {
        guard points.count >= 2 else { return 0 }
        var totalDistance: Float = 0
        for i in 0..<points.count - 1 {
            totalDistance += calculateDistance(from: points[i].position, to: points[i + 1].position)
        }
        return totalDistance
    }
    
    private func calculateDistance(from start: SIMD3<Float>, to end: SIMD3<Float>) -> Float {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let dz = end.z - start.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }

    // Zona prohibida: campo de juego y dentro del estadio (evitar rutas por el centro y dentro)
    // Usamos un radio circular para simplificar (más estricto que antes)
    // También prohibimos cualquier punto dentro del estadio (y > 0)
    private func isForbiddenField(_ pos: SIMD3<Float>) -> Bool {
        let nearGround = abs(pos.y) <= 1.0
        // Prohibir campo de juego por radio circular
        let distanceFromCenter = sqrt(pos.x*pos.x + pos.z*pos.z)
        let inField = nearGround && distanceFromCenter <= stadiumForbiddenRadius
        // Prohibir dentro del estadio (y > 0)
        let insideStadium = pos.y > 0
        return inField || insideStadium
    }
    
    // Verificar si un POI está dentro del estadio
    private func isInsideStadium(_ poi: POI) -> Bool {
        return poi.coordinates.y > 0
    }

    // Proyecta un punto fuera del campo y fuera del estadio si cae dentro de la zona prohibida
    private func projectOutsideField(_ pos: SIMD3<Float>) -> SIMD3<Float> {
        // SIEMPRE asegurar que y = 0 (nunca dentro del estadio)
        var projectedPos = SIMD3<Float>(pos.x, 0, pos.z)
        
        // Si está dentro del campo de juego, proyectarlo fuera
        if isForbiddenField(projectedPos) {
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
            projectedPos = SIMD3<Float>(x, 0, z)
        }
        
        // GARANTIZAR que y = 0 (nunca dentro del estadio)
        return SIMD3<Float>(projectedPos.x, 0, projectedPos.z)
    }
    
    // MARK: - Perímetro/Anillo
    
    private func angle(of pos: SIMD3<Float>) -> Float {
        atan2(pos.z, pos.x)
    }
    
    private func pointOnCircle(radius: Float, angle: Float) -> SIMD3<Float> {
        SIMD3<Float>(radius * cos(angle), 0, radius * sin(angle))
    }
    
    /// Genera puntos a lo largo de un arco sobre un círculo de radio dado, garantizando separación mínima.
    private func addArcPoints(radius: Float, startAngle: Float, endAngle: Float, to points: inout [RoutePoint], accessible: Bool, maxSegments: Int = 16) {
        // Normalizar dirección del arco (elegir el arco más corto)
        var a0 = startAngle
        var a1 = endAngle
        var delta = a1 - a0
        while delta > Float.pi { a0 += 2 * Float.pi; delta = a1 - a0 }
        while delta < -Float.pi { a0 -= 2 * Float.pi; delta = a1 - a0 }
        
        let segments = max(2, min(maxSegments, Int(abs(delta) / (Float.pi/16)))) // paso ~11.25°
        for i in 1..<segments {
            let t = Float(i) / Float(segments)
            let a = a0 + delta * t
            let p = pointOnCircle(radius: radius, angle: a)
            let projected = projectOutsideField(p)
            
            // Respetar separación mínima entre puntos
            if let last = points.last {
                let d = calculateDistance(from: last.position, to: projected)
                if d < minPointSpacing { continue }
            }
            
            let arcPOI = POI(
                id: "arc_\(radius)_\(i)",
                name: "Perímetro",
                description: "Punto del perímetro",
                type: .landmark,
                coordinates: projected,
                accessibility: POI.AccessibilityInfo(
                    wheelchairAccessible: accessible,
                    mobilityAidAccessible: accessible,
                    visualLandmarks: [],
                    hasElevator: false,
                    hasRamp: false,
                    hasAccessibleRestroom: false
                )
            )
            points.append(RoutePoint(id: arcPOI.id, poi: arcPOI, position: projected))
        }
    }
    
    /// Construye una ruta que bordea el estadio por un anillo (accesible o estándar) sin cruzar el interior.
    private func perimeterArcPath(from start: POI, to end: POI, radius: Float, accessible: Bool) -> [RoutePoint] {
        var points: [RoutePoint] = []
        let startGround = SIMD3<Float>(start.coordinates.x, 0, start.coordinates.z)
        let endGround = SIMD3<Float>(end.coordinates.x, 0, end.coordinates.z)
        
        // Posiciones sobre el anillo
        let a0 = angle(of: startGround)
        let a1 = angle(of: endGround)
        let ringStart = projectOutsideField(pointOnCircle(radius: radius, angle: a0))
        let ringEnd = projectOutsideField(pointOnCircle(radius: radius, angle: a1))
        
        // Asegurar que el inicio y fin estén fuera del estadio
        let safeStart = projectOutsideField(startGround)
        let safeEnd = projectOutsideField(endGround)
        
        // Agregar inicio
        points.append(RoutePoint(id: start.id, poi: start, position: safeStart))
        
        // Punto de llegada al anillo desde el inicio
        let startGatePOI = POI(
            id: "gate_start_\(start.id)",
            name: "Acceso Perímetro",
            description: "Acceso al perímetro",
            type: .landmark,
            coordinates: ringStart,
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: accessible,
                mobilityAidAccessible: accessible,
                visualLandmarks: [],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        )
        points.append(RoutePoint(id: startGatePOI.id, poi: startGatePOI, position: ringStart))
        
        // Arco por el perímetro (no cruza el estadio)
        addArcPoints(radius: radius, startAngle: a0, endAngle: a1, to: &points, accessible: accessible, maxSegments: 18)
        
        // Punto de salida del anillo hacia el destino
        let endGatePOI = POI(
            id: "gate_end_\(end.id)",
            name: "Salida Perímetro",
            description: "Salida del perímetro",
            type: .landmark,
            coordinates: ringEnd,
            accessibility: POI.AccessibilityInfo(
                wheelchairAccessible: accessible,
                mobilityAidAccessible: accessible,
                visualLandmarks: [],
                hasElevator: false,
                hasRamp: false,
                hasAccessibleRestroom: false
            )
        )
        points.append(RoutePoint(id: endGatePOI.id, poi: endGatePOI, position: ringEnd))
        
        // Agregar fin
        points.append(RoutePoint(id: end.id, poi: end, position: safeEnd))
        
        return points
    }
    
    private func calculateAccessiblePath(from start: POI, to end: POI) -> [RoutePoint] {
        // NUEVO: Forzar ruta por el perímetro exterior (anillo accesible)
        let points = perimeterArcPath(from: start, to: end, radius: accessibleRingRadius, accessible: true)
        return points
    }
    
    // Helper para crear ruta directa simple
    // GARANTIZA que todos los puntos estén fuera del estadio (y = 0)
    private func createDirectRoute(from start: POI, to end: POI, startPos: SIMD3<Float>, endPos: SIMD3<Float>, accessible: Bool) -> [RoutePoint] {
        // Asegurar que startPos y endPos tengan y = 0
        let startGround = SIMD3<Float>(startPos.x, 0, startPos.z)
        let endGround = SIMD3<Float>(endPos.x, 0, endPos.z)
        
        var points: [RoutePoint] = []
        let projectedStart = projectOutsideField(startGround)
        points.append(RoutePoint(id: start.id, poi: start, position: projectedStart))
        
        let distance = calculateDistance(from: projectedStart, to: endGround)
        // Solo agregar 1-2 puntos intermedios para distancias cortas
        if distance > 10 {
            let midPoint = SIMD3<Float>(
                (projectedStart.x + endGround.x) / 2,
                0, // SIEMPRE y = 0
                (projectedStart.z + endGround.z) / 2
            )
            
            // Proyectar fuera del campo si está dentro
            let projectedMid = projectOutsideField(midPoint)
            
            // Verificar que no esté dentro del estadio
            if !isForbiddenField(projectedMid) {
                let midPOI = POI(
                    id: "mid_\(start.id)_\(end.id)",
                    name: "Punto medio",
                    description: "Punto intermedio de la ruta",
                    type: .landmark,
                    coordinates: projectedMid, // y = 0 siempre
                    accessibility: POI.AccessibilityInfo(
                        wheelchairAccessible: accessible,
                        mobilityAidAccessible: accessible,
                        visualLandmarks: [],
                        hasElevator: false,
                        hasRamp: false,
                        hasAccessibleRestroom: false
                    )
                )
                points.append(RoutePoint(id: midPOI.id, poi: midPOI, position: projectedMid))
            }
        }
        
        let projectedEnd = projectOutsideField(endGround)
        points.append(RoutePoint(id: end.id, poi: end, position: projectedEnd))
        
        // VERIFICACIÓN FINAL: Asegurar que ningún punto esté dentro del estadio
        for point in points {
            if point.position.y > 0 {
                let correctedPos = SIMD3<Float>(point.position.x, 0, point.position.z)
                if let index = points.firstIndex(where: { $0.id == point.id }) {
                    points[index] = RoutePoint(id: point.id, poi: point.poi, position: correctedPos)
                }
            }
        }
        
        return points
    }
    
    // Helper para agregar puntos interpolados de forma eficiente
    // GARANTIZA que todos los puntos estén fuera del estadio (y = 0)
    private func addInterpolatedPoints(from start: SIMD3<Float>, to end: SIMD3<Float>, to points: inout [RoutePoint], accessible: Bool, maxPoints: Int) {
        // Asegurar que start y end tengan y = 0
        let startGround = SIMD3<Float>(start.x, 0, start.z)
        let endGround = SIMD3<Float>(end.x, 0, end.z)
        
        let distance = calculateDistance(from: startGround, to: endGround)
        let numPoints = min(maxPoints, max(1, Int(distance / 12))) // Un punto cada 12 unidades
        
        for i in 1..<numPoints {
            let progress = Float(i) / Float(numPoints)
            let x = startGround.x + (endGround.x - startGround.x) * progress
            let z = startGround.z + (endGround.z - startGround.z) * progress
            // SIEMPRE y = 0 (nunca dentro del estadio)
            var interpolatedPos = SIMD3<Float>(x, 0, z)
            
            // Proyectar fuera del campo si está dentro
            interpolatedPos = projectOutsideField(interpolatedPos)
            
            // Verificar que no esté muy cerca del último punto
            if let lastPoint = points.last {
                let dist = calculateDistance(from: lastPoint.position, to: interpolatedPos)
                if dist < 5.0 { continue }
            }
            
            // Verificar que no esté dentro del estadio (doble verificación)
            if isForbiddenField(interpolatedPos) {
                continue // Saltar este punto si está prohibido
            }
            
            let interpolatedPOI = POI(
                id: "intermediate_\(points.count)",
                name: "Punto \(points.count)",
                description: "Punto intermedio de la ruta",
                type: .landmark,
                coordinates: interpolatedPos, // y = 0 siempre
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
        // NUEVO: Forzar ruta por el perímetro interior (anillo estándar)
        let points = perimeterArcPath(from: start, to: end, radius: standardRingRadius, accessible: false)
        return points
    }
    
    private func estimateTime(distance: Float, accessible: Bool) -> TimeInterval {
        // Velocidad promedio: 1.2 m/s (accesible) o 1.5 m/s (estándar)
        let speed: Float = accessible ? 1.2 : 1.5
        
        // Calcular tiempo base
        var timeInSeconds = distance / speed
        
        // Agregar tiempo adicional por cambios de nivel, giros, etc.
        // Aproximadamente 10-15 segundos por cada punto intermedio
        let intermediatePoints = max(0, Int(distance / 15)) // Un punto cada ~15 unidades
        let additionalTime = Float(intermediatePoints) * 12.0 // 12 segundos por punto intermedio
        
        timeInSeconds += additionalTime
        
        // Asegurar un tiempo mínimo razonable (al menos 30 segundos)
        timeInSeconds = max(timeInSeconds, 30.0)
        
        return TimeInterval(timeInSeconds)
    }
    
    private func generateInstructions(from start: POI, to end: POI, points: [RoutePoint], accessible: Bool) -> [String] {
        var instructions: [String] = []
        
        guard points.count >= 2 else {
            instructions.append("📍 Inicia en \(start.name)")
            instructions.append("✅ Llega a \(end.name)")
            return instructions
        }
        
        // Calcular distancias entre puntos (asumiendo que 1 unidad = 1 metro aproximadamente)
        func distanceToMeters(_ distance: Float) -> Int {
            // Convertir distancia a metros (redondear)
            return Int(round(distance))
        }
        
        if accessible {
            // Instrucciones para ruta accesible: mencionar amenidades con distancias
            instructions.append("📍 Inicia en \(start.name)")
            
            var accumulatedDistance: Float = 0
            var previousPoint = points[0]
            
            for index in 1..<points.count {
                let currentPoint = points[index]
                let segmentDistance = calculateDistance(from: previousPoint.position, to: currentPoint.position)
                accumulatedDistance += segmentDistance
                let distanceInMeters = distanceToMeters(segmentDistance)
                
                let poi = currentPoint.poi
                var instruction = ""
                
                // Si es el último punto, es el destino
                if index == points.count - 1 {
                    instruction = "✅ Camina \(distanceInMeters) metros y llegarás a \(poi.name)"
                } else {
                    // Construir instrucción detallada según el tipo de POI
                    if poi.type == .elevator {
                        instruction = "🚶 Camina \(distanceInMeters) metros y encontrarás el \(poi.name). Usa el elevador para continuar."
                    } else if poi.type == .ramp {
                        instruction = "🚶 Camina \(distanceInMeters) metros y encontrarás la \(poi.name). Sube por la rampa para continuar."
                    } else if poi.accessibility.hasElevator {
                        instruction = "🚶 Camina \(distanceInMeters) metros y llegarás a \(poi.name). Aquí encontrarás un elevador disponible."
                    } else if poi.accessibility.hasRamp {
                        instruction = "🚶 Camina \(distanceInMeters) metros y llegarás a \(poi.name). Aquí encontrarás una rampa de acceso."
                    } else if poi.accessibility.hasAccessibleRestroom {
                        instruction = "🚶 Camina \(distanceInMeters) metros y pasarás por \(poi.name). Hay un baño accesible disponible."
                    } else if poi.type == .entrance {
                        instruction = "🚶 Camina \(distanceInMeters) metros y pasarás por \(poi.name). Zona accesible."
                    } else if poi.type == .restroom {
                        instruction = "🚶 Camina \(distanceInMeters) metros y pasarás por \(poi.name). Baño accesible disponible."
                    } else {
                        instruction = "🚶 Camina \(distanceInMeters) metros y pasarás por \(poi.name). Zona accesible."
                    }
                }
                
                instructions.append(instruction)
                previousPoint = currentPoint
            }
        } else {
            // Instrucciones para ruta estándar: mencionar puntos de paso con distancias
            instructions.append("📍 Inicia en \(start.name)")
            
            var accumulatedDistance: Float = 0
            var previousPoint = points[0]
            
            for index in 1..<points.count {
                let currentPoint = points[index]
                let segmentDistance = calculateDistance(from: previousPoint.position, to: currentPoint.position)
                accumulatedDistance += segmentDistance
                let distanceInMeters = distanceToMeters(segmentDistance)
                
                let poi = currentPoint.poi
                var instruction = ""
                
                // Si es el último punto, es el destino
                if index == points.count - 1 {
                    instruction = "✅ Camina \(distanceInMeters) metros y llegarás a \(poi.name)"
                } else {
                    // Construir instrucción detallada según el tipo de POI
                    if poi.type == .section && !poi.accessibility.wheelchairAccessible {
                        instruction = "🚶 Camina \(distanceInMeters) metros y pasarás por \(poi.name). Esta sección tiene escaleras."
                    } else if poi.type == .exit && !poi.accessibility.wheelchairAccessible {
                        instruction = "🚶 Camina \(distanceInMeters) metros y pasarás por \(poi.name). Salida con escaleras."
                    } else if poi.type == .landmark {
                        instruction = "🚶 Camina \(distanceInMeters) metros y pasarás por \(poi.name). Punto de referencia."
                    } else if poi.type == .entrance {
                        instruction = "🚶 Camina \(distanceInMeters) metros y pasarás por \(poi.name)."
                    } else if poi.id.contains("checkpoint") {
                        instruction = "🚶 Camina \(distanceInMeters) metros y pasarás por \(poi.name). Punto de control."
                    } else if poi.id.contains("pathway") {
                        instruction = "🚶 Camina \(distanceInMeters) metros y seguirás por \(poi.name)."
                    } else if poi.id.contains("crossing") {
                        instruction = "🚶 Camina \(distanceInMeters) metros y llegarás a \(poi.name). Cruce de caminos."
                    } else {
                        instruction = "🚶 Camina \(distanceInMeters) metros y pasarás por \(poi.name)."
                    }
                }
                
                instructions.append(instruction)
                previousPoint = currentPoint
            }
        }
        
        return instructions
    }
}

