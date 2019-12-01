import XCTest
@testable import RingBuffer

final class RingBufferMultipleItemsTests: XCTestCase {

    func testPushMultipleItems() {
        let items = [1, 2, 3, 4, 5]
        var rbuf = RingBuffer<Int>(capacity: 5)
        rbuf.push(items)
        XCTAssertEqual(rbuf.count, 5, "Buffer is submited")
    }

    func testPushMultipleItemsOverflow() {
        let items = [1, 2, 3, 4, 5, 6]
        var rbuf = RingBuffer<Int>(capacity: 5)
        rbuf.push(items)
        XCTAssertEqual(rbuf.count, 1, "Buffer is overflow")
        XCTAssertEqual(rbuf.pop(), 6)
    }

    func testPushMultipleItemsOverflowDrop() {
        let items = [1, 2, 3, 4, 5, 6]
        var rbuf = RingBuffer<Int>(capacity: 4)
        XCTAssertEqual(rbuf.push(items, drop: true), 2, "Two items must be dropped")
        XCTAssert(rbuf.isFull)
    }

    func testPushMultipleItemsOverflowDropFalse() {
        let items = [1, 2, 3, 4, 5, 6]
        var rbuf = RingBuffer<Int>(capacity: 4)
        XCTAssertEqual(rbuf.push(items, drop: false), 0, "No items must be dropped")
        XCTAssert(rbuf.count == 2)
    }

    func testPopMultipleItems() {
        let items = [1, 2, 3, 4, 5, 6]
        var rbuf = RingBuffer<Int>(capacity: 6)
        rbuf.push(items)
        XCTAssertEqual(rbuf.pop(amount: 4), [1, 2, 3, 4])
        XCTAssertEqual(rbuf.pop(amount: 2), [5, 6])
        XCTAssert(rbuf.isEmpty)
    }

    func testPopMultipleItemsWithOverflow() {
        let items = [1, 2, 3, 4, 5, 6]
        var rbuf = RingBuffer<Int>(capacity: 6)
        rbuf.push(items)
        XCTAssertEqual(rbuf.pop(amount: 7), nil)
        XCTAssertEqual(rbuf.pop(amount: rbuf.count), items)
        XCTAssert(rbuf.isEmpty)
    }

    func testMultipleItemsExample() {
        var rbuf = RingBuffer<Int>(capacity: 20)
        let dataSet1 = [Int](repeating: 1, count: 10)
        let dataSet2 = [Int](repeating: 2, count: 10)
        let dataSet3 = [Int](repeating: 3, count: 10)

        rbuf.push(dataSet1)
        rbuf.push(dataSet2)
        XCTAssertEqual(rbuf.count, 20)

        rbuf.push(dataSet3)
        XCTAssertEqual(rbuf.count, 10)

        XCTAssertEqual(rbuf.pop(amount: 10), dataSet3)
        XCTAssertEqual(rbuf.count, 0)
        XCTAssertEqual(rbuf.tail, 10)

        XCTAssertEqual(rbuf.head, 10)
        rbuf.push(dataSet1, drop: true)

        XCTAssertEqual(rbuf.head, 0)
        rbuf.push(dataSet2, drop: true)
        XCTAssert(rbuf.isFull)
        XCTAssertEqual(rbuf.head, 10)

        let dropped = rbuf.push(dataSet3, drop: true)
        XCTAssertEqual(dropped, 10)

        let data = rbuf.pop(amount: 20)
        XCTAssertEqual(data, dataSet1 + dataSet2)
    }

    static var allTests = [
        ("testPushMultipleItems", testPushMultipleItems),
        ("testPushMultipleItemsOverflow", testPushMultipleItemsOverflow),
        ("testPushMultipleItemsOverflowDrop", testPushMultipleItemsOverflowDrop),
        ("testPushMultipleItemsOverflowDropFalse", testPushMultipleItemsOverflowDropFalse),
        ("testPopMultipleItems", testPopMultipleItems),
        ("testPopMultipleItemsWithOverflow", testPopMultipleItemsWithOverflow),
        ("testMultipleItemsExample", testMultipleItemsExample)
    ]
}
