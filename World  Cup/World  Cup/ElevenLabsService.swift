import Foundation
import AVFoundation

class ElevenLabsService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.elevenlabs.io/v1"
    
    init(apiKey: String? = nil) {
        // Usa la API key proporcionada o la de la configuración
        self.apiKey = apiKey ?? ElevenLabsConfig.apiKey
    }
    
    // Generar audio desde texto
    // Optimizado para reducir consumo de créditos
    func textToSpeech(
        text: String,
        voiceId: String = "21m00Tcm4TlvDq8ikWAM", // Voice Rachel (puedes cambiarlo)
        modelId: String = "eleven_turbo_v2_5" // Modelo más económico y rápido
    ) async throws -> Data {
        let url = URL(string: "\(baseURL)/text-to-speech/\(voiceId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Voice settings optimizados para reducir costo
        // Stability más baja = menos procesamiento = menos créditos
        let requestBody: [String: Any] = [
            "text": text,
            "model_id": modelId,
            "voice_settings": [
                "stability": 0.4, // Reducido de 0.5 para menos procesamiento
                "similarity_boost": 0.7, // Reducido de 0.75
                "style": 0.0,
                "use_speaker_boost": false // Desactivado para reducir costo
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ElevenLabsError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Error desconocido"
            throw ElevenLabsError.apiError("Error \(httpResponse.statusCode): \(errorMessage)")
        }
        
        return data
    }
    
    // Generar audio desde texto dividido en chunks para mejor control
    // Útil para textos muy largos (reduce posibilidad de timeouts)
    func textToSpeechChunked(
        text: String,
        voiceId: String = "21m00Tcm4TlvDq8ikWAM",
        modelId: String = "eleven_turbo_v2_5",
        chunkSize: Int = 5000 // ~5000 caracteres por chunk
    ) async throws -> Data {
        // Dividir texto en chunks por párrafos (más natural)
        let paragraphs = text.components(separatedBy: "\n\n")
        var chunks: [String] = []
        var currentChunk = ""
        
        for paragraph in paragraphs {
            let paragraphTrimmed = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            if paragraphTrimmed.isEmpty { continue }
            
            // Si agregar este párrafo excede el límite, guardar chunk actual y empezar uno nuevo
            if currentChunk.count + paragraphTrimmed.count + 2 > chunkSize && !currentChunk.isEmpty {
                chunks.append(currentChunk)
                currentChunk = paragraphTrimmed
            } else {
                if !currentChunk.isEmpty {
                    currentChunk += "\n\n"
                }
                currentChunk += paragraphTrimmed
            }
        }
        
        // Agregar último chunk si no está vacío
        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }
        
        // Si solo hay un chunk, usar el método normal
        if chunks.count <= 1 {
            return try await textToSpeech(text: text, voiceId: voiceId, modelId: modelId)
        }
        
        // Generar audio para cada chunk y concatenar
        var audioSegments: [Data] = []
        for (index, chunk) in chunks.enumerated() {
            print("Generando chunk \(index + 1) de \(chunks.count) (\(chunk.count) caracteres)")
            let chunkAudio = try await textToSpeech(text: chunk, voiceId: voiceId, modelId: modelId)
            audioSegments.append(chunkAudio)
        }
        
        // Concatenar todos los segmentos de audio
        return concatenateAudioData(audioSegments)
    }
    
    // Concatenar múltiples segmentos de audio
    private func concatenateAudioData(_ audioSegments: [Data]) -> Data {
        guard !audioSegments.isEmpty else { return Data() }
        guard audioSegments.count > 1 else { return audioSegments[0] }
        
        // Crear un archivo temporal compuesto
        var combinedData = Data()
        for segment in audioSegments {
            combinedData.append(segment)
        }
        return combinedData
    }
    
    // Obtener lista de voces disponibles
    func getVoices() async throws -> [ElevenLabsVoice] {
        let url = URL(string: "\(baseURL)/voices")!
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ElevenLabsError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Error desconocido"
            throw ElevenLabsError.apiError("Error \(httpResponse.statusCode): \(errorMessage)")
        }
        
        let voicesResponse = try JSONDecoder().decode(ElevenLabsVoicesResponse.self, from: data)
        return voicesResponse.voices
    }
}

enum ElevenLabsError: LocalizedError {
    case apiError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return message
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        }
    }
}

// Modelos para las respuestas de la API
struct ElevenLabsVoicesResponse: Codable {
    let voices: [ElevenLabsVoice]
}

struct ElevenLabsVoice: Codable, Identifiable {
    let voice_id: String
    let name: String
    let category: String?
    let description: String?
    let preview_url: String?
    
    var id: String { voice_id }
}

