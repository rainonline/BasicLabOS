import Foundation

struct Product: Identifiable, Hashable {
    let id: String
    let name: String
    let productCode: String?
    let productUid: String?
    let categoryId: Int?
    let brandName: String?
    let seriesName: String?
    let mainImageURL: URL?
    let isFeatured: Bool
    let status: String?
    let price: Double?
}

struct ProductListItemDTO: Decodable {
    private struct BrandRef: Decodable {
        let brandCode: String?
        let brandName: String?
    }

    private struct SeriesRef: Decodable {
        let seriesCode: String?
        let seriesName: String?
    }

    let ownedProductId: Int?
    let productUid: String?
    let productCode: String?
    let productName: String?
    let categoryId: Int?
    let mainImageUrl: String?
    let isFeatured: Bool?
    let status: String?
    private let brand: BrandRef?
    private let series: SeriesRef?
    let brandCode: String?
    let brandName: String?
    let seriesCode: String?
    let seriesName: String?
    let retailPrice: Double?
    let price: Double?

    func toProduct() -> Product? {
        guard let id = resolvedID, let name = resolvedName else {
            return nil
        }

        let resolvedBrandName = brand?.brandName ?? brandName
        let resolvedSeriesName = series?.seriesName ?? seriesName
        let imageURL = mainImageUrl.flatMap { URL(string: $0) }

        return Product(
            id: id,
            name: name,
            productCode: productCode,
            productUid: productUid,
            categoryId: categoryId,
            brandName: resolvedBrandName,
            seriesName: resolvedSeriesName,
            mainImageURL: imageURL,
            isFeatured: isFeatured ?? false,
            status: status,
            price: retailPrice ?? price
        )
    }

    private var resolvedID: String? {
        if let ownedProductId {
            return String(ownedProductId)
        }
        if let productUid = productUid?.trimmingCharacters(in: .whitespacesAndNewlines), !productUid.isEmpty {
            return productUid
        }
        if let productCode = productCode?.trimmingCharacters(in: .whitespacesAndNewlines), !productCode.isEmpty {
            return productCode
        }
        return nil
    }

    private var resolvedName: String? {
        if let productName = productName?.trimmingCharacters(in: .whitespacesAndNewlines), !productName.isEmpty {
            return productName
        }
        if let productCode = productCode?.trimmingCharacters(in: .whitespacesAndNewlines), !productCode.isEmpty {
            return productCode
        }
        if let productUid = productUid?.trimmingCharacters(in: .whitespacesAndNewlines), !productUid.isEmpty {
            return productUid
        }
        return nil
    }
}

struct ProductListFilter: Encodable {
    let keyword: String?

    init(keyword: String? = nil) {
        let trimmed = keyword?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        self.keyword = trimmed.isEmpty ? nil : trimmed
    }

    var isEmpty: Bool {
        keyword == nil
    }
}

struct ProductListRequestBody: Encodable {
    let pagination: PaginationRequest
    let sort: SortRequest
    let filter: ProductListFilter?

    enum CodingKeys: String, CodingKey {
        case pagination
        case sort
        case filter
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pagination, forKey: .pagination)
        try container.encode(sort, forKey: .sort)
        if let filter, !filter.isEmpty {
            try container.encode(filter, forKey: .filter)
        }
    }
}

enum ProductListConstants {
    static let pageSize = 24
}
