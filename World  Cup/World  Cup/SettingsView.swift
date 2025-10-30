import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.pitchGreen.ignoresSafeArea()
            Text("Settings (placeholder)")
                .foregroundColor(.white)
                .padding()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview { SettingsView() }


