import SwiftUI

struct BottomBar: View {
    var body: some View {
        // bottom beige con curvatura superior, solo iconos
        ZStack {
            RoundedCorner(radius: 28, corners: [.topLeft, .topRight])
                .fill(Color.sandBeige)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -2)

            HStack(spacing: 28) {
                icon("house.fill", selected: true)
                icon("magnifyingglass")
                icon("waveform")
                icon("paperplane.fill")
                icon("gearshape.fill")
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 22)
            .foregroundColor(.white)
        }
    }

    private func icon(_ systemName: String, selected: Bool = false) -> some View {
        Image(systemName: systemName)
            .font(.system(size: selected ? 22 : 20, weight: selected ? .semibold : .regular))
            .frame(maxWidth: .infinity)
    }
}

#Preview { BottomBar() }
