import SwiftUI

struct ChatAssistantView: View {
    var body: some View {
        ZStack {
            Color.routeDarkGreen.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Asistente Multilingüe")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.routeText)
                Text("Placeholder – chat multilingüe y herramientas de traducción.")
                    .foregroundColor(.routeMuted)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .navigationTitle("Asistente")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview { ChatAssistantView() }


