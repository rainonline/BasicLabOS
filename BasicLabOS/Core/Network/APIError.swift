import Foundation

struct APIErrorPayload: Decodable, Sendable {
    let errorCode: String
    let message: String
    let traceId: String?
}

enum APIClientError: LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case serverError(APIErrorPayload)
    case contractMismatch(String)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "无效的请求地址。"
        case .invalidResponse:
            "服务器响应格式无效。"
        case let .httpStatus(code):
            "请求失败（HTTP \(code)）。"
        case let .serverError(payload):
            payload.message
        case let .contractMismatch(message):
            message
        case let .decoding(error):
            APIErrorMessage.decodingMessage(for: error)
        case let .transport(error):
            error.localizedDescription
        }
    }
}
