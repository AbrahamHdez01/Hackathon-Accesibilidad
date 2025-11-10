import SwiftUI

struct ChatAssistantView: View {
    @StateObject private var viewModel = ChatbotVM()
    @State private var showLanguagePicker = false
    
    var body: some View {
        ZStack {
            // Fondo con gradiente Canadá (Rojo → Granate)
            LinearGradient.canadaBackground
                .ignoresSafeArea()
            
            // Sombra hoja de maple difusa
            MapleLeafShadow()
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header con título y botón Globe
                HStack {
                    Text("Asistente Multilingüe")
                        .font(.worldCupTitle)
                        .foregroundColor(.wc_textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    
                    // Botón para cambiar idioma
                    Button(action: {
                        showLanguagePicker = true
                    }) {
                        Image(systemName: "globe")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.wc_canIceBlue)
                            .padding(12)
                            .canadaGlassCard(cornerRadius: 20)
                    }
                    .accessibilityLabel("Cambiar idioma")
                    .accessibilityHint("Doble toque para abrir el selector de idioma")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .canadaGlassCard(cornerRadius: 24)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Contenido principal
                if viewModel.faqStore.isLoading {
                    // Estado de carga
                    VStack(spacing: 24) {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .wc_canIceBlue))
                            .scaleEffect(1.2)
                        Text("Cargando preguntas...")
                            .font(.worldCupBody)
                            .foregroundColor(.wc_textSecondary)
                        Spacer()
                    }
                } else if viewModel.faqStore.allLanguages.isEmpty && viewModel.faqStore.errorMessage != nil {
                    // Estado de error solo si no hay datos por defecto
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                            .accessibilityHidden(true)
                        Text("Error al cargar FAQs")
                            .font(.worldCupHeadline)
                            .foregroundColor(.wc_textPrimary)
                        Text(viewModel.faqStore.errorMessage ?? "Error desconocido")
                            .font(.worldCupCaption)
                            .foregroundColor(.wc_textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        Spacer()
                    }
                } else if viewModel.selectedLanguage == nil {
                    // Estado: No hay idioma seleccionado
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.wc_canIceBlue)
                            .accessibilityHidden(true)
                        
                        Text("Selecciona un idioma")
                            .font(.worldCupHeadline)
                            .foregroundColor(.wc_textPrimary)
                        
                        Text("Elige tu idioma preferido para ver las preguntas frecuentes")
                            .font(.worldCupBody)
                            .foregroundColor(.wc_textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Button(action: {
                            showLanguagePicker = true
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "globe")
                                Text("Seleccionar Idioma")
                            }
                            .font(.worldCupHeadline)
                            .foregroundColor(.wc_textPrimary)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.wc_canIceBlue)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .accessibilityLabel("Seleccionar idioma")
                        .accessibilityHint("Doble toque para abrir el selector de idioma")
                        
                        Spacer()
                    }
                } else {
                    // Lista de preguntas FAQ
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Indicador de idioma actual
                            HStack {
                                Text("Idioma: \(viewModel.selectedLanguage?.name ?? "")")
                                    .font(.worldCupCaption)
                                    .foregroundColor(.wc_textSecondary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                            
                            // Lista de preguntas
                            if viewModel.currentFAQs.isEmpty {
                                // Estado vacío
                                VStack(spacing: 20) {
                                    Image(systemName: "questionmark.circle")
                                        .font(.system(size: 50))
                                        .foregroundColor(.wc_textSecondary)
                                        .accessibilityHidden(true)
                                    
                                    Text("No hay preguntas disponibles")
                                        .font(.worldCupHeadline)
                                        .foregroundColor(.wc_textPrimary)
                                    
                                    Text("Este idioma aún no tiene preguntas frecuentes configuradas")
                                        .font(.worldCupCaption)
                                        .foregroundColor(.wc_textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(24)
                                .canadaGlassCard(cornerRadius: 20)
                                .padding(.horizontal, 20)
                            } else {
                                ForEach(viewModel.currentFAQs) { item in
                                    VStack(spacing: 0) {
                                        // Botón de pregunta
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                viewModel.toggleQuestion(item)
                                            }
                                        }) {
                                            HStack(spacing: 12) {
                                                Text(item.q)
                                                    .font(.worldCupHeadline)
                                                    .foregroundColor(.wc_textPrimary)
                                                    .multilineTextAlignment(.leading)
                                                
                                                Spacer()
                                                
                                                Image(systemName: viewModel.expandedAnswerID == item.id ? "chevron.up" : "chevron.down")
                                                    .font(.worldCupCaption)
                                                    .foregroundColor(.wc_canIceBlue)
                                            }
                                            .padding(20)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .canadaGlassCard(cornerRadius: 20)
                                        .accessibilityLabel("Pregunta: \(item.q)")
                                        .accessibilityHint(viewModel.expandedAnswerID == item.id ? "Doble toque para ocultar la respuesta" : "Doble toque para ver la respuesta")
                                        
                                        // Respuesta expandible
                                        if viewModel.expandedAnswerID == item.id {
                                            VStack(alignment: .leading, spacing: 12) {
                                                Divider()
                                                    .background(Color.wc_textSecondary.opacity(0.3))
                                                
                                                Text(item.a)
                                                    .font(.worldCupBody)
                                                    .foregroundColor(.wc_textPrimary)
                                                    .multilineTextAlignment(.leading)
                                            }
                                            .padding(20)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.wc_canIce.opacity(0.2))
                                            )
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                            .accessibilityLabel("Respuesta: \(item.a)")
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle("Asistente")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityLabel("Asistente Multilingüe")
        .onAppear {
            // Si no hay idioma seleccionado, mostrar el selector automáticamente
            if viewModel.selectedLanguage == nil {
                showLanguagePicker = true
            }
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerView(
                languages: viewModel.languages,
                onSelect: { language in
                    viewModel.selectLanguage(language)
                }
            )
        }
    }
}

#Preview { 
    NavigationStack {
        ChatAssistantView()
    }
}

