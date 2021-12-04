import XCTest
@testable import RingBuffer

final class RingBufferSingleItemTests: XCTestCase {

    func testCountPropertyChange() {
        var rbuf = RingBuffer<Int>(capacity: 2)
        XCTAssert(rbuf.isEmpty)
        rbuf.push(1)
        XCTAssertEqual(rbuf.count, 1, "Count must increment after push() is called")
        rbuf.push(2)
        XCTAssertEqual(rbuf.count, 2, "Count must increment after push() is called")
        XCTAssert(rbuf.isFull)
        let item1 = rbuf.pop()
        XCTAssertEqual(rbuf.count, 1, "Count must decrement after pop() is called")
        XCTAssert(item1 == 1, "Value must equal to the first item that was written")
        let item2 = rbuf.pop()
        XCTAssertEqual(rbuf.count, 0, "Count must decrement after pop() is called")
        XCTAssert(item2 == 2, "Value must equal to the first item that was written")
        XCTAssert(rbuf.isEmpty)
        XCTAssertEqual(rbuf.capacity, 2, "Capacity must not change")
    }

    func testCheckHead() {

        var rbuf = RingBuffer<Int>(capacity: 3)
        rbuf.push(1)
        XCTAssertEqual(rbuf.head, 1)
        rbuf.push(2)
        XCTAssertEqual(rbuf.head, 2)
        rbuf.push(3)
        XCTAssertEqual(rbuf.head, 0)
        rbuf.push(4)
        XCTAssertEqual(rbuf.head, 1)
    }

    func testCheckTailWhenNoOverflow() {
        var rbuf = RingBuffer<Int>(capacity: 3)
        rbuf.push(1)
        rbuf.push(2)
        rbuf.push(3)
        XCTAssertEqual(rbuf.tail, 0)
        XCTAssertEqual(rbuf.pop(), 1)
        XCTAssertEqual(rbuf.tail, 1)
        XCTAssertEqual(rbuf.pop(), 2)
        XCTAssertEqual(rbuf.tail, 2)
        XCTAssertEqual(rbuf.pop(), 3)
        XCTAssertEqual(rbuf.tail, 0)
        XCTAssertEqual(rbuf.pop(), nil)
        XCTAssertEqual(rbuf.tail, 0)
    }

    func testCheckTailWhenOverflow() {
        var rbuf = RingBuffer<Int>(capacity: 3)
        rbuf.push(1)
        rbuf.push(2)
        rbuf.push(3)
        rbuf.push(4)
        XCTAssertEqual(rbuf.count, 1)
        XCTAssertEqual(rbuf.tail, 0)
        XCTAssertEqual(rbuf.pop(), 4)
        XCTAssertEqual(rbuf.tail, 1)
        XCTAssertEqual(rbuf.pop(), nil)
    }

    func testOverwriteBufferWhenInputExeedsCapacity() {
        var rbuf = RingBuffer<Int>(capacity: 3)
        rbuf.push(1)
        rbuf.push(2)
        rbuf.push(3)
        XCTAssert(rbuf.isFull)
        rbuf.push(4)
        XCTAssertEqual(rbuf.count, 1, "Count must equal to 1 after overflow")
        XCTAssertEqual(rbuf.capacity, 3, "Capacity must not change")
        XCTAssert(!rbuf.isFull)
        XCTAssert(!rbuf.isEmpty)
        let item = rbuf.pop()
        XCTAssert(item == 4, "Should overwrite buffer on overflow")
        XCTAssertEqual(rbuf.count, 0)
        XCTAssert(rbuf.isEmpty)
    }

    func testMustReturnNilOnPopEmpty() {
        var rbuf = RingBuffer<Int>(capacity: 1)
        rbuf.push(1)
        XCTAssertEqual(rbuf.count, 1)
        rbuf.pop()
        XCTAssert(rbuf.isEmpty)
        let item = rbuf.pop()
        XCTAssertEqual(item, nil)
    }

    func testMustDropItemIsFull() {
        var rbuf = RingBuffer<Int>(capacity: 2)
        XCTAssertEqual(rbuf.push(1, drop: true), 0)
        XCTAssertEqual(rbuf.push(2, drop: true), 0)
        XCTAssert(rbuf.isFull)
        XCTAssertEqual(rbuf.push(3, drop: true), 1, "Must drop 1 item")
        XCTAssertEqual(rbuf.push(4, drop: true), 1, "Must drop 1 item")
        rbuf.pop()
        XCTAssertEqual(rbuf.available, 1)
        XCTAssertEqual(rbuf.push(5, drop: true), 0, "Must drop 0 item")
        XCTAssert(rbuf.isFull)
        XCTAssertEqual(rbuf.push(6, drop: true), 1, "Must drop 1 item")
    }

    static var allTests = [
        ("testCountPropertyChange", testCountPropertyChange),
        ("testCheckHead", testCheckHead),
        ("testCheckTailWhenNoOverflow", testCheckTailWhenNoOverflow),
        ("testCheckTailWhenOverflow", testCheckTailWhenOverflow),
        ("testOverwriteBufferWhenInputExeedsCapacity", testOverwriteBufferWhenInputExeedsCapacity),
        ("testMustReturnNilOnPopEmpty", testMustReturnNilOnPopEmpty),
        ("testMustDropItemIsFull", testMustDropItemIsFull)
    ]
}
