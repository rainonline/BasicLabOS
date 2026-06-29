import SwiftUI

struct ProductStatusGlassBadge: View {
    let status: String

    var body: some View {
        Text(ProductStatusLabel.displayName(for: status))
            .font(.caption2.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .glassEffect(.regular.tint(.black.opacity(0.55)), in: .capsule)
    }
}

struct FeaturedGlassBadge: View {
    var body: some View {
        Text("推荐")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .glassEffect(.regular.tint(.orange), in: .capsule)
    }
}
