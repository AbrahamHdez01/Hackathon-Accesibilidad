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
    let narrationScript: String
    let isActive: Bool // Solo 3 partidos estarán activos (1 por categoría)
    
    var displayName: String {
        "\(homeTeam) vs \(awayTeam)"
    }
    
    var fullInfo: String {
        "\(stadium) - \(date) \(time)"
    }
}


