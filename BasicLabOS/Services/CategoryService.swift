import Foundation

private struct CategoryTreeNodeDTO: Decodable {
    let categoryId: Int
    let categoryName: String
    let children: [CategoryTreeNodeDTO]?
}

private struct CategoryTreeData: Decodable {
    let items: [CategoryTreeNodeDTO]
}

final class CategoryService {
    private let client: APIClient
    private var labelsById: [Int: String] = [:]
    private var isLoaded = false

    nonisolated init(client: APIClient = APIClient()) {
        self.client = client
    }

    func label(for categoryId: Int?) -> String? {
        guard let categoryId else {
            return nil
        }
        return labelsById[categoryId]
    }

    func loadIfNeeded(accessToken: String) async throws {
        guard !isLoaded else {
            return
        }

        let data: CategoryTreeData = try await client.request(
            path: "/api/v1/pim/catalog/categories/tree",
            auth: .bearer(accessToken)
        )

        var lookup: [Int: String] = [:]
        flatten(nodes: data.items, into: &lookup)
        labelsById = lookup
        isLoaded = true
    }

    private func flatten(nodes: [CategoryTreeNodeDTO], into lookup: inout [Int: String]) {
        for node in nodes {
            lookup[node.categoryId] = node.categoryName
            if let children = node.children {
                flatten(nodes: children, into: &lookup)
            }
        }
    }
}
