import SwiftUI

// MARK: - Live Caption Overlay
struct LiveCaptionOverlay: View {
    @ObservedObject var store: CaptionStore
    var alignment: Alignment = .bottom
    var maxLines: Int = 3
    
    var body: some View {
        VStack {
            if alignment == .top {
                captionContent
                Spacer()
            } else {
                Spacer()
                captionContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
    
    private var captionContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(visibleLines) { line in
                CaptionLineView(line: line)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            ZStack {
                // Fondo sólido semi-transparente para mejor contraste
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.routeDarkGreen.opacity(0.95))
                
                // Material glass encima para efecto blur
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 8)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .allowsHitTesting(false) // No bloquea gestos del fondo
    }
    
    private var visibleLines: [CaptionLine] {
        Array(store.lines.suffix(maxLines))
    }
}

// MARK: - Caption Line View
struct CaptionLineView: View {
    let line: CaptionLine
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Barra lateral de color para alta intensidad
            if line.intensity == .high {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accessibleLime)
                    .frame(width: 4)
                    .padding(.top, 2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // SFX (si existen)
                if !line.sfx.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(line.sfx, id: \.self) { sfx in
                            Text(sfx)
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundColor(.accessibleLime.opacity(0.9))
                        }
                    }
                }
                
                // Texto principal con keywords resaltadas
                Text(CaptionUtilities.attributedText(for: line))
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .foregroundColor(.white) // Texto blanco para máximo contraste
            }
        }
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isVisible = true
            }
            
            // Anuncio para VoiceOver
            if UIAccessibility.isVoiceOverRunning {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UIAccessibility.post(
                        notification: .announcement,
                        argument: CaptionUtilities.accessibilityText(for: line)
                    )
                }
            }
        }
        .accessibilityLabel(CaptionUtilities.accessibilityText(for: line))
        .accessibilityAddTraits(line.intensity == .high ? .isSummaryElement : [])
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.routeDarkGreen.ignoresSafeArea()
        
        VStack {
            Spacer()
            
            LiveCaptionOverlay(
                store: CaptionStore(),
                alignment: .bottom,
                maxLines: 3
            )
        }
        .onAppear {
            let store = CaptionStore()
            store.push(text: "¡Minuto 45! [Silbato] Tiro libre para México.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                store.push(text: "Centro de Lozano... remate de cabeza de Giménez ¡GOL!")
            }
        }
    }
}

