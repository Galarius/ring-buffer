import Dispatch

/**
 ## Ring (Circular) buffer in Swift
 
 - Thread-safe for single producer and single consumer
 - Write operations may override occupied space or skip items
 
 ### Example (override occupied space):
 ```swift
 
 var rbuf = RingBuffer<Int>(capacity: 20)
 let dataSet1 = [Int](repeating: 1, count: 10)
 let dataSet2 = [Int](repeating: 2, count: 10)
 let dataSet3 = [Int](repeating: 3, count: 10)
 
 rbuf.push(dataSet1)
 rbuf.push(dataSet2)
 // override first 10 elements with 3d data set
 rbuf.push(dataSet3)
 
 var data = rbuf.pop(amount: 10)
 // data is equal to dataSet3
 
 ```
 
 ### Example (skip items):
 ```swift
 
 var rbuf = RingBuffer<Int>(capacity: 20)
 let dataSet1 = [Int](repeating: 1, count: 10)
 let dataSet2 = [Int](repeating: 2, count: 10)
 let dataSet3 = [Int](repeating: 3, count: 10)
 
 rbuf.push(dataSet1, drop: true)
 rbuf.push(dataSet2, drop: true)
 // rbuf is full
  
 let nDropped = rbuf.push(dataSet3, drop: true)
 // 10 (nDropped) last elements from dataSet3 were skipped
 
 data = rbuf.pop(amount: 20)
 // data is equal to dataSet1 + dataSet2
 
 ```
 */
public struct RingBuffer<Element: Numeric> {

    private var items: [Element]
    private var _count = 0
    private let lock = DispatchSemaphore(value: 1)

    // MARK: - Properties

    /// Maximum number of elements in the buffer
    private(set) var capacity = 0
    /// Write index
    private(set) var head = 0
    /// Read index
    private(set) var tail = 0
    /// Number of elements in the buffer
    var count: Int {
        lock.wait()
        defer { lock.signal() }
        return _count
    }
    /// Available amount of elements that could be written to the buffer
    var available: Int {
        return capacity - count
    }
    /// Returns true if buffer is full
    var isFull: Bool {
        return capacity == count
    }
    /// Returns true if buffer is empty
    var isEmpty: Bool {
        return head == tail && !isFull
    }

    // MARK: - Init

    /**
     - parameters:
        - capacity: Maximum number of elements in the buffer
    */
    public init(capacity: Int) {
        precondition(capacity > 0)
        self.capacity = capacity
        items = [Element](repeating: 0, count: self.capacity)
    }

    // MARK: - Push

    /// Push single element (override on overflow by default)
    public mutating func push(_ value: Element) {
        items[head] = value
        head = (head + 1) % capacity
        atomicCountAdd(1)
    }
    /**
        Push single element with specifying write behavior
            
        - parameters:
            - value: Value to write
            - drop: Skip element if buffer is full
        
        - returns: 1 if value was skipped, otherwise 0
     */
    @discardableResult public mutating func push(_ value: Element, drop: Bool) -> Int {
        guard !isFull || !drop else { return 1 }
        push(value)
        return 0
    }

    /// Push multiple  elements (override on overflow by default)
    public mutating func push(_ values: [Element]) {
        for idx in 0..<(values.count) {
            items[(head + idx) % capacity] = values[idx]
        }
        head = (head + values.count) % capacity
        atomicCountAdd(values.count)
    }

    /**
        Push multiple  elements with specifying write behavior
            
        - parameters:
            - values: Values to write
            - drop: Skip element if buffer is full
        
        - returns: Number of skipped elements
     */
    @discardableResult public mutating func push(_ values: [Element], drop: Bool) -> Int {
        guard !(isFull && drop) else { return values.count }

        var dropped = 0
        var amount = values.count
        if values.count > available && drop {
            amount = available
            dropped = values.count - amount
        }

        for idx in 0..<(amount) {
            items[(head + idx) % capacity] = values[idx]
        }

        head = (head + amount) % capacity
        atomicCountAdd(amount)

        return dropped
    }

    // MARK: - Pop

    /**
        Pop single element
            
        - returns:
            Element or `nil` if buffer is empty
     */
    @discardableResult public mutating func pop() -> Element? {
        guard !isEmpty else { return nil}

        let item = items[tail]
        tail = (tail + 1) % capacity
        atomicCountAdd(-1)
        return item
    }

    /**
        Pop multiple  elements
    
        - parameters:
            - amount: Number of elements to read
     
        -  returns:
            Array of elements or `nil` if requested amount is greater than current buffer size
     */
    @discardableResult public mutating func pop(amount: Int) -> [Element]? {
        guard !isEmpty && amount <= count else { return nil}

        var values = [Element]()
        for idx in 0..<(amount) {
            values.append(items[(tail + idx) % capacity])
        }
        tail = (tail + amount) % capacity
        atomicCountAdd(-amount)

        return values
    }

    // MARK: -

    private mutating func atomicCountAdd(_ value: Int) {
        lock.wait()
        defer { lock.signal() }
        if _count + value > capacity {
            _count = (_count + value) % capacity
        } else {
            _count += value
        }
    }
}
