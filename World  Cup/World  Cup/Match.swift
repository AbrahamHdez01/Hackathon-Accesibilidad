import Foundation

enum MatchStatus: String, Codable {
    case live = "En vivo"
    case upcoming = "Próximamente"
    case previous = "Anteriores"
}

struct Match: Identifiable, Codable {
    let id: String
    let homeTeam: String
    let awayTeam: String
    let stadium: String
    let date: String
    let time: String
    let status: MatchStatus
    // Clave base del script (sin sufijo de idioma). Ej: "mexico_vs_brasil_live"
    let scriptKey: String
    let narrationScript: String
    let isActive: Bool // Solo 3 partidos estarán activos (1 por categoría)
    
    var displayName: String {
        "\(homeTeam) vs \(awayTeam)"
    }
    
    var fullInfo: String {
        "\(stadium) - \(date) \(time)"
    }
    
    // Inicializador de conveniencia para mantener compatibilidad con llamadas existentes
    // Permite omitir scriptKey; por defecto usa cadena vacía (sin localización específica)
    init(
        id: String,
        homeTeam: String,
        awayTeam: String,
        stadium: String,
        date: String,
        time: String,
        status: MatchStatus,
        narrationScript: String,
        isActive: Bool,
        scriptKey: String? = nil
    ) {
        self.id = id
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.stadium = stadium
        self.date = date
        self.time = time
        self.status = status
        self.narrationScript = narrationScript
        self.isActive = isActive
        self.scriptKey = scriptKey ?? ""
    }
}


