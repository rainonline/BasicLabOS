import SwiftUI

struct ProductCardView: View {
    let product: Product
    let categoryLabel: String?

    private let mediaCornerRadius: CGFloat = 12
    private let cardCornerRadius: CGFloat = 16
    /// 图片 / 标题 / 内容区 / 价签 之间的统一间距
    private let sectionSpacing: CGFloat = 6
    /// 内容区内部（编码、meta）行距
    private let contentLineSpacing: CGFloat = 2

    var body: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            mediaSection
            titleText
            contentSection
            priceRow
        }
        .padding(8)
        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .fill(.regularMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }

    private var titleText: some View {
        Text(product.name)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.primary)
            .lineLimit(2)
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: contentLineSpacing) {
            Text(
                ProductCardFormatter.subtitle(
                    productCode: product.productCode,
                    productUid: product.productUid
                )
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(metaLineText)
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .opacity(metaLineText.isEmpty ? 0 : 1)
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }

    private var priceRow: some View {
        HStack {
            Text(PriceFormatter.formatCny(product.price))
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .glassEffect(.regular, in: .capsule)
            Spacer(minLength: 0)
        }
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
                    .padding(6)
                }
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
            Color.secondary.opacity(0.12)
            Image(systemName: "photo")
                .font(.title3)
                .foregroundStyle(.tertiary)
        }
    }
}
