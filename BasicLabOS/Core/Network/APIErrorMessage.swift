import Foundation

enum APIErrorMessage {
    static func message(for error: Error) -> String {
        if let apiError = error as? APIClientError {
            return apiError.localizedDescription
        }
        if let sessionError = error as? SessionStoreError {
            return sessionError.localizedDescription
        }
        if error is DecodingError {
            return decodingMessage(for: error)
        }
        return error.localizedDescription
    }

    static func decodingMessage(for error: Error) -> String {
        guard let decodingError = error as? DecodingError else {
            return error.localizedDescription
        }

        switch decodingError {
        case let .keyNotFound(key, context):
            return "响应缺少字段 \(key.stringValue)：\(context.debugDescription)"
        case let .valueNotFound(type, context):
            return "响应字段类型不匹配（期望 \(type)）：\(context.debugDescription)"
        case let .typeMismatch(type, context):
            return "响应字段 \(context.codingPath.map(\.stringValue).joined(separator: ".")) 类型应为 \(type)。"
        case let .dataCorrupted(context):
            return "响应数据损坏：\(context.debugDescription)"
        @unknown default:
            return "无法解析服务器响应。"
        }
    }
}
