import Foundation

struct ProductTag: Hashable, Identifiable {
    var id: String { code }
    let code: String
    let name: String
}

struct ProductAttributeValue: Hashable, Identifiable {
    var id: String { attributeCode }
    let attributeCode: String
    let displayValue: String
}

struct ProductDetail: Identifiable, Hashable {
    let id: String
    let productUid: String
    let ownedProductId: Int
    let pimProductId: Int?
    let name: String
    let productCode: String?
    let categoryId: Int?
    let brandCode: String?
    let brandName: String?
    let seriesCode: String?
    let seriesName: String?
    let description: String?
    let mainImageURL: URL?
    let status: String?
    let isFeatured: Bool
    let priorityLevel: Int?
    let sellingPoints: [String]
    let complianceStandards: [String]
    let usageCaution: String?
    let tags: [ProductTag]
    let attributeValues: [ProductAttributeValue]
    let notes: String?
    let createdAt: String?
    let updatedAt: String?
}

struct ProductVariant: Identifiable, Hashable {
    let id: String
    let variantUid: String?
    let variantCode: String?
    let name: String
    let mainImageURL: URL?
    let status: String?
    let isMasterVariant: Bool
    let retailPrice: Double?
}

struct ProductDetailResponse: Decodable {
    let product: ProductDetailItemDTO
}

struct ProductDetailItemDTO: Decodable {
    private struct BrandRef: Decodable {
        let brandCode: String?
        let brandName: String?
    }

    private struct SeriesRef: Decodable {
        let seriesCode: String?
        let seriesName: String?
    }

    private struct TagRef: Decodable {
        let tagCode: String?
        let tagName: String?
    }

    private struct AttributeRef: Decodable {
        let attributeCode: String?
        let value: AttributeValuePayload?
    }

    let ownedProductId: Int?
    let pimProductId: Int?
    let productUid: String?
    let productCode: String?
    let productName: String?
    let categoryId: Int?
    let description: String?
    let mainImageUrl: String?
    let sellingPoints: [String]?
    let complianceStandards: [String]?
    let usageCautionCn: String?
    let status: String?
    let isFeatured: Bool?
    let priorityLevel: Int?
    let notes: String?
    let createdAt: String?
    let updatedAt: String?
    private let brand: BrandRef?
    private let series: SeriesRef?
    let brandCode: String?
    let brandName: String?
    let seriesCode: String?
    let seriesName: String?
    private let tags: [TagRef]?
    private let attributeValues: [AttributeRef]?

    func toProductDetail() -> ProductDetail? {
        guard let ownedProductId,
              let productUid = productUid?.trimmingCharacters(in: .whitespacesAndNewlines),
              !productUid.isEmpty,
              let name = productName?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty
        else {
            return nil
        }

        let resolvedBrandCode = brand?.brandCode ?? brandCode
        let resolvedBrandName = brand?.brandName ?? brandName
        let resolvedSeriesCode = series?.seriesCode ?? seriesCode
        let resolvedSeriesName = series?.seriesName ?? seriesName

        return ProductDetail(
            id: String(ownedProductId),
            productUid: productUid,
            ownedProductId: ownedProductId,
            pimProductId: pimProductId,
            name: name,
            productCode: productCode,
            categoryId: categoryId,
            brandCode: resolvedBrandCode,
            brandName: resolvedBrandName,
            seriesCode: resolvedSeriesCode,
            seriesName: resolvedSeriesName,
            description: description,
            mainImageURL: mainImageUrl.flatMap { URL(string: $0) },
            status: status,
            isFeatured: isFeatured ?? false,
            priorityLevel: priorityLevel,
            sellingPoints: (sellingPoints ?? []).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            complianceStandards: (complianceStandards ?? []).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            usageCaution: usageCautionCn,
            tags: (tags ?? []).compactMap { tag in
                guard let code = tag.tagCode?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty else {
                    return nil
                }
                let name = tag.tagName?.trimmingCharacters(in: .whitespacesAndNewlines)
                return ProductTag(code: code, name: (name?.isEmpty == false) ? name! : code)
            },
            attributeValues: (attributeValues ?? []).compactMap { item in
                guard let code = item.attributeCode?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !code.isEmpty,
                      let display = item.value?.displayString,
                      !display.isEmpty
                else {
                    return nil
                }
                return ProductAttributeValue(attributeCode: code, displayValue: display)
            },
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

struct ProductVariantListItemDTO: Decodable {
    let ownedVariantId: Int?
    let variantUid: String?
    let variantCode: String?
    let variantName: String?
    let displayName: String?
    let mainImageUrl: String?
    let status: String?
    let isMasterVariant: Bool?
    let retailPrice: Double?

    func toProductVariant() -> ProductVariant? {
        guard let ownedVariantId else {
            return nil
        }

        let resolvedName = [
            displayName,
            variantName,
            variantCode,
            variantUid,
        ]
        .compactMap { value -> String? in
            let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return trimmed.isEmpty ? nil : trimmed
        }
        .first ?? String(ownedVariantId)

        return ProductVariant(
            id: String(ownedVariantId),
            variantUid: variantUid,
            variantCode: variantCode,
            name: resolvedName,
            mainImageURL: mainImageUrl.flatMap { URL(string: $0) },
            status: status,
            isMasterVariant: isMasterVariant ?? false,
            retailPrice: retailPrice
        )
    }
}

struct VariantListFilter: Encodable {
    let ownedProductId: Int
    let includeDraft: Bool
}

struct VariantListRequestBody: Encodable {
    let pagination: PaginationRequest
    let sort: SortRequest
    let filter: VariantListFilter
}

enum VariantListConstants {
    static let pageSize = 100
}

private enum AttributeValuePayload: Decodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([String])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
            return
        }
        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
            return
        }
        if let value = try? container.decode(Int.self) {
            self = .int(value)
            return
        }
        if let value = try? container.decode(Double.self) {
            self = .double(value)
            return
        }
        if let value = try? container.decode(String.self) {
            self = .string(value)
            return
        }
        if let value = try? container.decode([String].self) {
            self = .array(value)
            return
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported attribute value type.")
    }

    var displayString: String? {
        switch self {
        case let .string(value):
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        case let .int(value):
            return String(value)
        case let .double(value):
            return String(value)
        case let .bool(value):
            return value ? "是" : "否"
        case let .array(values):
            let joined = values
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: "、")
            return joined.isEmpty ? nil : joined
        case .null:
            return nil
        }
    }
}
