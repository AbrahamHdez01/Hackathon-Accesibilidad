import Foundation
import SwiftUI
import UIKit

// MARK: - Caption Utilities
struct CaptionUtilities {
    
    // MARK: - Haptics
    
    /// Dispara un haptic feedback según la intensidad
    static func triggerHaptic(for intensity: CaptionIntensity) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        
        switch intensity {
        case .high:
            generator.notificationOccurred(.success)
        case .medium:
            let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
            impactGenerator.prepare()
            impactGenerator.impactOccurred()
        case .low:
            let impactGenerator = UIImpactFeedbackGenerator(style: .light)
            impactGenerator.prepare()
            impactGenerator.impactOccurred()
        }
    }
    
    // MARK: - Text Formatting
    
    /// Formatea un texto con keywords resaltadas usando AttributedString
    static func attributedText(for line: CaptionLine) -> AttributedString {
        var attributedString = AttributedString(line.text)
        
        // Aplicar estilo base a todo el texto (blanco para máximo contraste)
        let baseFont = Font.system(.title3, design: .rounded, weight: .semibold)
        attributedString.font = baseFont
        attributedString.foregroundColor = .white
        
        // Resaltar keywords (buscar todas las ocurrencias, case-insensitive)
        for keyword in line.keywords {
            let text = line.text
            var searchStart = text.startIndex
            
            while searchStart < text.endIndex {
                let searchRange = searchStart..<text.endIndex
                
                guard let range = text.range(of: keyword, options: [.caseInsensitive, .diacriticInsensitive], range: searchRange) else {
                    break
                }
                
                // Calcular la posición dentro del AttributedString
                let startOffset = text.distance(from: text.startIndex, to: range.lowerBound)
                let endOffset = text.distance(from: text.startIndex, to: range.upperBound)

                // Asegurar offsets válidos dentro del rango de caracteres del AttributedString
                let totalChars = attributedString.characters.count
                let safeStart = min(max(0, startOffset), totalChars)
                let safeLength = max(0, min(endOffset - startOffset, totalChars - safeStart))

                if safeLength > 0 {
                    let startIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: safeStart)
                    let endIndex = attributedString.index(startIndex, offsetByCharacters: safeLength)
                    let attributedRange = startIndex..<endIndex
                    attributedString[attributedRange].foregroundColor = .accessibleLime
                    attributedString[attributedRange].font = baseFont.bold()
                }
                
                // Continuar después de esta ocurrencia
                searchStart = range.upperBound
            }
        }
        
        return attributedString
    }
    
    /// Crea el texto completo incluyendo SFX
    static func fullText(for line: CaptionLine) -> String {
        var fullText = ""
        
        // Agregar SFX al inicio
        for sfx in line.sfx {
            fullText += "\(sfx) "
        }
        
        fullText += line.text
        
        return fullText
    }
    
    /// Crea el texto limpio para accesibilidad (sin corchetes de SFX)
    static func accessibilityText(for line: CaptionLine) -> String {
        var text = line.text
        
        // Remover corchetes de SFX para accesibilidad
        for sfx in line.sfx {
            text = text.replacingOccurrences(of: sfx, with: "")
        }
        
        // Limpiar espacios múltiples
        text = text.replacingOccurrences(of: "  ", with: " ")
        text = text.trimmingCharacters(in: .whitespaces)
        
        return text
    }
}

