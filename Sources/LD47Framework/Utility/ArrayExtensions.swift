import Foundation

public extension Array where Element: Equatable {
    mutating func removeOne (_ element: Element) {
        if let idx = firstIndex(of: element) {
            remove(at: idx)
        }
    }

    mutating func removeAll (_ element: Element) {
        removeAll { $0 == element }
    }
}
