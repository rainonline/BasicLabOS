import Foundation

enum ProductStatusLabel {
    private static let labels: [String: String] = [
        "draft": "草稿",
        "ready": "待启用",
        "active": "启用",
        "inactive": "停用",
        "discontinued": "停产",
    ]

    static func displayName(for status: String) -> String {
        let normalized = status.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else {
            return status
        }
        return labels[normalized] ?? status
    }
}
