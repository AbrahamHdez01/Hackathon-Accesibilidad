import Foundation
import SwiftUI
import UIKit

// MARK: - Chatbot ViewModel
class ChatbotVM: ObservableObject {
    @Published var selectedLanguage: LanguagePack?
    @Published var expandedAnswerID: String?
    @AppStorage("chatbot.lang") var storedLangCode: String = ""
    
    let faqStore: FAQStore
    
    var languages: [LanguagePack] {
        faqStore.allLanguages
    }
    
    init(faqStore: FAQStore = FAQStore()) {
        self.faqStore = faqStore
        
        // Cargar idioma guardado si existe
        if !storedLangCode.isEmpty {
            selectedLanguage = faqStore.language(by: storedLangCode)
        }
    }
    
    func selectLanguage(_ pack: LanguagePack) {
        selectedLanguage = pack
        storedLangCode = pack.code
        expandedAnswerID = nil // Limpiar respuesta expandida al cambiar idioma
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func toggleQuestion(_ item: FAQItem) {
        if expandedAnswerID == item.id {
            expandedAnswerID = nil
        } else {
            expandedAnswerID = item.id
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    var currentFAQs: [FAQItem] {
        selectedLanguage?.faqs ?? []
    }
}

