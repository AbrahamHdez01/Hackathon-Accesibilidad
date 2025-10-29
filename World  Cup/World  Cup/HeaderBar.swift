import SwiftUI

struct HeaderBar: View {
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 22, weight: .regular))
            Spacer()
            Text("FIFA WORLD CUP")
                .font(.system(size: 18, weight: .heavy))
                .kerning(1)
            Spacer()
            Image(systemName: "line.3.horizontal").opacity(0)
                .font(.system(size: 22, weight: .regular))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(
            RoundedCorner(radius: 28, corners: [.bottomLeft, .bottomRight])
                .fill(Color.sandBeige)
        )
    }
}

#Preview { HeaderBar().background(Color.pitchGreen) }
