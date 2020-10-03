import Foundation

public protocol Randomable {
    func seed(_ string: String)

    func get() -> UInt64
    func get(min: UInt64, max: UInt64) -> UInt64

    func get() -> Int
    func get(min: Int, max: Int) -> Int

    func get() -> Float
    func get(min: Float, max: Float) -> Float

    func get<T>(_ array: [T]) -> T

    func maybe(_ value: Float) -> Bool
}
