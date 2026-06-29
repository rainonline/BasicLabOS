import Foundation

enum PriceFormatter {
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CNY"
        formatter.currencySymbol = "¥"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func formatCny(_ value: Double?) -> String {
        guard let value else {
            return "未提供"
        }
        return currencyFormatter.string(from: NSNumber(value: value)) ?? "未提供"
    }
}

enum ProductCardFormatter {
    static func subtitle(productCode: String?, productUid: String?) -> String {
        let code = productCode?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !code.isEmpty {
            return code
        }

        let uid = productUid?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !uid.isEmpty {
            return uid
        }

        return "—"
    }

    static func metaLine(category: String?, brand: String?, series: String?) -> String {
        [category, brand, series]
            .compactMap { value -> String? in
                let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return trimmed.isEmpty ? nil : trimmed
            }
            .joined(separator: " · ")
    }
}
