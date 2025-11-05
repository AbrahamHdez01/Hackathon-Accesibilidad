import Foundation

// Configuración de voces específicas para narración
// Agrega aquí los IDs de tus voces de ElevenLabs
struct ElevenLabsVoicesConfig {
    // Voces predefinidas por idioma
    static let voices: [VoiceConfig] = [
        VoiceConfig(
            id: "QpDQJR3frbDwOhTIo8nW", // Narrador español
            name: "Español",
            language: "es"
        ),
        VoiceConfig(
            id: "aNk2JruNj5JE4gj7K3u7", // Narrador inglés
            name: "English",
            language: "en"
        ),
        VoiceConfig(
            id: "Q8X0Kxovj3a14eDLmt2l", // Narrador francés
            name: "Français",
            language: "fr"
        )
    ]
    
    static var defaultVoiceId: String {
        voices.first?.id ?? ""
    }
}

struct VoiceConfig: Identifiable {
    let id: String
    let name: String
    let language: String
}

