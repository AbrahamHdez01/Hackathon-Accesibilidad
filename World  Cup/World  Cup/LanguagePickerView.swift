import SwiftUI

// MARK: - Language Picker View
struct LanguagePickerView: View {
    let languages: [LanguagePack]
    let onSelect: (LanguagePack) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo con gradiente Canadá
                LinearGradient.canadaBackground
                    .ignoresSafeArea()
                
                // Sombra hoja de maple difusa
                MapleLeafShadow()
                    .opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(languages) { language in
                            Button(action: {
                                withAnimation(.spring()) {
                                    onSelect(language)
                                    dismiss()
                                }
                            }) {
                                HStack(spacing: 16) {
                                    // Bandera/icono del idioma
                                    Text(flagForLanguage(language.code))
                                        .font(.system(size: 36))
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(language.name)
                                            .font(.worldCupHeadline)
                                            .foregroundColor(.wc_textPrimary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.worldCupCaption)
                                        .foregroundColor(.wc_canIceBlue)
                                }
                                .padding(20)
                                .canadaGlassCard(cornerRadius: 20)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel("Idioma \(language.name)")
                            .accessibilityHint("Doble toque para seleccionar este idioma")
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Seleccionar Idioma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.wc_canIceBlue)
                }
            }
        }
    }
    
    private func flagForLanguage(_ code: String) -> String {
        switch code {
        case "es": return "🇲🇽"
        case "en": return "🇺🇸"
        case "pt": return "🇧🇷"
        case "fr": return "🇫🇷"
        default: return "🌐"
        }
    }
}

#Preview {
    LanguagePickerView(
        languages: [
            LanguagePack(code: "es", name: "Español", faqs: []),
            LanguagePack(code: "en", name: "English", faqs: [])
        ],
        onSelect: { _ in }
    )
}

