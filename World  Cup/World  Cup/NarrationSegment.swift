import Foundation

// MARK: - Narration Segment
struct NarrationSegment: Identifiable, Equatable {
    let id: UUID
    let text: String
    let voice: String // Language code (e.g., "es-ES", "en-US", "fr-FR")
    let rate: Float
    let pitch: Float
    
    init(id: UUID = UUID(), text: String, voice: String = "es-ES", rate: Float = 0.5, pitch: Float = 1.0) {
        self.id = id
        self.text = text
        self.voice = voice
        self.rate = rate
        self.pitch = pitch
    }
}

