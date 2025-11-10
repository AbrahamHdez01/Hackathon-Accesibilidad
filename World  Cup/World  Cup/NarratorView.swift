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
    
    // Sintetizador nativo como fallback por idioma
    @State private var nativeSynthesizer: AVSpeechSynthesizer?
    
    var body: some View {
        ZStack {
            // Fondo con gradiente USA (Navy profundo)
            LinearGradient.usaBackground
                .ignoresSafeArea()
            
            // Micro-estrellas difuminadas
            StarsPattern()
                .opacity(0.3)
                .ignoresSafeArea()
            
            // Banda diagonal "broadcast"
            BroadcastBand()
                .opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Título
                Text("Narrador Universal")
                    .font(.worldCupTitle)
                    .foregroundColor(.wc_textPrimary)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    .accessibilityAddTraits(.isHeader)
                
                // Selector de categorías con estilo mejorado
                Picker("Categoría", selection: $selectedCategory) {
                    Text("En vivo").tag(MatchStatus.live)
                    Text("Próximamente").tag(MatchStatus.upcoming)
                    Text("Anteriores").tag(MatchStatus.previous)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
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
                
                // Toggle de haptics con estilo mejorado
                HStack {
                    Toggle("Haptics", isOn: $captions.enableHaptics)
                        .toggleStyle(.switch)
                        .tint(.wc_usaRed)
                        .accessibilityLabel("Haptics")
                        .accessibilityHint("Activa o desactiva las vibraciones al recibir eventos de alta intensidad")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                
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
                    VStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundColor(.wc_textSecondary)
                            .accessibilityHidden(true)
                        Text("Este partido aún no está disponible")
                            .font(.worldCupHeadline)
                            .foregroundColor(.wc_textPrimary)
                        Text("Solo los partidos marcados están disponibles para narración")
                            .font(.worldCupCaption)
                            .foregroundColor(.wc_textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .usaGlassCard(cornerRadius: 20)
                    .padding(.horizontal, 20)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Este partido aún no está disponible. Solo los partidos marcados están disponibles para narración")
                }
            }
            
            // Controles de audio como overlay flotante - NO empujan el contenido
            VStack {
                Spacer()
                
                if let match = selectedMatch, match.isActive {
                    VStack(spacing: 16) {
                        // Información del partido seleccionado
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(match.displayName)
                                    .font(.worldCupHeadline)
                                    .foregroundColor(.wc_textPrimary)
                                    .accessibilityAddTraits(.isHeader)
                                Text(match.fullInfo)
                                    .font(.worldCupCaption)
                                    .foregroundColor(.wc_textSecondary)
                            }
                            Spacer()
                            
                            // Indicador de estado
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(match.status == .live ? Color.wc_statusLive : Color.wc_statusPrevious)
                                    .frame(width: 10, height: 10)
                                Text(match.status.rawValue)
                                    .font(.worldCupCaption)
                                    .foregroundColor(.wc_textSecondary)
                            }
                            .accessibilityLabel("Estado: \(match.status.rawValue)")
                            .accessibilityHidden(true)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .usaGlassCard(cornerRadius: 20)
                        .padding(.horizontal, 20)
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
                            .usaGlassCard(cornerRadius: 16)
                            .foregroundColor(.wc_textPrimary)
                            .padding(.horizontal, 20)
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
                        HStack(spacing: 16) {
                            // Botón Generar Audio
                            Button(action: generateAudio) {
                                HStack(spacing: 8) {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "waveform")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    Text(isLoading ? "Generando..." : "Iniciar Narración")
                                        .font(.worldCupHeadline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isLoading ? Color.gray.opacity(0.6) : Color.wc_usaRed)
                                .foregroundColor(.wc_usaWhite)
                                .cornerRadius(16)
                            }
                            .disabled(isLoading)
                            .accessibilityLabel(isLoading ? "Generando narración de audio" : "Iniciar narración")
                            .accessibilityHint(isLoading ? "Por favor espera mientras se genera el audio" : "Toca para generar y reproducir la narración del partido seleccionado")
                            
                            // Botones de reproducción
                            if audioPlayer.duration > 0 {
                                Button(action: {
                                    withAnimation(.spring()) {
                                        if audioPlayer.isPlaying {
                                            audioPlayer.pause()
                                        } else {
                                            audioPlayer.play()
                                        }
                                    }
                                }) {
                                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 44))
                                        .foregroundColor(.wc_usaRed)
                                }
                                .accessibilityLabel(audioPlayer.isPlaying ? "Pausar narración" : "Reproducir narración")
                                .accessibilityHint(audioPlayer.isPlaying ? "Toca para pausar la narración en reproducción" : "Toca para reanudar la narración")
                                
                                Button(action: {
                                    withAnimation(.spring()) {
                                        audioPlayer.stop()
                                        captions.clear()
                                    }
                                }) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.system(size: 44))
                                        .foregroundColor(.wc_usaRed)
                                }
                                .accessibilityLabel("Detener narración")
                                .accessibilityHint("Toca para detener completamente la narración")
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Barra de progreso del audio con indicador "En vivo"
                        if audioPlayer.duration > 0 {
                            VStack(spacing: 12) {
                                ProgressView(value: audioPlayer.currentTime, total: audioPlayer.duration)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .wc_usaRed))
                                    .accessibilityLabel("Progreso de la narración")
                                    .accessibilityValue("Reproduciendo en vivo")
                                
                                // Indicador "En vivo" en lugar de tiempos
                                HStack {
                                    Spacer()
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color.wc_statusLive)
                                            .frame(width: 10, height: 10)
                                            .accessibilityHidden(true)
                                        Text("En vivo")
                                            .font(.worldCupCaption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.wc_textPrimary)
                                    }
                                    Spacer()
                                }
                                .accessibilityLabel("Narración en vivo")
                                .accessibilityHidden(true)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                    .usaGlassCard(cornerRadius: 24)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient.usaBackground
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
                            HStack(spacing: 10) {
                                Image(systemName: "text.bubble.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Ver todos")
                                        .font(.worldCupCaption)
                                        .fontWeight(.semibold)
                                    
                                    // Mostrar el texto actual si hay subtítulos
                                    if let currentText = captions.lines.last?.text, !currentText.isEmpty {
                                        Text(currentText)
                                            .font(.system(size: 11))
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .foregroundColor(.wc_textSecondary)
                                    }
                                }
                            }
                            .foregroundColor(.wc_textPrimary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .usaGlassCard(cornerRadius: 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.wc_usaRed, lineWidth: 2)
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
        
        // Determinar idioma de la voz seleccionada
        let voiceLang = availableVoices.first(where: { $0.id == selectedVoiceId })?.language.lowercased() ?? "es"
        
        // Cargar script localizado según la voz seleccionada (si existe), si no, usar por defecto
        let localized = loadLocalizedScript(baseKey: match.scriptKey, language: voiceLang)
        let fullScript = localized ?? match.narrationScript
        
        // Parsear el script para preparar los segmentos de subtítulos
        let scriptSegments = ScriptParser.parseScript(fullScript)
        
        // Debug: mostrar qué voz se está usando y verificar el script
        print("Generando audio con voz ID: \(selectedVoiceId)")
        print("Script completo tiene \(fullScript.count) caracteres")
        print("Script dividido en \(scriptSegments.count) segmentos")
        print("⚠️ Estimación de créditos: ~\(Int(Double(fullScript.count) * 1.2)) créditos (modelo turbo)")
        if let selectedVoice = availableVoices.first(where: { $0.id == selectedVoiceId }) {
            print("Voz seleccionada: \(selectedVoice.name) (\(selectedVoice.language))")
            if match.scriptKey.isEmpty {
                print("ℹ️ scriptKey vacío en el partido, se usará el guion base.")
            } else if localized == nil && selectedVoice.language.lowercased() != "es" {
                print("⚠️ No se encontró guion localizado para \(match.scriptKey)_\(selectedVoice.language.lowercased()).txt. Usando español base.")
            } else if localized != nil {
                print("✅ Usando guion localizado: \(match.scriptKey)_\(selectedVoice.language.lowercased()).txt")
            }
        }
        
        // Fallback: si la voz elegida es EN o FR y notas español en ElevenLabs (posibles IDs no compatibles),
        // usa TTS nativo de iOS para asegurar idioma correcto, manteniendo subtítulos sincronizados de forma aproximada.
        if voiceLang == "en" || voiceLang == "fr" {
            // Detener cualquier reproducción previa
            audioPlayer.stop()
            nativeSynthesizer?.stopSpeaking(at: .immediate)
            
            // Estimar duración por idioma para sincronizar subtítulos
            let duration = estimateNativeSpeechDuration(for: fullScript, language: voiceLang)
            scheduleSubtitles(from: scriptSegments, audioDuration: duration)
            if let first = scriptSegments.first {
                captions.push(text: first.trimmingCharacters(in: .whitespaces), keepPrevious: true)
                lastSubtitleIndex = 0
            }
            
            // Lanzar TTS nativo
            let synth = AVSpeechSynthesizer()
            nativeSynthesizer = synth
            let utterance = AVSpeechUtterance(string: fullScript)
            utterance.voice = AVSpeechSynthesisVoice(language: voiceLang == "en" ? "en-US" : "fr-FR")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.52 // ritmo cómodo
            utterance.pitchMultiplier = 1.0
            utterance.postUtteranceDelay = 0.0
            synth.speak(utterance)
            isLoading = false
            return
        }
        
        Task {
            do {
                // Usar exactamente el mismo texto cargado para ElevenLabs
                let audioData = try await elevenLabsService.textToSpeech(
                    text: fullScript,
                    voiceId: selectedVoiceId
                )
                
                await MainActor.run {
                    isLoading = false
                    do {
                        let player = try AVAudioPlayer(data: audioData)
                        player.prepareToPlay()
                        let audioDuration = player.duration
                        scheduleSubtitles(from: scriptSegments, audioDuration: audioDuration)
                        if let firstSegment = scriptSegments.first {
                            captions.push(text: firstSegment.trimmingCharacters(in: .whitespaces), keepPrevious: true)
                            lastSubtitleIndex = 0
                        }
                        try audioPlayer.playAudio(from: audioData)
                    } catch {
                        errorMessage = "Error al reproducir audio: \(error.localizedDescription)"
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
    
    // Estimación simple de duración para TTS nativo, según WPM típico por idioma
    private func estimateNativeSpeechDuration(for text: String, language: String) -> TimeInterval {
        let words = max(1, text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count)
        let wpm: Double
        switch language {
        case "en": wpm = 160.0
        case "fr": wpm = 150.0
        default: wpm = 155.0
        }
        let minutes = Double(words) / wpm
        let seconds = minutes * 60.0
        return max(5.0, seconds)
    }
    
    /// Carga un script localizado `NarrationScripts/<baseKey>_<lang>.txt`. Fallback a `<baseKey>.txt`. Devuelve nil si no hay ninguno.
    private func loadLocalizedScript(baseKey: String, language: String) -> String? {
        let normalizedLang = ["es","en","fr","pt"].contains(language) ? language : "es"
        // 1) Intentar con sufijo de idioma
        let localizedName = "\(baseKey)_\(normalizedLang)"
        if let path = Bundle.main.path(forResource: "NarrationScripts/\(localizedName)", ofType: "txt"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            return content
        }
        // 2) Intentar sin sufijo (base)
        if let path = Bundle.main.path(forResource: "NarrationScripts/\(baseKey)", ofType: "txt"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            return content
        }
        return nil
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
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onSelect()
            }
        }) {
            HStack(spacing: 16) {
                // Indicador de estado
                VStack(spacing: 4) {
                    Circle()
                        .fill(match.status == .live ? Color.wc_statusLive : Color.wc_statusPrevious)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .accessibilityHidden(true)
                    if match.status == .live {
                        Text("LIVE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.wc_statusLive)
                            .accessibilityHidden(true)
                    }
                }
                
                // Información del partido
                VStack(alignment: .leading, spacing: 6) {
                    Text(match.displayName)
                        .font(.worldCupHeadline)
                        .foregroundColor(.wc_textPrimary)
                    
                    Text(match.fullInfo)
                        .font(.worldCupCaption)
                        .foregroundColor(.wc_textSecondary)
                }
                
                Spacer()
                
                // Icono de play (siempre visible, pero con color diferente si no está activo)
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(match.isActive ? .wc_usaRed : .wc_textTertiary)
                    .accessibilityHidden(true)
                
                // Indicador de selección
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.wc_usaRed)
                        .accessibilityHidden(true)
                }
            }
            .padding(20)
            .usaGlassCard(cornerRadius: 20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.wc_usaRed : Color.clear, lineWidth: 2)
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

