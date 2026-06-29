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

    static func hasPrice(_ value: Double?) -> Bool {
        value != nil
    }

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
            return compactIdentifier(uid)
        }

        return "—"
    }

    private static func compactIdentifier(_ value: String, maxLength: Int = 18) -> String {
        guard value.count > maxLength else {
            return value
        }

        let head = maxLength / 2 - 1
        let tail = maxLength - head - 1
        let start = value.prefix(head)
        let end = value.suffix(tail)
        return "\(start)…\(end)"
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
