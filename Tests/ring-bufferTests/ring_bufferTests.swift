import XCTest
@testable import ring_buffer

final class ring_bufferTests: XCTestCase {
    
    private let epsilon: Float = 0.000001
    
    func testCountPropertyChange() {
        
        var rbuf = RingBuffer<Float>(capacity: 3)
        
        // write one
        rbuf.write( sin(Float.pi / 2.0) )
        XCTAssertEqual(rbuf.count, 0, "Count must not increment until submit() is called")
        
        // submit one
        rbuf.submit()
        XCTAssertEqual(rbuf.count, 1, "Count must increment after submit() is called")
        
        // write one
        rbuf.write( sin(Float.pi / 4.0) )
        XCTAssertEqual(rbuf.count, 1, "Count must not increment until submit() is called")
        
        // submit one
        rbuf.submit()
        XCTAssertEqual(rbuf.count, 2, "Count must increment after submit() is called")
        
        // read one
        let pi2 = rbuf.read()
        XCTAssertEqual(rbuf.count, 2, "Count must not decrement until discard() is called")
        
        // discard one
        rbuf.discard()
        XCTAssertEqual(rbuf.count, 1, "Count must decrement after discard() is called")
        
        XCTAssert(abs(pi2 - sin(Float.pi / 2.0)) < epsilon, "Value must qual to the first that was written")
        
        // read one
        let pi4 = rbuf.read()
        XCTAssertEqual(rbuf.count, 1, "Count must not decrement until discard() is called")
        
        // discard one
        rbuf.discard()
        XCTAssertEqual(rbuf.count, 0, "Count must decrement after discard() is called")
        XCTAssert(abs(pi4 - sin(Float.pi / 4.0)) < epsilon, "Value must qual to the second that was written")
        
        XCTAssertEqual(rbuf.capacity, 3, "Capacity must not change")
    }
    
    func testOverrideBufferWhenInputExeedsCapacity() {
        var rbuf = RingBuffer<Float>(capacity: 3)
        rbuf.write(0.1); rbuf.submit()
        rbuf.write(0.2); rbuf.submit()
        rbuf.write(0.3); rbuf.submit()
        XCTAssertEqual(rbuf.count, rbuf.capacity, "Capacity must equal to count")
        
        rbuf.write(0.4); rbuf.submit()
        XCTAssertEqual(rbuf.count, 1, "Count must equal 1")
        
        let element = rbuf.read()
        XCTAssert(abs(element - 0.4) < epsilon, "Should override buffer on overflow")
    }
    
    static var allTests = [
        ("testCountPropertyChange", testCountPropertyChange),
        ("testOverrideBufferWhenInputExeedsCapacity", testOverrideBufferWhenInputExeedsCapacity)
    ]
}
