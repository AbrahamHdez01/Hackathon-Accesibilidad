import SwiftUI

// MARK: - Narration Transcript View (usando el orquestador)
struct NarrationTranscriptView: View {
    @ObservedObject var orchestrator: NarrationOrchestrator
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.routeDarkGreen.ignoresSafeArea()
                
                if orchestrator.visibleScripts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 60))
                            .foregroundColor(.routeMuted)
                            .accessibilityHidden(true)
                        
                        Text("No hay subtítulos aún")
                            .font(.headline)
                            .foregroundColor(.routeText)
                        
                        Text("Los subtítulos aparecerán aquí cuando comience la narración")
                            .font(.subheadline)
                            .foregroundColor(.routeMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("No hay subtítulos aún. Los subtítulos aparecerán aquí cuando comience la narración")
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 16) {
                                ForEach(Array(orchestrator.visibleScripts.enumerated()), id: \.element.id) { index, segment in
                                    NarrationTranscriptRow(
                                        segment: segment,
                                        isCurrent: index == orchestrator.currentLineIndex,
                                        currentRange: index == orchestrator.currentLineIndex ? orchestrator.currentRange : nil,
                                        orchestrator: orchestrator
                                    )
                                    .id(segment.id)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .onChange(of: orchestrator.currentLineIndex) { _ in
                            // Auto-scroll a la línea actual
                            if orchestrator.currentLineIndex < orchestrator.visibleScripts.count {
                                let currentId = orchestrator.visibleScripts[orchestrator.currentLineIndex].id
                                withAnimation {
                                    proxy.scrollTo(currentId, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Subtítulos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.accessibleLime)
                }
            }
            .accessibilityLabel("Pantalla de subtítulos completos")
        }
    }
}

// MARK: - Narration Transcript Row
struct NarrationTranscriptRow: View {
    let segment: NarrationSegment
    let isCurrent: Bool
    let currentRange: NSRange?
    let orchestrator: NarrationOrchestrator
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Indicador de línea actual
            if isCurrent {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accessibleLime)
                    .frame(width: 4)
                    .padding(.top, 4)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Texto principal con subrayado dinámico
                if isCurrent, let range = currentRange {
                    // Usar AttributedText para mostrar el subrayado
                    AttributedText(
                        attributedString: orchestrator.attributedCurrentLine(
                            full: segment.text,
                            range: range
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(segment.text)
                        .font(.system(.body, design: .rounded, weight: isCurrent ? .semibold : .medium))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(isCurrent ? .routeText : .routeMuted)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isCurrent ? Color.routePanelGreen.opacity(0.8) : Color.routePanelGreen)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isCurrent ? Color.accessibleLime.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(segment.text)
        .accessibilityAddTraits(isCurrent ? .isSelected : [])
    }
}

