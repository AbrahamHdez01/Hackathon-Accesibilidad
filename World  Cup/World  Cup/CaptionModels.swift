import SwiftUI

// MARK: - Caption Intensity
enum CaptionIntensity: Int, Codable {
    case low = 0
    case medium = 1
    case high = 2
}

// MARK: - Caption Line Model
struct CaptionLine: Identifiable, Equatable, Codable {
    let id: UUID
    let timestamp: Date
    let text: String
    let sfx: [String]           // p.ej. ["[Silbato]", "[Celebración]"]
    let keywords: [String]      // p.ej. ["GOL", "Giménez"]
    let intensity: CaptionIntensity
    let ttl: TimeInterval       // tiempo en pantalla (s)
    
    init(text: String,
         sfx: [String] = [],
         keywords: [String] = [],
         intensity: CaptionIntensity = .medium,
         ttl: TimeInterval = 4.0,
         id: UUID = .init(),
         timestamp: Date = .now) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
        self.sfx = sfx
        self.keywords = keywords
        self.intensity = intensity
        self.ttl = ttl
    }
}

