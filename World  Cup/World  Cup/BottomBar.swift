import SwiftUI

struct BottomBar: View {
    var body: some View {
        HStack(spacing: 28) {
            barItem(icon: "house", title: "Home", selected: true)
            barItem(icon: "calendar", title: "Schedule")
            barItem(icon: "building.2", title: "Venues")
            barItem(icon: "star", title: "Favorites")
        }
        .padding(.top, 10)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
        .padding(.horizontal, 16)
    }

    private func barItem(icon: String, title: String, selected: Bool = false) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: selected ? .semibold : .regular))
            Text(title)
                .font(.system(size: 12, weight: selected ? .semibold : .regular))
        }
        .foregroundColor(selected ? .primary : .secondary)
        .frame(maxWidth: .infinity)
    }
}

#Preview { BottomBar() }
