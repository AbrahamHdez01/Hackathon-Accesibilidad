import SwiftUI

struct HeaderBar: View {
    var body: some View {
        GeometryReader { geo in
            let safeAreaTop = geo.safeAreaInsets.top
            let screenWidth = geo.size.width

            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 24, weight: .medium))
                    Spacer()
                    Text("FIFA WORLD CUP")
                        .font(.system(size: min(30, screenWidth * 0.200), weight: .bold, design: .rounded))
                        .kerning(2)
                        .tracking(1)
                    Spacer()
                    Image(systemName: "line.3.horizontal").opacity(0)
                        .font(.system(size: 24, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.top, safeAreaTop + 8)
                .padding(.bottom, 8)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: safeAreaTop + 48)
            .ignoresSafeArea(edges: .top)
        }
    }
}

#Preview { HeaderBar().background(Color.pitchGreen) }
