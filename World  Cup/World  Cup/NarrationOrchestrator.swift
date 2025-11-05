import Foundation
import AVFoundation
import SwiftUI

// MARK: - Narration Orchestrator
final class NarrationOrchestrator: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published var isHapticsOn: Bool = false {
        didSet {
            subtitlesEnabled = isHapticsOn
        }
    }
    
    @Published private(set) var subtitlesEnabled: Bool = false
    @Published private(set) var currentLineIndex: Int = 0
    @Published private(set) var currentRange: NSRange?
    @Published private(set) var currentLineText: String = ""
    
    var visibleScripts: [NarrationSegment] {
        guard currentLineIndex < scripts.count else { return scripts }
        return Array(scripts.prefix(currentLineIndex + 1))
    }
    
    // MARK: - Private Properties
    
    private let synth = AVSpeechSynthesizer()
    private var scripts: [NarrationSegment] = []
    private var wordTick = 0
    private let selectionGen = UISelectionFeedbackGenerator()
    private let impactGen = UIImpactFeedbackGenerator(style: .light)
    private var isPlaying = false
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        synth.delegate = self
        selectionGen.prepare()
        impactGen.prepare()
    }
    
    // MARK: - Public API
    
    func load(scripts: [NarrationSegment]) {
        stopAndReset()
        self.scripts = scripts
        currentLineIndex = 0
        currentRange = nil
        currentLineText = scripts.first?.text ?? ""
    }
    
    func start() {
        guard !scripts.isEmpty, !isPlaying else { return }
        isPlaying = true
        
        for seg in scripts {
            let utterance = AVSpeechUtterance(string: seg.text)
            
            // Configurar voz
            if let voice = AVSpeechSynthesisVoice(language: seg.voice) {
                utterance.voice = voice
            } else {
                // Fallback a voz por defecto del idioma
                utterance.voice = AVSpeechSynthesisVoice(language: seg.voice)
            }
            
            utterance.rate = seg.rate
            utterance.pitchMultiplier = seg.pitch
            utterance.volume = 1.0
            
            synth.speak(utterance)
        }
    }
    
    func pause() {
        guard isPlaying else { return }
        synth.pauseSpeaking(at: .word)
    }
    
    func resume() {
        guard isPlaying else { return }
        synth.continueSpeaking()
    }
    
    func stopAndReset() {
        synth.stopSpeaking(at: .immediate)
        isPlaying = false
        currentLineIndex = 0
        currentRange = nil
        currentLineText = scripts.first?.text ?? ""
        wordTick = 0
    }
    
    // MARK: - Helper Methods
    
    func attributedCurrentLine(full: String, range: NSRange?) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: full)
        
        // Aplicar negritas a todo el texto
        let fullRange = NSRange(location: 0, length: full.count)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .semibold), range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: fullRange)
        
        // Aplicar subrayado solo al rango actual si existe
        if let range = range, range.location + range.length <= full.count {
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            attributedString.addAttribute(.underlineColor, value: UIColor.systemGreen, range: range)
        }
        
        return attributedString
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension NarrationOrchestrator: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentRange = nil
            self.currentLineText = utterance.speechString
            
            // Actualizar índice basado en el texto que empieza
            if let index = self.scripts.firstIndex(where: { $0.text == utterance.speechString }) {
                self.currentLineIndex = index
            }
            
            // Haptic ligero al inicio de línea si está habilitado
            if self.isHapticsOn {
                self.impactGen.impactOccurred()
            }
            
            self.wordTick = 0
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           willSpeakRangeOfSpeechString characterRange: NSRange,
                           utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentRange = characterRange
            self.currentLineText = utterance.speechString
            
            // Haptic con throttle si está habilitado
            if self.isHapticsOn {
                self.wordTick += 1
                if self.wordTick % 3 == 0 {
                    self.selectionGen.selectionChanged()
                }
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentRange = nil
            self.wordTick = 0
            
            // Avanzar al siguiente segmento
            if self.currentLineIndex < self.scripts.count - 1 {
                self.currentLineIndex += 1
                self.currentLineText = self.scripts[self.currentLineIndex].text
            } else {
                // Terminó toda la narración
                self.isPlaying = false
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isPlaying = false
            self.currentRange = nil
        }
    }
}

