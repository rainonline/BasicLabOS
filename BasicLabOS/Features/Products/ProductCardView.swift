import SwiftUI

struct ProductCardView: View {
    let product: Product
    let categoryLabel: String?

    private let cardCornerRadius: CGFloat = 18
    private let cardPadding: CGFloat = 10
    /// 同心圆角：内层半径 = 外层 − 内边距
    private var mediaCornerRadius: CGFloat { cardCornerRadius - cardPadding }
    private let sectionSpacing: CGFloat = 8
    private let contentLineSpacing: CGFloat = 3
    private let mediaBadgeInset: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            mediaSection
            textSection
            priceRow
        }
        .padding(cardPadding)
        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(CatalogSurfaceStyle.card)
                .shadow(color: .black.opacity(0.07), radius: 5, x: 0, y: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }

    private var textSection: some View {
        VStack(alignment: .leading, spacing: contentLineSpacing) {
            titleText

            Text(
                ProductCardFormatter.subtitle(
                    productCode: product.productCode,
                    productUid: product.productUid
                )
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
            .monospacedDigit()
            .lineLimit(1)
            .truncationMode(.middle)
            .frame(maxWidth: .infinity, alignment: .leading)

            if !metaLineText.isEmpty {
                Text(metaLineText)
                    .font(.caption2)
                    .foregroundStyle(.secondary.opacity(0.78))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }

    private var titleText: some View {
        Text(product.name)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.primary)
            .lineLimit(2)
            .lineSpacing(1)
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private var priceRow: some View {
        HStack(alignment: .firstTextBaseline) {
            if PriceFormatter.hasPrice(product.price) {
                Text(PriceFormatter.formatCny(product.price))
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .glassEffect(.regular, in: .capsule)
            } else {
                Text("未提供")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 1)
    }

    private var metaLineText: String {
        ProductCardFormatter.metaLine(
            category: categoryLabel,
            brand: product.brandName,
            series: product.seriesName
        )
    }

    private var mediaSection: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background {
                productImage
                    .scaledToFill()
            }
            .overlay {
                GlassEffectContainer {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top, spacing: 6) {
                            if product.isFeatured {
                                FeaturedGlassBadge()
                            }
                            Spacer(minLength: 0)
                        }

                        Spacer(minLength: 0)

                        HStack(alignment: .bottom, spacing: 6) {
                            Spacer(minLength: 0)
                            if let status = product.status?.trimmingCharacters(in: .whitespacesAndNewlines),
                               !status.isEmpty
                            {
                                ProductStatusGlassBadge(status: status)
                            }
                        }
                    }
                    .padding(mediaBadgeInset)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: mediaCornerRadius, style: .continuous)
                    .strokeBorder(.quaternary.opacity(0.55), lineWidth: 0.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: mediaCornerRadius, style: .continuous))
    }

    @ViewBuilder
    private var productImage: some View {
        if let url = product.mainImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    imagePlaceholder
                case let .success(image):
                    image
                        .resizable()
                        .transition(.opacity)
                case .failure:
                    imagePlaceholder
                @unknown default:
                    imagePlaceholder
                }
            }
        } else {
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        ZStack {
            Color(.secondarySystemFill)
            Image(systemName: "photo")
                .font(.title3.weight(.light))
                .foregroundStyle(.quaternary)
                .symbolRenderingMode(.hierarchical)
        }
    }
}
