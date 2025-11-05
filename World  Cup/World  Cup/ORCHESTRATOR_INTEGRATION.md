# Integración del NarrationOrchestrator

## Archivos creados

1. **NarrationSegment.swift** - Modelo de datos para segmentos de narración
2. **NarrationOrchestrator.swift** - Orquestador que sincroniza voz + subtítulos + haptics
3. **AttributedTextHelper.swift** - Helper para mostrar texto con atributos (subrayado dinámico)
4. **NarrationTranscriptView.swift** - Vista del transcript usando el orquestador

## Cómo integrar en NarratorView (sin romper nada)

### Paso 1: Agregar el orquestador como StateObject

```swift
struct NarratorView: View {
    // ... tus StateObjects existentes ...
    @StateObject private var orchestrator = NarrationOrchestrator()
    
    // ... resto del código ...
}
```

### Paso 2: Convertir el script a NarrationSegment

Cuando cargas el script del match, conviértelo a segmentos:

```swift
private func loadScriptForMatch(_ match: Match) {
    guard let script = match.narrationScript else { return }
    
    // Parsear el script en líneas
    let lines = ScriptParser.parseScript(script)
    
    // Convertir a NarrationSegment
    let segments = lines.map { line in
        NarrationSegment(
            text: line,
            voice: getVoiceCode(for: match.language), // "es-ES", "en-US", "fr-FR"
            rate: 0.5, // Ajustar según necesidad
            pitch: 1.0
        )
    }
    
    // Cargar en el orquestador
    orchestrator.load(scripts: segments)
}
```

### Paso 3: Conectar el botón Haptics

```swift
// Reemplazar el toggle existente
Toggle("Haptics", isOn: $orchestrator.isHapticsOn)
    .toggleStyle(.switch)
    .tint(.accessibleLime)
```

### Paso 4: Conectar el botón "Ver todos"

```swift
Button(action: {
    showCaptionHistory = true
}) {
    HStack(spacing: 8) {
        Image(systemName: "text.bubble.fill")
        Text(orchestrator.subtitlesEnabled ? orchestrator.currentLineText : "Ver todos")
            .font(.caption)
            .fontWeight(.semibold)
    }
    .foregroundColor(.routeDarkGreen)
    // ... resto del estilo ...
}
```

### Paso 5: Iniciar la narración

```swift
// En lugar de usar ElevenLabs, usar el orquestador
func startNarration() {
    orchestrator.start()
}
```

### Paso 6: Usar NarrationTranscriptView en lugar de CaptionHistoryView

```swift
.sheet(isPresented: $showCaptionHistory) {
    NarrationTranscriptView(orchestrator: orchestrator)
}
```

## Ejemplo completo de integración mínima

```swift
struct NarratorView: View {
    @StateObject private var orchestrator = NarrationOrchestrator()
    @StateObject private var matchDataService = MatchDataService()
    @State private var selectedMatch: Match?
    @State private var showCaptionHistory = false
    
    var body: some View {
        VStack {
            // Toggle de haptics conectado al orquestador
            Toggle("Haptics", isOn: $orchestrator.isHapticsOn)
            
            // Botón "Ver todos"
            Button(action: { showCaptionHistory = true }) {
                Text(orchestrator.subtitlesEnabled ? orchestrator.currentLineText : "Ver todos")
            }
            
            // Botón de inicio
            Button("Iniciar") {
                if let match = selectedMatch, let script = match.narrationScript {
                    let segments = ScriptParser.parseScript(script)
                        .map { NarrationSegment(text: $0, voice: "es-ES") }
                    orchestrator.load(scripts: segments)
                    orchestrator.start()
                }
            }
        }
        .sheet(isPresented: $showCaptionHistory) {
            NarrationTranscriptView(orchestrator: orchestrator)
        }
    }
}
```

## Ventajas del orquestador

1. **Sincronización automática**: Voz + subtítulos + haptics están siempre sincronizados
2. **Lock-step**: Al activar haptics, se activan subtítulos automáticamente
3. **No mostrar futuro**: Solo se muestran las líneas que ya se han narrado
4. **Subrayado dinámico**: El texto se subraya palabra por palabra según la voz
5. **Autoscroll**: El transcript se desplaza automáticamente a la línea actual

## Notas importantes

- El orquestador usa `AVSpeechSynthesizer` (nativo de iOS), no ElevenLabs
- Si necesitas mantener ElevenLabs, puedes crear un adaptador o usar ambos sistemas
- El transcript solo muestra las líneas ya narradas (`visibleScripts`)
- Los haptics se disparan automáticamente cuando `isHapticsOn` está activo

