import SwiftUI
import AVFoundation

struct NarratorView: View {
    @StateObject private var elevenLabsService = ElevenLabsService()
    @StateObject private var audioPlayer = AudioPlayerManager()
    @StateObject private var matchDataService = MatchDataService()
    @StateObject private var captions = CaptionStore()
    
    @State private var selectedCategory: MatchStatus = .live
    @State private var selectedMatch: Match?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var availableVoices: [VoiceConfig] = []
    @State private var selectedVoiceId: String = ElevenLabsVoicesConfig.defaultVoiceId
    @State private var showCaptionHistory = false
    
    // Para sincronización de subtítulos con el audio
    @State private var subtitleSchedule: [(startTime: TimeInterval, text: String)] = []
    @State private var subtitleTimer: Timer?
    @State private var lastSubtitleIndex: Int = -1
    
    var body: some View {
        ZStack {
            Color.routeDarkGreen.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Título
                Text("Narrador Universal")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.routeText)
                    .padding(.top)
                    .padding(.bottom, 8)
                    .accessibilityAddTraits(.isHeader)
                
                // Selector de categorías
                Picker("Categoría", selection: $selectedCategory) {
                    Text("En vivo").tag(MatchStatus.live)
                    Text("Próximamente").tag(MatchStatus.upcoming)
                    Text("Anteriores").tag(MatchStatus.previous)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 16)
                .accessibilityLabel("Selector de categoría de partidos")
                .accessibilityHint("Desliza para cambiar entre En vivo, Próximamente y Anteriores")
                .onChange(of: selectedCategory) { _ in
                    selectedMatch = nil
                    audioPlayer.stop()
                    captions.clear()
                    stopSubtitleSync()
                    lastSubtitleIndex = -1
                }
                
                // Observar el tiempo del audio para sincronizar subtítulos
                .onChange(of: audioPlayer.currentTime) { newTime in
                    syncSubtitlesWithAudio(currentTime: newTime)
                }
                
                .onChange(of: audioPlayer.isPlaying) { isPlaying in
                    if !isPlaying {
                        // Si se pausa, no hacer nada (los subtítulos se mantienen)
                        // Si se detiene, limpiar subtítulos
                        if audioPlayer.currentTime == 0 {
                            captions.clear()
                            stopSubtitleSync()
                            lastSubtitleIndex = -1
                        }
                    }
                }
                
                // Toggle de haptics
                HStack {
                    Toggle("Haptics", isOn: $captions.enableHaptics)
                        .toggleStyle(.switch)
                        .tint(.accessibleLime)
                        .accessibilityLabel("Haptics")
                        .accessibilityHint("Activa o desactiva las vibraciones al recibir eventos de alta intensidad")
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Lista de partidos - Siempre visible con padding dinámico
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(matchDataService.getMatches(for: selectedCategory)) { match in
                            MatchCard(
                                match: match,
                                isSelected: selectedMatch?.id == match.id,
                                onSelect: {
                                    selectedMatch = match
                                    audioPlayer.stop()
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    // Padding inferior dinámico para que el contenido no quede oculto detrás de los controles
                    .padding(.bottom, (selectedMatch?.isActive == true) ? 300 : 20)
                }
                
                // Mensaje para partidos no activos
                if let match = selectedMatch, !match.isActive {
                    VStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundColor(.routeMuted)
                            .accessibilityHidden(true)
                        Text("Este partido aún no está disponible")
                            .font(.headline)
                            .foregroundColor(.routeText)
                        Text("Solo los partidos marcados están disponibles para narración")
                            .font(.caption)
                            .foregroundColor(.routeMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .liquidGlass(intensity: .medium, cornerRadius: 16, padding: 0)
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Este partido aún no está disponible. Solo los partidos marcados están disponibles para narración")
                }
            }
            
            // Controles de audio como overlay flotante - NO empujan el contenido
            VStack {
                Spacer()
                
                if let match = selectedMatch, match.isActive {
                    VStack(spacing: 12) {
                        // Información del partido seleccionado
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(match.displayName)
                                    .font(.headline)
                                    .foregroundColor(.routeText)
                                    .accessibilityAddTraits(.isHeader)
                                Text(match.fullInfo)
                                    .font(.caption)
                                    .foregroundColor(.routeMuted)
                            }
                            Spacer()
                            
                            // Indicador de estado
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(match.status == .live ? Color.red : Color.gray)
                                    .frame(width: 8, height: 8)
                                Text(match.status.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.routeMuted)
                            }
                            .accessibilityLabel("Estado: \(match.status.rawValue)")
                            .accessibilityHidden(true)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .liquidGlass(intensity: .medium, cornerRadius: 16, padding: 0)
                        .padding(.horizontal)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Partido seleccionado: \(match.displayName), \(match.fullInfo), Estado \(match.status.rawValue)")
                        
                        // Selector de voz
                        if !availableVoices.isEmpty {
                            Picker("Idioma / Language", selection: $selectedVoiceId) {
                                ForEach(availableVoices) { voice in
                                    Text(voice.name).tag(voice.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .liquidGlass(intensity: .medium, cornerRadius: 12, padding: 0)
                            .foregroundColor(.routeText)
                            .padding(.horizontal)
                            .onChange(of: selectedVoiceId) { newVoiceId in
                                print("Voz seleccionada cambiada a: \(newVoiceId)")
                                if audioPlayer.isPlaying {
                                    audioPlayer.stop()
                                }
                            }
                            .accessibilityLabel("Selector de idioma para la narración")
                            .accessibilityHint("Toca para elegir el idioma de la narración: Español, Inglés o Francés")
                        }
                        
                        // Botones de control
                        HStack(spacing: 20) {
                            // Botón Generar Audio
                            Button(action: generateAudio) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "waveform")
                                    }
                                    Text(isLoading ? "Generando..." : "Iniciar Narración")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isLoading ? Color.gray : Color.accessibleLime)
                                .foregroundColor(isLoading ? .white : .routeDarkGreen)
                                .cornerRadius(12)
                                .font(.headline)
                            }
                            .disabled(isLoading)
                            .accessibilityLabel(isLoading ? "Generando narración de audio" : "Iniciar narración")
                            .accessibilityHint(isLoading ? "Por favor espera mientras se genera el audio" : "Toca para generar y reproducir la narración del partido seleccionado")
                            
                            // Botones de reproducción
                            if audioPlayer.duration > 0 {
                                Button(action: {
                                    if audioPlayer.isPlaying {
                                        audioPlayer.pause()
                                    } else {
                                        audioPlayer.play()
                                    }
                                }) {
                                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.accessibleLime)
                                }
                                .accessibilityLabel(audioPlayer.isPlaying ? "Pausar narración" : "Reproducir narración")
                                .accessibilityHint(audioPlayer.isPlaying ? "Toca para pausar la narración en reproducción" : "Toca para reanudar la narración")
                                
                                Button(action: {
                                    audioPlayer.stop()
                                    captions.clear()
                                }) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.accessibleLime)
                                }
                                .accessibilityLabel("Detener narración")
                                .accessibilityHint("Toca para detener completamente la narración")
                            }
                        }
                        .padding(.horizontal)
                        
                        // Barra de progreso del audio con indicador "En vivo"
                        if audioPlayer.duration > 0 {
                            VStack(spacing: 8) {
                                ProgressView(value: audioPlayer.currentTime, total: audioPlayer.duration)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .accessibleLime))
                                    .accessibilityLabel("Progreso de la narración")
                                    .accessibilityValue("Reproduciendo en vivo")
                                
                                // Indicador "En vivo" en lugar de tiempos
                                HStack {
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 8, height: 8)
                                            .accessibilityHidden(true)
                                        Text("En vivo")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.routeText)
                                    }
                                    Spacer()
                                }
                                .accessibilityLabel("Narración en vivo")
                                .accessibilityHidden(true)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .liquidGlass(intensity: .medium, cornerRadius: 20, padding: 0)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .background(
                        Color.routeDarkGreen
                            .ignoresSafeArea(edges: .bottom)
                    )
                }
            }
            
            // Botón "Ver todos" flotante - Solo visible cuando hay narración activa o subtítulos disponibles
            if let match = selectedMatch, match.isActive, (audioPlayer.isPlaying || audioPlayer.duration > 0 || !captions.lines.isEmpty) {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showCaptionHistory = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "text.bubble.fill")
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Ver todos")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    
                                    // Mostrar el texto actual si hay subtítulos
                                    if let currentText = captions.lines.last?.text, !currentText.isEmpty {
                                        Text(currentText)
                                            .font(.caption2)
                                            .fontWeight(.regular)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .foregroundColor(.routeDarkGreen.opacity(0.8))
                                    }
                                }
                            }
                            .foregroundColor(.routeDarkGreen)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .liquidGlass(intensity: .medium, cornerRadius: 20, padding: 0)
                            .overlay(
                                Capsule()
                                    .stroke(Color.accessibleLime, lineWidth: 2)
                            )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, (selectedMatch?.isActive == true) ? 280 : 20)
                        .accessibilityLabel(captions.lines.isEmpty ? "Ver todos los subtítulos" : "Ver todos los subtítulos. Texto actual: \(captions.lines.last?.text ?? "")")
                        .accessibilityHint("Doble toque para abrir la pantalla completa con todos los subtítulos")
                    }
                }
            }
        }
        .navigationTitle("Narrador")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityLabel("Narrador Universal")
            .onAppear {
                loadVoices()
            }
            .sheet(isPresented: $showCaptionHistory) {
                CaptionHistoryView(store: captions)
            }
        }
    
    private func generateAudio() {
        guard let match = selectedMatch, match.isActive else { return }
        
        // Verificar que la API key esté configurada
        if ElevenLabsConfig.apiKey == "TU_API_KEY_AQUI" {
            errorMessage = "Por favor configura tu API key en ElevenLabsConfig.swift"
            return
        }
        
        // Verificar que hay una voz seleccionada válida
        guard !selectedVoiceId.isEmpty else {
            errorMessage = "Por favor selecciona un idioma para la narración"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Limpiar subtítulos anteriores
        captions.clear()
        
        // Obtener el script completo del archivo (el mismo que usará ElevenLabs)
        let fullScript = match.narrationScript
        
        // Parsear el script para preparar los segmentos de subtítulos
        let scriptSegments = ScriptParser.parseScript(fullScript)
        
        // Debug: mostrar qué voz se está usando y verificar el script
        print("Generando audio con voz ID: \(selectedVoiceId)")
        print("Script completo tiene \(fullScript.count) caracteres")
        print("Script dividido en \(scriptSegments.count) segmentos")
        print("⚠️ Estimación de créditos: ~\(Int(Double(fullScript.count) * 1.2)) créditos (modelo turbo)")
        if let selectedVoice = availableVoices.first(where: { $0.id == selectedVoiceId }) {
            print("Voz seleccionada: \(selectedVoice.name) (\(selectedVoice.language))")
        }
        
        Task {
            do {
                // Usar exactamente el mismo texto del archivo para ElevenLabs
                // Usando modelo turbo optimizado para reducir consumo de créditos
                let audioData = try await elevenLabsService.textToSpeech(
                    text: fullScript,
                    voiceId: selectedVoiceId
                )
                
                await MainActor.run {
                    isLoading = false
                    do {
                        // Preparar el audio player para obtener la duración real
                        let player = try AVAudioPlayer(data: audioData)
                        player.prepareToPlay()
                        let audioDuration = player.duration
                        
                        // Ahora programar los subtítulos con la duración real del audio
                        scheduleSubtitles(from: scriptSegments, audioDuration: audioDuration)
                        
                        // Mostrar el primer subtítulo inmediatamente al inicio
                        if let firstSegment = scriptSegments.first {
                            captions.push(text: firstSegment.trimmingCharacters(in: .whitespaces), keepPrevious: true)
                            lastSubtitleIndex = 0
                        }
                        
                        // Reproducir el audio
                        try audioPlayer.playAudio(from: audioData)
                    } catch {
                        errorMessage = "Error al reproducir audio: \(error.localizedDescription)"
                        // Limpiar subtítulos si falla la reproducción
                        captions.clear()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Error al generar audio: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Programa los subtítulos basándose en los segmentos del script y la duración real del audio
    /// Ahora usa un sistema de sincronización basado en currentTime del audio player
    private func scheduleSubtitles(from segments: [String], audioDuration: TimeInterval) {
        guard !segments.isEmpty, audioDuration > 0 else { 
            print("⚠️ No se pueden programar subtítulos: segmentos=\(segments.count), duración=\(audioDuration)")
            return 
        }
        
        // Limpiar subtítulos anteriores y el timer
        stopSubtitleSync()
        captions.clear()
        lastSubtitleIndex = -1
        
        // Calcular la longitud total del texto (en caracteres) - usar el mismo texto que ElevenLabs
        let totalLength = segments.reduce(0) { $0 + $1.count }
        guard totalLength > 0 else { 
            print("⚠️ Longitud total del texto es 0")
            return 
        }
        
        print("📝 Programando \(segments.count) subtítulos:")
        print("   - Duración total del audio: \(String(format: "%.2f", audioDuration)) segundos")
        print("   - Longitud total del texto: \(totalLength) caracteres")
        
        // Calcular el tiempo acumulado proporcionalmente
        var accumulatedTime: TimeInterval = 0.0
        var schedule: [(startTime: TimeInterval, text: String)] = []
        
        for (index, segment) in segments.enumerated() {
            // Calcular la proporción de este segmento respecto al total (basado en caracteres)
            let segmentProportion = Double(segment.count) / Double(totalLength)
            
            // Calcular la duración de este segmento basándose en la proporción
            let segmentDuration = audioDuration * segmentProportion
            
            // El tiempo de inicio es el tiempo acumulado hasta ahora
            let startTime = accumulatedTime
            
            let segmentText = segment.trimmingCharacters(in: .whitespaces) // Limpiar espacios
            schedule.append((startTime: startTime, text: segmentText))
            
            print("   - Subtítulo \(index + 1): aparece en \(String(format: "%.2f", startTime))s, dura \(String(format: "%.2f", segmentDuration))s")
            print("     Texto: \(segmentText.prefix(50))...")
            
            // Acumular tiempo para el siguiente segmento
            accumulatedTime += segmentDuration
        }
        
        // Guardar el schedule para sincronización en tiempo real
        subtitleSchedule = schedule
        
        print("✅ Programados \(segments.count) subtítulos correctamente")
    }
    
    /// Sincroniza los subtítulos con el tiempo actual del audio
    /// Solo muestra el subtítulo que se está diciendo actualmente, no el próximo
    /// Los subtítulos pasados se mantienen en el historial para el scroll
    private func syncSubtitlesWithAudio(currentTime: TimeInterval) {
        guard !subtitleSchedule.isEmpty, audioPlayer.isPlaying else { return }
        
        // Encontrar el subtítulo que debería estar visible en este momento
        // Buscar el último subtítulo cuyo startTime sea <= currentTime
        var currentSubtitleIndex = -1
        
        for (index, item) in subtitleSchedule.enumerated() {
            if item.startTime <= currentTime {
                currentSubtitleIndex = index
            } else {
                break
            }
        }
        
        // Si encontramos un subtítulo que debería estar visible
        if currentSubtitleIndex >= 0 {
            let currentSubtitle = subtitleSchedule[currentSubtitleIndex]
            
            // Verificar si este subtítulo ya está en el historial
            let isInHistory = captions.lines.contains { $0.text == currentSubtitle.text }
            
            // Si es un nuevo subtítulo (avanzó al siguiente)
            if currentSubtitleIndex > lastSubtitleIndex {
                // Agregar el nuevo subtítulo al historial
                // No limpiar los anteriores, así se mantienen en el historial
                captions.push(text: currentSubtitle.text, keepPrevious: true)
                lastSubtitleIndex = currentSubtitleIndex
            } else if currentSubtitleIndex == lastSubtitleIndex {
                // Es el mismo subtítulo, asegurar que esté visible en el historial
                // Si por alguna razón no está visible (por ejemplo, fue eliminado por TTL), agregarlo de nuevo
                if !isInHistory {
                    captions.push(text: currentSubtitle.text, keepPrevious: true)
                }
            }
            // El subtítulo actual permanece visible hasta que el siguiente comience
        } else {
            // No hay subtítulo activo en este momento (puede pasar antes del primer subtítulo o al final)
            // Si estamos después del inicio y hay un subtítulo anterior, mantenerlo visible
            if currentTime > 0 && lastSubtitleIndex >= 0 && lastSubtitleIndex < subtitleSchedule.count {
                let lastSubtitle = subtitleSchedule[lastSubtitleIndex]
                let isInHistory = captions.lines.contains { $0.text == lastSubtitle.text }
                if !isInHistory {
                    // Re-agregar el último subtítulo si fue eliminado
                    captions.push(text: lastSubtitle.text, keepPrevious: true)
                }
            } else if currentTime >= 0 && !subtitleSchedule.isEmpty {
                // Si estamos al inicio (currentTime >= 0) y hay subtítulos, mostrar el primero
                let firstSubtitle = subtitleSchedule[0]
                let isInHistory = captions.lines.contains { $0.text == firstSubtitle.text }
                if !isInHistory {
                    captions.push(text: firstSubtitle.text, keepPrevious: true)
                    lastSubtitleIndex = 0
                }
            }
        }
    }
    
    /// Detiene la sincronización de subtítulos
    private func stopSubtitleSync() {
        subtitleTimer?.invalidate()
        subtitleTimer = nil
        subtitleSchedule.removeAll()
    }
    
    private func loadVoices() {
        // Cargar las voces predefinidas desde la configuración
        availableVoices = ElevenLabsVoicesConfig.voices
        
        // Si no hay voces configuradas o están con valores por defecto, mostrar mensaje
        if availableVoices.isEmpty || availableVoices.first?.id.contains("AGREGAR_ID") == true {
            // Si no están configuradas, usar voces por defecto (opcional)
            // Por ahora, simplemente no cargamos nada
            return
        }
        
        // Establecer la primera voz como seleccionada por defecto solo si no hay una seleccionada
        if selectedVoiceId.isEmpty || selectedVoiceId.contains("AGREGAR_ID") || !availableVoices.contains(where: { $0.id == selectedVoiceId }) {
            selectedVoiceId = availableVoices.first?.id ?? ""
        }
        
        // Debug: mostrar voces cargadas
        print("Voces cargadas: \(availableVoices.map { "\($0.name): \($0.id)" }.joined(separator: ", "))")
        print("Voz seleccionada por defecto: \(selectedVoiceId)")
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
}

// Componente para la tarjeta de partido
struct MatchCard: View {
    let match: Match
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Indicador de estado
                VStack {
                    Circle()
                        .fill(match.status == .live ? Color.red : Color.gray)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .accessibilityHidden(true)
                    if match.status == .live {
                        Text("LIVE")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.red)
                            .accessibilityHidden(true)
                    }
                }
                
                // Información del partido
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.displayName)
                        .font(.headline)
                        .foregroundColor(.routeText)
                    
                    Text(match.fullInfo)
                        .font(.caption)
                        .foregroundColor(.routeMuted)
                }
                
                Spacer()
                
                // Icono de play (siempre visible, pero con color diferente si no está activo)
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(match.isActive ? .accessibleLime : .routeMuted)
                    .accessibilityHidden(true)
                
                // Indicador de selección
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accessibleLime)
                        .accessibilityHidden(true)
                }
            }
            .padding()
            .liquidGlass(intensity: isSelected ? .heavy : .medium, cornerRadius: 12, padding: 0)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accessibleLime : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(buildAccessibilityLabel())
        .accessibilityHint(buildAccessibilityHint())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private func buildAccessibilityLabel() -> String {
        var label = "Partido: \(match.displayName). \(match.fullInfo)."
        if match.status == .live {
            label += " En vivo."
        } else {
            label += " \(match.status.rawValue)."
        }
        if isSelected {
            label += " Seleccionado."
        }
        if match.isActive {
            label += " Disponible para narración."
        } else {
            label += " No disponible aún."
        }
        return label
    }
    
    private func buildAccessibilityHint() -> String {
        if match.isActive {
            return "Doble toque para seleccionar este partido y comenzar la narración"
        } else {
            return "Este partido aún no está disponible para narración"
        }
    }
}

#Preview {
    NavigationStack {
        NarratorView()
    }
}

