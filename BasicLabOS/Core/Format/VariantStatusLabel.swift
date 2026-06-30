import Foundation

enum VariantStatusLabel {
    private static let labels: [String: String] = [
        "draft": "草稿",
        "active": "启用",
        "inactive": "停用",
        "discontinued": "停用归档",
    ]

    static func displayName(for status: String) -> String {
        let normalized = status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else {
            return status
        }
        return labels[normalized] ?? status
    }
}
