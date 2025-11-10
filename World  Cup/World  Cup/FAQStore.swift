import Foundation
import SwiftUI

// MARK: - FAQ Store
class FAQStore: ObservableObject {
    @Published var root: FAQRoot?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        loadFAQs()
    }
    
    func loadFAQs() {
        isLoading = true
        errorMessage = nil
        
        // Intentar cargar desde el bundle
        if let url = Bundle.main.url(forResource: "faqs", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                root = try decoder.decode(FAQRoot.self, from: data)
                isLoading = false
                return
            } catch {
                print("⚠️ Error al decodificar faqs.json: \(error.localizedDescription)")
                // Continuar con datos por defecto
            }
        } else {
            print("⚠️ No se encontró faqs.json en el bundle, usando datos por defecto")
        }
        
        // Si no se pudo cargar, usar datos por defecto
        root = getDefaultFAQs()
        isLoading = false
    }
    
    private func getDefaultFAQs() -> FAQRoot {
        return FAQRoot(languages: [
            LanguagePack(
                code: "es",
                name: "Español",
                faqs: [
                    FAQItem(q: "¿Dónde están los baños?", a: "Los baños están ubicados en cada nivel del estadio, junto a las zonas de comida. También hay baños accesibles señalizados con el símbolo internacional. 🚻"),
                    FAQItem(q: "¿Hay Wi-Fi gratis?", a: "Sí, hay Wi-Fi gratis disponible en todo el estadio. La red se llama STADIUM_FREE. Acepta los términos y condiciones en el portal de acceso."),
                    FAQItem(q: "¿Dónde están las zonas accesibles?", a: "Las zonas accesibles están señalizadas con el símbolo internacional de accesibilidad. Hay elevadores en las entradas principales y rampas en todas las secciones. Consulta el mapa para ubicar la sección más cercana."),
                    FAQItem(q: "¿Puedo traer comida?", a: "Se permite traer comida en contenedores transparentes. No se permiten latas, botellas de vidrio ni alcohol. Hay puestos de comida disponibles en cada nivel."),
                    FAQItem(q: "¿Dónde está el estacionamiento?", a: "El estacionamiento principal está en la zona norte del estadio. Hay espacios reservados para personas con discapacidad cerca de las entradas accesibles. El estacionamiento se llena rápido, te recomendamos llegar temprano."),
                    FAQItem(q: "¿Hay servicio médico?", a: "Sí, hay puestos de primeros auxilios en cada nivel del estadio, señalizados con una cruz roja. Si necesitas ayuda médica, contacta al personal de seguridad más cercano."),
                    FAQItem(q: "¿Cómo llego en transporte público?", a: "El estadio está conectado con varias líneas de metro y autobuses. La estación más cercana es 'Estadio Azteca'. Hay paradas de autobús accesibles en la entrada sur."),
                    FAQItem(q: "¿Dónde puedo comprar boletos?", a: "Los boletos se pueden comprar en las taquillas oficiales ubicadas en las entradas principales, o en línea a través de la página oficial del estadio. Hay descuentos para personas con discapacidad."),
                    FAQItem(q: "¿Hay cajeros automáticos?", a: "Sí, hay cajeros automáticos en cada nivel del estadio, cerca de las entradas principales y zonas de comida. Aceptan las principales tarjetas de crédito y débito."),
                    FAQItem(q: "¿Puedo salir y volver a entrar?", a: "No, una vez que sales del estadio no puedes volver a entrar con el mismo boleto. Si necesitas salir, deberás comprar un nuevo boleto para reingresar."),
                    FAQItem(q: "¿Dónde está la zona VIP?", a: "La zona VIP está ubicada en el nivel superior del estadio, con acceso exclusivo por la entrada oeste. Incluye restaurantes, bares y asientos preferenciales."),
                    FAQItem(q: "¿Hay guardarropa?", a: "Sí, hay servicio de guardarropa disponible en las entradas principales. El costo es de $50 pesos por artículo. Se recomienda no dejar objetos de valor."),
                    FAQItem(q: "¿Puedo traer una mochila?", a: "Se permiten mochilas pequeñas (máximo 30x30 cm). Todas las mochilas serán revisadas en la entrada. No se permiten mochilas grandes ni mochilas con ruedas."),
                    FAQItem(q: "¿Hay estacionamiento para bicicletas?", a: "Sí, hay un área designada para estacionar bicicletas cerca de la entrada sur. Es gratuita pero no hay vigilancia, así que trae tu propia cadena de seguridad."),
                    FAQItem(q: "¿Dónde puedo cargar mi teléfono?", a: "Hay estaciones de carga disponibles en cada nivel, cerca de las zonas de comida y baños. Trae tu propio cable. También hay power banks disponibles para renta."),
                    FAQItem(q: "¿Hay servicio de intérprete de señas?", a: "Sí, hay servicio gratuito de intérprete de señas disponible. Debes solicitarlo con anticipación en la página web del estadio o en las taquillas al momento de comprar tu boleto."),
                    FAQItem(q: "¿Puedo traer mi perro de servicio?", a: "Sí, los perros de servicio son bienvenidos. Deben estar identificados con su chaleco oficial y tener toda su documentación al día. Contacta al personal de seguridad al llegar."),
                    FAQItem(q: "¿Hay áreas de descanso?", a: "Sí, hay áreas de descanso con asientos cómodos en cada nivel, especialmente diseñadas para personas mayores o con movilidad reducida. Están señalizadas claramente."),
                    FAQItem(q: "¿Dónde está la oficina de objetos perdidos?", a: "La oficina de objetos perdidos está ubicada en la entrada principal, nivel 1. Está abierta durante todo el evento y hasta una hora después de que termine."),
                    FAQItem(q: "¿Puedo traer una silla de ruedas?", a: "Sí, las sillas de ruedas son bienvenidas. Hay espacios designados para sillas de ruedas en todas las secciones. Si necesitas una silla de ruedas, puedes rentarla en la entrada principal."),
                    FAQItem(q: "¿Hay servicio de enfermería?", a: "Sí, hay una enfermería completa en cada nivel del estadio, con personal médico capacitado. Está señalizada con una cruz verde y está disponible durante todo el evento."),
                    FAQItem(q: "¿Dónde puedo comprar souvenirs?", a: "Hay tiendas oficiales de souvenirs en cada nivel del estadio, cerca de las entradas principales. También hay vendedores ambulantes autorizados en los pasillos."),
                    FAQItem(q: "¿Hay áreas para fumadores?", a: "No, el estadio es completamente libre de humo. Está prohibido fumar en cualquier área del estadio, incluyendo las áreas exteriores cercanas a las entradas."),
                    FAQItem(q: "¿Puedo traer una cámara profesional?", a: "Se permiten cámaras personales y teléfonos con cámara. No se permiten cámaras profesionales con lentes intercambiables ni equipos de grabación profesional sin autorización previa."),
                    FAQItem(q: "¿Hay servicio de taxi o Uber?", a: "Sí, hay una zona designada para taxis y servicios de transporte compartido (Uber, Didi) en la salida sur del estadio. Está señalizada claramente y hay personal que ayuda a organizar las filas.")
                ]
            ),
            LanguagePack(
                code: "en",
                name: "English",
                faqs: [
                    FAQItem(q: "Where are the restrooms?", a: "Restrooms are located on every level of the stadium, next to food courts. There are also accessible restrooms marked with the international symbol. 🚻"),
                    FAQItem(q: "Is there free Wi-Fi?", a: "Yes, free Wi-Fi is available throughout the stadium. The network is called STADIUM_FREE. Accept the terms and conditions on the access portal."),
                    FAQItem(q: "Where are the accessible areas?", a: "Accessible areas are marked with the international accessibility symbol. There are elevators at the main entrances and ramps in all sections. Check the map to find the nearest section."),
                    FAQItem(q: "Can I bring food?", a: "Food is allowed in transparent containers. Cans, glass bottles, and alcohol are not permitted. Food stands are available on every level."),
                    FAQItem(q: "Where is the parking?", a: "The main parking is in the north zone of the stadium. There are reserved spaces for people with disabilities near accessible entrances. Parking fills up quickly, we recommend arriving early."),
                    FAQItem(q: "Is there medical service?", a: "Yes, there are first aid stations on every level of the stadium, marked with a red cross. If you need medical assistance, contact the nearest security personnel."),
                    FAQItem(q: "How do I get here by public transport?", a: "The stadium is connected to several metro and bus lines. The nearest station is 'Estadio Azteca'. There are accessible bus stops at the south entrance."),
                    FAQItem(q: "Where can I buy tickets?", a: "Tickets can be purchased at official ticket offices located at the main entrances, or online through the stadium's official website. There are discounts for people with disabilities."),
                    FAQItem(q: "Are there ATMs?", a: "Yes, there are ATMs on every level of the stadium, near the main entrances and food courts. They accept major credit and debit cards."),
                    FAQItem(q: "Can I leave and re-enter?", a: "No, once you leave the stadium you cannot re-enter with the same ticket. If you need to leave, you will need to purchase a new ticket to re-enter."),
                    FAQItem(q: "Where is the VIP area?", a: "The VIP area is located on the upper level of the stadium, with exclusive access through the west entrance. It includes restaurants, bars, and premium seating."),
                    FAQItem(q: "Is there a coat check?", a: "Yes, coat check service is available at the main entrances. The cost is $50 pesos per item. It is recommended not to leave valuables."),
                    FAQItem(q: "Can I bring a backpack?", a: "Small backpacks are allowed (maximum 30x30 cm). All backpacks will be checked at the entrance. Large backpacks and wheeled backpacks are not permitted."),
                    FAQItem(q: "Is there bicycle parking?", a: "Yes, there is a designated area for bicycle parking near the south entrance. It is free but there is no surveillance, so bring your own security chain."),
                    FAQItem(q: "Where can I charge my phone?", a: "There are charging stations available on every level, near food courts and restrooms. Bring your own cable. Power banks are also available for rent."),
                    FAQItem(q: "Is there sign language interpreter service?", a: "Yes, free sign language interpreter service is available. You must request it in advance on the stadium's website or at ticket offices when purchasing your ticket."),
                    FAQItem(q: "Can I bring my service dog?", a: "Yes, service dogs are welcome. They must be identified with their official vest and have all their documentation up to date. Contact security personnel upon arrival."),
                    FAQItem(q: "Are there rest areas?", a: "Yes, there are rest areas with comfortable seating on every level, especially designed for elderly people or those with reduced mobility. They are clearly marked."),
                    FAQItem(q: "Where is the lost and found office?", a: "The lost and found office is located at the main entrance, level 1. It is open throughout the event and until one hour after it ends."),
                    FAQItem(q: "Can I bring a wheelchair?", a: "Yes, wheelchairs are welcome. There are designated spaces for wheelchairs in all sections. If you need a wheelchair, you can rent one at the main entrance."),
                    FAQItem(q: "Is there a nursing service?", a: "Yes, there is a complete nursing station on every level of the stadium, with trained medical staff. It is marked with a green cross and is available throughout the event."),
                    FAQItem(q: "Where can I buy souvenirs?", a: "There are official souvenir shops on every level of the stadium, near the main entrances. There are also authorized street vendors in the hallways."),
                    FAQItem(q: "Are there smoking areas?", a: "No, the stadium is completely smoke-free. Smoking is prohibited in any area of the stadium, including exterior areas near the entrances."),
                    FAQItem(q: "Can I bring a professional camera?", a: "Personal cameras and camera phones are allowed. Professional cameras with interchangeable lenses and professional recording equipment are not permitted without prior authorization."),
                    FAQItem(q: "Is there taxi or Uber service?", a: "Yes, there is a designated area for taxis and ride-sharing services (Uber, Didi) at the south exit of the stadium. It is clearly marked and there is staff to help organize the lines.")
                ]
            ),
            LanguagePack(
                code: "pt",
                name: "Português",
                faqs: [
                    FAQItem(q: "Onde estão os banheiros?", a: "Os banheiros estão localizados em cada nível do estádio, ao lado das áreas de alimentação. Também há banheiros acessíveis sinalizados com o símbolo internacional. 🚻"),
                    FAQItem(q: "Há Wi-Fi gratuito?", a: "Sim, há Wi-Fi gratuito disponível em todo o estádio. A rede se chama STADIUM_FREE. Aceite os termos e condições no portal de acesso."),
                    FAQItem(q: "Onde estão as áreas acessíveis?", a: "As áreas acessíveis estão sinalizadas com o símbolo internacional de acessibilidade. Há elevadores nas entradas principais e rampas em todas as seções. Consulte o mapa para localizar a seção mais próxima."),
                    FAQItem(q: "Posso trazer comida?", a: "É permitido trazer comida em recipientes transparentes. Latas, garrafas de vidro e álcool não são permitidos. Há barracas de comida disponíveis em cada nível."),
                    FAQItem(q: "Onde fica o estacionamento?", a: "O estacionamento principal fica na zona norte do estádio. Há vagas reservadas para pessoas com deficiência perto das entradas acessíveis. O estacionamento enche rapidamente, recomendamos chegar cedo."),
                    FAQItem(q: "Há serviço médico?", a: "Sim, há postos de primeiros socorros em cada nível do estádio, sinalizados com uma cruz vermelha. Se precisar de assistência médica, entre em contato com o pessoal de segurança mais próximo."),
                    FAQItem(q: "Como chego de transporte público?", a: "O estádio está conectado a várias linhas de metrô e ônibus. A estação mais próxima é 'Estadio Azteca'. Há paradas de ônibus acessíveis na entrada sul."),
                    FAQItem(q: "Onde posso comprar ingressos?", a: "Os ingressos podem ser comprados nas bilheterias oficiais localizadas nas entradas principais, ou online através do site oficial do estádio. Há descontos para pessoas com deficiência."),
                    FAQItem(q: "Há caixas eletrônicos?", a: "Sim, há caixas eletrônicos em cada nível do estádio, perto das entradas principais e áreas de alimentação. Eles aceitam os principais cartões de crédito e débito."),
                    FAQItem(q: "Posso sair e voltar a entrar?", a: "Não, uma vez que você saia do estádio, não pode voltar a entrar com o mesmo ingresso. Se precisar sair, terá que comprar um novo ingresso para reingressar."),
                    FAQItem(q: "Onde fica a área VIP?", a: "A área VIP está localizada no nível superior do estádio, com acesso exclusivo pela entrada oeste. Inclui restaurantes, bares e assentos preferenciais."),
                    FAQItem(q: "Há guarda-volumes?", a: "Sim, há serviço de guarda-volumes disponível nas entradas principais. O custo é de $50 pesos por item. Recomenda-se não deixar objetos de valor."),
                    FAQItem(q: "Posso trazer uma mochila?", a: "Mochilas pequenas são permitidas (máximo 30x30 cm). Todas as mochilas serão revistadas na entrada. Mochilas grandes e mochilas com rodas não são permitidas."),
                    FAQItem(q: "Há estacionamento para bicicletas?", a: "Sim, há uma área designada para estacionar bicicletas perto da entrada sul. É gratuita, mas não há vigilância, então traga sua própria corrente de segurança."),
                    FAQItem(q: "Onde posso carregar meu celular?", a: "Há estações de carregamento disponíveis em cada nível, perto das áreas de alimentação e banheiros. Traga seu próprio cabo. Também há power banks disponíveis para aluguel."),
                    FAQItem(q: "Há serviço de intérprete de libras?", a: "Sim, há serviço gratuito de intérprete de libras disponível. Você deve solicitá-lo com antecedência no site do estádio ou nas bilheterias ao comprar seu ingresso."),
                    FAQItem(q: "Posso trazer meu cão de serviço?", a: "Sim, cães de serviço são bem-vindos. Eles devem estar identificados com seu colete oficial e ter toda a documentação em dia. Entre em contato com o pessoal de segurança ao chegar."),
                    FAQItem(q: "Há áreas de descanso?", a: "Sim, há áreas de descanso com assentos confortáveis em cada nível, especialmente projetadas para idosos ou pessoas com mobilidade reduzida. Elas estão claramente sinalizadas."),
                    FAQItem(q: "Onde fica o escritório de objetos perdidos?", a: "O escritório de objetos perdidos está localizado na entrada principal, nível 1. Está aberto durante todo o evento e até uma hora após o término."),
                    FAQItem(q: "Posso trazer uma cadeira de rodas?", a: "Sim, cadeiras de rodas são bem-vindas. Há espaços designados para cadeiras de rodas em todas as seções. Se precisar de uma cadeira de rodas, você pode alugar uma na entrada principal."),
                    FAQItem(q: "Há serviço de enfermagem?", a: "Sim, há uma enfermaria completa em cada nível do estádio, com pessoal médico treinado. Está sinalizada com uma cruz verde e está disponível durante todo o evento."),
                    FAQItem(q: "Onde posso comprar lembranças?", a: "Há lojas oficiais de lembranças em cada nível do estádio, perto das entradas principais. Também há vendedores ambulantes autorizados nos corredores."),
                    FAQItem(q: "Há áreas para fumantes?", a: "Não, o estádio é completamente livre de fumo. É proibido fumar em qualquer área do estádio, incluindo áreas exteriores próximas às entradas."),
                    FAQItem(q: "Posso trazer uma câmera profissional?", a: "Câmeras pessoais e telefones com câmera são permitidos. Câmeras profissionais com lentes intercambiáveis e equipamentos de gravação profissional não são permitidos sem autorização prévia."),
                    FAQItem(q: "Há serviço de táxi ou Uber?", a: "Sim, há uma área designada para táxis e serviços de transporte compartilhado (Uber, Didi) na saída sul do estádio. Está claramente sinalizada e há pessoal para ajudar a organizar as filas.")
                ]
            ),
            LanguagePack(
                code: "fr",
                name: "Français",
                faqs: [
                    FAQItem(q: "Où sont les toilettes?", a: "Les toilettes sont situées à chaque niveau du stade, à côté des zones de restauration. Il y a aussi des toilettes accessibles signalées avec le symbole international. 🚻"),
                    FAQItem(q: "Y a-t-il du Wi-Fi gratuit?", a: "Oui, le Wi-Fi gratuit est disponible dans tout le stade. Le réseau s'appelle STADIUM_FREE. Acceptez les termes et conditions sur le portail d'accès."),
                    FAQItem(q: "Où sont les zones accessibles?", a: "Les zones accessibles sont signalées avec le symbole international d'accessibilité. Il y a des ascenseurs aux entrées principales et des rampes dans toutes les sections. Consultez la carte pour trouver la section la plus proche."),
                    FAQItem(q: "Puis-je apporter de la nourriture?", a: "La nourriture est autorisée dans des contenants transparents. Les canettes, bouteilles en verre et l'alcool ne sont pas autorisés. Des stands de nourriture sont disponibles à chaque niveau."),
                    FAQItem(q: "Où est le parking?", a: "Le parking principal se trouve dans la zone nord du stade. Il y a des places réservées pour les personnes handicapées près des entrées accessibles. Le parking se remplit rapidement, nous recommandons d'arriver tôt."),
                    FAQItem(q: "Y a-t-il un service médical?", a: "Oui, il y a des postes de premiers secours à chaque niveau du stade, signalés par une croix rouge. Si vous avez besoin d'assistance médicale, contactez le personnel de sécurité le plus proche."),
                    FAQItem(q: "Comment y arriver en transport public?", a: "Le stade est connecté à plusieurs lignes de métro et de bus. La station la plus proche est 'Estadio Azteca'. Il y a des arrêts de bus accessibles à l'entrée sud."),
                    FAQItem(q: "Où puis-je acheter des billets?", a: "Les billets peuvent être achetés aux guichets officiels situés aux entrées principales, ou en ligne via le site officiel du stade. Il y a des réductions pour les personnes handicapées."),
                    FAQItem(q: "Y a-t-il des distributeurs automatiques?", a: "Oui, il y a des distributeurs automatiques à chaque niveau du stade, près des entrées principales et des zones de restauration. Ils acceptent les principales cartes de crédit et de débit."),
                    FAQItem(q: "Puis-je sortir et revenir?", a: "Non, une fois que vous quittez le stade, vous ne pouvez pas revenir avec le même billet. Si vous devez sortir, vous devrez acheter un nouveau billet pour réintégrer."),
                    FAQItem(q: "Où se trouve la zone VIP?", a: "La zone VIP est située au niveau supérieur du stade, avec un accès exclusif par l'entrée ouest. Elle comprend des restaurants, des bars et des sièges privilégiés."),
                    FAQItem(q: "Y a-t-il un vestiaire?", a: "Oui, le service de vestiaire est disponible aux entrées principales. Le coût est de 50 pesos par article. Il est recommandé de ne pas laisser d'objets de valeur."),
                    FAQItem(q: "Puis-je apporter un sac à dos?", a: "Les petits sacs à dos sont autorisés (maximum 30x30 cm). Tous les sacs à dos seront vérifiés à l'entrée. Les grands sacs à dos et les sacs à dos à roulettes ne sont pas autorisés."),
                    FAQItem(q: "Y a-t-il un parking pour vélos?", a: "Oui, il y a une zone désignée pour garer les vélos près de l'entrée sud. C'est gratuit mais il n'y a pas de surveillance, alors apportez votre propre chaîne de sécurité."),
                    FAQItem(q: "Où puis-je charger mon téléphone?", a: "Il y a des stations de charge disponibles à chaque niveau, près des zones de restauration et des toilettes. Apportez votre propre câble. Des power banks sont également disponibles à la location."),
                    FAQItem(q: "Y a-t-il un service d'interprète en langue des signes?", a: "Oui, un service gratuit d'interprète en langue des signes est disponible. Vous devez le demander à l'avance sur le site web du stade ou aux guichets lors de l'achat de votre billet."),
                    FAQItem(q: "Puis-je apporter mon chien d'assistance?", a: "Oui, les chiens d'assistance sont les bienvenus. Ils doivent être identifiés avec leur gilet officiel et avoir toute leur documentation à jour. Contactez le personnel de sécurité à l'arrivée."),
                    FAQItem(q: "Y a-t-il des zones de repos?", a: "Oui, il y a des zones de repos avec des sièges confortables à chaque niveau, spécialement conçues pour les personnes âgées ou à mobilité réduite. Elles sont clairement signalées."),
                    FAQItem(q: "Où se trouve le bureau des objets trouvés?", a: "Le bureau des objets trouvés est situé à l'entrée principale, niveau 1. Il est ouvert pendant tout l'événement et jusqu'à une heure après la fin."),
                    FAQItem(q: "Puis-je apporter un fauteuil roulant?", a: "Oui, les fauteuils roulants sont les bienvenus. Il y a des espaces désignés pour les fauteuils roulants dans toutes les sections. Si vous avez besoin d'un fauteuil roulant, vous pouvez en louer un à l'entrée principale."),
                    FAQItem(q: "Y a-t-il un service d'infirmerie?", a: "Oui, il y a une infirmerie complète à chaque niveau du stade, avec du personnel médical formé. Elle est signalée par une croix verte et est disponible pendant tout l'événement."),
                    FAQItem(q: "Où puis-je acheter des souvenirs?", a: "Il y a des boutiques officielles de souvenirs à chaque niveau du stade, près des entrées principales. Il y a aussi des vendeurs ambulants autorisés dans les couloirs."),
                    FAQItem(q: "Y a-t-il des zones fumeurs?", a: "Non, le stade est entièrement non-fumeur. Il est interdit de fumer dans n'importe quelle zone du stade, y compris les zones extérieures près des entrées."),
                    FAQItem(q: "Puis-je apporter un appareil photo professionnel?", a: "Les appareils photo personnels et les téléphones avec appareil photo sont autorisés. Les appareils photo professionnels avec objectifs interchangeables et les équipements d'enregistrement professionnels ne sont pas autorisés sans autorisation préalable."),
                    FAQItem(q: "Y a-t-il un service de taxi ou Uber?", a: "Oui, il y a une zone désignée pour les taxis et les services de transport partagé (Uber, Didi) à la sortie sud du stade. Elle est clairement signalée et il y a du personnel pour aider à organiser les files d'attente.")
                ]
            )
        ])
    }
    
    func language(by code: String) -> LanguagePack? {
        return root?.languages.first { $0.code == code }
    }
    
    var allLanguages: [LanguagePack] {
        return root?.languages ?? []
    }
}

