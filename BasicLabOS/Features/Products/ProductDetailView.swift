import SwiftUI

struct ProductDetailView: View {
    let productUid: String
    let accessToken: String

    @State private var viewModel: ProductDetailViewModel?

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel: viewModel)
            } else {
                ProgressView("加载中…")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(CatalogSurfaceStyle.canvas)
        .task {
            guard viewModel == nil else {
                return
            }
            let model = ProductDetailViewModel(productUid: productUid, accessToken: accessToken)
            viewModel = model
            await model.load()
        }
    }

    @ViewBuilder
    private func content(viewModel: ProductDetailViewModel) -> some View {
        if viewModel.isLoading, viewModel.product == nil {
            ProgressView("加载中…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage, viewModel.product == nil {
            ContentUnavailableView {
                Label("加载失败", systemImage: "exclamationmark.triangle")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("重试") {
                    Task {
                        await viewModel.load()
                    }
                }
                .buttonStyle(.glassProminent)
            }
        } else if let product = viewModel.product {
            detailList(product: product, viewModel: viewModel)
                .navigationTitle(product.name)
        }
    }

    @ViewBuilder
    private func detailList(product: ProductDetail, viewModel: ProductDetailViewModel) -> some View {
        List {
            heroImageSection(product: product)
            summarySection(product: product)
            infoSection(product: product, viewModel: viewModel)
            complianceSection(product: product)
            operationsSection(product: product)
            notesSection(product: product)
            attributesSection(product: product)
            variantsSection(variants: viewModel.variants)
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(12)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func heroImageSection(product: ProductDetail) -> some View {
        Section {
            heroImage(url: product.mainImageURL)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder
    private func summarySection(product: ProductDetail) -> some View {
        let description = product.description?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let status = product.status?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let hasSummary = description != nil || status != nil

        if hasSummary {
            Section {
                if let description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let status {
                    LabeledContent("状态") {
                        Text(ProductStatusLabel.displayName(for: status))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func infoSection(product: ProductDetail, viewModel: ProductDetailViewModel) -> some View {
        Section("商品信息") {
            LabeledContent("类目", value: viewModel.categoryLabel(for: product) ?? "—")
            LabeledContent("商品编码", value: product.productCode?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "—")
            LabeledContent("品牌", value: masterDataLabel(code: product.brandCode, name: product.brandName))
            LabeledContent("系列", value: masterDataLabel(code: product.seriesCode, name: product.seriesName))
            if let status = product.status?.trimmingCharacters(in: .whitespacesAndNewlines), !status.isEmpty {
                LabeledContent("商品状态") {
                    Text(ProductStatusLabel.displayName(for: status))
                }
            }
        }
    }

    @ViewBuilder
    private func complianceSection(product: ProductDetail) -> some View {
        Section("内容与合规") {
            LabeledContent("合规标准") {
                if product.complianceStandards.isEmpty {
                    Text("—")
                } else {
                    Text(product.complianceStandards.joined(separator: "、"))
                        .multilineTextAlignment(.trailing)
                }
            }

            if product.sellingPoints.isEmpty {
                LabeledContent("卖点", value: "—")
            } else {
                ForEach(Array(product.sellingPoints.enumerated()), id: \.offset) { index, point in
                    LabeledContent("卖点 \(index + 1)", value: point)
                }
            }

            LabeledContent("使用注意事项") {
                Text(product.usageCaution?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "—")
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    @ViewBuilder
    private func operationsSection(product: ProductDetail) -> some View {
        Section("销售运营") {
            LabeledContent("是否推荐", value: booleanLabel(product.isFeatured))
            LabeledContent("优先级", value: product.priorityLevel.map(String.init) ?? "未设置")
            LabeledContent("Tag") {
                if product.tags.isEmpty {
                    Text("未设置")
                } else {
                    Text(product.tags.map(\.name).joined(separator: "、"))
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }

    @ViewBuilder
    private func notesSection(product: ProductDetail) -> some View {
        let notes = product.notes?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let createdAt = DateTimeDisplayFormatter.format(product.createdAt)
        let updatedAt = DateTimeDisplayFormatter.format(product.updatedAt)
        let hasContent = notes != nil || createdAt != nil || updatedAt != nil

        Section("备注与时间") {
            if let notes {
                LabeledContent("内部备注") {
                    Text(notes)
                        .multilineTextAlignment(.trailing)
                }
            }
            if let createdAt {
                LabeledContent("创建时间", value: createdAt)
            }
            if let updatedAt {
                LabeledContent("更新时间", value: updatedAt)
            }
            if !hasContent {
                Text("暂无备注与时间信息。")
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func attributesSection(product: ProductDetail) -> some View {
        Section("扩展属性") {
            if product.attributeValues.isEmpty {
                Text(product.pimProductId == nil ? "暂无 PIM 产品关联。" : "暂无扩展属性。")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(product.attributeValues) { attribute in
                    LabeledContent(attribute.attributeCode, value: attribute.displayValue)
                }
            }
        }
    }

    @ViewBuilder
    private func variantsSection(variants: [ProductVariant]) -> some View {
        Section("规格") {
            if variants.isEmpty {
                ContentUnavailableView(
                    "暂无规格",
                    systemImage: "cube",
                    description: Text("该商品尚未登记规格。")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(variants) { variant in
                    ProductVariantRowView(variant: variant)
                }
            }
        }
    }

    @ViewBuilder
    private func heroImage(url: URL?) -> some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        heroPlaceholder
                    case let .success(image):
                        image.resizable().scaledToFill()
                    case .failure:
                        heroPlaceholder
                    @unknown default:
                        heroPlaceholder
                    }
                }
            } else {
                heroPlaceholder
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.quaternary.opacity(0.55), lineWidth: 0.5)
        }
    }

    private var heroPlaceholder: some View {
        ZStack {
            Color(.secondarySystemFill)
            Image(systemName: "photo")
                .font(.largeTitle.weight(.light))
                .foregroundStyle(.quaternary)
                .symbolRenderingMode(.hierarchical)
        }
    }

    private func masterDataLabel(code: String?, name: String?) -> String {
        let resolvedName = name?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let resolvedCode = code?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty

        switch (resolvedName, resolvedCode) {
        case let (name?, code?):
            return "\(name)（\(code)）"
        case let (name?, nil):
            return name
        case let (nil, code?):
            return code
        case (nil, nil):
            return "—"
        }
    }

    private func booleanLabel(_ value: Bool) -> String {
        value ? "是" : "否"
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
