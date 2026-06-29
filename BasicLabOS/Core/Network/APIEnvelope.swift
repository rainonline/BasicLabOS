import Foundation

struct APIEnvelope<Data: Decodable>: Decodable {
    let status: String
    let msg: String?
    let traceId: String?
    let data: Data?
    let error: APIErrorPayload?

    enum CodingKeys: String, CodingKey {
        case status
        case msg
        case traceId = "trace_id"
        case data
        case error
    }

    var isSuccess: Bool {
        status == "success"
    }
}
