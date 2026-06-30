import Foundation

struct ProductService {
    private let client: APIClient

    nonisolated init(client: APIClient = APIClient()) {
        self.client = client
    }

    func getProducts(
        page: Int,
        keyword: String? = nil,
        accessToken: String
    ) async throws -> (items: [Product], hasMore: Bool) {
        let body = ProductListRequestBody(
            pagination: PaginationRequest(
                page: page,
                pageSize: ProductListConstants.pageSize,
                includeTotal: true
            ),
            sort: SortRequest(orderBy: "updated_at", direction: "desc"),
            filter: {
                let filter = ProductListFilter(keyword: keyword)
                return filter.isEmpty ? nil : filter
            }()
        )

        let response: PaginatedData<ProductListItemDTO> = try await client.request(
            path: "/api/v1/owned/products/list",
            method: .post,
            body: body,
            auth: .bearer(accessToken)
        )

        return (
            items: response.items.compactMap { $0.toProduct() },
            hasMore: response.meta.hasMore
        )
    }

    func getProductDetail(productUid: String, accessToken: String) async throws -> ProductDetail {
        let response: ProductDetailResponse = try await client.request(
            path: "/api/v1/owned/products/detail",
            method: .get,
            query: ["product_uid": productUid],
            auth: .bearer(accessToken)
        )

        guard let product = response.product.toProductDetail() else {
            throw APIClientError.contractMismatch("商品详情数据不完整。")
        }

        return product
    }

    func getVariants(ownedProductId: Int, accessToken: String) async throws -> [ProductVariant] {
        let body = VariantListRequestBody(
            pagination: PaginationRequest(
                page: 1,
                pageSize: VariantListConstants.pageSize,
                includeTotal: true
            ),
            sort: SortRequest(orderBy: "updated_at", direction: "desc"),
            filter: VariantListFilter(ownedProductId: ownedProductId, includeDraft: true)
        )

        let response: PaginatedData<ProductVariantListItemDTO> = try await client.request(
            path: "/api/v1/owned/variants/list",
            method: .post,
            body: body,
            auth: .bearer(accessToken)
        )

        return response.items.compactMap { $0.toProductVariant() }
    }
}
