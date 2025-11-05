import SwiftUI

struct ChatAssistantView: View {
    var body: some View {
        ZStack {
            Color.routeDarkGreen.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Asistente Multilingüe")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.routeText)
                    .accessibilityAddTraits(.isHeader)
                Text("Placeholder – chat multilingüe y herramientas de traducción.")
                    .foregroundColor(.routeMuted)
                    .multilineTextAlignment(.center)
                    .padding()
                    .liquidGlass(intensity: .medium, cornerRadius: 20, padding: 0)
                    .accessibilityLabel("Asistente Multilingüe. Placeholder, chat multilingüe y herramientas de traducción")
            }
        }
        .navigationTitle("Asistente")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityLabel("Asistente Multilingüe")
    }
}

#Preview { ChatAssistantView() }


