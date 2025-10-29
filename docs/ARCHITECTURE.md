# Arquitectura Técnica - Access 2026

## 🏗️ Visión General del Sistema

Access 2026 está diseñado como una arquitectura de microservicios que integra tres pilares principales a través de APIs RESTful y servicios de IA. El sistema está optimizado para manejar 50,000+ usuarios simultáneos durante eventos del Mundial 2026.

## 📊 Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONTEND LAYER                          │
├─────────────────────────────────────────────────────────────────┤
│  Mobile App (React Native)  │  Web App (React + Three.js)     │
│  - iOS/Android              │  - Desktop/Tablet               │
│  - Offline capabilities     │  - 3D Visualization             │
│  - Voice Interface          │  - Admin Dashboard              │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY LAYER                         │
├─────────────────────────────────────────────────────────────────┤
│  API Gateway (Kong/AWS API Gateway)                            │
│  - Authentication & Authorization                              │
│  - Rate Limiting                                              │
│  - Request Routing                                            │
│  - Caching Layer (Redis)                                      │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                     MICROSERVICES LAYER                        │
├─────────────────────────────────────────────────────────────────┤
│  Navigation Service  │  AI Narrator Service  │  Chat Service   │
│  - Route Planning    │  - Sports Data API    │  - NLP/NLU      │
│  - Graph Database    │  - LLM Integration   │  - Translation  │
│  - 3D Assets        │  - TTS/STT           │  - Voice Chat    │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│  PostgreSQL     │  Redis Cache    │  S3 Storage    │  CDN      │
│  - User Data    │  - Session      │  - 3D Models   │  - Assets │
│  - Analytics    │  - Routes       │  - Audio Files │  - Images │
│  - Logs         │  - AI Responses │  - Videos      │           │
└─────────────────────────────────────────────────────────────────┘
```

## 🎯 Pilar 1: Navegador Accesible

### Arquitectura del Sistema de Navegación

#### 1. Grafo de Nodos (Core Logic)
```json
{
  "nodes": {
    "node_id": {
      "id": "entrance_main",
      "type": "entrance",
      "coordinates": {"x": 100, "y": 200, "z": 0},
      "accessibility": {
        "wheelchair": true,
        "mobility_aid": true,
        "visual_landmarks": ["statue", "fountain"]
      },
      "services": ["ticket_booth", "information"]
    }
  },
  "edges": {
    "edge_id": {
      "from": "entrance_main",
      "to": "section_104",
      "distance": 150,
      "type": "ramp",
      "accessibility": {
        "wheelchair": true,
        "mobility_aid": true,
        "gradient": 5
      },
      "estimated_time": 120
    }
  }
}
```

#### 2. Algoritmo de Ruteo (Dijkstra Optimizado)
```python
class AccessibleRouter:
    def __init__(self, graph_data):
        self.graph = self.build_graph(graph_data)
    
    def find_route(self, start, end, accessibility_needs):
        # Filtrar aristas según necesidades de accesibilidad
        accessible_edges = self.filter_accessible_edges(
            accessibility_needs
        )
        
        # Aplicar algoritmo Dijkstra
        route = self.dijkstra(start, end, accessible_edges)
        
        # Generar instrucciones paso a paso
        instructions = self.generate_instructions(route)
        
        return {
            "route": route,
            "instructions": instructions,
            "total_distance": self.calculate_distance(route),
            "estimated_time": self.calculate_time(route)
        }
```

#### 3. Servicio de Navegación
```typescript
interface NavigationService {
  // Endpoints principales
  POST /api/navigation/route
  GET  /api/navigation/accessibility-info
  GET  /api/navigation/3d-assets/:nodeId
  POST /api/navigation/feedback
}

// Implementación
class NavigationService {
  async calculateRoute(request: RouteRequest): Promise<RouteResponse> {
    const router = new AccessibleRouter(this.graphData);
    const route = router.find_route(
      request.start,
      request.end,
      request.accessibilityNeeds
    );
    
    // Enriquecer con assets 3D
    const assets = await this.get3DAssets(route.nodes);
    
    return {
      ...route,
      assets,
      alternatives: await this.findAlternatives(route)
    };
  }
}
```

### Integración con Transporte Público

#### API de Integración
```typescript
interface PublicTransportAPI {
  // Integración con Tren Ligero
  GET /api/transport/stations
  GET /api/transport/routes/:stationId
  GET /api/transport/accessibility/:stationId
  
  // Integración con Metro
  GET /api/metro/stations
  GET /api/metro/elevators/:stationId
}
```

## 🎯 Pilar 2: Narrador Universal (IA)

### Arquitectura del Sistema de IA

#### 1. Pipeline de Datos Deportivos
```python
class SportsDataPipeline:
    def __init__(self):
        self.api_client = APIFootballClient()
        self.llm_client = GeminiClient()
        self.tts_client = GoogleTTSClient()
    
    async def process_match_event(self, event_data):
        # Paso 1: Obtener datos del evento
        raw_event = await self.api_client.get_live_event(event_data)
        
        # Paso 2: Generar descripción con IA
        description = await self.llm_client.generate_description(
            prompt=self.build_narration_prompt(raw_event),
            context=self.get_match_context()
        )
        
        # Paso 3: Convertir a audio
        audio_url = await self.tts_client.text_to_speech(
            text=description,
            voice="spanish_male_sports",
            speed=1.1
        )
        
        return {
            "event": raw_event,
            "description": description,
            "audio_url": audio_url,
            "timestamp": datetime.now()
        }
```

#### 2. Sistema de Subtitulado Avanzado
```python
class AdvancedCaptioning:
    def __init__(self):
        self.stt_client = GoogleSTTClient()
        self.audio_classifier = AudioClassificationModel()
    
    async def process_audio_stream(self, audio_stream):
        # Transcripción en tiempo real
        transcription = await self.stt_client.transcribe_stream(audio_stream)
        
        # Clasificación de eventos de audio
        audio_events = await self.audio_classifier.classify(audio_stream)
        
        # Generar subtítulos enriquecidos
        captions = self.enrich_captions(transcription, audio_events)
        
        return {
            "text": captions,
            "events": audio_events,
            "confidence": transcription.confidence
        }
```

#### 3. Servicio de Narración
```typescript
interface NarratorService {
  // WebSocket para streaming en tiempo real
  WS /api/narrator/live-stream
  
  // Endpoints REST
  GET  /api/narrator/match-status
  GET  /api/narrator/recent-events
  POST /api/narrator/customize-voice
  GET  /api/narrator/sign-language/:eventType
}

// Implementación
class NarratorService {
  async startLiveNarration(matchId: string, userPreferences: UserPreferences) {
    const pipeline = new SportsDataPipeline();
    
    // Configurar WebSocket
    const ws = new WebSocket(`/api/narrator/live-stream/${matchId}`);
    
    // Procesar eventos en tiempo real
    pipeline.on('event', async (event) => {
      const narration = await pipeline.process_match_event(event);
      
      // Enviar a cliente
      ws.send(JSON.stringify({
        type: 'narration',
        data: narration
      }));
    });
  }
}
```

## 🎯 Pilar 3: Asistente Conversacional Multilingüe

### Arquitectura del Sistema de Chat

#### 1. Motor de Procesamiento de Lenguaje Natural
```python
class MultilingualNLP:
    def __init__(self):
        self.translator = GoogleTranslateClient()
        self.nlu_engine = DialogflowClient()
        self.intent_classifier = IntentClassificationModel()
    
    async def process_user_input(self, input_text: str, user_language: str):
        # Detectar idioma si no se especifica
        detected_lang = await self.detect_language(input_text)
        
        # Traducir a español para procesamiento
        spanish_text = await self.translator.translate(
            text=input_text,
            target_lang='es',
            source_lang=detected_lang
        )
        
        # Procesar intención
        intent = await self.nlu_engine.detect_intent(spanish_text)
        
        # Clasificar tipo de consulta
        query_type = await self.intent_classifier.classify(intent)
        
        return {
            "original_text": input_text,
            "detected_language": detected_lang,
            "spanish_text": spanish_text,
            "intent": intent,
            "query_type": query_type
        }
```

#### 2. Sistema de Integración entre Pilares
```python
class PilarIntegration:
    def __init__(self):
        self.navigation_service = NavigationService()
        self.narrator_service = NarratorService()
        self.nlp_engine = MultilingualNLP()
    
    async def handle_user_query(self, query: str, user_context: UserContext):
        # Procesar entrada del usuario
        processed_input = await self.nlp_engine.process_user_input(
            query, user_context.language
        )
        
        # Determinar qué pilar maneja la consulta
        if processed_input.query_type == "navigation":
            response = await self.handle_navigation_query(
                processed_input, user_context
            )
        elif processed_input.query_type == "match_info":
            response = await self.handle_match_query(
                processed_input, user_context
            )
        else:
            response = await self.handle_general_query(
                processed_input, user_context
            )
        
        # Traducir respuesta al idioma del usuario
        translated_response = await self.translate_response(
            response, user_context.language
        )
        
        return translated_response
    
    async def handle_navigation_query(self, processed_input, user_context):
        # Extraer parámetros de navegación
        nav_params = self.extract_navigation_params(processed_input.intent)
        
        # Consultar servicio de navegación
        route = await self.navigation_service.calculateRoute({
            start: nav_params.start,
            end: nav_params.end,
            accessibilityNeeds: user_context.accessibility_needs
        })
        
        # Generar respuesta conversacional
        return self.generate_navigation_response(route, user_context.language)
```

#### 3. Servicio de Chat
```typescript
interface ChatService {
  // WebSocket para chat en tiempo real
  WS /api/chat/conversation
  
  // Endpoints REST
  POST /api/chat/message
  GET  /api/chat/history
  POST /api/chat/voice-message
  GET  /api/chat/supported-languages
}

// Implementación
class ChatService {
  async processMessage(message: ChatMessage, userContext: UserContext) {
    const integration = new PilarIntegration();
    
    // Procesar mensaje
    const response = await integration.handle_user_query(
      message.text, userContext
    );
    
    // Generar respuesta multimodal
    const multimodalResponse = await this.generateMultimodalResponse(
      response, userContext
    );
    
    return multimodalResponse;
  }
  
  private async generateMultimodalResponse(response: any, userContext: UserContext) {
    const result = {
      text: response.text,
      audio: null,
      visual: null,
      actions: []
    };
    
    // Generar audio si es necesario
    if (userContext.preferences.audio_enabled) {
      result.audio = await this.tts_client.text_to_speech(
        response.text, userContext.language
      );
    }
    
    // Generar elementos visuales
    if (response.type === 'navigation') {
      result.visual = await this.generateNavigationVisual(response.route);
      result.actions = ['show_route', 'start_navigation'];
    }
    
    return result;
  }
}
```

## 🔧 Servicios de Infraestructura

### 1. Sistema de Autenticación y Autorización
```typescript
interface AuthService {
  POST /api/auth/login
  POST /api/auth/register
  POST /api/auth/refresh
  GET  /api/auth/profile
  POST /api/auth/preferences
}

// Implementación con JWT
class AuthService {
  async authenticateUser(credentials: LoginCredentials) {
    const user = await this.validateCredentials(credentials);
    const token = this.generateJWT(user);
    
    // Guardar sesión en Redis
    await this.redis.setex(
      `session:${user.id}`, 
      3600, 
      JSON.stringify(user.preferences)
    );
    
    return { token, user: this.sanitizeUser(user) };
  }
}
```

### 2. Sistema de Cache Distribuido
```python
class CacheManager:
    def __init__(self):
        self.redis_client = redis.Redis(host='redis-cluster')
        self.local_cache = {}
    
    async def get_cached_route(self, route_key: str):
        # Intentar cache local primero
        if route_key in self.local_cache:
            return self.local_cache[route_key]
        
        # Intentar Redis
        cached_data = await self.redis_client.get(route_key)
        if cached_data:
            route_data = json.loads(cached_data)
            self.local_cache[route_key] = route_data
            return route_data
        
        return None
    
    async def cache_route(self, route_key: str, route_data: dict, ttl: int = 300):
        # Cache local
        self.local_cache[route_key] = route_data
        
        # Cache Redis
        await self.redis_client.setex(
            route_key, 
            ttl, 
            json.dumps(route_data)
        )
```

### 3. Sistema de Monitoreo y Analytics
```typescript
interface AnalyticsService {
  POST /api/analytics/event
  GET  /api/analytics/usage-stats
  GET  /api/analytics/accessibility-metrics
  GET  /api/analytics/performance-metrics
}

// Implementación
class AnalyticsService {
  async trackUserEvent(event: UserEvent) {
    const analyticsData = {
      userId: event.userId,
      eventType: event.type,
      timestamp: new Date(),
      metadata: event.metadata,
      sessionId: event.sessionId
    };
    
    // Enviar a sistema de analytics
    await this.sendToAnalytics(analyticsData);
    
    // Actualizar métricas en tiempo real
    await this.updateRealTimeMetrics(event);
  }
}
```

## 🚀 Despliegue y Escalabilidad

### Arquitectura de Despliegue
```yaml
# docker-compose.yml
version: '3.8'
services:
  api-gateway:
    image: kong:latest
    ports:
      - "8000:8000"
      - "8001:8001"
    environment:
      - KONG_DATABASE=off
      - KONG_DECLARATIVE_CONFIG=/kong/declarative/kong.yml
  
  navigation-service:
    build: ./services/navigation
    environment:
      - DATABASE_URL=postgresql://user:pass@postgres:5432/navigation
      - REDIS_URL=redis://redis:6379
  
  ai-narrator-service:
    build: ./services/ai-narrator
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - GOOGLE_TTS_KEY=${GOOGLE_TTS_KEY}
  
  chat-service:
    build: ./services/chat
    environment:
      - DIALOGFLOW_PROJECT_ID=${DIALOGFLOW_PROJECT_ID}
  
  postgres:
    image: postgres:13
    environment:
      - POSTGRES_DB=navigation
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
  
  redis:
    image: redis:6-alpine
    command: redis-server --appendonly yes
```

### Estrategia de Escalabilidad
1. **Horizontal Scaling:** Microservicios independientes
2. **Load Balancing:** Distribución de carga con Kong
3. **Caching:** Redis para datos frecuentemente accedidos
4. **CDN:** CloudFront para assets estáticos
5. **Database Sharding:** Por tipo de datos y región

## 📊 Métricas y Monitoreo

### KPIs Técnicos
- **Latencia:** < 200ms para respuestas de API
- **Throughput:** 1000+ requests/segundo por servicio
- **Disponibilidad:** 99.9% uptime
- **Error Rate:** < 0.1%

### Métricas de Negocio
- **User Engagement:** Tiempo promedio de sesión
- **Feature Usage:** Uso por pilar y funcionalidad
- **Accessibility Impact:** Reducción en tiempo de navegación
- **Language Support:** Distribución de idiomas utilizados

---

*Esta arquitectura está diseñada para ser escalable, mantenible y centrada en la experiencia del usuario con necesidades de accesibilidad.*
