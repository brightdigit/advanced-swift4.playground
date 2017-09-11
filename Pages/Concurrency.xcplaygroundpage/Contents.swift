//: [Previous](@previous)
import Foundation
import PlaygroundSupport

public struct Meetup : Codable {
  public let time:Date
  public let name:String
  public let description:String
  public let link:URL
  public let id:Int
}

let url = URL(string: "https://api.meetup.com/A2-CocoaHeads/events")!

let session = URLSession(configuration: .default)
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .millisecondsSince1970

let task = session.dataTask(with: url) { (data, _, error) in
  
  print(String(data: data!, encoding: String.Encoding.utf8))
  let meetups = try! decoder.decode([Meetup].self, from: data!)
  let nameKeyPath = \Meetup.name
  
  for meetup in meetups {
    //print(meetup[keyPath: nameKeyPath])
  }
  PlaygroundPage.current.finishExecution()
}

task.resume()

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)


