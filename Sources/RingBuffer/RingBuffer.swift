import Dispatch

struct RingBuffer<Element: Numeric> {

    var capacity = 0
    private var items: [Element]
    private(set) var head = 0
    private(set) var tail = 0
    private var _count = 0
    private let lock = DispatchSemaphore(value: 1)

    public var count: Int {
        lock.wait()
        defer { lock.signal() }
        return _count
    }

    public var available: Int {
        return capacity - count
    }

    public var isFull: Bool {
        return capacity == count
    }

    public var isEmpty: Bool {
        return head == tail && !isFull
    }

    init(capacity: Int) {
        precondition(capacity > 0)
        self.capacity = capacity
        items = [Element](repeating: 0, count: self.capacity)
    }

    mutating func push(_ value: Element) {
        items[head] = value
        head = (head + 1) % capacity
        atomicCountAdd(1)
    }

    @discardableResult mutating func push(_ value: Element, drop: Bool) -> Int {

        guard !isFull || !drop else { return 1 }

        push(value)
        return 0
    }

    mutating func push(_ values: [Element]) {
        for idx in 0..<(values.count) {
            items[(head + idx) % capacity] = values[idx]
        }
        head = (head + values.count) % capacity
        atomicCountAdd(values.count)
    }

    @discardableResult mutating func push(_ values: [Element], drop: Bool) -> Int {

        guard !isFull || !drop else { return values.count }

        var dropped = 0
        for idx in 0..<(values.count) {
            if isFull && drop {
                dropped+=1
            } else {
                items[(head + idx) % capacity] = values[idx]
                head = (head + 1) % capacity
                atomicCountAdd(1)
            }
        }

        return dropped
    }

    @discardableResult mutating func pop() -> Element? {
        guard !isEmpty else { return nil}

        let item = items[tail]
        tail = (tail + 1) % capacity
        atomicCountAdd(-1)
        return item
    }

    @discardableResult mutating func pop(amount: Int) -> [Element]? {
        guard !isEmpty && amount <= count else { return nil}

        var values = [Element]()
        for idx in 0..<(amount) {
            values.append(items[tail + idx])
        }
        tail = (tail + amount) % capacity
        atomicCountAdd(-amount)

        return values
    }

    mutating private func atomicCountAdd(_ value: Int) {
        lock.wait()
        defer { lock.signal() }
        if _count + value > capacity {
            _count = (_count + value) % capacity
        } else {
            _count += value
        }
    }
}
