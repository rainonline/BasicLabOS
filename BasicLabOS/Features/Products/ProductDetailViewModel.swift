import Foundation
import Observation

@Observable
@MainActor
final class ProductDetailViewModel {
    var product: ProductDetail?
    var variants: [ProductVariant] = []
    var isLoading = false
    var errorMessage: String?

    private let productUid: String
    private let accessToken: String
    private let productService: ProductService
    private let categoryService: CategoryService

    init(
        productUid: String,
        accessToken: String,
        productService: ProductService = ProductService(),
        categoryService: CategoryService = CategoryService()
    ) {
        self.productUid = productUid
        self.accessToken = accessToken
        self.productService = productService
        self.categoryService = categoryService
    }

    func categoryLabel(for product: ProductDetail) -> String? {
        categoryService.label(for: product.categoryId)
    }

    func load() async {
        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil
        product = nil
        variants = []

        defer { isLoading = false }

        do {
            try await categoryService.loadIfNeeded(accessToken: accessToken)
            let detail = try await productService.getProductDetail(
                productUid: productUid,
                accessToken: accessToken
            )
            product = detail

            async let variantsTask = productService.getVariants(
                ownedProductId: detail.ownedProductId,
                accessToken: accessToken
            )
            variants = try await variantsTask
        } catch {
            errorMessage = APIErrorMessage.message(for: error)
        }
    }
}
