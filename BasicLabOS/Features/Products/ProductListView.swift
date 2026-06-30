import SwiftUI

struct ProductListView: View {
    @Environment(AuthSessionStore.self) private var authStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var viewModel: ProductListViewModel?

    private var horizontalPadding: CGFloat {
        ProductCardLayout.horizontalPadding(for: horizontalSizeClass)
    }

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel: viewModel)
            } else {
                ProgressView("加载中…")
            }
        }
        .navigationTitle("商品")
        .tabRootNavigationStyle()
        .task {
            guard viewModel == nil, let token = authStore.accessToken else {
                return
            }
            let model = ProductListViewModel(
                accessToken: token,
                productService: ProductService(),
                categoryService: CategoryService()
            )
            viewModel = model
            await model.loadInitial()
        }
    }

    @ViewBuilder
    private func content(viewModel: ProductListViewModel) -> some View {
        mainContent(viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CatalogSurfaceStyle.canvas)
            .refreshable {
                await viewModel.refresh()
            }
    }

    @ViewBuilder
    private func mainContent(viewModel: ProductListViewModel) -> some View {
        if viewModel.isLoading, viewModel.items.isEmpty {
            loadingGrid
        } else if let errorMessage = viewModel.errorMessage, viewModel.items.isEmpty {
            errorState(message: errorMessage) {
                Task {
                    await viewModel.loadInitial()
                }
            }
            .padding(.horizontal, horizontalPadding)
        } else if viewModel.items.isEmpty {
            ContentUnavailableView(
                "暂无商品",
                systemImage: "shippingbox",
                description: Text("当前没有匹配的自营商品。")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, horizontalPadding)
        } else {
            ScrollView {
                LazyVGrid(
                    columns: ProductCardLayout.columns(for: horizontalSizeClass),
                    alignment: .leading,
                    spacing: ProductCardLayout.rowSpacing
                ) {
                    ForEach(viewModel.items) { product in
                        productCardLink(for: product, viewModel: viewModel)
                    }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .catalogCanvasBackground()
            .contentMargins(.horizontal, horizontalPadding, for: .scrollContent)
            .contentMargins(.vertical, 8, for: .scrollContent)
            .navigationDestination(for: String.self) { productUid in
                if let token = authStore.accessToken {
                    ProductDetailView(productUid: productUid, accessToken: token)
                }
            }
        }
    }

    @ViewBuilder
    private func productCardLink(for product: Product, viewModel: ProductListViewModel) -> some View {
        let card = ProductCardView(
            product: product,
            categoryLabel: viewModel.categoryLabel(for: product)
        )
        .frame(minWidth: 0, maxWidth: .infinity)
        .task {
            await viewModel.loadMoreIfNeeded(currentItem: product)
        }

        if let navigationUid = product.navigationUid, authStore.accessToken != nil {
            NavigationLink(value: navigationUid) {
                card
            }
            .buttonStyle(.plain)
        } else {
            card
        }
    }

    private var loadingGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: ProductCardLayout.columns(for: horizontalSizeClass),
                alignment: .leading,
                spacing: ProductCardLayout.rowSpacing
            ) {
                ForEach(0 ..< 6, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(CatalogSurfaceStyle.card)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: ProductCardLayout.skeletonHeight)
                }
            }
        }
        .catalogCanvasBackground()
        .contentMargins(.horizontal, horizontalPadding, for: .scrollContent)
        .contentMargins(.vertical, 8, for: .scrollContent)
    }

    private func errorState(message: String, retry: @escaping () -> Void) -> some View {
        ContentUnavailableView {
            Label("加载失败", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("重试", action: retry)
                .buttonStyle(.glassProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
