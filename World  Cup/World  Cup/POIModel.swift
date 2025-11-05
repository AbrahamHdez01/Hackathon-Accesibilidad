import Foundation
import SwiftUI

// MARK: - Point of Interest Model
struct POI: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let type: POIType
    let coordinates: SIMD3<Float> // Coordenadas 3D en el modelo
    let accessibility: AccessibilityInfo
    
    enum POIType: String, Codable, Equatable {
        case entrance = "Entrada"
        case exit = "Salida"
        case section = "Sección"
        case landmark = "Punto de Referencia"
        case service = "Servicio"
        case restroom = "Baño"
        case elevator = "Elevador"
        case ramp = "Rampa"
    }
    
    struct AccessibilityInfo: Codable, Equatable {
        let wheelchairAccessible: Bool
        let mobilityAidAccessible: Bool
        let visualLandmarks: [String]
        let hasElevator: Bool
        let hasRamp: Bool
        let hasAccessibleRestroom: Bool
    }
}

// MARK: - Route Point
struct RoutePoint: Identifiable, Equatable {
    let id: String
    let poi: POI
    let position: SIMD3<Float>
}

// MARK: - Route
struct Route: Identifiable {
    let id: String
    let start: POI
    let end: POI
    let points: [RoutePoint]
    let isAccessible: Bool
    let estimatedTime: TimeInterval // en segundos
    let distance: Float // en metros
    let instructions: [String]
}

