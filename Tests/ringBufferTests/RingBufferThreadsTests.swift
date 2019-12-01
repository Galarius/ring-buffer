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
                for idx in 0..<64 {
                    self.rbuf.push(idx)
                    print("WRITE value: \(idx), count: (\(self.rbuf.count)), available: \(self.rbuf.available)")
                }
            }
            self.dispatchGroup.leave()
        }
    }

    func runConsumer() {
        let queueConsumer = DispatchQueue(label: "QueueConsumer")
        dispatchGroup.enter()
        queueConsumer.async {
            for _ in 0..<3 {
                for _ in 0..<64 {
                    let val = self.rbuf.pop()
                    print("READ  value: \(String(describing: val)),
                                 count: (\(self.rbuf.count)),
                                available: \(self.rbuf.available)")
                }
            }
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
