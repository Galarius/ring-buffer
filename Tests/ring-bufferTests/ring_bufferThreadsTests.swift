import XCTest
@testable import ring_buffer

final class ring_bufferThreadsTests: XCTestCase {
    
    private let dispatchGroup = DispatchGroup()
    private var rbuf = RingBuffer<Float>(capacity: 512)
    
    func runProducer() {
        let queueProducer = DispatchQueue(label: "QueueProducer")
        dispatchGroup.enter()
        queueProducer.async() {
            for _ in 0..<5 {
                for i in 0..<256 {
                    let val = Float(i) * 0.1
                    self.rbuf.write(val)
                    self.rbuf.submit()
                    print("WRITE value: \(NSString(format:"%.2f", val)), count: (\(self.rbuf.count)), available: \(self.rbuf.available)")
                }
            }
            self.dispatchGroup.leave()
        }
    }
    
    func runConsumer() {
        let queueConsumer = DispatchQueue(label: "QueueConsumer")
        dispatchGroup.enter()
        queueConsumer.async() {
            for _ in 0..<5 {
                for _ in 0..<256 {
                    let val = self.rbuf.read()
                    self.rbuf.discard()
                    print("READ  value: \(NSString(format:"%.2f", val)), count: (\(self.rbuf.count)), available: \(self.rbuf.available)")
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
