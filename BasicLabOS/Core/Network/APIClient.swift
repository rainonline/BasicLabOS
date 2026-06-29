import Foundation

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIAuth: Sendable {
    case none
    case bearer(String)
}

struct APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let timeout: TimeInterval

    nonisolated init(
        baseURL: URL = AppConfig.apiBaseURL,
        session: URLSession = .shared,
        timeout: TimeInterval = AppConfig.requestTimeout
    ) {
        self.baseURL = baseURL
        self.session = session
        self.timeout = timeout
    }

    func request<Response: Decodable>(
        path: String,
        method: HTTPMethod = .get,
        body: (any Encodable)? = nil,
        auth: APIAuth = .none
    ) async throws -> Response {
        let url = try resolveURL(path: path)
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        switch auth {
        case .none:
            break
        case let .bearer(token):
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIClientError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        return try decodeEnvelope(data: data, httpStatusCode: httpResponse.statusCode)
    }

    private func decodeEnvelope<Response: Decodable>(
        data: Data,
        httpStatusCode: Int
    ) throws -> Response {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIClientError.invalidResponse
        }

        let status = json["status"] as? String ?? ""
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        if status == "success" {
            guard let dataObject = json["data"], !(dataObject is NSNull) else {
                throw APIClientError.contractMismatch("响应缺少 data 字段。")
            }
            let payloadData = try JSONSerialization.data(withJSONObject: dataObject)
            do {
                return try decoder.decode(Response.self, from: payloadData)
            } catch {
                throw APIClientError.decoding(error)
            }
        }

        if let errorObject = json["error"], !(errorObject is NSNull) {
            let errorData = try JSONSerialization.data(withJSONObject: errorObject)
            let errorPayload = try decoder.decode(APIErrorPayload.self, from: errorData)
            throw APIClientError.serverError(errorPayload)
        }

        if !(200 ..< 300).contains(httpStatusCode) {
            throw APIClientError.httpStatus(httpStatusCode)
        }

        throw APIClientError.contractMismatch("服务器返回了无法识别的响应。")
    }

    private func resolveURL(path: String) throws -> URL {
        if let url = URL(string: path), url.scheme != nil {
            return url
        }

        let normalized = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return baseURL.appending(path: normalized)
    }
}

private struct AnyEncodable: Encodable {
    private let encodeValue: (Encoder) throws -> Void

    init(_ value: any Encodable) {
        encodeValue = value.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeValue(encoder)
    }
}
