// ARCHIVO TEMPORAL - NUEVA CONFIGURACIÓN DE POIs
// Este archivo contiene solo la función loadDefaultPOIs() nueva para copiar al archivo original

private func loadDefaultPOIs() -> [POI] {
    // POIs reorganizados para DIFERENCIAR claramente rutas accesibles vs estándar
    // TODOS los POIs están FUERA del estadio (y = 0)
    // Los POIs accesibles forman un ANILLO EXTERIOR (más alejados del centro)
    // Los POIs estándar forman un ANILLO INTERIOR (más cercanos al centro, con escaleras)
    
    return [
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

