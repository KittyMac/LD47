import Foundation

public extension Encodable {
    func encoded() throws -> Data {
        return try JSONEncoder().encode(self)
    }

    func json() throws -> String {
        return try String(data: JSONEncoder().encode(self), encoding: .utf8)!
    }
}

public extension Data {
    func decoded<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}

public extension String {
    func decoded<T: Decodable>() throws -> T {
        guard let jsonData = self.data(using: .utf8) else {
            throw "Unable to convert json String to Data"
        }
        return try JSONDecoder().decode(T.self, from: jsonData)
    }
}
