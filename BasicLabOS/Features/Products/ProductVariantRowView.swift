import SwiftUI

struct ProductVariantRowView: View {
    let variant: ProductVariant

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(variant.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    if variant.isMasterVariant {
                        Text("主规格")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule(style: .continuous).fill(.secondary.opacity(0.18)))
                    }
                }

                if let code = variant.variantCode?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty {
                    Text(code)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    if let status = variant.status?.trimmingCharacters(in: .whitespacesAndNewlines), !status.isEmpty {
                        Text(VariantStatusLabel.displayName(for: status))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Text(PriceFormatter.formatCny(variant.retailPrice))
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var thumbnail: some View {
        Group {
            if let url = variant.mainImageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case let .success(image):
                        image.resizable().scaledToFill()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(.quaternary.opacity(0.55), lineWidth: 0.5)
        }
    }

    private var placeholder: some View {
        ZStack {
            Color(.secondarySystemFill)
            Image(systemName: "cube")
                .font(.caption)
                .foregroundStyle(.quaternary)
        }
    }
}
