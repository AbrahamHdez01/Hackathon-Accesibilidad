# UI/UX Design Specification - Access 2026

## 🎨 Principios de Diseño

### Accesibilidad Universal
- **WCAG 2.1 AA Compliance:** Cumplimiento completo de estándares de accesibilidad web
- **Contraste Mínimo:** Ratio de contraste 4.5:1 para texto normal, 3:1 para texto grande
- **Tamaños de Toque:** Mínimo 44x44 puntos para elementos interactivos
- **Navegación por Teclado:** Soporte completo para navegación sin mouse
- **Lectores de Pantalla:** Compatibilidad con VoiceOver (iOS) y TalkBack (Android)

### Diseño Inclusivo
- **Personalización:** Adaptación según necesidades específicas del usuario
- **Simplicidad:** Interfaz intuitiva para usuarios de todas las edades
- **Consistencia:** Patrones de diseño uniformes en toda la aplicación
- **Feedback Visual:** Confirmación clara de acciones del usuario

## 📱 Estructura de la Aplicación

### Flujo Principal de Usuario
```
Splash Screen → Onboarding → Configuración → Dashboard → Funcionalidades
```

### Pantallas Principales
1. **Splash Screen & Onboarding**
2. **Configuración de Accesibilidad**
3. **Dashboard Principal**
4. **Navegación (Pilar 1)**
5. **Narración en Vivo (Pilar 2)**
6. **Asistente Conversacional (Pilar 3)**
7. **Perfil y Configuraciones**

## 🎯 Pantalla 1: Splash Screen & Onboarding

### Splash Screen
```swift
struct SplashScreen: View {
    var body: some View {
        VStack(spacing: 30) {
            // Logo y branding
            Image("access2026_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .accessibilityLabel("Access 2026 Logo")
            
            Text("Access 2026")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("El Asistente Inclusivo del Estadio Azteca")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Indicador de carga
            ProgressView()
                .scaleEffect(1.2)
                .accessibilityLabel("Cargando aplicación")
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
```

### Onboarding - Introducción
```swift
struct OnboardingView: View {
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Página 1: Bienvenida
            OnboardingPage(
                title: "¡Bienvenido a Access 2026!",
                description: "Tu asistente personal para una experiencia completamente inclusiva en el Estadio Azteca",
                image: "stadium_welcome",
                color: .blue
            )
            .tag(0)
            
            // Página 2: Navegación
            OnboardingPage(
                title: "Navegación Accesible",
                description: "Encuentra rutas personalizadas desde el transporte público hasta tu asiento",
                image: "navigation_feature",
                color: .green
            )
            .tag(1)
            
            // Página 3: Narración IA
            OnboardingPage(
                title: "Narración Inteligente",
                description: "Disfruta del partido con narración en tiempo real adaptada a tus necesidades",
                image: "narration_feature",
                color: .orange
            )
            .tag(2)
            
            // Página 4: Asistente Multilingüe
            OnboardingPage(
                title: "Asistente Conversacional",
                description: "Habla con nuestro asistente en tu idioma preferido",
                image: "chat_feature",
                color: .purple
            )
            .tag(3)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
    }
}
```

## ⚙️ Pantalla 2: Configuración de Accesibilidad

### Configuración Principal
```swift
struct AccessibilitySetupView: View {
    @State private var selectedNeeds: Set<AccessibilityNeed> = []
    @State private var preferredLanguage = "es"
    @State private var voiceSettings = VoiceSettings()
    
    var body: some View {
        NavigationView {
            Form {
                // Sección de Necesidades de Accesibilidad
                Section(header: Text("Necesidades de Accesibilidad")) {
                    AccessibilityNeedRow(
                        need: .wheelchair,
                        isSelected: selectedNeeds.contains(.wheelchair)
                    ) { isSelected in
                        if isSelected {
                            selectedNeeds.insert(.wheelchair)
                        } else {
                            selectedNeeds.remove(.wheelchair)
                        }
                    }
                    
                    AccessibilityNeedRow(
                        need: .visualImpairment,
                        isSelected: selectedNeeds.contains(.visualImpairment)
                    ) { isSelected in
                        if isSelected {
                            selectedNeeds.insert(.visualImpairment)
                        } else {
                            selectedNeeds.remove(.visualImpairment)
                        }
                    }
                    
                    AccessibilityNeedRow(
                        need: .hearingImpairment,
                        isSelected: selectedNeeds.contains(.hearingImpairment)
                    ) { isSelected in
                        if isSelected {
                            selectedNeeds.insert(.hearingImpairment)
                        } else {
                            selectedNeeds.remove(.hearingImpairment)
                        }
                    }
                }
                
                // Sección de Idioma
                Section(header: Text("Idioma Preferido")) {
                    Picker("Idioma", selection: $preferredLanguage) {
                        Text("Español").tag("es")
                        Text("English").tag("en")
                        Text("Deutsch").tag("de")
                        Text("Français").tag("fr")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Sección de Configuración de Voz
                Section(header: Text("Configuración de Voz")) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Velocidad")
                            Spacer()
                            Text("\(Int(voiceSettings.speed * 100))%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $voiceSettings.speed, in: 0.5...2.0, step: 0.1)
                            .accessibilityLabel("Velocidad de voz")
                        
                        HStack {
                            Text("Volumen")
                            Spacer()
                            Text("\(Int(voiceSettings.volume * 100))%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $voiceSettings.volume, in: 0.0...1.0, step: 0.1)
                            .accessibilityLabel("Volumen de voz")
                    }
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Continuar") {
                        // Guardar configuración y continuar
                        saveConfiguration()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct AccessibilityNeedRow: View {
    let need: AccessibilityNeed
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: need.icon)
                .foregroundColor(need.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(need.title)
                    .font(.headline)
                Text(need.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isSelected },
                set: onToggle
            ))
            .accessibilityLabel("Activar \(need.title)")
        }
        .padding(.vertical, 4)
    }
}
```

## 🏠 Pantalla 3: Dashboard Principal

### Dashboard
```swift
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingNavigation = false
    @State private var showingNarration = false
    @State private var showingChat = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header con información del usuario
                    UserHeaderView(user: viewModel.currentUser)
                    
                    // Tarjetas de funcionalidades principales
                    VStack(spacing: 16) {
                        FeatureCard(
                            title: "Navegación Accesible",
                            description: "Encuentra rutas personalizadas",
                            icon: "map.fill",
                            color: .blue,
                            action: { showingNavigation = true }
                        )
                        
                        FeatureCard(
                            title: "Narración en Vivo",
                            description: "Disfruta del partido con IA",
                            icon: "speaker.wave.3.fill",
                            color: .orange,
                            action: { showingNarration = true }
                        )
                        
                        FeatureCard(
                            title: "Asistente Conversacional",
                            description: "Habla con nuestro asistente",
                            icon: "message.fill",
                            color: .green,
                            action: { showingChat = true }
                        )
                    }
                    
                    // Información del partido actual
                    if let match = viewModel.currentMatch {
                        MatchInfoCard(match: match)
                    }
                    
                    // Accesos rápidos
                    QuickActionsView()
                }
                .padding()
            }
            .navigationTitle("Access 2026")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { /* Mostrar perfil */ }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showingNavigation) {
            NavigationView()
        }
        .sheet(isPresented: $showingNarration) {
            LiveNarrationView()
        }
        .sheet(isPresented: $showingChat) {
            ChatAssistantView()
        }
    }
}

struct FeatureCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title): \(description)")
        .accessibilityHint("Toca para abrir")
    }
}
```

## 🗺️ Pantalla 4: Navegación (Pilar 1)

### Vista de Navegación
```swift
struct NavigationView: View {
    @StateObject private var viewModel = NavigationViewModel()
    @State private var showingRouteDetails = false
    @State private var selectedRoute: Route?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Mapa o vista de navegación
                NavigationMapView(
                    route: viewModel.currentRoute,
                    userLocation: viewModel.userLocation
                )
                .frame(maxHeight: .infinity)
                
                // Panel inferior con instrucciones
                if let route = viewModel.currentRoute {
                    NavigationInstructionsPanel(
                        route: route,
                        currentStep: viewModel.currentStep
                    )
                    .transition(.move(edge: .bottom))
                } else {
                    NavigationSetupPanel(
                        onRouteRequested: { start, end, preferences in
                            viewModel.calculateRoute(from: start, to: end, preferences: preferences)
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle("Navegación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        viewModel.cancelNavigation()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Detalles") {
                        showingRouteDetails = true
                    }
                    .disabled(viewModel.currentRoute == nil)
                }
            }
        }
        .sheet(isPresented: $showingRouteDetails) {
            if let route = viewModel.currentRoute {
                RouteDetailsView(route: route)
            }
        }
    }
}

struct NavigationInstructionsPanel: View {
    let route: Route
    let currentStep: RouteStep
    
    var body: some View {
        VStack(spacing: 12) {
            // Progreso de la ruta
            RouteProgressView(
                currentStep: currentStep.stepNumber,
                totalSteps: route.steps.count
            )
            
            // Instrucción actual
            HStack(spacing: 12) {
                Image(systemName: currentStep.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentStep.instruction)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Distancia: \(currentStep.distance)m • Tiempo: \(currentStep.estimatedTime)min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Botones de acción
            HStack(spacing: 12) {
                Button("Anterior") {
                    // Navegar al paso anterior
                }
                .disabled(currentStep.stepNumber == 1)
                
                Spacer()
                
                Button("Siguiente") {
                    // Navegar al paso siguiente
                }
                .buttonStyle(.borderedProminent)
                .disabled(currentStep.stepNumber == route.steps.count)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
}
```

## 🎙️ Pantalla 5: Narración en Vivo (Pilar 2)

### Vista de Narración
```swift
struct LiveNarrationView: View {
    @StateObject private var viewModel = NarrationViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Información del partido
                MatchHeaderView(match: viewModel.currentMatch)
                
                // Controles de narración
                NarrationControlsView(
                    isPlaying: viewModel.isPlaying,
                    volume: viewModel.volume,
                    speed: viewModel.speed,
                    onPlayPause: viewModel.togglePlayback,
                    onVolumeChange: viewModel.setVolume,
                    onSpeedChange: viewModel.setSpeed
                )
                
                // Eventos recientes
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.recentEvents) { event in
                            EventCard(event: event)
                        }
                    }
                    .padding()
                }
                
                // Controles de accesibilidad
                AccessibilityControlsView(
                    showSubtitles: viewModel.showSubtitles,
                    showSignLanguage: viewModel.showSignLanguage,
                    onSubtitlesToggle: viewModel.toggleSubtitles,
                    onSignLanguageToggle: viewModel.toggleSignLanguage
                )
            }
            .navigationTitle("Narración en Vivo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Configuración") {
                        showingSettings = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            NarrationSettingsView()
        }
    }
}

struct EventCard: View {
    let event: MatchEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // Icono del evento
            Image(systemName: event.icon)
                .font(.title2)
                .foregroundColor(event.color)
                .frame(width: 40, height: 40)
                .background(event.color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.description)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Minuto \(event.minute)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Botón de reproducir audio
            Button(action: { event.playAudio() }) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .accessibilityLabel("Reproducir narración del evento")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}
```

## 💬 Pantalla 6: Asistente Conversacional (Pilar 3)

### Vista de Chat
```swift
struct ChatAssistantView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""
    @State private var isRecording = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Historial de mensajes
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input de mensaje
                ChatInputView(
                    messageText: $messageText,
                    isRecording: $isRecording,
                    onSendMessage: { text in
                        viewModel.sendMessage(text)
                        messageText = ""
                    },
                    onStartRecording: viewModel.startRecording,
                    onStopRecording: viewModel.stopRecording
                )
            }
            .navigationTitle("Asistente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Configuración") {
                        // Mostrar configuración de chat
                    }
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16, corners: [.topLeft, .topRight, .bottomLeft])
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(16, corners: [.topLeft, .topRight, .bottomRight])
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message.isFromUser ? "Tú: \(message.text)" : "Asistente: \(message.text)")
    }
}

struct ChatInputView: View {
    @Binding var messageText: String
    @Binding var isRecording: Bool
    let onSendMessage: (String) -> Void
    let onStartRecording: () -> Void
    let onStopRecording: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Campo de texto
            TextField("Escribe tu mensaje...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    if !messageText.isEmpty {
                        onSendMessage(messageText)
                    }
                }
            
            // Botón de grabación de voz
            Button(action: {
                if isRecording {
                    onStopRecording()
                } else {
                    onStartRecording()
                }
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.title2)
                    .foregroundColor(isRecording ? .red : .blue)
            }
            .accessibilityLabel(isRecording ? "Detener grabación" : "Iniciar grabación de voz")
            
            // Botón de envío
            Button(action: {
                if !messageText.isEmpty {
                    onSendMessage(messageText)
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(messageText.isEmpty ? .gray : .blue)
            }
            .disabled(messageText.isEmpty)
            .accessibilityLabel("Enviar mensaje")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
}
```

## 🎨 Sistema de Diseño

### Paleta de Colores
```swift
extension Color {
    // Colores principales
    static let accessBlue = Color(red: 0.0, green: 0.48, blue: 0.65)
    static let accessGreen = Color(red: 0.0, green: 0.65, blue: 0.31)
    static let accessOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let accessPurple = Color(red: 0.55, green: 0.27, blue: 0.75)
    
    // Colores de accesibilidad
    static let wheelchairBlue = Color(red: 0.0, green: 0.48, blue: 0.65)
    static let visualYellow = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let hearingRed = Color(red: 0.86, green: 0.08, blue: 0.24)
    
    // Colores de estado
    static let successGreen = Color(red: 0.0, green: 0.65, blue: 0.31)
    static let warningOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let errorRed = Color(red: 0.86, green: 0.08, blue: 0.24)
}
```

### Tipografía
```swift
extension Font {
    // Títulos
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
    static let title1 = Font.system(size: 28, weight: .bold, design: .default)
    static let title2 = Font.system(size: 22, weight: .bold, design: .default)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
    
    // Texto del cuerpo
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
}
```

### Espaciado
```swift
struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

## ♿ Características de Accesibilidad

### VoiceOver/TalkBack
```swift
// Ejemplo de implementación de accesibilidad
struct AccessibleButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
        }
        .accessibilityLabel(title)
        .accessibilityHint("Toca para ejecutar la acción")
        .accessibilityAddTraits(.isButton)
    }
}
```

### Contraste y Visibilidad
- **Alto Contraste:** Modo disponible para usuarios con baja visión
- **Tamaños de Fuente:** Soporte para tamaños dinámicos del sistema
- **Indicadores Visuales:** Iconos claros y distintivos para cada función
- **Feedback Háptico:** Vibración para confirmar acciones importantes

### Navegación por Teclado
- **Tab Order:** Orden lógico de navegación
- **Focus Indicators:** Indicadores visuales claros del foco
- **Keyboard Shortcuts:** Atajos de teclado para funciones principales

## 📱 Responsive Design

### Adaptación a Diferentes Pantallas
```swift
struct ResponsiveView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // Layout para iPhone
            CompactLayout()
        } else {
            // Layout para iPad
            RegularLayout()
        }
    }
}
```

### Orientación
- **Portrait:** Layout optimizado para uso vertical
- **Landscape:** Adaptación para uso horizontal durante eventos

## 🎯 Métricas de UX

### Objetivos de Usabilidad
- **Tiempo de Configuración:** < 2 minutos para configuración inicial
- **Tiempo de Navegación:** Reducción del 80% en tiempo de navegación
- **Satisfacción del Usuario:** Score NPS > 70
- **Tasa de Abandono:** < 5% durante configuración inicial

### Testing de Usabilidad
- **Usuarios con Discapacidad:** Testing con usuarios reales
- **Diferentes Idiomas:** Validación en múltiples idiomas
- **Diferentes Edades:** Testing con usuarios de 18-80 años
- **Diferentes Dispositivos:** iPhone, Android, iPad, tablets

---

*Este sistema de diseño está optimizado para crear una experiencia verdaderamente inclusiva y accesible para todos los usuarios.*
