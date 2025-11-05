import SwiftUI

// MARK: - Caption History View
struct CaptionHistoryView: View {
    @ObservedObject var store: CaptionStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.routeDarkGreen.ignoresSafeArea()
                
                if store.lines.isEmpty {
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
                                ForEach(store.lines) { line in
                                    CaptionHistoryRow(line: line)
                                        .id(line.id)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .onChange(of: store.lines.count) { _ in
                            // Auto-scroll al último subtítulo cuando se agrega uno nuevo
                            if let lastLine = store.lines.last {
                                withAnimation {
                                    proxy.scrollTo(lastLine.id, anchor: .bottom)
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

// MARK: - Caption History Row
struct CaptionHistoryRow: View {
    let line: CaptionLine
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Barra lateral de color para alta intensidad
            if line.intensity == .high {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accessibleLime)
                    .frame(width: 4)
                    .padding(.top, 4)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // SFX (si existen)
                if !line.sfx.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(line.sfx, id: \.self) { sfx in
                            Text(sfx)
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .foregroundColor(.accessibleLime)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accessibleLime.opacity(0.2))
                                .cornerRadius(6)
                        }
                    }
                }
                
                // Texto principal con keywords resaltadas
                Text(CaptionUtilities.attributedText(for: line))
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.routeText)
                
                // Timestamp (opcional)
                Text(formatTimestamp(line.timestamp))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.routeMuted)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.routePanelGreen)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(line.intensity == .high ? Color.accessibleLime.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(buildAccessibilityLabel())
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
    private func buildAccessibilityLabel() -> String {
        var label = CaptionUtilities.accessibilityText(for: line)
        if !line.sfx.isEmpty {
            label += ". Efectos de sonido: \(line.sfx.joined(separator: ", "))"
        }
        if line.intensity == .high {
            label += ". Alta intensidad"
        }
        return label
    }
}

#Preview {
    CaptionHistoryView(store: CaptionStore())
        .onAppear {
            let store = CaptionStore()
            store.push(text: "¡Minuto 45! [Silbato] Tiro libre para México.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                store.push(text: "Centro de Lozano... remate de cabeza de Giménez ¡GOL!")
            }
        }
}

