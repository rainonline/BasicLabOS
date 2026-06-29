import Foundation

struct PaginationRequest: Encodable {
    let page: Int
    let pageSize: Int
    let includeTotal: Bool
}

struct SortRequest: Encodable {
    let orderBy: String
    let direction: String
}

struct PaginationMeta: Decodable {
    let page: Int
    let pageSize: Int
    let hasMore: Bool
    let total: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize) ?? 20
        hasMore = try container.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
        total = try container.decodeIfPresent(Int.self, forKey: .total)
    }

    private enum CodingKeys: String, CodingKey {
        case page
        case pageSize
        case hasMore
        case total
    }
}

struct PaginatedData<Item: Decodable>: Decodable {
    let items: [Item]
    let meta: PaginationMeta

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([Item].self, forKey: .items) ?? []
        meta = try container.decode(PaginationMeta.self, forKey: .meta)
    }

    private enum CodingKeys: String, CodingKey {
        case items
        case meta
    }
}
