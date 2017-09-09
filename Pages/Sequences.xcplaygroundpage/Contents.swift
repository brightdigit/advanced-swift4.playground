
/*:
 # The Advanced Mechanics of Sequence and Collection Types
 
 Swift has a hierarchy of protocols, classes, and structs for
 handling complex data structures. Here is a brief survey...
 */

import Darwin

public struct RandomIterator : IteratorProtocol {
  public typealias Element = UInt32
  
  let sequence : RandomSequence
  var times = 0
  
  public init (_ sequence: RandomSequence) {
    self.sequence = sequence
  }
  
  public mutating func next() -> ItemIterator.Element? {
    guard times < self.sequence.count else {
      return nil
    }
    times += 1
    return arc4random()
  }
}

public struct RandomSequence : Sequence {
  public typealias Iterator = RandomIterator
  
  let count : Int
  
  public func makeIterator() -> RandomIterator {
    return RandomIterator(self)
  }
}
