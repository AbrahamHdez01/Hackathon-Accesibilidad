import Foundation

// MARK: - Script Parser
struct ScriptParser {
    /// Divide el script de narración en segmentos para subtítulos
    /// Usa exactamente el mismo texto que se lee del archivo
    static func parseScript(_ script: String) -> [String] {
        // Primero, dividir por líneas nuevas (respeta la estructura del archivo)
        let lines = script.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // Si hay líneas con contenido, devolverlas como segmentos
        // Esto mantiene la estructura original del archivo
        if !lines.isEmpty {
            return lines
        }
        
        // Si no hay líneas, dividir por oraciones (puntos seguidos de espacio o signos de exclamación/interrogación)
        let sentences = script.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // Si aún no hay segmentos, dividir por comas
        if sentences.isEmpty {
            let commaSegments = script.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            return commaSegments
        }
        
        return sentences
    }
    
    /// Estima el tiempo de duración de cada segmento basado en palabras por minuto
    static func estimateDuration(for text: String, wordsPerMinute: Double = 150.0) -> TimeInterval {
        let words = text.components(separatedBy: .whitespaces).count
        let minutes = Double(words) / wordsPerMinute
        return max(minutes * 60.0, 2.0) // Mínimo 2 segundos
    }
}

