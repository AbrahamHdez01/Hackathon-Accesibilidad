import Foundation

class MatchDataService: ObservableObject {
    @Published var matches: [Match] = []
    
    init() {
        loadMatches()
    }
    
    private func loadMatches() {
        // Partido EN VIVO (activo)
        let liveMatch = Match(
            id: "match_live_001",
            homeTeam: "México",
            awayTeam: "Brasil",
            stadium: "Estadio Azteca",
            date: "15 Jun 2026",
            time: "20:00",
            status: .live,
            narrationScript: loadScript(fileName: "mexico_vs_brasil_live"),
            isActive: true
        )
        
        // Partido PRÓXIMAMENTE (activo)
        let upcomingMatch = Match(
            id: "match_upcoming_001",
            homeTeam: "Estados Unidos",
            awayTeam: "Argentina",
            stadium: "Estadio Azteca",
            date: "18 Jun 2026",
            time: "16:00",
            status: .upcoming,
            narrationScript: loadScript(fileName: "usa_vs_argentina_upcoming"),
            isActive: true
        )
        
        // Partido ANTERIORES (activo)
        let previousMatch = Match(
            id: "match_previous_001",
            homeTeam: "Canadá",
            awayTeam: "España",
            stadium: "Estadio Azteca",
            date: "12 Jun 2026",
            time: "14:00",
            status: .previous,
            narrationScript: loadScript(fileName: "canada_vs_spain_previous"),
            isActive: true
        )
        
        // Partidos adicionales (no activos, solo para mostrar)
        let additionalMatches: [Match] = [
            // En vivo
            Match(
                id: "match_live_002",
                homeTeam: "Francia",
                awayTeam: "Alemania",
                stadium: "MetLife Stadium",
                date: "15 Jun 2026",
                time: "22:00",
                status: .live,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_live_003",
                homeTeam: "Italia",
                awayTeam: "Holanda",
                stadium: "AT&T Stadium",
                date: "16 Jun 2026",
                time: "14:00",
                status: .live,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_live_004",
                homeTeam: "Bélgica",
                awayTeam: "Croacia",
                stadium: "Estadio Azteca",
                date: "16 Jun 2026",
                time: "17:00",
                status: .live,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_live_005",
                homeTeam: "Inglaterra",
                awayTeam: "Portugal",
                stadium: "Gillette Stadium",
                date: "16 Jun 2026",
                time: "20:00",
                status: .live,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_live_006",
                homeTeam: "España",
                awayTeam: "Marruecos",
                stadium: "Estadio Azteca",
                date: "17 Jun 2026",
                time: "15:00",
                status: .live,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_live_007",
                homeTeam: "Uruguay",
                awayTeam: "Colombia",
                stadium: "MetLife Stadium",
                date: "17 Jun 2026",
                time: "18:00",
                status: .live,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_live_008",
                homeTeam: "Chile",
                awayTeam: "Perú",
                stadium: "AT&T Stadium",
                date: "17 Jun 2026",
                time: "21:00",
                status: .live,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_live_009",
                homeTeam: "Ecuador",
                awayTeam: "Venezuela",
                stadium: "Gillette Stadium",
                date: "18 Jun 2026",
                time: "14:00",
                status: .live,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_live_010",
                homeTeam: "Paraguay",
                awayTeam: "Bolivia",
                stadium: "Estadio Azteca",
                date: "18 Jun 2026",
                time: "17:00",
                status: .live,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_live_011",
                homeTeam: "Costa Rica",
                awayTeam: "Panamá",
                stadium: "MetLife Stadium",
                date: "18 Jun 2026",
                time: "20:00",
                status: .live,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_live_012",
                homeTeam: "Jamaica",
                awayTeam: "Honduras",
                stadium: "AT&T Stadium",
                date: "19 Jun 2026",
                time: "15:00",
                status: .live,
                narrationScript: "",
                isActive: false
            ),
            // Próximamente
            Match(
                id: "match_upcoming_002",
                homeTeam: "Inglaterra",
                awayTeam: "Portugal",
                stadium: "Estadio Azteca",
                date: "19 Jun 2026",
                time: "18:00",
                status: .upcoming,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_upcoming_003",
                homeTeam: "Brasil",
                awayTeam: "Francia",
                stadium: "MetLife Stadium",
                date: "20 Jun 2026",
                time: "16:00",
                status: .upcoming,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_upcoming_004",
                homeTeam: "España",
                awayTeam: "Alemania",
                stadium: "AT&T Stadium",
                date: "20 Jun 2026",
                time: "19:00",
                status: .upcoming,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_upcoming_005",
                homeTeam: "México",
                awayTeam: "Canadá",
                stadium: "Estadio Azteca",
                date: "21 Jun 2026",
                time: "15:00",
                status: .upcoming,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_upcoming_006",
                homeTeam: "Japón",
                awayTeam: "Corea del Sur",
                stadium: "Gillette Stadium",
                date: "21 Jun 2026",
                time: "18:00",
                status: .upcoming,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_upcoming_007",
                homeTeam: "Egipto",
                awayTeam: "Senegal",
                stadium: "Estadio Azteca",
                date: "22 Jun 2026",
                time: "16:00",
                status: .upcoming,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_upcoming_008",
                homeTeam: "Túnez",
                awayTeam: "Marruecos",
                stadium: "MetLife Stadium",
                date: "22 Jun 2026",
                time: "19:00",
                status: .upcoming,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_upcoming_009",
                homeTeam: "Irán",
                awayTeam: "Arabia Saudí",
                stadium: "AT&T Stadium",
                date: "23 Jun 2026",
                time: "14:00",
                status: .upcoming,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_upcoming_010",
                homeTeam: "Australia",
                awayTeam: "Nueva Zelanda",
                stadium: "Gillette Stadium",
                date: "23 Jun 2026",
                time: "17:00",
                status: .upcoming,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_upcoming_011",
                homeTeam: "Camerún",
                awayTeam: "Ghana",
                stadium: "Estadio Azteca",
                date: "23 Jun 2026",
                time: "20:00",
                status: .upcoming,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_upcoming_012",
                homeTeam: "Nigeria",
                awayTeam: "Costa de Marfil",
                stadium: "MetLife Stadium",
                date: "24 Jun 2026",
                time: "16:00",
                status: .upcoming,
                narrationScript: "",
                isActive: false
            ),
            // Anteriores
            Match(
                id: "match_previous_002",
                homeTeam: "Japón",
                awayTeam: "Corea del Sur",
                stadium: "Estadio Azteca",
                date: "11 Jun 2026",
                time: "12:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_003",
                homeTeam: "México",
                awayTeam: "Estados Unidos",
                stadium: "Estadio Azteca",
                date: "10 Jun 2026",
                time: "20:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_004",
                homeTeam: "Brasil",
                awayTeam: "Argentina",
                stadium: "MetLife Stadium",
                date: "9 Jun 2026",
                time: "16:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_005",
                homeTeam: "Francia",
                awayTeam: "Inglaterra",
                stadium: "AT&T Stadium",
                date: "8 Jun 2026",
                time: "14:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_006",
                homeTeam: "Italia",
                awayTeam: "Holanda",
                stadium: "Gillette Stadium",
                date: "7 Jun 2026",
                time: "18:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_007",
                homeTeam: "Uruguay",
                awayTeam: "Chile",
                stadium: "Estadio Azteca",
                date: "6 Jun 2026",
                time: "16:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_008",
                homeTeam: "Colombia",
                awayTeam: "Ecuador",
                stadium: "MetLife Stadium",
                date: "6 Jun 2026",
                time: "19:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_009",
                homeTeam: "Perú",
                awayTeam: "Paraguay",
                stadium: "AT&T Stadium",
                date: "5 Jun 2026",
                time: "14:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_010",
                homeTeam: "Venezuela",
                awayTeam: "Bolivia",
                stadium: "Gillette Stadium",
                date: "5 Jun 2026",
                time: "17:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_011",
                homeTeam: "Costa Rica",
                awayTeam: "Jamaica",
                stadium: "Estadio Azteca",
                date: "4 Jun 2026",
                time: "20:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_012",
                homeTeam: "Panamá",
                awayTeam: "Honduras",
                stadium: "MetLife Stadium",
                date: "3 Jun 2026",
                time: "15:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_013",
                homeTeam: "Egipto",
                awayTeam: "Túnez",
                stadium: "AT&T Stadium",
                date: "2 Jun 2026",
                time: "18:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            ),
            Match(
                id: "match_previous_014",
                homeTeam: "Senegal",
                awayTeam: "Marruecos",
                stadium: "Gillette Stadium",
                date: "1 Jun 2026",
                time: "16:00",
                status: .previous,
                narrationScript: "",
                isActive: false
            )
        ]
        
        matches = [liveMatch, upcomingMatch, previousMatch] + additionalMatches
    }
    
    private func loadScript(fileName: String) -> String {
        // Intentar cargar desde el bundle principal
        if let path = Bundle.main.path(forResource: fileName, ofType: "txt"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            return content
        }
        
        // Intentar cargar desde la carpeta NarrationScripts
        if let path = Bundle.main.path(forResource: "NarrationScripts/\(fileName)", ofType: "txt"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            return content
        }
        
        // Si no encuentra el archivo, retorna un script por defecto
        return getDefaultScript(for: fileName)
    }
    
    private func getDefaultScript(for fileName: String) -> String {
        if fileName.contains("mexico_vs_brasil_live") {
            return """
            ¡Bienvenidos al Estadio Azteca! Estamos en vivo para el partido más esperado del día: México contra Brasil. 
            
            El ambiente está electrizante, más de 87 mil aficionados llenan este templo del fútbol. Los colores verde y amarillo se mezclan con el verde, blanco y rojo en las gradas. 
            
            Minuto 3: ¡Primera jugada peligrosa! Lozano corre por la banda derecha, centra al área... ¡Santi Giménez cabecea! La pelota pasa rozando el poste. ¡Qué inicio de partido!
            
            Minuto 15: Brasil responde con una jugada magistral. Neymar controla en el centro, da un pase filtrado a Vinicius Jr. que dispara... ¡Ochoa con una atajada espectacular! El portero mexicano mantiene el cero a cero.
            
            Minuto 33: ¡GOOOOOOL! ¡GOOOOOOL DE MÉXICO! Raúl Jiménez remata de cabeza un centro perfecto de Lozano. El Azteca estalla en júbilo. México 1, Brasil 0.
            
            Minuto 45+2: Al final del primer tiempo, el marcador sigue 1-0. México ha sido superior en la primera mitad, controlando el ritmo del juego.
            
            Minuto 67: Brasil presiona buscando el empate. Richarlison dispara desde fuera del área... ¡La pelota golpea el travesaño! El estadio contiene la respiración.
            
            Minuto 82: ¡Contraataque mexicano! Chucky Lozano corre solo, se enfrenta al portero... ¡Dispara! ¡GOOOOOOL! ¡2-0 para México! El Estadio Azteca está enloquecido.
            
            Minuto 90+4: ¡Final del partido! México gana 2-0 ante Brasil en el Estadio Azteca. Una victoria histórica que será recordada por siempre. ¡Viva México!
            """
        } else if fileName.contains("usa_vs_argentina_upcoming") {
            return """
            ¡Bienvenidos a la previa del partido más esperado de la fase de grupos! Estados Unidos se enfrentará a Argentina en el Estadio Azteca.
            
            El ambiente ya se siente en las calles de Ciudad de México. Miles de aficionados de ambos equipos han llegado desde temprano para vivir este momento histórico.
            
            Por el lado de Estados Unidos, el equipo llega con confianza tras sus victorias anteriores. Christian Pulisic y Giovanni Reyna son los jugadores a seguir, ambos han estado en excelente forma durante el torneo.
            
            Argentina, la campeona del mundo, llega con toda su experiencia. Lionel Messi, el capitán, busca seguir haciendo historia. Acompañado de Julián Álvarez, Enzo Fernández y el resto del equipo que conquistó Qatar 2022.
            
            Los expertos predicen un partido táctico. Estados Unidos buscará aprovechar su velocidad y energía, mientras que Argentina confiará en su experiencia y calidad técnica.
            
            El Estadio Azteca se prepara para recibir a más de 87 mil espectadores. Las gradas ya se llenan de colores: rojo, blanco y azul por un lado, celeste y blanco por el otro.
            
            Este encuentro puede definir el primer lugar del grupo. Ambos equipos llegan invictos, así que hoy será una batalla por el liderato.
            
            El pitido inicial será a las 4 de la tarde, hora local. ¡Prepárense para un partido de infarto! ¡No se lo pierdan!
            """
        } else if fileName.contains("canada_vs_spain_previous") {
            return """
            Retrocedamos al pasado, al partido que conmocionó a todos el 12 de junio: Canadá contra España.
            
            El partido comenzó con España dominando el balón, como es su costumbre. La roja presionaba alta, buscando el gol tempranero. Minuto 8: Asensio dispara desde fuera del área... ¡Gol! España se adelanta 1-0.
            
            Pero Canadá no se rindió. Los canadienses, con su garra característica, comenzaron a presionar. Minuto 23: ¡Jonathan David! El delantero aprovecha un error defensivo y empata el partido. 1-1.
            
            Minuto 34: España vuelve a adelantarse. Morata remata un centro perfecto de Pedri. 2-1 para España al descanso.
            
            Segundo tiempo: Canadá salió transformado. Alphonso Davies, el mejor jugador de la MLS, comenzó a desbordar por la izquierda. Minuto 58: Davies centra, David remata de cabeza... ¡Gol! ¡Empate 2-2!
            
            Minuto 72: ¡Qué jugada! Davies roba el balón en medio campo, corre 50 metros, se enfrenta al portero... ¡Golazo! Canadá se adelanta 3-2. ¡Increíble!
            
            España, desesperada, lanzó todo al ataque. Minuto 89: Oyarzabal dispara... ¡Otra vez Davies! El canadiense bloquea el tiro en la línea. ¡Heroico!
            
            Minuto 90+3: Final del partido. Canadá vence 3-2 a España en una de las sorpresas del torneo. Alphonso Davies fue la figura del partido con un gol y una asistencia.
            
            Una victoria histórica para el fútbol canadiense que será recordada como una de las grandes hazañas del Mundial 2026.
            """
        }
        
        return "Script de narración no disponible."
    }
    
    func getMatches(for status: MatchStatus) -> [Match] {
        matches.filter { $0.status == status }
    }
    
    func getActiveMatch(for status: MatchStatus) -> Match? {
        matches.first { $0.status == status && $0.isActive }
    }
}

