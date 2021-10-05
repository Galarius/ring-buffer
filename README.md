# Ring (Circular) buffer in Swift

- Thread-safe for single producer and single consumer
- Write operations may overwrite oldest elements or skip elements that overflow the buffer

## Example (overwrite occupied space):
```swift

var rbuf = RingBuffer<Int>(capacity: 20)
let dataSet1 = [Int](repeating: 1, count: 10)
let dataSet2 = [Int](repeating: 2, count: 10)
let dataSet3 = [Int](repeating: 3, count: 10)

rbuf.push(dataSet1)
rbuf.push(dataSet2)
// overwrite first 10 elements with 3d data set
rbuf.push(dataSet3)

var data = rbuf.pop(amount: 10)
// data is equal to dataSet3

```

## Example (skip elements):
```swift

var rbuf = RingBuffer<Int>(capacity: 20)
let dataSet1 = [Int](repeating: 1, count: 10)
let dataSet2 = [Int](repeating: 2, count: 10)
let dataSet3 = [Int](repeating: 3, count: 10)

rbuf.push(dataSet1, drop: true)
rbuf.push(dataSet2, drop: true)
// rbuf is full
 
let dropped = rbuf.push(dataSet3, drop: true)
// 10 (nDropped) last elements from dataSet3 were skipped

data = rbuf.pop(amount: 20)
// data is equal to dataSet1 + dataSet2

```
