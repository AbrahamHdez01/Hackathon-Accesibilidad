import Foundation
import SwiftUI

// MARK: - Caption Store
class CaptionStore: ObservableObject {
    @Published var lines: [CaptionLine] = []
    @Published var enableHaptics: Bool = true
    
    private var removalTimers: [UUID: DispatchWorkItem] = [:]
    
    // MARK: - Public Methods
    
    /// Push un texto crudo que será analizado y clasificado automáticamente
    func push(text: String) {
        push(text: text, keepPrevious: false)
    }
    
    /// Push un texto crudo que será analizado y clasificado automáticamente
    func push(text: String, keepPrevious: Bool) {
        let normalizedText = text.uppercased()
        
        // Heurística para detectar intensidad y extraer keywords/SFX
        var intensity: CaptionIntensity = .medium
        var keywords: [String] = []
        var sfx: [String] = []
        var ttl: TimeInterval = 4.0
        
        // Detectar GOL/GOAL
        if normalizedText.contains("GOL") || normalizedText.contains("GOAL") {
            intensity = .high
            keywords.append("GOL")
            sfx.append("[Celebración]")
            ttl = 5.0 // Goles duran más en pantalla
        }
        
        // Detectar silbato
        if normalizedText.contains("SILBATO") || normalizedText.contains("WHISTLE") {
            sfx.append("[Silbato]")
        }
        
        // Detectar tiro/disparo
        if normalizedText.contains("TIRO") || normalizedText.contains("SHOT") || normalizedText.contains("DISPARA") {
            intensity = .medium
            keywords.append("Tiro")
        }
        
        // Detectar jugadores comunes (puedes expandir esta lista)
        let playerKeywords = ["GIMÉNEZ", "LOZANO", "JIMÉNEZ", "OCHOA", "MESSI", "PULISIC", "DAVID"]
        for keyword in playerKeywords {
            if normalizedText.contains(keyword) {
                keywords.append(keyword.capitalized)
            }
        }
        
        // Crear la línea con la información detectada
        let line = CaptionLine(
            text: text,
            sfx: sfx,
            keywords: keywords,
            intensity: intensity,
            ttl: ttl
        )
        
        push(line: line, keepPrevious: keepPrevious)
    }
    
    /// Push una línea ya "curada" por la IA
    func push(line: CaptionLine) {
        push(line: line, keepPrevious: false)
    }
    
    /// Push una línea ya "curada" por la IA con opción de mantener las anteriores
    func push(line: CaptionLine, keepPrevious: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Verificar si la línea ya existe (evitar duplicados)
            let alreadyExists = self.lines.contains { $0.text == line.text }
            if alreadyExists {
                // Si ya existe, no agregarla de nuevo pero asegurar que no se elimine
                // Cancelar el timer de remoción si existe
                if let existingLine = self.lines.first(where: { $0.text == line.text }) {
                    self.removalTimers[existingLine.id]?.cancel()
                    self.removalTimers.removeValue(forKey: existingLine.id)
                }
                return
            }
            
            // Si keepPrevious es false, limpiar los anteriores antes de agregar
            if !keepPrevious {
                // Cancelar todos los timers de remoción anteriores
                for (_, workItem) in self.removalTimers {
                    workItem.cancel()
                }
                self.removalTimers.removeAll()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    self.lines.removeAll()
                }
            }
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                self.lines.append(line)
            }
            
            // Disparar haptic si está habilitado y es alta intensidad
            if self.enableHaptics && line.intensity == .high {
                // Usar DispatchQueue para asegurar que se ejecute en el hilo principal
                DispatchQueue.main.async {
                    CaptionUtilities.triggerHaptic(for: line.intensity)
                }
            }
            
            // Solo programar remoción automática si keepPrevious es false
            // Si keepPrevious es true, los subtítulos se mantienen en el historial permanentemente
            if !keepPrevious {
                self.scheduleRemoval(for: line)
            }
            // Si keepPrevious es true, NO programar remoción - los subtítulos permanecen en el historial
        }
    }
    
    /// Limpiar todas las líneas
    func clear() {
        // Cancelar todos los timers
        for (_, workItem) in removalTimers {
            workItem.cancel()
        }
        removalTimers.removeAll()
        
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.lines.removeAll()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func scheduleRemoval(for line: CaptionLine) {
        let workItem = DispatchWorkItem { [weak self] in
            self?.removeLine(with: line.id)
        }
        
        removalTimers[line.id] = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + line.ttl, execute: workItem)
    }
    
    private func removeLine(with id: UUID) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                self.lines.removeAll { $0.id == id }
            }
            
            self.removalTimers.removeValue(forKey: id)
        }
    }
}

