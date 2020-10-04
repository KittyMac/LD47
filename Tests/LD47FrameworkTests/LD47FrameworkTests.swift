import XCTest
@testable import LD47Framework

final class LD47FrameworkTests: XCTestCase {
    
    func testGameGeneration() {
        
        measure {
            _ = Game(42, 5000)
        }

    }

    static var allTests = [
        ("testGameGeneration", testGameGeneration),
    ]
}
