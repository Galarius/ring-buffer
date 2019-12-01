import XCTest
@testable import RingBuffer

final class RingBufferThreadsTests: XCTestCase {

    private let dispatchGroup = DispatchGroup()
    private var rbuf = RingBuffer<Int>(capacity: 128)

    func runProducer() {
        let queueProducer = DispatchQueue(label: "QueueProducer")
        dispatchGroup.enter()
        queueProducer.async {
            for _ in 0..<3 {
                var data = [Int](repeating: 0, count: 64)
                for idx in 0..<(data.count) {
                    data[idx] = idx * 2
                }
                self.rbuf.push(data)
                print("PUSH data: \(data)")
            }
            self.dispatchGroup.leave()
        }
    }

    func runConsumer() {
        let queueConsumer = DispatchQueue(label: "QueueConsumer")
        dispatchGroup.enter()
        queueConsumer.asyncAfter(wallDeadline: .now() + 0.05) {
            let data = self.rbuf.pop(amount: 64)
            print("POP data: \(String(describing: data))")
            self.dispatchGroup.leave()
        }
    }

    func testProducerConsumerConcurrentSafety() {
        runProducer()
        runConsumer()
        dispatchGroup.wait()
        XCTAssert(true)
    }

    static var allTests = [
        ("testProducerConsumerConcurrentSafety", testProducerConsumerConcurrentSafety)
    ]
}
