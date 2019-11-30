#if canImport(Dispatch)
import Dispatch

struct RingBuffer<Element: FloatingPoint> {
    
    var items: [Element]
    var head = 0
    var tail = 0
    var capacity = 0
    
    private let lock = DispatchSemaphore(value: 1)
    private var _count = 0

    public var count: Int {
        get {
            lock.wait()
            defer { lock.signal() }
            return _count
        }
    }
    
    public var available: Int {
        get {
            return capacity - count
        }
    }
    
    public var isFull: Bool {
        get {
            return capacity == count
        }
    }
    
    public var isEmpty: Bool {
        get {
            return head == tail && !isFull
        }
    }
    
    init(capacity: Int) {
        precondition(capacity > 0)
        self.capacity = capacity
        items = [Element](repeating:0, count: self.capacity)
    }
    
    mutating func write(_ item: Element) {
        items[head] = item
    }
    
    mutating func submit() {
        head = (head + 1) % capacity
        if available > 0 {
            atomicCountAdd(1)
        } else {
            atomicCountSet(1)
        }
    }
    
    func read() -> Element {
        return items[tail]
    }
            
    mutating func discard() {
        tail = (tail + 1) % capacity;
        if count > 0 {
            atomicCountAdd(-1)
        }
    }
        
    mutating private func atomicCountAdd(_ value: Int) {
        lock.wait()
        defer { lock.signal() }
        _count += value
    }
    
    mutating private func atomicCountSet(_ value: Int) {
        lock.wait()
        defer { lock.signal() }
        _count = value
    }
    
}
#endif
