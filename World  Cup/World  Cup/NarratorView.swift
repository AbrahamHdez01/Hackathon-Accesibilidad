import SwiftUI

struct NarratorView: View {
    var body: some View {
        ZStack {
            Color.routeDarkGreen.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Narrador Universal")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.routeText)
                Text("Placeholder de MVP – aquí irá el narrador con TTS y descripciones de accesibilidad.")
                    .foregroundColor(.routeMuted)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .navigationTitle("Narrador")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview { NarratorView() }


