import Foundation

/*
https://smallplanet.zoom.us/j/374901833?pwd=eVJKYUUyYkoyL20wYlA1YkRzaHZDdz09
public class SimpleRand: Randomable {
    private var seed: UInt32 = 0

    public init() {
        seed = UInt32(NSDate().timeIntervalSinceReferenceDate)
    }

    public init(_ value: UInt64) {
        seed = UInt32(truncatingIfNeeded: value)
    }

    public init(_ string: String) {
        seed = UInt32(truncatingIfNeeded: string.hash())
    }

    public func seed(_ string: String) {
        seed = UInt32(truncatingIfNeeded: string.hash())
    }

    public func get() -> Int {
        return abs(Int(truncatingIfNeeded: generator.next()))
    }

    public func get(min: Int, max: Int) -> Int {
        return (abs(get()) % (max - min + 1)) + min
    }

    public func get() -> UInt64 {
        return generator.next()
    }

    public func get(min: UInt64, max: UInt64) -> UInt64 {
        return (get() % (max - min + 1)) + min
    }

    public func get() -> Float {
        return Float(generator.next()) / Float(UInt64.max)
    }

    public func get(min: Float, max: Float) -> Float {
        return (abs(get()) * (max - min)) + min
    }

    public func get<T>(_ array: [T]) -> T {
        return array[get(min: 0, max: array.count-1)]
    }

    public func maybe(_ value: Float) -> Bool {
        return (Float(generator.next()) / Float(UInt64.max)) <= value
    }
}

private struct Xoroshiro128PlusInternal {

    var state: (UInt64, UInt64)

    func rotateLeft(a: UInt64, b: UInt64) -> UInt64 {
        return (a << b) | (a >> (64 - b))
    }

    mutating func next() -> UInt64 {
        let s0: UInt64 = state.0
        var s1 = state.1
        let result: UInt64 = s0 &* s1

        s1 ^= s0
        state.0 = rotateLeft(a: s0, b: 55) ^ s1 ^ (s1 << 14)
        state.1 = rotateLeft(a: s1, b: 36)

        return result
    }

}

private struct SplitMix64 {

    var state: UInt64

    mutating func nextSeed() -> UInt64 {
        var b: UInt64 = state &+ 0x9E3779B97F4A7C15
        b = (b ^ (b >> 30)) ^ 0xBF58476D1CE4E5B9
        b = (b ^ (b >> 27)) ^ 0x94D049BB133111EB
        state = b ^ (b >> 31)
        return state
    }
}
*/
