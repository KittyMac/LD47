import XCTest
@testable import LD47Framework

final class LD47FrameworkTests: XCTestCase {
    
    func testGameGeneration() {
        
        measure {
            _ = Game(42, 5000, 0)
        }

    }
    
    func testRNG() {
        
        let rng = Xoroshiro128Plus()
        
        for _ in 0..<100 {
            print(rng.get(min: 0, max: 3))
        }

    }

    static var allTests = [
        ("testGameGeneration", testGameGeneration),
    ]
}
