import Foundation

/// 从公开接口拉取参会者名单，作为「网络数据」示例。
/// 默认使用 JSONPlaceholder 的 users 接口，只取 name 字段。
struct AttendeeService {
    var url = URL(string: "https://jsonplaceholder.typicode.com/users")!
    var limit = 5

    func fetchAttendees() async throws -> [String] {
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try Self.decodeNames(from: data, limit: limit)
    }

    /// 抽出来方便用固定 JSON 做单元测试。
    static func decodeNames(from data: Data, limit: Int) throws -> [String] {
        struct User: Decodable {
            let name: String
        }
        let users = try JSONDecoder().decode([User].self, from: data)
        return users.prefix(limit).map(\.name)
    }
}
