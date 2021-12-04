import XCTest
@testable import RingBuffer

struct Complex : Equatable
{
    var r: Double
    var i: Double
}

final class RingBufferNonNumericItemsTests: XCTestCase {

    func testCountPropertyChange() {
        let value1 = Complex(r: 1, i: -3)
        let value2 = Complex(r: 3, i: -1)
        var rbuf = RingBuffer<Complex>(capacity: 2)
        XCTAssert(rbuf.isEmpty)
        rbuf.push(value1)
        XCTAssertEqual(rbuf.count, 1, "Count must increment after push() is called")
        rbuf.push(value2)
        XCTAssertEqual(rbuf.count, 2, "Count must increment after push() is called")
        XCTAssert(rbuf.isFull)
        let item1 = rbuf.pop()
        XCTAssertEqual(rbuf.count, 1, "Count must decrement after pop() is called")
        XCTAssert(item1 == value1, "Value must equal to the first item that was written")
        let item2 = rbuf.pop()
        XCTAssertEqual(rbuf.count, 0, "Count must decrement after pop() is called")
        XCTAssert(item2 == value2, "Value must equal to the first item that was written")
        XCTAssert(rbuf.isEmpty)
        XCTAssertEqual(rbuf.capacity, 2, "Capacity must not change")
    }

    func testCheckHead() {
        var rbuf = RingBuffer<Complex>(capacity: 3)
        rbuf.push(Complex(r: 1, i: -3))
        XCTAssertEqual(rbuf.head, 1)
        rbuf.push(Complex(r: 0, i: -4))
        XCTAssertEqual(rbuf.head, 2)
        rbuf.push(Complex(r: 1, i: -1))
        XCTAssertEqual(rbuf.head, 0)
        rbuf.push(Complex(r: -1, i: 1))
        XCTAssertEqual(rbuf.head, 1)
    }

    func testCheckTailWhenNoOverflow() {
        var rbuf = RingBuffer<Complex>(capacity: 3)
        let value1 = Complex(r: -3, i: -3)
        let value2 = Complex(r: -3, i: -1)
        let value3 = Complex(r: -1, i: -3)
        rbuf.push(value1)
        rbuf.push(value2)
        rbuf.push(value3)
        XCTAssertEqual(rbuf.tail, 0)
        XCTAssertEqual(rbuf.pop(), value1)
        XCTAssertEqual(rbuf.tail, 1)
        XCTAssertEqual(rbuf.pop(), value2)
        XCTAssertEqual(rbuf.tail, 2)
        XCTAssertEqual(rbuf.pop(), value3)
        XCTAssertEqual(rbuf.tail, 0)
        XCTAssertEqual(rbuf.pop(), nil)
        XCTAssertEqual(rbuf.tail, 0)
    }

    func testMustReturnNilOnPopEmpty() {
        var rbuf = RingBuffer<Complex>(capacity: 1)
        rbuf.push(Complex(r: -3, i: -1))
        XCTAssertEqual(rbuf.count, 1)
        rbuf.pop()
        XCTAssert(rbuf.isEmpty)
        let item = rbuf.pop()
        XCTAssertEqual(item, nil)
    }

    func testMustDropItemIsFull() {
        var rbuf = RingBuffer<Complex>(capacity: 2)
        XCTAssertEqual(rbuf.push(Complex(r: 1, i: 1), drop: true), 0)
        XCTAssertEqual(rbuf.push(Complex(r: 2, i: 2), drop: true), 0)
        XCTAssert(rbuf.isFull)
        XCTAssertEqual(rbuf.push(Complex(r: 3, i: 3), drop: true), 1, "Must drop 1 item")
        XCTAssertEqual(rbuf.push(Complex(r: 4, i: 4), drop: true), 1, "Must drop 1 item")
        rbuf.pop()
        XCTAssertEqual(rbuf.available, 1)
        XCTAssertEqual(rbuf.push(Complex(r: 5, i: 5), drop: true), 0, "Must drop 0 item")
        XCTAssert(rbuf.isFull)
        XCTAssertEqual(rbuf.push(Complex(r: 6, i: 6), drop: true), 1, "Must drop 1 item")
    }

    static var allTests = [
        ("testCountPropertyChange", testCountPropertyChange),
        ("testCheckHead", testCheckHead),
        ("testCheckTailWhenNoOverflow", testCheckTailWhenNoOverflow),
        ("testMustReturnNilOnPopEmpty", testMustReturnNilOnPopEmpty),
        ("testMustDropItemIsFull", testMustDropItemIsFull)
    ]
}
