import XCTest
import Flynn
@testable import LD47Framework

final class LD47FrameworkTests: XCTestCase {
    
    override func setUp() {
        Flynn.startup()
    }

    override func tearDown() {
        Flynn.shutdown()
    }
    
    func testGameGeneration() {
        
        let options = XCTMeasureOptions()
        options.iterationCount = 10000
        if #available(OSX 10.15, *) {
            self.measure(options: options, block: {
                _ = Game(42, 4000, 250)
            })
        } else {
            self.measure() {
                _ = Game(42, 4000, 250)
            }
        }

    }
    
    func testGameDeinit() {
        
        for _ in 0..<10 {
            _ = Game(42, 4000, 42)
        }
        
    }
    
    func testRNG() {
        
        let rng = Xoroshiro256StarStar()
        
        for _ in 0..<100 {
            print(rng.get(min: 0, max: 3))
        }

    }

    static var allTests = [
        ("testGameGeneration", testGameGeneration),
    ]
}
