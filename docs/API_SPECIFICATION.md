# API Specification - Access 2026

## 📋 Información General

**Base URL:** `https://api.access2026.com/v1`  
**Version:** 1.0  
**Authentication:** Bearer Token (JWT)  
**Rate Limiting:** 1000 requests/hour per user  

## 🔐 Autenticación

### POST /auth/login
Autentica un usuario y retorna un token JWT.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "device_info": {
    "platform": "ios",
    "version": "15.0",
    "device_id": "unique-device-id"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "refresh-token-here",
    "user": {
      "id": "user-123",
      "email": "user@example.com",
      "name": "Juan Pérez",
      "preferences": {
        "language": "es",
        "accessibility_needs": ["wheelchair"],
        "audio_enabled": true,
        "voice_speed": 1.0
      }
    },
    "expires_in": 3600
  }
}
```

### POST /auth/register
Registra un nuevo usuario.

**Request:**
```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "name": "María García",
  "accessibility_needs": ["visual_impairment"],
  "preferred_language": "es"
}
```

### POST /auth/refresh
Renueva el token de acceso.

**Request:**
```json
{
  "refresh_token": "refresh-token-here"
}
```

## 🗺️ Pilar 1: Navegación Accesible

### POST /navigation/route
Calcula una ruta accesible entre dos puntos.

**Request:**
```json
{
  "start": {
    "type": "transport_station",
    "id": "tren_ligero_azteca",
    "coordinates": {
      "lat": 19.3028,
      "lng": -99.1503
    }
  },
  "end": {
    "type": "seat",
    "id": "section_104_row_15_seat_8",
    "coordinates": {
      "lat": 19.3030,
      "lng": -99.1500
    }
  },
  "accessibility_needs": {
    "wheelchair": true,
    "mobility_aid": false,
    "visual_impairment": true,
    "hearing_impairment": false
  },
  "preferences": {
    "max_walking_distance": 500,
    "avoid_stairs": true,
    "prefer_elevators": true
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "route_id": "route-123",
    "total_distance": 450,
    "estimated_time": 8,
    "accessibility_score": 95,
    "steps": [
      {
        "step_number": 1,
        "instruction": "Dirígete hacia la salida principal del Tren Ligero",
        "distance": 50,
        "estimated_time": 1,
        "node": {
          "id": "tren_exit",
          "type": "exit",
          "coordinates": {
            "lat": 19.3029,
            "lng": -99.1502
          },
          "accessibility": {
            "wheelchair": true,
            "visual_landmarks": ["statue", "fountain"]
          }
        },
        "3d_asset": {
          "image_url": "https://cdn.access2026.com/3d/tren_exit.jpg",
          "description": "Vista desde la salida del tren hacia el estadio"
        }
      },
      {
        "step_number": 2,
        "instruction": "Toma la rampa hacia la entrada principal",
        "distance": 100,
        "estimated_time": 2,
        "node": {
          "id": "main_entrance",
          "type": "entrance",
          "coordinates": {
            "lat": 19.3031,
            "lng": -99.1501
          }
        },
        "3d_asset": {
          "image_url": "https://cdn.access2026.com/3d/main_entrance.jpg",
          "description": "Entrada principal del Estadio Azteca"
        }
      }
    ],
    "alternatives": [
      {
        "route_id": "route-124",
        "total_distance": 600,
        "estimated_time": 12,
        "description": "Ruta alternativa con menos escalones"
      }
    ],
    "warnings": [
      {
        "type": "construction",
        "message": "Hay obras en la zona norte del estadio",
        "severity": "medium"
      }
    ]
  }
}
```

### GET /navigation/accessibility-info/{location_id}
Obtiene información de accesibilidad de una ubicación específica.

**Response:**
```json
{
  "success": true,
  "data": {
    "location_id": "section_104",
    "name": "Sección 104",
    "accessibility": {
      "wheelchair": {
        "available": true,
        "count": 8,
        "location": "fila_15"
      },
      "elevator": {
        "available": true,
        "distance": 50,
        "wait_time": 2
      },
      "bathroom": {
        "accessible": true,
        "distance": 30,
        "features": ["wide_door", "grab_bars", "emergency_button"]
      },
      "services": {
        "food_service": true,
        "merchandise": true,
        "medical_station": true
      }
    },
    "visual_landmarks": [
      "large_screen_north",
      "concession_stand_blue"
    ],
    "audio_guidance": {
      "available": true,
      "beacon_id": "beacon_104_001"
    }
  }
}
```

### GET /navigation/3d-assets/{node_id}
Obtiene assets 3D para un nodo específico.

**Response:**
```json
{
  "success": true,
  "data": {
    "node_id": "main_entrance",
    "assets": [
      {
        "type": "image",
        "url": "https://cdn.access2026.com/3d/main_entrance_360.jpg",
        "description": "Vista panorámica de la entrada principal",
        "view_angle": "front"
      },
      {
        "type": "image",
        "url": "https://cdn.access2026.com/3d/main_entrance_close.jpg",
        "description": "Vista cercana de las puertas de acceso",
        "view_angle": "close"
      }
    ],
    "audio_description": {
      "url": "https://cdn.access2026.com/audio/main_entrance_desc.mp3",
      "duration": 15,
      "language": "es"
    }
  }
}
```

### POST /navigation/feedback
Envía feedback sobre una ruta utilizada.

**Request:**
```json
{
  "route_id": "route-123",
  "rating": 4,
  "feedback": "La ruta fue muy útil, pero faltó mencionar el elevador",
  "issues": [
    {
      "step_number": 2,
      "issue_type": "accessibility_problem",
      "description": "El elevador estaba fuera de servicio"
    }
  ],
  "actual_time": 10,
  "actual_distance": 480
}
```

## 🎙️ Pilar 2: Narrador Universal (IA)

### WebSocket /narrator/live-stream/{match_id}
Conexión WebSocket para recibir narración en tiempo real.

**Connection:**
```javascript
const ws = new WebSocket('wss://api.access2026.com/v1/narrator/live-stream/match-123');
```

**Messages recibidos:**
```json
{
  "type": "narration",
  "data": {
    "event_id": "event-456",
    "minute": 70,
    "event_type": "shot",
    "description": "¡Minuto 70! Lozano le pega desde fuera del área, la pelota revienta el poste y se va!",
    "audio_url": "https://cdn.access2026.com/audio/narration_456.mp3",
    "timestamp": "2026-06-15T20:15:30Z",
    "importance": "high",
    "visual_description": "El jugador mexicano dispara desde 25 metros, la pelota golpea el poste derecho y rebota fuera del área"
  }
}
```

```json
{
  "type": "match_status",
  "data": {
    "minute": 70,
    "score": "1-1",
    "possession": "Mexico 65%",
    "next_event": "corner_kick"
  }
}
```

### GET /narrator/match-status/{match_id}
Obtiene el estado actual del partido.

**Response:**
```json
{
  "success": true,
  "data": {
    "match_id": "match-123",
    "status": "live",
    "minute": 70,
    "score": {
      "home": 1,
      "away": 1
    },
    "teams": {
      "home": {
        "name": "México",
        "flag": "🇲🇽"
      },
      "away": {
        "name": "Brasil",
        "flag": "🇧🇷"
      }
    },
    "last_event": {
      "minute": 70,
      "type": "shot",
      "player": "H. Lozano",
      "description": "Disparo al poste desde fuera del área"
    },
    "next_events": [
      {
        "type": "corner_kick",
        "minute": 71,
        "team": "México"
      }
    ]
  }
}
```

### GET /narrator/recent-events/{match_id}
Obtiene los eventos recientes del partido.

**Query Parameters:**
- `limit`: Número de eventos (default: 10)
- `event_type`: Filtrar por tipo de evento

**Response:**
```json
{
  "success": true,
  "data": {
    "events": [
      {
        "event_id": "event-456",
        "minute": 70,
        "event_type": "shot",
        "player": "H. Lozano",
        "description": "Disparo al poste desde fuera del área",
        "audio_url": "https://cdn.access2026.com/audio/narration_456.mp3",
        "timestamp": "2026-06-15T20:15:30Z"
      },
      {
        "event_id": "event-455",
        "minute": 68,
        "event_type": "substitution",
        "player": "R. Jiménez",
        "description": "Entra Jiménez por Chicharito",
        "audio_url": "https://cdn.access2026.com/audio/narration_455.mp3",
        "timestamp": "2026-06-15T20:13:45Z"
      }
    ]
  }
}
```

### POST /narrator/customize-voice
Personaliza la voz del narrador.

**Request:**
```json
{
  "voice_settings": {
    "language": "es",
    "gender": "male",
    "speed": 1.1,
    "pitch": 1.0,
    "volume": 0.8
  },
  "narration_style": {
    "detail_level": "high",
    "emotion_level": "high",
    "include_tactics": true,
    "include_statistics": false
  }
}
```

### GET /narrator/sign-language/{event_type}
Obtiene video de lengua de señas para un tipo de evento.

**Response:**
```json
{
  "success": true,
  "data": {
    "event_type": "goal",
    "video_url": "https://cdn.access2026.com/video/sign_language/goal_lsm.mp4",
    "duration": 5,
    "language": "lsm",
    "description": "Señalización de 'Gol' en Lengua de Señas Mexicana"
  }
}
```

## 💬 Pilar 3: Asistente Conversacional Multilingüe

### WebSocket /chat/conversation
Conexión WebSocket para chat en tiempo real.

**Connection:**
```javascript
const ws = new WebSocket('wss://api.access2026.com/v1/chat/conversation');
```

**Mensaje enviado:**
```json
{
  "type": "message",
  "data": {
    "text": "¿Dónde está el baño más cercano?",
    "language": "es",
    "input_method": "voice"
  }
}
```

**Mensaje recibido:**
```json
{
  "type": "response",
  "data": {
    "text": "El baño más cercano está en la Sección 104, a 30 metros de tu ubicación actual.",
    "language": "es",
    "confidence": 0.95,
    "actions": [
      {
        "type": "show_route",
        "data": {
          "route_id": "route-125",
          "destination": "bathroom_section_104"
        }
      }
    ],
    "audio_url": "https://cdn.access2026.com/audio/response_789.mp3",
    "visual_elements": [
      {
        "type": "map",
        "url": "https://cdn.access2026.com/maps/bathroom_route.jpg"
      }
    ]
  }
}
```

### POST /chat/message
Envía un mensaje al asistente conversacional.

**Request:**
```json
{
  "text": "Wo ist die nächste barrierefreie Toilette?",
  "language": "de",
  "context": {
    "current_location": {
      "section": "104",
      "row": "15",
      "seat": "8"
    },
    "accessibility_needs": ["wheelchair"],
    "conversation_history": [
      {
        "text": "Hola, ¿puedes ayudarme?",
        "response": "¡Por supuesto! ¿En qué puedo ayudarte?"
      }
    ]
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "response_id": "response-789",
    "text": "Die nächste barrierefreie Toilette befindet sich in Sektion 104, nur 30 Meter von Ihrem aktuellen Standort entfernt.",
    "language": "de",
    "confidence": 0.92,
    "intent": "find_accessible_bathroom",
    "actions": [
      {
        "type": "show_route",
        "data": {
          "route_id": "route-126",
          "destination": "bathroom_section_104",
          "instructions": [
            "Gehen Sie geradeaus zur Haupttreppe",
            "Nehmen Sie den Aufzug nach unten",
            "Die Toilette befindet sich rechts"
          ]
        }
      }
    ],
    "audio_url": "https://cdn.access2026.com/audio/response_789_de.mp3",
    "visual_elements": [
      {
        "type": "map",
        "url": "https://cdn.access2026.com/maps/bathroom_route_de.jpg",
        "description": "Ruta hacia el baño accesible"
      }
    ],
    "follow_up_questions": [
      "¿Necesitas ayuda para llegar allí?",
      "¿Hay algo más en lo que pueda ayudarte?"
    ]
  }
}
```

### POST /chat/voice-message
Envía un mensaje de voz al asistente.

**Request:**
```multipart/form-data
Content-Type: multipart/form-data

audio: [archivo de audio]
language: "es"
context: {
  "current_location": {...},
  "accessibility_needs": [...]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "transcription": "¿Cuál fue el último gol del partido?",
    "confidence": 0.88,
    "response": {
      "text": "El último gol fue de Lozano en el minuto 45, un disparo desde fuera del área que se coló por la escuadra.",
      "audio_url": "https://cdn.access2026.com/audio/response_790.mp3"
    }
  }
}
```

### GET /chat/history
Obtiene el historial de conversación del usuario.

**Query Parameters:**
- `limit`: Número de mensajes (default: 50)
- `offset`: Offset para paginación

**Response:**
```json
{
  "success": true,
  "data": {
    "conversations": [
      {
        "conversation_id": "conv-123",
        "started_at": "2026-06-15T19:30:00Z",
        "ended_at": "2026-06-15T21:30:00Z",
        "messages": [
          {
            "message_id": "msg-456",
            "timestamp": "2026-06-15T19:30:15Z",
            "type": "user",
            "text": "¿Dónde está mi asiento?",
            "language": "es"
          },
          {
            "message_id": "msg-457",
            "timestamp": "2026-06-15T19:30:16Z",
            "type": "assistant",
            "text": "Tu asiento está en la Sección 104, Fila 15, Asiento 8.",
            "language": "es",
            "actions": ["show_seat_location"]
          }
        ]
      }
    ],
    "pagination": {
      "total": 150,
      "limit": 50,
      "offset": 0,
      "has_more": true
    }
  }
}
```

### GET /chat/supported-languages
Obtiene la lista de idiomas soportados.

**Response:**
```json
{
  "success": true,
  "data": {
    "languages": [
      {
        "code": "es",
        "name": "Español",
        "native_name": "Español",
        "supported_features": ["text", "voice", "translation"]
      },
      {
        "code": "en",
        "name": "English",
        "native_name": "English",
        "supported_features": ["text", "voice", "translation"]
      },
      {
        "code": "de",
        "name": "German",
        "native_name": "Deutsch",
        "supported_features": ["text", "translation"]
      },
      {
        "code": "fr",
        "name": "French",
        "native_name": "Français",
        "supported_features": ["text", "translation"]
      }
    ]
  }
}
```

## 🚌 Servicios de Transporte Público

### GET /transport/stations
Obtiene todas las estaciones de transporte público cercanas al estadio.

**Response:**
```json
{
  "success": true,
  "data": {
    "stations": [
      {
        "station_id": "tren_ligero_azteca",
        "name": "Estadio Azteca",
        "type": "tren_ligero",
        "coordinates": {
          "lat": 19.3028,
          "lng": -99.1503
        },
        "accessibility": {
          "wheelchair": true,
          "elevator": true,
          "ramp": true,
          "audio_announcements": true
        },
        "distance_to_stadium": 200,
        "estimated_walking_time": 3
      },
      {
        "station_id": "metro_cuatro_caminos",
        "name": "Cuatro Caminos",
        "type": "metro",
        "coordinates": {
          "lat": 19.4500,
          "lng": -99.2000
        },
        "accessibility": {
          "wheelchair": true,
          "elevator": true,
          "ramp": false,
          "audio_announcements": true
        },
        "distance_to_stadium": 5000,
        "estimated_walking_time": 15
      }
    ]
  }
}
```

### GET /transport/routes/{station_id}
Obtiene las rutas disponibles desde una estación específica.

**Response:**
```json
{
  "success": true,
  "data": {
    "station_id": "tren_ligero_azteca",
    "routes": [
      {
        "route_id": "tl_route_1",
        "name": "Tren Ligero Línea 1",
        "destination": "Xochimilco",
        "frequency": "5 minutos",
        "operating_hours": "05:00 - 24:00",
        "accessibility": {
          "wheelchair_spaces": 4,
          "priority_seating": 8,
          "audio_announcements": true
        }
      }
    ]
  }
}
```

## 📊 Analytics y Métricas

### POST /analytics/event
Registra un evento de analytics.

**Request:**
```json
{
  "event_type": "route_completed",
  "user_id": "user-123",
  "session_id": "session-456",
  "metadata": {
    "route_id": "route-123",
    "completion_time": 8,
    "user_rating": 4,
    "accessibility_needs": ["wheelchair"]
  },
  "timestamp": "2026-06-15T20:15:30Z"
}
```

### GET /analytics/usage-stats
Obtiene estadísticas de uso (requiere permisos de admin).

**Query Parameters:**
- `start_date`: Fecha de inicio
- `end_date`: Fecha de fin
- `group_by`: Agrupar por (day, hour, feature)

**Response:**
```json
{
  "success": true,
  "data": {
    "period": {
      "start": "2026-06-15T00:00:00Z",
      "end": "2026-06-15T23:59:59Z"
    },
    "metrics": {
      "total_users": 1250,
      "active_sessions": 890,
      "routes_calculated": 2100,
      "narration_minutes": 4500,
      "chat_messages": 3200
    },
    "feature_usage": {
      "navigation": 2100,
      "narration": 1800,
      "chat": 1500
    },
    "accessibility_distribution": {
      "wheelchair": 450,
      "visual_impairment": 320,
      "hearing_impairment": 280,
      "no_accessibility_needs": 200
    }
  }
}
```

## 🚨 Códigos de Error

### Errores de Autenticación
- `401 Unauthorized`: Token inválido o expirado
- `403 Forbidden`: Permisos insuficientes
- `429 Too Many Requests`: Límite de rate limiting excedido

### Errores de Validación
- `400 Bad Request`: Datos de entrada inválidos
- `422 Unprocessable Entity`: Error de validación de datos

### Errores del Servidor
- `500 Internal Server Error`: Error interno del servidor
- `503 Service Unavailable`: Servicio temporalmente no disponible

### Ejemplo de Respuesta de Error
```json
{
  "success": false,
  "error": {
    "code": "INVALID_ROUTE_PARAMETERS",
    "message": "Los parámetros de inicio y fin son requeridos",
    "details": {
      "missing_fields": ["start", "end"],
      "validation_errors": {
        "start": "Debe ser un objeto válido con coordenadas",
        "end": "Debe ser un objeto válido con coordenadas"
      }
    },
    "timestamp": "2026-06-15T20:15:30Z",
    "request_id": "req-789"
  }
}
```

## 📝 Notas de Implementación

### Rate Limiting
- **Usuarios autenticados:** 1000 requests/hour
- **Usuarios no autenticados:** 100 requests/hour
- **WebSocket connections:** 10 conexiones simultáneas por usuario

### Caching
- **Rutas:** Cache por 5 minutos
- **Información de accesibilidad:** Cache por 1 hora
- **Datos de partidos:** Cache por 30 segundos

### WebSocket
- **Reconexión automática:** Cada 30 segundos
- **Heartbeat:** Ping cada 30 segundos
- **Máximo de mensajes:** 1000 por conexión

### Seguridad
- **HTTPS obligatorio:** Todas las comunicaciones
- **CORS:** Configurado para dominios autorizados
- **Validación de entrada:** Sanitización de todos los inputs
- **Logging:** Registro de todas las operaciones sensibles

---

*Esta especificación de API está diseñada para ser clara, completa y fácil de implementar por cualquier desarrollador.*
