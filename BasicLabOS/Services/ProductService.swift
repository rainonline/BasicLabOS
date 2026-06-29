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
}
