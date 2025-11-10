import Foundation

// MARK: - FAQ Models

struct FAQItem: Identifiable, Codable {
    let id: String
    let q: String
    let a: String
    
    init(q: String, a: String) {
        self.id = q // Usar la pregunta como ID único
        self.q = q
        self.a = a
    }
}

struct LanguagePack: Identifiable, Codable {
    let code: String
    let name: String
    let faqs: [FAQItem]
    
    var id: String { code }
}

struct FAQRoot: Codable {
    let languages: [LanguagePack]
}

