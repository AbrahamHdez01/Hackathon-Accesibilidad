import SwiftUI

struct HeaderBar: View {
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 22, weight: .regular))
            Spacer()
            Text("FIFA WORLD CUP")
                .font(.system(size: 18, weight: .heavy))
                .kerning(1)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 22, weight: .regular))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.clear)
    }
}

#Preview { HeaderBar().background(Color.pitchGreen) }
