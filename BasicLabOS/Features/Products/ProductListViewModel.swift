import Foundation
import Observation

@Observable
@MainActor
final class ProductListViewModel {
    var items: [Product] = []
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    private(set) var hasMore = true

    private var currentPage = 0
    private let productService: ProductService
    private let categoryService: CategoryService
    private let accessToken: String

    init(
        accessToken: String,
        productService: ProductService,
        categoryService: CategoryService
    ) {
        self.accessToken = accessToken
        self.productService = productService
        self.categoryService = categoryService
    }

    func categoryLabel(for product: Product) -> String? {
        categoryService.label(for: product.categoryId)
    }

    func loadInitial() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil
        currentPage = 0
        hasMore = true
        items = []

        defer { isLoading = false }

        do {
            try? await categoryService.loadIfNeeded(accessToken: accessToken)
            let result = try await fetchPage(1)
            items = result.items
            hasMore = result.hasMore
            currentPage = 1
        } catch {
            errorMessage = APIErrorMessage.message(for: error)
        }
    }

    func refresh() async {
        await loadInitial()
    }

    func loadMoreIfNeeded(currentItem: Product) async {
        guard hasMore, !isLoading, !isLoadingMore else {
            return
        }
        guard let index = items.firstIndex(of: currentItem), index >= items.count - 6 else {
            return
        }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let nextPage = currentPage + 1
            let result = try await fetchPage(nextPage)
            items.append(contentsOf: result.items)
            hasMore = result.hasMore
            currentPage = nextPage
        } catch {
            errorMessage = APIErrorMessage.message(for: error)
        }
    }

    private func fetchPage(_ page: Int) async throws -> (items: [Product], hasMore: Bool) {
        try await productService.getProducts(
            page: page,
            accessToken: accessToken
        )
    }
}
