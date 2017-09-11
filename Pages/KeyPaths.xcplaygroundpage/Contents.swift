//: [Previous](@previous)
import Foundation
import PlaygroundSupport

extension Sequence {
  func filterBy<Root, Value>(path: KeyPath<Root, Value>, by closure: (Value) -> Bool) -> [Self.Element] where Self.Element == (Root) {
    return self.filter({ (item) -> Bool in
      let value = item[keyPath: path]
      return closure(value)
    })
  }
}

//
public struct Meetup : Codable {
  public let time:Date
  public let name:String
  public let description:String
  public let link:URL
  public let id:String
  public let duration:TimeInterval?
}
//
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .millisecondsSince1970
//
let url = Bundle.main.url(forResource: "a2Cocoaheads", withExtension: "json")!
//let text = try! String(contentsOf: url)
let data = try! Data(contentsOf: url)
//let task = session.dataTask(with: url) { (data, _, error) in
let nameKeyPath = \Meetup.name
let allMeetups = try! decoder.decode([Meetup].self, from: data)
let filteredMeetups = allMeetups.filterBy(path: nameKeyPath, by: {$0 != "COCOA CODELAB"})
print(filteredMeetups)

//let meetups = try! decoder.decode([Meetup].self, from: data).filter({$0[keyPath: nameKeyPath] != "COCOA CODELAB"})

//let meetups = try! decoder.decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: <#T##Data#>)
//  print("test")
//  print(meetups.first?[keyPath: nameKeyPath])
//  PlaygroundPage.current.finishExecution()
//}

//task.resume()

//PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
