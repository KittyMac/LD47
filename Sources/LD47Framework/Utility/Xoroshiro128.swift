//  Created by Daniel Hurdle on 5/18/16.
//  Copyright © 2016 All rights reserved.
//
// Pseudo-Random Number generator utilizing xoroshiro128+ algorithm
// translated from: http://xoroshiro.di.unimi.it/xoroshiro128plus.c
//
// https://github.com/drhurdle/Xoroshiro128Plus-Swift-pRNG/blob/master/Xoroshiro128Plus.swift

// swiftlint:disable identifier_name

import Foundation

public extension String {
    static let `default` = ""

    func hash() -> UInt64 {
        var hash: UInt64 = 0
        var i: UInt64 = 0
        for c in self {
            let optionalASCIIvalue = c.unicodeScalars.filter {$0.isASCII}.first?.value
            if let ASCIIvalue = optionalASCIIvalue {
                hash = (hash &+ UInt64(ASCIIvalue) &* i) &* (hash &+ UInt64(ASCIIvalue) &* i)
            }
            i += 1
        }
        return hash
    }
}

public class Xoroshiro128Plus: Randomable {
    private var rngState: (UInt64, UInt64) = (0, 0)
    fileprivate var generator = Xoroshiro128PlusInternal(state: (0, 0))

    public init() {
        generateSeeds(seed: UInt64(NSDate().timeIntervalSinceReferenceDate))
    }

    public init(_ seed: UInt64) {
        generateSeeds(seed: seed)
    }

    public init(_ string: String) {
        seed(string)
    }

    private func generateSeeds(seed: UInt64) {
        var seeder = SplitMix64(state: seed)
        var statePart: UInt64

        for x in 0...10 {
            statePart = seeder.nextSeed()
            rngState.0 = x == 9 ? statePart : 0
            rngState.1 = x == 10 ? statePart : 0
        }
        generator.state = rngState
    }

    public func seed(_ string: String) {
        generateSeeds(seed: string.hash())
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
